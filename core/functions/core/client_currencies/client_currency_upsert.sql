-- ================================================================
-- CLIENT_CURRENCY_UPSERT: Client para birimi ekle/güncelle
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.client_currency_upsert(BIGINT, BIGINT, CHAR(3), BOOLEAN);

CREATE OR REPLACE FUNCTION core.client_currency_upsert(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_currency_code CHAR(3),
    p_is_enabled BOOLEAN DEFAULT TRUE
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

    -- 3. Currency Validation
    IF NOT EXISTS (SELECT 1 FROM catalog.currencies WHERE currency_code = p_currency_code AND is_active = TRUE) THEN
         RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.currency.not-found';
    END IF;

    -- 5. Upsert Logic
    IF EXISTS (SELECT 1 FROM core.client_currencies WHERE client_id = p_client_id AND currency_code = p_currency_code) THEN
        UPDATE core.client_currencies
        SET is_enabled = p_is_enabled,
            updated_at = NOW()
        WHERE client_id = p_client_id AND currency_code = p_currency_code;
    ELSE
        INSERT INTO core.client_currencies (client_id, currency_code, is_enabled)
        VALUES (p_client_id, p_currency_code, p_is_enabled);
    END IF;
END;
$$;

COMMENT ON FUNCTION core.client_currency_upsert(BIGINT, BIGINT, CHAR(3), BOOLEAN) IS 'Assigns or updates a currency for a client. Checks caller permissions.';
