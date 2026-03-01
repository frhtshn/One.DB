-- ================================================================
-- TENANT_PROVISION_FAIL: Provisioning başarısız olarak işaretle
-- ================================================================
-- Max retry aşıldığında veya kritik hata oluştuğunda çağrılır.
-- Tenant provisioning_status → 'failed'.
-- Outbox event: 'tenant_provision_failed' yayınlanır.
-- BO'ya bildirim gider, "Tekrar Dene" seçeneği sunulur.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_provision_fail(BIGINT, UUID, TEXT, TEXT);

CREATE OR REPLACE FUNCTION core.tenant_provision_fail(
    p_tenant_id BIGINT,
    p_run_id UUID,
    p_error_message TEXT DEFAULT NULL,
    p_error_detail TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_tenant_code VARCHAR;
    v_last_step VARCHAR;
BEGIN
    -- Parametre kontrolü
    IF p_tenant_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.tenant.id-required';
    END IF;

    IF p_run_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.run-id-required';
    END IF;

    -- Tenant varlık kontrolü
    SELECT tenant_code, provisioning_step
    INTO v_tenant_code, v_last_step
    FROM core.tenants
    WHERE id = p_tenant_id AND provisioning_status = 'provisioning';

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.not-in-provisioning';
    END IF;

    -- Tenant'ı failed yap
    UPDATE core.tenants SET
        provisioning_status = 'failed',
        updated_at = NOW()
    WHERE id = p_tenant_id;

    -- Outbox event: tenant_provision_failed
    INSERT INTO outbox.messages (
        action_type, aggregate_type, aggregate_id,
        payload, tenant_id
    ) VALUES (
        'event_publish',
        'tenant',
        p_tenant_id::VARCHAR,
        jsonb_build_object(
            'event', 'tenant_provision_failed',
            'tenantId', p_tenant_id,
            'tenantCode', v_tenant_code,
            'runId', p_run_id,
            'failedStep', v_last_step,
            'errorMessage', p_error_message,
            'errorDetail', p_error_detail,
            'failedAt', NOW()
        ),
        p_tenant_id
    );
END;
$$;

COMMENT ON FUNCTION core.tenant_provision_fail(BIGINT, UUID, TEXT, TEXT) IS 'Marks tenant provisioning as failed. Sets provisioning_status=failed. Publishes tenant_provision_failed outbox event with error details. BO can retry via tenant_provision_start.';
