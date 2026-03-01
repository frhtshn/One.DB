-- ================================================================
-- CLIENT_DECOMMISSION_COMPLETE: Client kapatma tamamla
-- ================================================================
-- Tüm decommission adımları tamamlandığında çağrılır.
-- provisioning_status → 'decommissioned', decommissioned_at kaydı.
-- client_servers kayıtları 'removed' olarak işaretlenir.
-- infrastructure_servers.current_clients düşürülür.
-- Outbox event: 'client_decommissioned' yayınlanır.
-- ================================================================

DROP FUNCTION IF EXISTS core.client_decommission_complete(BIGINT, UUID);

CREATE OR REPLACE FUNCTION core.client_decommission_complete(
    p_client_id BIGINT,
    p_run_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_client_code VARCHAR;
    v_incomplete_count INTEGER;
    v_server_ids BIGINT[];
BEGIN
    -- Parametre kontrolü
    IF p_client_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.client.id-required';
    END IF;

    IF p_run_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.run-id-required';
    END IF;

    -- Client varlık ve durum kontrolü
    SELECT client_code INTO v_client_code
    FROM core.clients
    WHERE id = p_client_id AND provisioning_status = 'suspended';

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.decommission.not-in-progress';
    END IF;

    -- Tüm adımlar tamamlanmış mı?
    SELECT COUNT(*)
    INTO v_incomplete_count
    FROM core.client_provisioning_log
    WHERE client_id = p_client_id
      AND provision_run_id = p_run_id
      AND status NOT IN ('completed', 'skipped');

    IF v_incomplete_count > 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.decommission.steps-not-complete';
    END IF;

    -- Decommission öncesi atanmış sunucu ID'lerini kaydet (current_clients düşürmek için)
    SELECT ARRAY_AGG(DISTINCT server_id)
    INTO v_server_ids
    FROM core.client_servers
    WHERE client_id = p_client_id
      AND status != 'removed';

    -- Client'ı kapatılmış olarak işaretle
    UPDATE core.clients SET
        provisioning_status = 'decommissioned',
        provisioning_step = 'FINALIZE',
        decommissioned_at = NOW(),
        updated_at = NOW()
    WHERE id = p_client_id;

    -- Client sunucu kayıtlarını 'removed' yap
    UPDATE core.client_servers SET
        status = 'removed',
        health_status = 'unknown',
        updated_at = NOW()
    WHERE client_id = p_client_id
      AND status != 'removed';

    -- Infrastructure sunucularının client sayısını düşür
    IF v_server_ids IS NOT NULL THEN
        UPDATE core.infrastructure_servers SET
            current_clients = GREATEST(current_clients - 1, 0),
            updated_at = NOW()
        WHERE id = ANY(v_server_ids);
    END IF;

    -- Outbox event: client_decommissioned
    INSERT INTO outbox.messages (
        action_type, aggregate_type, aggregate_id,
        payload, client_id
    ) VALUES (
        'event_publish',
        'client',
        p_client_id::VARCHAR,
        jsonb_build_object(
            'event', 'client_decommissioned',
            'clientId', p_client_id,
            'clientCode', v_client_code,
            'runId', p_run_id,
            'decommissionedAt', NOW()
        ),
        p_client_id
    );
END;
$$;

COMMENT ON FUNCTION core.client_decommission_complete(BIGINT, UUID) IS 'Completes client decommission. Validates all steps done. Sets provisioning_status=decommissioned, records decommissioned_at. Marks client_servers as removed, decrements infrastructure_servers.current_clients. Publishes client_decommissioned outbox event.';
