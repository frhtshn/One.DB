-- ================================================================
-- CURRENCY_CREATE: Yeni para birimi oluşturur
-- Code: 3 karakter (ISO 4217), Name: en az 2 karakter olmalı.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.currency_create(CHAR(3), VARCHAR, VARCHAR, SMALLINT);

CREATE OR REPLACE FUNCTION catalog.currency_create(
    p_code CHAR(3),
    p_name VARCHAR(100),
    p_symbol VARCHAR(10) DEFAULT NULL,
    p_numeric_code SMALLINT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_code CHAR(3);
    v_name VARCHAR(100);
BEGIN
    -- Kod kontrolu (3 karakter)
    IF p_code IS NULL OR LENGTH(TRIM(p_code)) != 3 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.currency.code-invalid';
    END IF;

    -- Isim kontrolu
    IF p_name IS NULL OR LENGTH(TRIM(p_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.currency.name-invalid';
    END IF;

    v_code := UPPER(TRIM(p_code));
    v_name := TRIM(p_name);

    -- Mevcut mu kontrolu
    IF EXISTS(SELECT 1 FROM catalog.currencies c WHERE c.currency_code = v_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.currency.create.code-exists';
    END IF;

    -- Ekle
    INSERT INTO catalog.currencies (currency_code, currency_name, symbol, numeric_code, is_active)
    VALUES (v_code, v_name, p_symbol, p_numeric_code, TRUE);
END;
$$;

COMMENT ON FUNCTION catalog.currency_create IS 'Creates a new currency';
