-- ================================================================
-- TENANT_PROVISION_STATUS: Provisioning durumu sorgula
-- ================================================================
-- IDOR korumalı. BO kullanıcıları için provisioning görünümü.
-- Tenant bilgisi, tüm adımlar ve sunucu durumları döner.
-- En güncel run_id üzerinden adımları gösterir.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_provision_status(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_provision_status(
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
    v_tenant RECORD;
    v_current_run_id UUID;
    v_steps JSONB;
    v_servers JSONB;
BEGIN
    -- Tenant varlık kontrolü
    SELECT id, company_id, tenant_code, provisioning_status, provisioning_step,
           provisioned_at, domain, hosting_mode
    INTO v_tenant
    FROM core.tenants
    WHERE id = p_tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_tenant.company_id);

    -- En güncel run_id'yi bul
    SELECT provision_run_id
    INTO v_current_run_id
    FROM core.tenant_provisioning_log
    WHERE tenant_id = p_tenant_id
    ORDER BY created_at DESC
    LIMIT 1;

    -- Adımları getir (en güncel run)
    IF v_current_run_id IS NOT NULL THEN
        SELECT COALESCE(jsonb_agg(
            jsonb_build_object(
                'stepName', pl.step_name,
                'stepOrder', pl.step_order,
                'status', pl.status,
                'startedAt', pl.started_at,
                'completedAt', pl.completed_at,
                'durationMs', pl.duration_ms,
                'errorMessage', pl.error_message,
                'retryCount', pl.retry_count,
                'maxRetries', pl.max_retries,
                'output', pl.output
            ) ORDER BY pl.step_order
        ), '[]'::jsonb)
        INTO v_steps
        FROM core.tenant_provisioning_log pl
        WHERE pl.tenant_id = p_tenant_id
          AND pl.provision_run_id = v_current_run_id;
    ELSE
        v_steps := '[]'::jsonb;
    END IF;

    -- Sunucu durumlarını getir
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'role', ts.server_role,
            'host', s.host,
            'region', s.region,
            'containerId', ts.container_id,
            'containerName', ts.container_name,
            'status', ts.status,
            'healthStatus', ts.health_status,
            'lastHealthAt', ts.last_health_at
        ) ORDER BY ts.server_role
    ), '[]'::jsonb)
    INTO v_servers
    FROM core.tenant_servers ts
    JOIN core.infrastructure_servers s ON s.id = ts.server_id
    WHERE ts.tenant_id = p_tenant_id;

    -- Sonuç döndür
    RETURN jsonb_build_object(
        'tenantId', v_tenant.id,
        'tenantCode', v_tenant.tenant_code,
        'provisioningStatus', v_tenant.provisioning_status,
        'provisioningStep', v_tenant.provisioning_step,
        'provisionedAt', v_tenant.provisioned_at,
        'domain', v_tenant.domain,
        'hostingMode', v_tenant.hosting_mode,
        'currentRunId', v_current_run_id,
        'steps', v_steps,
        'servers', v_servers
    );
END;
$$;

COMMENT ON FUNCTION core.tenant_provision_status(BIGINT, BIGINT) IS 'Returns full provisioning status for a tenant: current state, all steps from latest run with timing/errors, and server assignments with health. IDOR protected.';
