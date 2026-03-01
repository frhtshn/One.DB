-- ================================================================
-- CLIENT_PROVISION_STATUS: Provisioning durumu sorgula
-- ================================================================
-- IDOR korumalı. BO kullanıcıları için provisioning görünümü.
-- Client bilgisi, tüm adımlar ve sunucu durumları döner.
-- En güncel run_id üzerinden adımları gösterir.
-- ================================================================

DROP FUNCTION IF EXISTS core.client_provision_status(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.client_provision_status(
    p_caller_id BIGINT,
    p_client_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_company_id BIGINT;
    v_client RECORD;
    v_current_run_id UUID;
    v_steps JSONB;
    v_servers JSONB;
BEGIN
    -- Client varlık kontrolü
    SELECT id, company_id, client_code, provisioning_status, provisioning_step,
           provisioned_at, domain, hosting_mode
    INTO v_client
    FROM core.clients
    WHERE id = p_client_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_client.company_id);

    -- En güncel run_id'yi bul
    SELECT provision_run_id
    INTO v_current_run_id
    FROM core.client_provisioning_log
    WHERE client_id = p_client_id
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
        FROM core.client_provisioning_log pl
        WHERE pl.client_id = p_client_id
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
    FROM core.client_servers ts
    JOIN core.infrastructure_servers s ON s.id = ts.server_id
    WHERE ts.client_id = p_client_id;

    -- Sonuç döndür
    RETURN jsonb_build_object(
        'clientId', v_client.id,
        'clientCode', v_client.client_code,
        'provisioningStatus', v_client.provisioning_status,
        'provisioningStep', v_client.provisioning_step,
        'provisionedAt', v_client.provisioned_at,
        'domain', v_client.domain,
        'hostingMode', v_client.hosting_mode,
        'currentRunId', v_current_run_id,
        'steps', v_steps,
        'servers', v_servers
    );
END;
$$;

COMMENT ON FUNCTION core.client_provision_status(BIGINT, BIGINT) IS 'Returns full provisioning status for a client: current state, all steps from latest run with timing/errors, and server assignments with health. IDOR protected.';
