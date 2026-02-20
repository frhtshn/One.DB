-- ================================================================
-- RESTRICTION_REVOKE: Kısıtlamayı kaldır
-- ================================================================
-- Aktif kısıtlamayı kaldırır (status → revoked).
-- Minimum süre kontrolü yapar.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.restriction_revoke(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION kyc.restriction_revoke(
    p_restriction_id BIGINT,
    p_revoked_by     BIGINT DEFAULT NULL,
    p_reason         VARCHAR(500) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_restriction RECORD;
BEGIN
    IF p_restriction_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-restriction.restriction-required';
    END IF;

    -- Kısıtlama kontrolü
    SELECT r.id, r.player_id, r.status, r.can_be_revoked,
           r.min_duration_days, r.starts_at
    INTO v_restriction
    FROM kyc.player_restrictions r
    WHERE r.id = p_restriction_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-restriction.not-found';
    END IF;

    -- Aktif olmalı
    IF v_restriction.status != 'active' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.kyc-restriction.not-active';
    END IF;

    -- İptal edilebilir mi?
    IF v_restriction.can_be_revoked = FALSE THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.kyc-restriction.cannot-revoke';
    END IF;

    -- Minimum süre kontrolü
    IF v_restriction.min_duration_days IS NOT NULL THEN
        IF v_restriction.starts_at + (v_restriction.min_duration_days || ' days')::INTERVAL > NOW() THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.kyc-restriction.min-duration-not-met';
        END IF;
    END IF;

    -- Kısıtlamayı kaldır
    UPDATE kyc.player_restrictions
    SET status = 'revoked',
        updated_at = NOW()
    WHERE id = p_restriction_id;

    -- Geçmiş kaydı
    INSERT INTO kyc.player_limit_history (
        player_id, action_type, entity_type, entity_id,
        old_value, performed_by, reason
    ) VALUES (
        v_restriction.player_id, 'REVOKE', 'restriction', p_restriction_id,
        jsonb_build_object('status', 'active'),
        COALESCE(p_revoked_by::VARCHAR, 'admin'), p_reason
    );
END;
$$;

COMMENT ON FUNCTION kyc.restriction_revoke IS 'Revokes an active restriction. Checks can_be_revoked flag and minimum duration requirement.';
