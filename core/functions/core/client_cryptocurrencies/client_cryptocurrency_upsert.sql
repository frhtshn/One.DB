-- ================================================================
-- CLIENT_CRYPTOCURRENCY_UPSERT: Client kripto para birimi ekle/güncelle
-- Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.client_cryptocurrency_upsert(BIGINT, BIGINT, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION core.client_cryptocurrency_upsert(
    p_caller_id  BIGINT,
    p_client_id  BIGINT,
    p_symbol     VARCHAR(20),
    p_is_enabled BOOLEAN DEFAULT TRUE
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_client_company_id BIGINT;
    v_symbol            VARCHAR(20);
BEGIN
    v_symbol := UPPER(TRIM(p_symbol));

    -- 1. Client varlık kontrolü
    SELECT company_id INTO v_client_company_id
    FROM core.clients WHERE id = p_client_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- 2. Company erişim kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_client_company_id);

    -- 3. Cryptocurrency varlık kontrolü
    IF NOT EXISTS (SELECT 1 FROM catalog.cryptocurrencies WHERE symbol = v_symbol AND is_active = TRUE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.cryptocurrency.not-found';
    END IF;

    -- 4. Upsert logic
    IF EXISTS (SELECT 1 FROM core.client_cryptocurrencies WHERE client_id = p_client_id AND symbol = v_symbol) THEN
        UPDATE core.client_cryptocurrencies
        SET is_enabled = p_is_enabled,
            updated_at = NOW()
        WHERE client_id = p_client_id AND symbol = v_symbol;
    ELSE
        INSERT INTO core.client_cryptocurrencies (client_id, symbol, is_enabled)
        VALUES (p_client_id, v_symbol, p_is_enabled);
    END IF;
END;
$$;

COMMENT ON FUNCTION core.client_cryptocurrency_upsert(BIGINT, BIGINT, VARCHAR, BOOLEAN) IS 'Assigns or updates a cryptocurrency for a client. Checks caller permissions.';
