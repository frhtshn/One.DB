-- ================================================================
-- TENANT_DECOMMISSION_COMPLETE: Tenant kapatma tamamla
-- ================================================================
-- Tüm decommission adımları tamamlandığında çağrılır.
-- provisioning_status → 'decommissioned', decommissioned_at kaydı.
-- tenant_servers kayıtları 'removed' olarak işaretlenir.
-- infrastructure_servers.current_tenants düşürülür.
-- Outbox event: 'tenant_decommissioned' yayınlanır.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_decommission_complete(BIGINT, UUID);

CREATE OR REPLACE FUNCTION core.tenant_decommission_complete(
    p_tenant_id BIGINT,
    p_run_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_tenant_code VARCHAR;
    v_incomplete_count INTEGER;
    v_server_ids BIGINT[];
BEGIN
    -- Parametre kontrolü
    IF p_tenant_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.tenant.id-required';
    END IF;

    IF p_run_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.run-id-required';
    END IF;

    -- Tenant varlık ve durum kontrolü
    SELECT tenant_code INTO v_tenant_code
    FROM core.tenants
    WHERE id = p_tenant_id AND provisioning_status = 'suspended';

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.decommission.not-in-progress';
    END IF;

    -- Tüm adımlar tamamlanmış mı?
    SELECT COUNT(*)
    INTO v_incomplete_count
    FROM core.tenant_provisioning_log
    WHERE tenant_id = p_tenant_id
      AND provision_run_id = p_run_id
      AND status NOT IN ('completed', 'skipped');

    IF v_incomplete_count > 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.decommission.steps-not-complete';
    END IF;

    -- Decommission öncesi atanmış sunucu ID'lerini kaydet (current_tenants düşürmek için)
    SELECT ARRAY_AGG(DISTINCT server_id)
    INTO v_server_ids
    FROM core.tenant_servers
    WHERE tenant_id = p_tenant_id
      AND status != 'removed';

    -- Tenant'ı kapatılmış olarak işaretle
    UPDATE core.tenants SET
        provisioning_status = 'decommissioned',
        provisioning_step = 'FINALIZE',
        decommissioned_at = NOW(),
        updated_at = NOW()
    WHERE id = p_tenant_id;

    -- Tenant sunucu kayıtlarını 'removed' yap
    UPDATE core.tenant_servers SET
        status = 'removed',
        health_status = 'unknown',
        updated_at = NOW()
    WHERE tenant_id = p_tenant_id
      AND status != 'removed';

    -- Infrastructure sunucularının tenant sayısını düşür
    IF v_server_ids IS NOT NULL THEN
        UPDATE core.infrastructure_servers SET
            current_tenants = GREATEST(current_tenants - 1, 0),
            updated_at = NOW()
        WHERE id = ANY(v_server_ids);
    END IF;

    -- Outbox event: tenant_decommissioned
    INSERT INTO outbox.messages (
        action_type, aggregate_type, aggregate_id,
        payload, tenant_id
    ) VALUES (
        'event_publish',
        'tenant',
        p_tenant_id::VARCHAR,
        jsonb_build_object(
            'event', 'tenant_decommissioned',
            'tenantId', p_tenant_id,
            'tenantCode', v_tenant_code,
            'runId', p_run_id,
            'decommissionedAt', NOW()
        ),
        p_tenant_id
    );
END;
$$;

COMMENT ON FUNCTION core.tenant_decommission_complete(BIGINT, UUID) IS 'Completes tenant decommission. Validates all steps done. Sets provisioning_status=decommissioned, records decommissioned_at. Marks tenant_servers as removed, decrements infrastructure_servers.current_tenants. Publishes tenant_decommissioned outbox event.';
