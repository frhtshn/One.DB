-- ================================================================
-- LIMIT_SET: Oyuncu limiti belirleme
-- ================================================================
-- Yeni limit oluşturur veya mevcut limiti günceller.
-- Oyuncu tarafından azaltma anında, artırma bekleme süreli.
-- Admin değişiklikleri anında aktif.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.limit_set(BIGINT, VARCHAR, VARCHAR, DECIMAL, CHAR, VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION kyc.limit_set(
    p_player_id     BIGINT,
    p_limit_type    VARCHAR(30),
    p_limit_period  VARCHAR(20),
    p_limit_value   DECIMAL(18,2),
    p_currency_code CHAR(3) DEFAULT NULL,
    p_set_by        VARCHAR(20) DEFAULT 'player',
    p_admin_user_id BIGINT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_existing    RECORD;
    v_limit_id    BIGINT;
    v_old_value   JSONB;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-limit.player-required';
    END IF;

    IF p_limit_type IS NULL OR TRIM(p_limit_type) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-limit.type-required';
    END IF;

    IF p_limit_value IS NULL OR p_limit_value <= 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-limit.value-required';
    END IF;

    -- Oyuncu kontrolü
    IF NOT EXISTS (SELECT 1 FROM auth.players WHERE id = p_player_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-limit.player-not-found';
    END IF;

    -- Mevcut aktif limit var mı?
    SELECT id, limit_value INTO v_existing
    FROM kyc.player_limits
    WHERE player_id = p_player_id
      AND limit_type = p_limit_type
      AND limit_period = p_limit_period
      AND status = 'active';

    IF FOUND THEN
        v_old_value := jsonb_build_object('limitValue', v_existing.limit_value);

        IF p_set_by = 'admin' THEN
            -- Admin: anında güncelle
            UPDATE kyc.player_limits
            SET limit_value = p_limit_value,
                set_by = 'admin',
                updated_at = NOW()
            WHERE id = v_existing.id;
        ELSIF p_limit_value < v_existing.limit_value THEN
            -- Oyuncu azaltma: anında
            UPDATE kyc.player_limits
            SET limit_value = p_limit_value,
                updated_at = NOW()
            WHERE id = v_existing.id;
        ELSE
            -- Oyuncu artırma: 24 saat bekleme
            UPDATE kyc.player_limits
            SET pending_value = p_limit_value,
                pending_activation_at = NOW() + INTERVAL '24 hours',
                updated_at = NOW()
            WHERE id = v_existing.id;
        END IF;

        v_limit_id := v_existing.id;
    ELSE
        -- Yeni limit
        INSERT INTO kyc.player_limits (
            player_id, limit_type, limit_period, limit_value,
            currency_code, set_by
        ) VALUES (
            p_player_id, p_limit_type, p_limit_period, p_limit_value,
            p_currency_code, COALESCE(p_set_by, 'player')
        )
        RETURNING id INTO v_limit_id;

        v_old_value := NULL;
    END IF;

    -- Geçmiş kaydı
    INSERT INTO kyc.player_limit_history (
        player_id, action_type, entity_type, entity_id,
        old_value, new_value, performed_by, admin_user_id
    ) VALUES (
        p_player_id,
        CASE WHEN v_existing.id IS NOT NULL THEN 'UPDATE' ELSE 'CREATE' END,
        'limit', v_limit_id,
        v_old_value,
        jsonb_build_object('limitType', p_limit_type, 'limitPeriod', p_limit_period, 'limitValue', p_limit_value),
        COALESCE(p_set_by, 'player'), p_admin_user_id
    );

    RETURN v_limit_id;
END;
$$;

COMMENT ON FUNCTION kyc.limit_set IS 'Sets or updates a player limit. Player decreases are instant, increases have 24h cooling period. Admin changes are always instant.';
