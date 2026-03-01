-- ================================================================
-- CLIENT_SETTING_DELETE: Ayarı siler
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.client_setting_delete(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION core.client_setting_delete(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_key VARCHAR
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

    -- 3. Delete
    DELETE FROM core.client_settings
    WHERE client_id = p_client_id AND setting_key = p_key;
END;
$$;

COMMENT ON FUNCTION core.client_setting_delete(BIGINT, BIGINT, VARCHAR) IS 'Deletes a client configuration setting. Checks caller permissions.';
