-- ================================================================
-- SITE_SETTINGS_GET: Site ayarlarını getir (tek satır)
-- ================================================================

DROP FUNCTION IF EXISTS presentation.get_site_settings();

CREATE OR REPLACE FUNCTION presentation.get_site_settings()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id',                   id,
        'companyName',          company_name,
        'companyRegNumber',     company_reg_number,
        'contactEmail',         contact_email,
        'contactPhone',         contact_phone,
        'contactAddress',       contact_address,
        'analyticsConfig',      analytics_config,
        'cookieConsentConfig',  cookie_consent_config,
        'ageGateConfig',        age_gate_config,
        'liveChatProvider',     live_chat_provider,
        'liveChatConfig',       live_chat_config,
        'updatedAt',            updated_at
    )
    INTO v_result
    FROM presentation.site_settings
    LIMIT 1;

    RETURN COALESCE(v_result, '{}'::JSONB);
END;
$$;

COMMENT ON FUNCTION presentation.get_site_settings() IS 'Return the single site settings row as JSONB. Returns empty object if not yet initialized.';
