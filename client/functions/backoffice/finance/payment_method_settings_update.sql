-- ================================================================
-- PAYMENT_METHOD_SETTINGS_UPDATE: Client customization güncelleme
-- ================================================================
-- COALESCE pattern (NULL = mevcut değeri koru).
-- Sadece client-editable alanları günceller.
-- Auth-agnostic (cross-DB auth pattern).
-- ================================================================

DROP FUNCTION IF EXISTS finance.payment_method_settings_update(
    BIGINT, BOOLEAN, BOOLEAN, BOOLEAN, INTEGER,
    VARCHAR, VARCHAR, TEXT,
    VARCHAR(20)[], CHAR(2)[], CHAR(2)[],
    TIMESTAMP, TIMESTAMP
);

CREATE OR REPLACE FUNCTION finance.payment_method_settings_update(
    p_payment_method_id BIGINT,
    p_is_visible BOOLEAN DEFAULT NULL,
    p_is_featured BOOLEAN DEFAULT NULL,
    p_allow_deposit BOOLEAN DEFAULT NULL,
    p_display_order INTEGER DEFAULT NULL,
    p_custom_name VARCHAR(255) DEFAULT NULL,
    p_custom_icon_url VARCHAR(500) DEFAULT NULL,
    p_custom_description TEXT DEFAULT NULL,
    p_allowed_platforms VARCHAR(20)[] DEFAULT NULL,
    p_blocked_countries CHAR(2)[] DEFAULT NULL,
    p_allowed_countries CHAR(2)[] DEFAULT NULL,
    p_available_from TIMESTAMP DEFAULT NULL,
    p_available_until TIMESTAMP DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_payment_method_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.id-required';
    END IF;

    UPDATE finance.payment_method_settings SET
        is_visible = COALESCE(p_is_visible, is_visible),
        is_featured = COALESCE(p_is_featured, is_featured),
        allow_deposit = COALESCE(p_allow_deposit, allow_deposit),
        display_order = COALESCE(p_display_order, display_order),
        custom_name = COALESCE(p_custom_name, custom_name),
        custom_icon_url = COALESCE(p_custom_icon_url, custom_icon_url),
        custom_description = COALESCE(p_custom_description, custom_description),
        allowed_platforms = COALESCE(p_allowed_platforms, allowed_platforms),
        blocked_countries = COALESCE(p_blocked_countries, blocked_countries),
        allowed_countries = COALESCE(p_allowed_countries, allowed_countries),
        available_from = COALESCE(p_available_from, available_from),
        available_until = COALESCE(p_available_until, available_until),
        updated_at = NOW()
    WHERE payment_method_id = p_payment_method_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.payment-method.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION finance.payment_method_settings_update IS 'Updates client-editable payment method settings (custom_name, display_order, blocked_countries, etc). COALESCE pattern. Auth-agnostic.';
