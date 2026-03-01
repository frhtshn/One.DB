-- ================================================================
-- INFRASTRUCTURE_SERVER_LIST: Sunucu listesi (filtreli)
-- ================================================================
-- SUPER_ADMIN korumalı.
-- Region, tip, durum ve kapasite filtresi.
-- p_has_capacity = true → sadece boş kapasiteli sunucular.
-- ================================================================

DROP FUNCTION IF EXISTS core.infrastructure_server_list(BIGINT, VARCHAR, VARCHAR, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION core.infrastructure_server_list(
    p_caller_id BIGINT,
    p_region VARCHAR(50) DEFAULT NULL,
    p_server_type VARCHAR(30) DEFAULT NULL,
    p_status VARCHAR(20) DEFAULT NULL,
    p_has_capacity BOOLEAN DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_role_level INTEGER;
    v_result JSONB;
BEGIN
    -- SUPER_ADMIN kontrolü
    SELECT al.role_level INTO v_role_level
    FROM security.user_get_access_level(p_caller_id) al;

    IF v_role_level IS NULL OR v_role_level < 100 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.auth.super-admin-required';
    END IF;

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', s.id,
            'serverCode', s.server_code,
            'serverName', s.server_name,
            'host', s.host,
            'region', s.region,
            'cloudProvider', s.cloud_provider,
            'serverType', s.server_type,
            'serverPurpose', s.server_purpose,
            'specs', s.specs,
            'maxClients', s.max_clients,
            'currentClients', s.current_clients,
            'availableSlots', GREATEST(s.max_clients - s.current_clients, 0),
            'status', s.status,
            'healthStatus', s.health_status,
            'lastHealthAt', s.last_health_at
        ) ORDER BY s.region, s.server_code
    ), '[]'::jsonb)
    INTO v_result
    FROM core.infrastructure_servers s
    WHERE (p_region IS NULL OR s.region = p_region)
      AND (p_server_type IS NULL OR s.server_type = p_server_type)
      AND (p_status IS NULL OR s.status = p_status)
      AND (p_has_capacity IS NULL OR p_has_capacity = false OR s.current_clients < s.max_clients);

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.infrastructure_server_list(BIGINT, VARCHAR, VARCHAR, VARCHAR, BOOLEAN) IS 'Lists infrastructure servers with optional region, type, status, and capacity filters. p_has_capacity=true shows only servers with available slots. Requires SUPER_ADMIN role.';
