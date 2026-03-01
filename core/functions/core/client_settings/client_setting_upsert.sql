-- ================================================================
-- CLIENT_SETTING_UPSERT: Client ayarı ekler veya günceller
-- Key-Value yapısında çalışır. Key unique'dir (client bazında).
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.client_setting_upsert(BIGINT, BIGINT, VARCHAR, JSONB, VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS core.client_setting_upsert(BIGINT, BIGINT, VARCHAR, TEXT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION core.client_setting_upsert(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_key VARCHAR,
    p_value TEXT,
    p_description VARCHAR DEFAULT NULL,
    p_category VARCHAR DEFAULT 'General'
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_client_company_id BIGINT;
BEGIN
    -- 1. Client varlık kontrolü
    SELECT company_id INTO v_client_company_id
    FROM core.clients WHERE id = p_client_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- 2. Company erişim kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_client_company_id);

    -- 3. Upsert
    INSERT INTO core.client_settings (
        client_id,
        setting_key,
        setting_value,
        description,
        category,
        updated_at
    ) VALUES (
        p_client_id,
        p_key,
        p_value::jsonb,
        p_description,
        p_category,
        NOW()
    )
    ON CONFLICT (client_id, setting_key)
    DO UPDATE SET
        setting_value = EXCLUDED.setting_value,
        description = COALESCE(EXCLUDED.description, core.client_settings.description),
        category = COALESCE(EXCLUDED.category, core.client_settings.category),
        updated_at = NOW();
END;
$$;

COMMENT ON FUNCTION core.client_setting_upsert(BIGINT, BIGINT, VARCHAR, TEXT, VARCHAR, VARCHAR) IS 'Inserts or updates a client configuration setting. Checks caller permissions.';
