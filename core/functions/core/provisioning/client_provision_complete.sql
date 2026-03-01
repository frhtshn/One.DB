-- ================================================================
-- CLIENT_PROVISION_COMPLETE: Provisioning başarılı tamamla
-- ================================================================
-- Tüm adımlar 'completed' veya 'skipped' olduğunda çağrılır.
-- Client provisioning_status → 'active', provisioned_at kaydı.
-- Outbox event: 'client_provisioned' yayınlanır.
-- ================================================================

DROP FUNCTION IF EXISTS core.client_provision_complete(BIGINT, UUID);

CREATE OR REPLACE FUNCTION core.client_provision_complete(
    p_client_id BIGINT,
    p_run_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_incomplete_count INTEGER;
    v_client_code VARCHAR;
BEGIN
    -- Parametre kontrolü
    IF p_client_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.client.id-required';
    END IF;

    IF p_run_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.run-id-required';
    END IF;

    -- Client varlık kontrolü
    SELECT client_code INTO v_client_code
    FROM core.clients
    WHERE id = p_client_id AND provisioning_status = 'provisioning';

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.not-in-provisioning';
    END IF;

    -- Tüm adımlar tamamlanmış mı? (completed veya skipped olmalı)
    SELECT COUNT(*)
    INTO v_incomplete_count
    FROM core.client_provisioning_log
    WHERE client_id = p_client_id
      AND provision_run_id = p_run_id
      AND status NOT IN ('completed', 'skipped');

    IF v_incomplete_count > 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.steps-not-complete';
    END IF;

    -- Client'ı aktif yap
    UPDATE core.clients SET
        provisioning_status = 'active',
        provisioning_step = 'ACTIVATE',
        provisioned_at = NOW(),
        updated_at = NOW()
    WHERE id = p_client_id;

    -- Outbox event: client_provisioned
    INSERT INTO outbox.messages (
        action_type, aggregate_type, aggregate_id,
        payload, client_id
    ) VALUES (
        'event_publish',
        'client',
        p_client_id::VARCHAR,
        jsonb_build_object(
            'event', 'client_provisioned',
            'clientId', p_client_id,
            'clientCode', v_client_code,
            'runId', p_run_id,
            'provisionedAt', NOW()
        ),
        p_client_id
    );
END;
$$;

COMMENT ON FUNCTION core.client_provision_complete(BIGINT, UUID) IS 'Marks client provisioning as complete. Validates all steps are completed/skipped. Sets provisioning_status=active, records provisioned_at. Publishes client_provisioned outbox event.';
