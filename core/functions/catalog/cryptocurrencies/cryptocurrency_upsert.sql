-- ================================================================
-- CRYPTOCURRENCY_UPSERT: Kripto para birimi ekler veya günceller
-- Coinlayer /list endpoint'inden gelen verileri senkronize eder
-- Symbol zaten varsa günceller, yoksa yeni kayıt oluşturur
-- ================================================================

DROP FUNCTION IF EXISTS catalog.cryptocurrency_upsert(VARCHAR, VARCHAR, VARCHAR, NUMERIC, VARCHAR);

CREATE OR REPLACE FUNCTION catalog.cryptocurrency_upsert(
    p_symbol    VARCHAR(20),              -- Kripto sembolü: BTC, ETH
    p_name      VARCHAR(100),             -- Kısa ad: Bitcoin, Ethereum
    p_name_full VARCHAR(200) DEFAULT NULL, -- Tam ad (coinlayer'dan gelen)
    p_max_supply NUMERIC(30,8) DEFAULT NULL, -- Maksimum arz
    p_icon_url  VARCHAR(500) DEFAULT NULL -- Coin ikon URL'i
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INT;
    v_symbol VARCHAR(20);
BEGIN
    -- Symbol kontrolü
    IF p_symbol IS NULL OR LENGTH(TRIM(p_symbol)) = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.cryptocurrency.symbol-required';
    END IF;

    -- İsim kontrolü
    IF p_name IS NULL OR LENGTH(TRIM(p_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.cryptocurrency.name-invalid';
    END IF;

    v_symbol := UPPER(TRIM(p_symbol));

    -- Upsert: varsa güncelle, yoksa ekle
    INSERT INTO catalog.cryptocurrencies (
        symbol, name, name_full, max_supply, icon_url
    ) VALUES (
        v_symbol, TRIM(p_name), TRIM(p_name_full), p_max_supply, TRIM(p_icon_url)
    )
    ON CONFLICT (symbol) DO UPDATE SET
        name       = EXCLUDED.name,
        name_full  = EXCLUDED.name_full,
        max_supply = EXCLUDED.max_supply,
        icon_url   = EXCLUDED.icon_url,
        updated_at = NOW()
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION catalog.cryptocurrency_upsert(VARCHAR, VARCHAR, VARCHAR, NUMERIC, VARCHAR) IS 'Upserts a cryptocurrency from Coinlayer /list sync. Creates if new, updates if symbol exists. Returns ID.';
