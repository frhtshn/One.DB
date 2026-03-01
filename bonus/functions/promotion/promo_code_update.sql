-- ================================================================
-- PROMO_CODE_UPDATE: Promosyon kodu güncelle
-- ================================================================
-- COALESCE pattern: NULL = mevcut değeri koru.
-- Kod değiştirilebilir (unique kontrolü yapılır).
-- current_redemptions bu fonksiyonla güncellenemez (atomik).
-- ================================================================

DROP FUNCTION IF EXISTS promotion.promo_code_update(BIGINT, VARCHAR, VARCHAR, BIGINT, INT, INT, TIMESTAMPTZ, TIMESTAMPTZ, BOOLEAN);

CREATE OR REPLACE FUNCTION promotion.promo_code_update(
    p_id BIGINT,
    p_code VARCHAR(50) DEFAULT NULL,
    p_promo_name VARCHAR(255) DEFAULT NULL,
    p_bonus_rule_id BIGINT DEFAULT NULL,
    p_max_redemptions INT DEFAULT NULL,
    p_max_per_player INT DEFAULT NULL,
    p_valid_from TIMESTAMPTZ DEFAULT NULL,
    p_valid_until TIMESTAMPTZ DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_current RECORD;
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.promo.id-required';
    END IF;

    SELECT id, client_id, code INTO v_current
    FROM promotion.promo_codes WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.promo.not-found';
    END IF;

    -- code değişiyorsa unique kontrolü
    IF p_code IS NOT NULL AND UPPER(TRIM(p_code)) != v_current.code THEN
        IF EXISTS (
            SELECT 1 FROM promotion.promo_codes
            WHERE client_id IS NOT DISTINCT FROM v_current.client_id
              AND code = UPPER(TRIM(p_code))
              AND id != p_id
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.promo.code-exists';
        END IF;
    END IF;

    -- bonus_rule_id değişiyorsa varlık kontrolü
    IF p_bonus_rule_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM bonus.bonus_rules WHERE id = p_bonus_rule_id AND is_active = true) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-rule.not-found-or-inactive';
        END IF;
    END IF;

    UPDATE promotion.promo_codes SET
        code = COALESCE(UPPER(TRIM(NULLIF(p_code, ''))), code),
        promo_name = COALESCE(TRIM(NULLIF(p_promo_name, '')), promo_name),
        bonus_rule_id = COALESCE(p_bonus_rule_id, bonus_rule_id),
        max_redemptions = COALESCE(p_max_redemptions, max_redemptions),
        max_per_player = COALESCE(p_max_per_player, max_per_player),
        valid_from = COALESCE(p_valid_from, valid_from),
        valid_until = COALESCE(p_valid_until, valid_until),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION promotion.promo_code_update IS 'Updates a promotional code. COALESCE pattern preserves existing values. current_redemptions is atomic-only.';
