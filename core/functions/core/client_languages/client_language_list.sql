-- ================================================================
-- CLIENT_LANGUAGE_LIST: Client dillerini listeler
-- Default language bilgisini isDefault olarak işaretler.
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.client_language_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.client_language_list(
    p_caller_id BIGINT,
    p_client_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_default_language CHAR(2);
    v_result JSONB;
    v_client_company_id BIGINT;
BEGIN
    -- 1. Client varlık kontrolü ve default language alımı
    SELECT company_id, default_language INTO v_client_company_id, v_default_language
    FROM core.clients WHERE id = p_client_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- 2. Company erişim kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_client_company_id);

    -- 3. List Data
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', tl.id,
            'clientId', tl.client_id,
            'code', tl.language_code,
            'name', l.language_name,
            'isEnabled', tl.is_enabled,
            'isDefault', COALESCE((tl.language_code = v_default_language), false),
            'createdAt', tl.created_at,
            'updatedAt', tl.updated_at
        ) ORDER BY (tl.language_code = v_default_language) DESC, tl.is_enabled DESC, l.language_name
    ), '[]'::jsonb)
    INTO v_result
    FROM core.client_languages tl
    JOIN catalog.languages l ON l.language_code = tl.language_code
    WHERE tl.client_id = p_client_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.client_language_list(BIGINT, BIGINT) IS 'Lists all assigned languages for a client. Checks caller permissions.';
