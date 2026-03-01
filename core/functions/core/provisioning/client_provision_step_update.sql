-- ================================================================
-- CLIENT_PROVISION_STEP_UPDATE: Provisioning adım durumu güncelle
-- ================================================================
-- ProductionManager tarafından her adım sonrası çağrılır.
-- Adım durumunu günceller: running, completed, failed, skipped.
-- 'running' → started_at kaydı, 'completed' → süre hesabı,
-- 'failed' → retry_count++ ve hata kaydı.
-- Client'ın provisioning_step alanını da günceller.
-- ================================================================

DROP FUNCTION IF EXISTS core.client_provision_step_update(BIGINT, UUID, VARCHAR, VARCHAR, TEXT, TEXT, JSONB);

CREATE OR REPLACE FUNCTION core.client_provision_step_update(
    p_client_id BIGINT,
    p_run_id UUID,
    p_step_name VARCHAR(50),
    p_status VARCHAR(20),
    p_error_message TEXT DEFAULT NULL,
    p_error_detail TEXT DEFAULT NULL,
    p_output JSONB DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_step RECORD;
BEGIN
    -- Parametre kontrolü
    IF p_client_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.client.id-required';
    END IF;

    IF p_run_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.run-id-required';
    END IF;

    IF p_status IS NULL OR p_status NOT IN ('running', 'completed', 'failed', 'skipped', 'rolled_back') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.invalid-step-status';
    END IF;

    -- Adım kaydını bul
    SELECT id, status, started_at
    INTO v_step
    FROM core.client_provisioning_log
    WHERE client_id = p_client_id
      AND provision_run_id = p_run_id
      AND step_name = p_step_name;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provision.step-not-found';
    END IF;

    -- Adım durumuna göre güncelle
    IF p_status = 'running' THEN
        UPDATE core.client_provisioning_log SET
            status = 'running',
            started_at = NOW(),
            output = COALESCE(p_output, output)
        WHERE id = v_step.id;

    ELSIF p_status = 'completed' THEN
        UPDATE core.client_provisioning_log SET
            status = 'completed',
            completed_at = NOW(),
            duration_ms = CASE
                WHEN started_at IS NOT NULL THEN EXTRACT(EPOCH FROM (NOW() - started_at))::INTEGER * 1000
                ELSE NULL
            END,
            output = COALESCE(p_output, output)
        WHERE id = v_step.id;

    ELSIF p_status = 'failed' THEN
        UPDATE core.client_provisioning_log SET
            status = 'failed',
            completed_at = NOW(),
            duration_ms = CASE
                WHEN started_at IS NOT NULL THEN EXTRACT(EPOCH FROM (NOW() - started_at))::INTEGER * 1000
                ELSE NULL
            END,
            error_message = p_error_message,
            error_detail = p_error_detail,
            retry_count = retry_count + 1,
            output = COALESCE(p_output, output)
        WHERE id = v_step.id;

    ELSIF p_status IN ('skipped', 'rolled_back') THEN
        UPDATE core.client_provisioning_log SET
            status = p_status,
            completed_at = NOW(),
            output = COALESCE(p_output, output)
        WHERE id = v_step.id;
    END IF;

    -- Client'ın provisioning_step alanını güncelle
    UPDATE core.clients SET
        provisioning_step = p_step_name,
        updated_at = NOW()
    WHERE id = p_client_id;
END;
$$;

COMMENT ON FUNCTION core.client_provision_step_update(BIGINT, UUID, VARCHAR, VARCHAR, TEXT, TEXT, JSONB) IS 'Updates provisioning step status (running/completed/failed/skipped). Records timing, errors, retry count, and step output. Called by ProductionManager after each step.';
