-- ================================================================
-- RESTRICTION_GET: Kısıtlama detayı getir
-- ================================================================
-- Tek kısıtlamanın detayını döner.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.restriction_get(BIGINT);

CREATE OR REPLACE FUNCTION kyc.restriction_get(
    p_restriction_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_restriction_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-restriction.restriction-required';
    END IF;

    SELECT jsonb_build_object(
        'id', r.id,
        'playerId', r.player_id,
        'restrictionType', r.restriction_type,
        'scope', r.scope,
        'status', r.status,
        'startsAt', r.starts_at,
        'endsAt', r.ends_at,
        'reason', r.reason,
        'setBy', r.set_by,
        'canBeRevoked', r.can_be_revoked,
        'minDurationDays', r.min_duration_days,
        'reinstatementRequestedAt', r.reinstatement_requested_at,
        'reinstatementApprovedAt', r.reinstatement_approved_at,
        'reinstatementApprovedBy', r.reinstatement_approved_by,
        'createdAt', r.created_at,
        'updatedAt', r.updated_at
    )
    INTO v_result
    FROM kyc.player_restrictions r
    WHERE r.id = p_restriction_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-restriction.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION kyc.restriction_get IS 'Returns restriction detail including reinstatement information.';
