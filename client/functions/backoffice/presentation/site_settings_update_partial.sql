-- ================================================================
-- SITE_SETTINGS_UPDATE_PARTIAL: Belirli bir JSONB alanını güncelle
-- jsonb_set ile mevcut yapıyı koruyarak kısmi güncelleme
-- Hedef alanlar: analytics_config, cookie_consent_config, age_gate_config, live_chat_config
-- ================================================================

DROP FUNCTION IF EXISTS presentation.update_site_settings_partial(VARCHAR, JSONB, INTEGER);

CREATE OR REPLACE FUNCTION presentation.update_site_settings_partial(
    p_field_name    VARCHAR(50),    -- 'analyticsConfig' | 'cookieConsentConfig' | 'ageGateConfig' | 'liveChatConfig'
    p_value         JSONB,
    p_user_id       INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_column_name TEXT;
BEGIN
    IF p_field_name IS NULL THEN
        RAISE EXCEPTION 'error.site-settings.field-name-required';
    END IF;
    IF p_value IS NULL THEN
        RAISE EXCEPTION 'error.site-settings.value-required';
    END IF;

    -- camelCase → snake_case eşleşmesi
    v_column_name := CASE p_field_name
        WHEN 'analyticsConfig'      THEN 'analytics_config'
        WHEN 'cookieConsentConfig'  THEN 'cookie_consent_config'
        WHEN 'ageGateConfig'        THEN 'age_gate_config'
        WHEN 'liveChatConfig'       THEN 'live_chat_config'
        ELSE NULL
    END;

    IF v_column_name IS NULL THEN
        RAISE EXCEPTION 'error.site-settings.invalid-field';
    END IF;

    -- Dinamik sütun güncellemesi
    IF v_column_name = 'analytics_config' THEN
        UPDATE presentation.site_settings
        SET analytics_config = p_value, updated_by = p_user_id, updated_at = NOW();
    ELSIF v_column_name = 'cookie_consent_config' THEN
        UPDATE presentation.site_settings
        SET cookie_consent_config = p_value, updated_by = p_user_id, updated_at = NOW();
    ELSIF v_column_name = 'age_gate_config' THEN
        UPDATE presentation.site_settings
        SET age_gate_config = p_value, updated_by = p_user_id, updated_at = NOW();
    ELSIF v_column_name = 'live_chat_config' THEN
        UPDATE presentation.site_settings
        SET live_chat_config = p_value, updated_by = p_user_id, updated_at = NOW();
    END IF;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'error.site-settings.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION presentation.update_site_settings_partial(VARCHAR, JSONB, INTEGER) IS 'Replace a specific JSONB config field (analyticsConfig, cookieConsentConfig, ageGateConfig, liveChatConfig) in site_settings. Use upsert_site_settings for full updates.';
