-- ================================================================
-- CLIENT_SETTING_GET: Belirli bir ayarın değerini döner
-- Setting objesini JSONB olarak döner.
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.client_setting_get(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION core.client_setting_get(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_key VARCHAR
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
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

    -- 3. Get Data
    SELECT jsonb_build_object(
        'id', id,
        'clientId', client_id,
        'category', category,
        'key', setting_key,
        'value', setting_value,
        'description', description,
        'updatedAt', updated_at
    )
    INTO v_result
    FROM core.client_settings
    WHERE client_id = p_client_id AND setting_key = p_key;

    RETURN v_result; -- Returns NULL if not found
END;
$$;

COMMENT ON FUNCTION core.client_setting_get(BIGINT, BIGINT, VARCHAR) IS 'Returns a specific client setting. Checks caller permissions.';
