-- ================================================================
-- INFRASTRUCTURE_SERVER_UPDATE: Sunucu bilgileri güncelle (COALESCE)
-- ================================================================
-- SUPER_ADMIN korumalı. NULL = mevcut değeri koru.
-- Sağlık durumu ve kapasite güncellemeleri dahil.
-- ================================================================

DROP FUNCTION IF EXISTS core.infrastructure_server_update(
    BIGINT, BIGINT, VARCHAR, VARCHAR, VARCHAR, BOOLEAN,
    VARCHAR, VARCHAR, VARCHAR,
    VARCHAR, VARCHAR, JSONB, INTEGER, INTEGER,
    VARCHAR, VARCHAR, JSONB
);

CREATE OR REPLACE FUNCTION core.infrastructure_server_update(
    p_caller_id BIGINT,
    p_id BIGINT,
    p_server_name VARCHAR(255) DEFAULT NULL,
    p_host VARCHAR(255) DEFAULT NULL,
    p_docker_host VARCHAR(255) DEFAULT NULL,
    p_docker_tls_verify BOOLEAN DEFAULT NULL,
    p_region VARCHAR(50) DEFAULT NULL,
    p_cloud_provider VARCHAR(50) DEFAULT NULL,
    p_availability_zone VARCHAR(50) DEFAULT NULL,
    p_server_type VARCHAR(30) DEFAULT NULL,
    p_server_purpose VARCHAR(30) DEFAULT NULL,
    p_specs JSONB DEFAULT NULL,
    p_max_clients INTEGER DEFAULT NULL,
    p_current_clients INTEGER DEFAULT NULL,
    p_status VARCHAR(20) DEFAULT NULL,
    p_health_status VARCHAR(20) DEFAULT NULL,
    p_health_metadata JSONB DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_role_level INTEGER;
BEGIN
    -- SUPER_ADMIN kontrolü
    SELECT al.role_level INTO v_role_level
    FROM security.user_get_access_level(p_caller_id) al;

    IF v_role_level IS NULL OR v_role_level < 100 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.auth.super-admin-required';
    END IF;

    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.server.id-required';
    END IF;

    -- server_type validasyon
    IF p_server_type IS NOT NULL AND p_server_type NOT IN ('dedicated', 'shared') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.server.invalid-type';
    END IF;

    -- status validasyon
    IF p_status IS NOT NULL AND p_status NOT IN ('active', 'maintenance', 'full', 'decommissioned') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.server.invalid-status';
    END IF;

    UPDATE core.infrastructure_servers SET
        server_name = COALESCE(TRIM(p_server_name), server_name),
        host = COALESCE(TRIM(p_host), host),
        docker_host = COALESCE(TRIM(p_docker_host), docker_host),
        docker_tls_verify = COALESCE(p_docker_tls_verify, docker_tls_verify),
        region = COALESCE(TRIM(p_region), region),
        cloud_provider = COALESCE(TRIM(p_cloud_provider), cloud_provider),
        availability_zone = COALESCE(TRIM(p_availability_zone), availability_zone),
        server_type = COALESCE(p_server_type, server_type),
        server_purpose = COALESCE(p_server_purpose, server_purpose),
        specs = COALESCE(p_specs, specs),
        max_clients = COALESCE(p_max_clients, max_clients),
        current_clients = COALESCE(p_current_clients, current_clients),
        status = COALESCE(p_status, status),
        health_status = COALESCE(p_health_status, health_status),
        health_metadata = COALESCE(p_health_metadata, health_metadata),
        last_health_at = CASE WHEN p_health_status IS NOT NULL THEN NOW() ELSE last_health_at END,
        updated_at = NOW()
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.server.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION core.infrastructure_server_update IS 'Updates infrastructure server details. COALESCE pattern preserves existing values. Requires SUPER_ADMIN role.';
