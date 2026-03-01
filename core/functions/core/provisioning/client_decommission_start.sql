-- ================================================================
-- CLIENT_DECOMMISSION_START: Client kapatma sürecini başlat
-- ================================================================
-- Aktif veya askıya alınmış client'ı kapatma sürecine alır.
-- Operasyonel status → 0 (Pasif), login/işlem engellenir.
-- provisioning_status → 'suspended' (altyapı değişikliği bekleniyor).
-- 4 adımlık decommission log kaydı oluşturur ve UUID run_id döner.
-- ProductionManager tarafından çağrılır (system caller).
-- ================================================================

DROP FUNCTION IF EXISTS core.client_decommission_start(BIGINT, BIGINT, TEXT);

CREATE OR REPLACE FUNCTION core.client_decommission_start(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_reason TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_client RECORD;
    v_run_id UUID;
    v_steps TEXT[] := ARRAY[
        'STOP_SERVICES', 'DROP_DATABASES', 'CLEANUP_CONFIG', 'FINALIZE'
    ];
    v_i INTEGER;
BEGIN
    -- Parametre kontrolü
    IF p_client_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.client.id-required';
    END IF;

    -- Client varlık ve durum kontrolü
    SELECT id, company_id, client_code, provisioning_status
    INTO v_client
    FROM core.clients
    WHERE id = p_client_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_client.company_id);

    -- Sadece active veya suspended client kapatılabilir
    IF v_client.provisioning_status NOT IN ('active', 'suspended') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.decommission.invalid-status';
    END IF;

    -- Client'ı pasifleştir ve askıya al
    v_run_id := gen_random_uuid();

    UPDATE core.clients SET
        status = 0,
        provisioning_status = 'suspended',
        provisioning_step = 'STOP_SERVICES',
        updated_at = NOW()
    WHERE id = p_client_id;

    -- 4 adımlık decommission log kaydı oluştur
    FOR v_i IN 1..array_length(v_steps, 1) LOOP
        INSERT INTO core.client_provisioning_log (
            client_id, provision_run_id, step_name, step_order, status, created_at
        ) VALUES (
            p_client_id, v_run_id, v_steps[v_i], v_i, 'pending', NOW()
        );
    END LOOP;

    -- Outbox event: client_decommission_started
    INSERT INTO outbox.messages (
        action_type, aggregate_type, aggregate_id,
        payload, client_id
    ) VALUES (
        'event_publish',
        'client',
        p_client_id::VARCHAR,
        jsonb_build_object(
            'event', 'client_decommission_started',
            'clientId', p_client_id,
            'clientCode', v_client.client_code,
            'runId', v_run_id,
            'reason', p_reason,
            'startedAt', NOW()
        ),
        p_client_id
    );

    RETURN v_run_id;
END;
$$;

COMMENT ON FUNCTION core.client_decommission_start(BIGINT, BIGINT, TEXT) IS 'Starts client decommission process. Sets status=0 (disabled) and provisioning_status=suspended. Creates 4-step decommission log (STOP_SERVICES, DROP_DATABASES, CLEANUP_CONFIG, FINALIZE). Returns run_id UUID. IDOR protected.';
