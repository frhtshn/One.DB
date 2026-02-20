-- ================================================================
-- LIMIT_GET: Oyuncu limitlerini getir
-- ================================================================
-- Oyuncunun tüm aktif limitlerini döner.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.limit_get(BIGINT);

CREATE OR REPLACE FUNCTION kyc.limit_get(
    p_player_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-limit.player-required';
    END IF;

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', l.id,
            'limitType', l.limit_type,
            'limitPeriod', l.limit_period,
            'limitValue', l.limit_value,
            'currencyCode', l.currency_code,
            'status', l.status,
            'pendingValue', l.pending_value,
            'pendingActivationAt', l.pending_activation_at,
            'setBy', l.set_by,
            'startsAt', l.starts_at,
            'expiresAt', l.expires_at,
            'createdAt', l.created_at,
            'updatedAt', l.updated_at
        ) ORDER BY l.limit_type, l.limit_period
    ), '[]'::jsonb)
    INTO v_result
    FROM kyc.player_limits l
    WHERE l.player_id = p_player_id
      AND l.status = 'active';

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION kyc.limit_get IS 'Returns all active limits for a player including pending value changes.';
