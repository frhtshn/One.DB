-- ================================================================
-- PROMO_CODE_CREATE: Promosyon kodu oluştur
-- ================================================================
-- Bir bonus kuralına bağlı promo kod tanımlar.
-- Unique: (client_id, code). Kod büyük harfe çevrilir.
-- bonus_rule_id mevcut ve aktif olmalı.
-- ================================================================

DROP FUNCTION IF EXISTS promotion.promo_code_create(BIGINT, VARCHAR, VARCHAR, BIGINT, INT, INT, TIMESTAMPTZ, TIMESTAMPTZ);

CREATE OR REPLACE FUNCTION promotion.promo_code_create(
    p_client_id BIGINT,
    p_code VARCHAR(50),
    p_promo_name VARCHAR(255),
    p_bonus_rule_id BIGINT,
    p_max_redemptions INT DEFAULT NULL,
    p_max_per_player INT DEFAULT 1,
    p_valid_from TIMESTAMPTZ DEFAULT NULL,
    p_valid_until TIMESTAMPTZ DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_new_id BIGINT;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_code IS NULL OR TRIM(p_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.promo.code-required';
    END IF;

    IF p_promo_name IS NULL OR TRIM(p_promo_name) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.promo.name-required';
    END IF;

    IF p_valid_from IS NULL OR p_valid_until IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.promo.dates-required';
    END IF;

    IF p_valid_until <= p_valid_from THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.promo.end-before-start';
    END IF;

    -- bonus_rule_id kontrolü
    IF NOT EXISTS (SELECT 1 FROM bonus.bonus_rules WHERE id = p_bonus_rule_id AND is_active = true) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-rule.not-found-or-inactive';
    END IF;

    -- Unique kod kontrolü
    IF EXISTS (
        SELECT 1 FROM promotion.promo_codes
        WHERE client_id IS NOT DISTINCT FROM p_client_id
          AND code = UPPER(TRIM(p_code))
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.promo.code-exists';
    END IF;

    INSERT INTO promotion.promo_codes (
        client_id, code, promo_name, bonus_rule_id,
        max_redemptions, max_per_player, current_redemptions,
        valid_from, valid_until,
        is_active, created_at, updated_at
    ) VALUES (
        p_client_id,
        UPPER(TRIM(p_code)),
        TRIM(p_promo_name),
        p_bonus_rule_id,
        p_max_redemptions,
        COALESCE(p_max_per_player, 1),
        0,
        p_valid_from,
        p_valid_until,
        true,
        NOW(), NOW()
    )
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION promotion.promo_code_create IS 'Creates a promotional code linked to a bonus rule. Code stored in uppercase. Unique by (client_id, code). Validates bonus rule exists and is active.';
