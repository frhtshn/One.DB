-- ================================================================
-- TENANT_SERVER_LIST: Tenant'ın tüm sunucu/container listesi
-- ================================================================
-- IDOR korumalı. Infrastructure server detayları dahil.
-- Her role için container durumu ve sağlık bilgisi döner.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_server_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_server_list(
    p_caller_id BIGINT,
    p_tenant_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_company_id BIGINT;
    v_result JSONB;
BEGIN
    -- Tenant varlık kontrolü
    SELECT company_id INTO v_company_id
    FROM core.tenants WHERE id = p_tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_company_id);

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', ts.id,
            'serverId', ts.server_id,
            'serverCode', s.server_code,
            'serverName', s.server_name,
            'host', s.host,
            'region', s.region,
            'serverType', s.server_type,
            'serverRole', ts.server_role,
            'containerId', ts.container_id,
            'containerName', ts.container_name,
            'containerImage', ts.container_image,
            'containerPort', ts.container_port,
            'status', ts.status,
            'healthStatus', ts.health_status,
            'healthEndpoint', ts.health_endpoint,
            'lastHealthAt', ts.last_health_at,
            'createdAt', ts.created_at,
            'updatedAt', ts.updated_at
        ) ORDER BY ts.server_role
    ), '[]'::jsonb)
    INTO v_result
    FROM core.tenant_servers ts
    JOIN core.infrastructure_servers s ON s.id = ts.server_id
    WHERE ts.tenant_id = p_tenant_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.tenant_server_list(BIGINT, BIGINT) IS 'Returns all server/container assignments for a tenant with infrastructure server details. Ordered by role. IDOR protected.';
