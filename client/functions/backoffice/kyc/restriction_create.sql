-- ================================================================
-- RESTRICTION_CREATE: Oyuncu kısıtlaması oluştur
-- ================================================================
-- Oyuncuya kısıtlama ekler (deposit, withdrawal, login vb.).
-- Limit geçmişi kaydeder.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.restriction_create(BIGINT, VARCHAR, VARCHAR, TIMESTAMP, TIMESTAMP, VARCHAR, VARCHAR, BOOLEAN, INT);

CREATE OR REPLACE FUNCTION kyc.restriction_create(
    p_player_id       BIGINT,
    p_restriction_type VARCHAR(30),
    p_scope           VARCHAR(30) DEFAULT 'all',
    p_starts_at       TIMESTAMP DEFAULT NOW(),
    p_ends_at         TIMESTAMP DEFAULT NULL,
    p_reason          VARCHAR(500) DEFAULT NULL,
    p_set_by          VARCHAR(20) DEFAULT 'admin',
    p_can_be_revoked  BOOLEAN DEFAULT FALSE,
    p_min_duration_days INT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_restriction_id BIGINT;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-restriction.player-required';
    END IF;

    IF p_restriction_type IS NULL OR TRIM(p_restriction_type) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-restriction.type-required';
    END IF;

    -- Oyuncu kontrolü
    IF NOT EXISTS (SELECT 1 FROM auth.players WHERE id = p_player_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-restriction.player-not-found';
    END IF;

    -- Kısıtlama oluştur
    INSERT INTO kyc.player_restrictions (
        player_id, restriction_type, scope, starts_at, ends_at,
        reason, set_by, can_be_revoked, min_duration_days
    ) VALUES (
        p_player_id, p_restriction_type, COALESCE(p_scope, 'all'),
        COALESCE(p_starts_at, NOW()), p_ends_at,
        p_reason, COALESCE(p_set_by, 'admin'), p_can_be_revoked, p_min_duration_days
    )
    RETURNING id INTO v_restriction_id;

    -- Geçmiş kaydı
    INSERT INTO kyc.player_limit_history (
        player_id, action_type, entity_type, entity_id,
        new_value, performed_by, reason
    ) VALUES (
        p_player_id, 'CREATE', 'restriction', v_restriction_id,
        jsonb_build_object('restrictionType', p_restriction_type, 'scope', p_scope),
        COALESCE(p_set_by, 'admin'), p_reason
    );

    RETURN v_restriction_id;
END;
$$;

COMMENT ON FUNCTION kyc.restriction_create IS 'Creates a player restriction (deposit, withdrawal, login, etc.) with history entry.';
