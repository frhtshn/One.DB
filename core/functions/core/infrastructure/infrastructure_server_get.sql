-- ================================================================
-- INFRASTRUCTURE_SERVER_GET: Tekil sunucu detay
-- ================================================================
-- SUPER_ADMIN korumalı.
-- Tüm alanlar + hesaplanmış availableSlots döner.
-- ================================================================

DROP FUNCTION IF EXISTS core.infrastructure_server_get(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.infrastructure_server_get(
    p_caller_id BIGINT,
    p_id BIGINT
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

    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.server.id-required';
    END IF;

    SELECT jsonb_build_object(
        'id', s.id,
        'serverCode', s.server_code,
        'serverName', s.server_name,
        'host', s.host,
        'dockerHost', s.docker_host,
        'dockerTlsVerify', s.docker_tls_verify,
        'region', s.region,
        'cloudProvider', s.cloud_provider,
        'availabilityZone', s.availability_zone,
        'serverType', s.server_type,
        'serverPurpose', s.server_purpose,
        'specs', s.specs,
        'maxTenants', s.max_tenants,
        'currentTenants', s.current_tenants,
        'availableSlots', GREATEST(s.max_tenants - s.current_tenants, 0),
        'status', s.status,
        'healthStatus', s.health_status,
        'lastHealthAt', s.last_health_at,
        'healthMetadata', s.health_metadata,
        'createdAt', s.created_at,
        'updatedAt', s.updated_at
    )
    INTO v_result
    FROM core.infrastructure_servers s
    WHERE s.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.server.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.infrastructure_server_get(BIGINT, BIGINT) IS 'Returns single infrastructure server detail with computed availableSlots. Requires SUPER_ADMIN role.';
