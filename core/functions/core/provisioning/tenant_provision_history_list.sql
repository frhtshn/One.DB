-- ================================================================
-- TENANT_PROVISION_HISTORY_LIST: Provisioning geçmişi listele
-- ================================================================
-- IDOR korumalı. Tenant'ın tüm provisioning/decommission
-- denemelerini run bazlı gruplandırarak döner.
-- Her run için: başlangıç/bitiş, adım sayısı, durum özeti.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_provision_history_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_provision_history_list(
    p_caller_id BIGINT,
    p_tenant_id BIGINT
)
RETURNS TABLE (
    run_id UUID,
    run_type VARCHAR,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    total_steps INTEGER,
    completed_steps INTEGER,
    failed_steps INTEGER,
    total_duration_ms BIGINT,
    last_step VARCHAR,
    last_status VARCHAR
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_company_id BIGINT;
BEGIN
    -- Parametre kontrolü
    IF p_tenant_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.tenant.id-required';
    END IF;

    -- Tenant varlık ve IDOR kontrolü
    SELECT company_id INTO v_company_id
    FROM core.tenants
    WHERE id = p_tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    PERFORM security.user_assert_access_company(p_caller_id, v_company_id);

    -- Run bazlı geçmiş listesi
    RETURN QUERY
    SELECT
        pl.provision_run_id AS run_id,
        -- İlk adıma göre tip belirle (VALIDATE = provisioning, STOP_SERVICES = decommission)
        CASE
            WHEN MIN(pl.step_name) FILTER (WHERE pl.step_order = 1) = 'VALIDATE' THEN 'provisioning'::VARCHAR
            WHEN MIN(pl.step_name) FILTER (WHERE pl.step_order = 1) = 'STOP_SERVICES' THEN 'decommission'::VARCHAR
            ELSE 'unknown'::VARCHAR
        END AS run_type,
        MIN(pl.created_at) AS started_at,
        MAX(pl.completed_at) AS completed_at,
        COUNT(*)::INTEGER AS total_steps,
        COUNT(*) FILTER (WHERE pl.status IN ('completed', 'skipped'))::INTEGER AS completed_steps,
        COUNT(*) FILTER (WHERE pl.status = 'failed')::INTEGER AS failed_steps,
        COALESCE(SUM(pl.duration_ms), 0)::BIGINT AS total_duration_ms,
        -- En son güncellenen adım
        (ARRAY_AGG(pl.step_name ORDER BY pl.step_order DESC))[1] FILTER (WHERE pl.status != 'pending') AS last_step,
        (ARRAY_AGG(pl.status ORDER BY pl.step_order DESC))[1] FILTER (WHERE pl.status != 'pending') AS last_status
    FROM core.tenant_provisioning_log pl
    WHERE pl.tenant_id = p_tenant_id
    GROUP BY pl.provision_run_id
    ORDER BY MIN(pl.created_at) DESC;
END;
$$;

COMMENT ON FUNCTION core.tenant_provision_history_list(BIGINT, BIGINT) IS 'Lists all provisioning/decommission runs for a tenant grouped by run_id. Returns summary per run: type, timing, step counts, duration. IDOR protected.';
