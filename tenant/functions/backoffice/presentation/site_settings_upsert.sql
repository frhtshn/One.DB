-- ================================================================
-- SITE_SETTINGS_UPSERT: Site ayarlarını oluştur veya güncelle
-- Tabloda her zaman yalnızca bir satır bulunur
-- ================================================================

DROP FUNCTION IF EXISTS presentation.upsert_site_settings(VARCHAR, VARCHAR, VARCHAR, VARCHAR, JSONB, JSONB, JSONB, JSONB, VARCHAR, JSONB, INTEGER);

CREATE OR REPLACE FUNCTION presentation.upsert_site_settings(
    p_company_name          VARCHAR(200)    DEFAULT NULL,
    p_company_reg_number    VARCHAR(100)    DEFAULT NULL,
    p_contact_email         VARCHAR(200)    DEFAULT NULL,
    p_contact_phone         VARCHAR(50)     DEFAULT NULL,
    p_contact_address       JSONB           DEFAULT NULL,
    p_analytics_config      JSONB           DEFAULT NULL,
    p_cookie_consent_config JSONB           DEFAULT NULL,
    p_age_gate_config       JSONB           DEFAULT NULL,
    p_live_chat_provider    VARCHAR(50)     DEFAULT NULL,
    p_live_chat_config      JSONB           DEFAULT NULL,
    p_user_id               INTEGER         DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    -- Tek satır kontrolü: güncelle
    UPDATE presentation.site_settings
    SET
        company_name            = COALESCE(p_company_name, company_name),
        company_reg_number      = COALESCE(p_company_reg_number, company_reg_number),
        contact_email           = COALESCE(p_contact_email, contact_email),
        contact_phone           = COALESCE(p_contact_phone, contact_phone),
        contact_address         = COALESCE(p_contact_address, contact_address),
        analytics_config        = COALESCE(p_analytics_config, analytics_config),
        cookie_consent_config   = COALESCE(p_cookie_consent_config, cookie_consent_config),
        age_gate_config         = COALESCE(p_age_gate_config, age_gate_config),
        live_chat_provider      = COALESCE(p_live_chat_provider, live_chat_provider),
        live_chat_config        = COALESCE(p_live_chat_config, live_chat_config),
        updated_by              = p_user_id,
        updated_at              = NOW()
    RETURNING id INTO v_id;

    -- Satır yoksa oluştur
    IF v_id IS NULL THEN
        INSERT INTO presentation.site_settings (
            company_name, company_reg_number, contact_email, contact_phone, contact_address,
            analytics_config, cookie_consent_config, age_gate_config,
            live_chat_provider, live_chat_config, created_by, updated_by
        )
        VALUES (
            p_company_name, p_company_reg_number, p_contact_email, p_contact_phone, p_contact_address,
            COALESCE(p_analytics_config, '{}'), COALESCE(p_cookie_consent_config, '{}'),
            COALESCE(p_age_gate_config, '{"min_age": 18}'),
            p_live_chat_provider, COALESCE(p_live_chat_config, '{}'),
            p_user_id, p_user_id
        )
        RETURNING id INTO v_id;
    END IF;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION presentation.upsert_site_settings(VARCHAR, VARCHAR, VARCHAR, VARCHAR, JSONB, JSONB, JSONB, JSONB, VARCHAR, JSONB, INTEGER) IS 'Create or update the single site settings row. Updates only provided (non-null) fields on existing row. Returns the settings ID.';
