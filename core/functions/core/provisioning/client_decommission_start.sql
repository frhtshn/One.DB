-- ================================================================
-- TENANT_DECOMMISSION_START: Tenant kapatma sürecini başlat
-- ================================================================
-- Aktif veya askıya alınmış tenant'ı kapatma sürecine alır.
-- Operasyonel status → 0 (Pasif), login/işlem engellenir.
-- provisioning_status → 'suspended' (altyapı değişikliği bekleniyor).
-- 4 adımlık decommission log kaydı oluşturur ve UUID run_id döner.
-- ProductionManager tarafından çağrılır (system caller).
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_decommission_start(BIGINT, BIGINT, TEXT);

CREATE OR REPLACE FUNCTION core.tenant_decommission_start(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_reason TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_tenant RECORD;
    v_run_id UUID;
    v_steps TEXT[] := ARRAY[
        'STOP_SERVICES', 'DROP_DATABASES', 'CLEANUP_CONFIG', 'FINALIZE'
    ];
    v_i INTEGER;
BEGIN
    -- Parametre kontrolü
    IF p_tenant_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.tenant.id-required';
    END IF;

    -- Tenant varlık ve durum kontrolü
    SELECT id, company_id, tenant_code, provisioning_status
    INTO v_tenant
    FROM core.tenants
    WHERE id = p_tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_tenant.company_id);

    -- Sadece active veya suspended tenant kapatılabilir
    IF v_tenant.provisioning_status NOT IN ('active', 'suspended') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.decommission.invalid-status';
    END IF;

    -- Tenant'ı pasifleştir ve askıya al
    v_run_id := gen_random_uuid();

    UPDATE core.tenants SET
        status = 0,
        provisioning_status = 'suspended',
        provisioning_step = 'STOP_SERVICES',
        updated_at = NOW()
    WHERE id = p_tenant_id;

    -- 4 adımlık decommission log kaydı oluştur
    FOR v_i IN 1..array_length(v_steps, 1) LOOP
        INSERT INTO core.tenant_provisioning_log (
            tenant_id, provision_run_id, step_name, step_order, status, created_at
        ) VALUES (
            p_tenant_id, v_run_id, v_steps[v_i], v_i, 'pending', NOW()
        );
    END LOOP;

    -- Outbox event: tenant_decommission_started
    INSERT INTO outbox.messages (
        action_type, aggregate_type, aggregate_id,
        payload, tenant_id
    ) VALUES (
        'event_publish',
        'tenant',
        p_tenant_id::VARCHAR,
        jsonb_build_object(
            'event', 'tenant_decommission_started',
            'tenantId', p_tenant_id,
            'tenantCode', v_tenant.tenant_code,
            'runId', v_run_id,
            'reason', p_reason,
            'startedAt', NOW()
        ),
        p_tenant_id
    );

    RETURN v_run_id;
END;
$$;

COMMENT ON FUNCTION core.tenant_decommission_start(BIGINT, BIGINT, TEXT) IS 'Starts tenant decommission process. Sets status=0 (disabled) and provisioning_status=suspended. Creates 4-step decommission log (STOP_SERVICES, DROP_DATABASES, CLEANUP_CONFIG, FINALIZE). Returns run_id UUID. IDOR protected.';
