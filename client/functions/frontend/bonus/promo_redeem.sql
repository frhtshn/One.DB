-- ================================================================
-- PROMO_REDEEM: Promo kod kullanımı kaydet
-- ================================================================
-- Auth-agnostic. Oyuncu promo kod kullandığında çağrılır.
-- Backend promo kodu Bonus DB'de doğrular (aktif, geçerli, limit),
-- sonra bu fonksiyonu Client DB'de çağırır.
-- bonus_award_id NULL gelebilir (award Worker tarafından yapılır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.promo_redeem(BIGINT, BIGINT, VARCHAR, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION bonus.promo_redeem(
    p_player_id BIGINT,
    p_promo_code_id BIGINT,
    p_promo_code VARCHAR(50),
    p_bonus_award_id BIGINT DEFAULT NULL,
    p_status VARCHAR(20) DEFAULT 'success'
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id BIGINT;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.promo.player-required';
    END IF;

    IF p_promo_code_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.promo.code-id-required';
    END IF;

    IF p_promo_code IS NULL OR TRIM(p_promo_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.promo.code-required';
    END IF;

    -- status validasyon
    IF p_status NOT IN ('success', 'failed', 'expired') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.promo.invalid-status';
    END IF;

    INSERT INTO bonus.promo_redemptions (
        player_id, promo_code_id, promo_code,
        bonus_award_id, status,
        redeemed_at, created_at, updated_at
    ) VALUES (
        p_player_id,
        p_promo_code_id,
        UPPER(TRIM(p_promo_code)),
        p_bonus_award_id,
        p_status,
        NOW(), NOW(), NOW()
    )
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION bonus.promo_redeem(BIGINT, BIGINT, VARCHAR, BIGINT, VARCHAR) IS 'Records a promo code redemption. Backend validates code in Bonus DB first, then calls this in Client DB. bonus_award_id may be NULL if award is created asynchronously by Worker.';
