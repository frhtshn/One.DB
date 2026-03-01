-- ================================================================
-- CLIENT_SERVER_ASSIGN: Client'a sunucu ata (role bazlı)
-- ================================================================
-- IDOR korumalı (user_assert_access_company).
-- server_id active ve kapasiteli olmalı.
-- UPSERT: (client_id, server_id, server_role).
-- Shared sunucularda yeni atamada current_clients++ yapılır.
-- ================================================================

DROP FUNCTION IF EXISTS core.client_server_assign(BIGINT, BIGINT, BIGINT, VARCHAR, VARCHAR, INTEGER, VARCHAR);

CREATE OR REPLACE FUNCTION core.client_server_assign(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_server_id BIGINT,
    p_server_role VARCHAR(30),
    p_container_image VARCHAR(255) DEFAULT NULL,
    p_container_port INTEGER DEFAULT NULL,
    p_health_endpoint VARCHAR(255) DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_company_id BIGINT;
    v_server RECORD;
    v_is_new BOOLEAN;
    v_new_id BIGINT;
BEGIN
    -- Client varlık kontrolü
    SELECT company_id INTO v_company_id
    FROM core.clients WHERE id = p_client_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_company_id);

    -- Parametre kontrolleri
    IF p_server_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.server.id-required';
    END IF;

    IF p_server_role IS NULL OR p_server_role NOT IN ('db_primary', 'db_replica', 'db_failover', 'backend', 'callback', 'frontend') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.server.invalid-role';
    END IF;

    -- Sunucu varlık + durum kontrolü
    SELECT id, server_type, max_clients, current_clients, status
    INTO v_server
    FROM core.infrastructure_servers
    WHERE id = p_server_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.server.not-found';
    END IF;

    IF v_server.status != 'active' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.server.not-active';
    END IF;

    -- Shared sunucularda kapasite kontrolü
    IF v_server.server_type = 'shared' AND v_server.current_clients >= v_server.max_clients THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.server.capacity-full';
    END IF;

    -- Mevcut atama kontrolü (yeni mi güncelleme mi?)
    v_is_new := NOT EXISTS(
        SELECT 1 FROM core.client_servers
        WHERE client_id = p_client_id AND server_id = p_server_id AND server_role = p_server_role
    );

    -- UPSERT
    INSERT INTO core.client_servers (
        client_id, server_id, server_role,
        container_image, container_port, health_endpoint,
        status, created_at, updated_at
    ) VALUES (
        p_client_id, p_server_id, p_server_role,
        p_container_image, p_container_port, p_health_endpoint,
        'pending', NOW(), NOW()
    )
    ON CONFLICT (client_id, server_id, server_role) DO UPDATE SET
        container_image = COALESCE(p_container_image, core.client_servers.container_image),
        container_port = COALESCE(p_container_port, core.client_servers.container_port),
        health_endpoint = COALESCE(p_health_endpoint, core.client_servers.health_endpoint),
        updated_at = NOW()
    RETURNING id INTO v_new_id;

    -- Yeni atamada shared sunucu current_clients++
    IF v_is_new AND v_server.server_type = 'shared' THEN
        UPDATE core.infrastructure_servers
        SET current_clients = current_clients + 1, updated_at = NOW()
        WHERE id = p_server_id;
    END IF;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION core.client_server_assign IS 'Assigns a server to a client for a specific role (db_primary, backend, etc). UPSERT by (client, server, role). Checks capacity for shared servers. IDOR protected.';
