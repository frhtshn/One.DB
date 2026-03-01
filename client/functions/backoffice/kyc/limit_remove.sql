-- ================================================================
-- LIMIT_REMOVE: Limiti kaldır
-- ================================================================
-- Aktif limiti kaldırır (status → removed).
-- Geçmiş kaydı oluşturur.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.limit_remove(BIGINT, VARCHAR, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION kyc.limit_remove(
    p_limit_id     BIGINT,
    p_performed_by VARCHAR(20) DEFAULT 'player',
    p_admin_user_id BIGINT DEFAULT NULL,
    p_reason       VARCHAR(500) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_limit RECORD;
BEGIN
    IF p_limit_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-limit.limit-required';
    END IF;

    -- Limit kontrolü
    SELECT l.id, l.player_id, l.limit_type, l.limit_value, l.status
    INTO v_limit
    FROM kyc.player_limits l
    WHERE l.id = p_limit_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-limit.not-found';
    END IF;

    IF v_limit.status != 'active' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.kyc-limit.not-active';
    END IF;

    -- Limiti kaldır
    UPDATE kyc.player_limits
    SET status = 'removed',
        updated_at = NOW()
    WHERE id = p_limit_id;

    -- Geçmiş kaydı
    INSERT INTO kyc.player_limit_history (
        player_id, action_type, entity_type, entity_id,
        old_value, performed_by, admin_user_id, reason
    ) VALUES (
        v_limit.player_id, 'REMOVE', 'limit', p_limit_id,
        jsonb_build_object('limitType', v_limit.limit_type, 'limitValue', v_limit.limit_value),
        COALESCE(p_performed_by, 'player'), p_admin_user_id, p_reason
    );
END;
$$;

COMMENT ON FUNCTION kyc.limit_remove IS 'Removes an active limit with history entry.';
