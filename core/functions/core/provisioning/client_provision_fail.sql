-- ================================================================
-- CLIENT_PROVISION_FAIL: Provisioning başarısız olarak işaretle
-- ================================================================
-- Max retry aşıldığında veya kritik hata oluştuğunda çağrılır.
-- Client provisioning_status → 'failed'.
-- Outbox event: 'client_provision_failed' yayınlanır.
-- BO'ya bildirim gider, "Tekrar Dene" seçeneği sunulur.
-- ================================================================

DROP FUNCTION IF EXISTS core.client_provision_fail(BIGINT, UUID, TEXT, TEXT);

CREATE OR REPLACE FUNCTION core.client_provision_fail(
    p_client_id BIGINT,
    p_run_id UUID,
    p_error_message TEXT DEFAULT NULL,
    p_error_detail TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_client_code VARCHAR;
    v_last_step VARCHAR;
BEGIN
    -- Parametre kontrolü
    IF p_client_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.client.id-required';
    END IF;

    IF p_run_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.run-id-required';
    END IF;

    -- Client varlık kontrolü
    SELECT client_code, provisioning_step
    INTO v_client_code, v_last_step
    FROM core.clients
    WHERE id = p_client_id AND provisioning_status = 'provisioning';

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.not-in-provisioning';
    END IF;

    -- Client'ı failed yap
    UPDATE core.clients SET
        provisioning_status = 'failed',
        updated_at = NOW()
    WHERE id = p_client_id;

    -- Outbox event: client_provision_failed
    INSERT INTO outbox.messages (
        action_type, aggregate_type, aggregate_id,
        payload, client_id
    ) VALUES (
        'event_publish',
        'client',
        p_client_id::VARCHAR,
        jsonb_build_object(
            'event', 'client_provision_failed',
            'clientId', p_client_id,
            'clientCode', v_client_code,
            'runId', p_run_id,
            'failedStep', v_last_step,
            'errorMessage', p_error_message,
            'errorDetail', p_error_detail,
            'failedAt', NOW()
        ),
        p_client_id
    );
END;
$$;

COMMENT ON FUNCTION core.client_provision_fail(BIGINT, UUID, TEXT, TEXT) IS 'Marks client provisioning as failed. Sets provisioning_status=failed. Publishes client_provision_failed outbox event with error details. BO can retry via client_provision_start.';
