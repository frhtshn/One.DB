-- ================================================================
-- CLIENT_CRYPTOCURRENCY_LIST: Client kripto para birimlerini listeler
-- Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.client_cryptocurrency_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.client_cryptocurrency_list(
    p_caller_id BIGINT,
    p_client_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result            JSONB;
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

    -- 3. Liste oluştur
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', tc.id,
            'clientId', tc.client_id,
            'symbol', tc.symbol,
            'name', c.name,
            'nameFull', c.name_full,
            'iconUrl', c.icon_url,
            'isEnabled', tc.is_enabled,
            'createdAt', tc.created_at,
            'updatedAt', tc.updated_at
        ) ORDER BY tc.is_enabled DESC, c.name
    ), '[]'::jsonb)
    INTO v_result
    FROM core.client_cryptocurrencies tc
    JOIN catalog.cryptocurrencies c ON c.symbol = tc.symbol
    WHERE tc.client_id = p_client_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.client_cryptocurrency_list(BIGINT, BIGINT) IS 'Lists all assigned cryptocurrencies for a client. Checks caller permissions.';
