-- ================================================================
-- CLIENT_CURRENCY_LIST: Client para birimlerini listeler
-- Base currency bilgisini isBase olarak işaretler.
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.client_currency_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.client_currency_list(
    p_caller_id BIGINT,
    p_client_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_base_currency CHAR(3);
    v_result JSONB;
    v_client_company_id BIGINT;
BEGIN
    -- 1. Client varlık kontrolü ve base currency alımı
    SELECT company_id, base_currency INTO v_client_company_id, v_base_currency
    FROM core.clients WHERE id = p_client_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- 2. Company erişim kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_client_company_id);

    -- 3. List Data
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', tc.id,
            'clientId', tc.client_id,
            'code', tc.currency_code,
            'name', c.currency_name,
            'symbol', c.symbol,
            'isEnabled', tc.is_enabled,
            'isBase', COALESCE((tc.currency_code = v_base_currency), false),
            'createdAt', tc.created_at,
            'updatedAt', tc.updated_at
        ) ORDER BY (tc.currency_code = v_base_currency) DESC, tc.is_enabled DESC, c.currency_name
    ), '[]'::jsonb)
    INTO v_result
    FROM core.client_currencies tc
    JOIN catalog.currencies c ON c.currency_code = tc.currency_code
    WHERE tc.client_id = p_client_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.client_currency_list(BIGINT, BIGINT) IS 'Lists all assigned currencies for a client. Checks caller permissions.';
