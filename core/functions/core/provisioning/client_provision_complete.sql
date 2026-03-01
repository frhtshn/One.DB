-- ================================================================
-- TENANT_PROVISION_COMPLETE: Provisioning başarılı tamamla
-- ================================================================
-- Tüm adımlar 'completed' veya 'skipped' olduğunda çağrılır.
-- Tenant provisioning_status → 'active', provisioned_at kaydı.
-- Outbox event: 'tenant_provisioned' yayınlanır.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_provision_complete(BIGINT, UUID);

CREATE OR REPLACE FUNCTION core.tenant_provision_complete(
    p_tenant_id BIGINT,
    p_run_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_incomplete_count INTEGER;
    v_tenant_code VARCHAR;
BEGIN
    -- Parametre kontrolü
    IF p_tenant_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.tenant.id-required';
    END IF;

    IF p_run_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.run-id-required';
    END IF;

    -- Tenant varlık kontrolü
    SELECT tenant_code INTO v_tenant_code
    FROM core.tenants
    WHERE id = p_tenant_id AND provisioning_status = 'provisioning';

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.not-in-provisioning';
    END IF;

    -- Tüm adımlar tamamlanmış mı? (completed veya skipped olmalı)
    SELECT COUNT(*)
    INTO v_incomplete_count
    FROM core.tenant_provisioning_log
    WHERE tenant_id = p_tenant_id
      AND provision_run_id = p_run_id
      AND status NOT IN ('completed', 'skipped');

    IF v_incomplete_count > 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.steps-not-complete';
    END IF;

    -- Tenant'ı aktif yap
    UPDATE core.tenants SET
        provisioning_status = 'active',
        provisioning_step = 'ACTIVATE',
        provisioned_at = NOW(),
        updated_at = NOW()
    WHERE id = p_tenant_id;

    -- Outbox event: tenant_provisioned
    INSERT INTO outbox.messages (
        action_type, aggregate_type, aggregate_id,
        payload, tenant_id
    ) VALUES (
        'event_publish',
        'tenant',
        p_tenant_id::VARCHAR,
        jsonb_build_object(
            'event', 'tenant_provisioned',
            'tenantId', p_tenant_id,
            'tenantCode', v_tenant_code,
            'runId', p_run_id,
            'provisionedAt', NOW()
        ),
        p_tenant_id
    );
END;
$$;

COMMENT ON FUNCTION core.tenant_provision_complete(BIGINT, UUID) IS 'Marks tenant provisioning as complete. Validates all steps are completed/skipped. Sets provisioning_status=active, records provisioned_at. Publishes tenant_provisioned outbox event.';
