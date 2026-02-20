-- ================================================================
-- RESTRICTION_LIST: Kısıtlama listesi
-- ================================================================
-- Oyuncunun kısıtlamalarını listeler.
-- Opsiyonel durum ve tip filtresi.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.restriction_list(BIGINT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION kyc.restriction_list(
    p_player_id       BIGINT,
    p_status          VARCHAR(20) DEFAULT NULL,
    p_restriction_type VARCHAR(30) DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-restriction.player-required';
    END IF;

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', r.id,
            'restrictionType', r.restriction_type,
            'scope', r.scope,
            'status', r.status,
            'startsAt', r.starts_at,
            'endsAt', r.ends_at,
            'reason', r.reason,
            'setBy', r.set_by,
            'canBeRevoked', r.can_be_revoked,
            'createdAt', r.created_at
        ) ORDER BY r.created_at DESC
    ), '[]'::jsonb)
    INTO v_result
    FROM kyc.player_restrictions r
    WHERE r.player_id = p_player_id
      AND (p_status IS NULL OR r.status = p_status)
      AND (p_restriction_type IS NULL OR r.restriction_type = p_restriction_type);

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION kyc.restriction_list IS 'Lists player restrictions with optional status and type filters.';
