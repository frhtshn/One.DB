-- ================================================================
-- CLIENT_SETTING_LIST: Client'a ait tüm ayarları listeler
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.client_setting_list(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION core.client_setting_list(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_category VARCHAR DEFAULT NULL -- Optional filter
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
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

    -- 3. List Data
    RETURN COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'id', id,
                'clientId', client_id,
                'category', category,
                'key', setting_key,
                'value', setting_value,
                'description', description,
                'updatedAt', updated_at
            ) ORDER BY category, setting_key
        )
        FROM core.client_settings
        WHERE client_id = p_client_id
        AND (p_category IS NULL OR category = p_category)
    ), '[]'::jsonb);
END;
$$;

COMMENT ON FUNCTION core.client_setting_list(BIGINT, BIGINT, VARCHAR) IS 'Lists configuration settings for a client. Checks caller permissions.';
