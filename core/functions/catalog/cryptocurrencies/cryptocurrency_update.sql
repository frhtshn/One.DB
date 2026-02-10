-- ================================================================
-- CRYPTOCURRENCY_UPDATE: Kripto para birimi bilgilerini günceller
-- Admin tarafından sort_order, icon_url, is_active değişiklikleri
-- ================================================================

DROP FUNCTION IF EXISTS catalog.cryptocurrency_update(VARCHAR, VARCHAR, VARCHAR, NUMERIC, VARCHAR, BOOLEAN, INT);

CREATE OR REPLACE FUNCTION catalog.cryptocurrency_update(
    p_symbol     VARCHAR(20),
    p_name       VARCHAR(100),
    p_name_full  VARCHAR(200),
    p_max_supply NUMERIC(30,8),
    p_icon_url   VARCHAR(500),
    p_is_active  BOOLEAN,
    p_sort_order INT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_symbol VARCHAR(20);
    v_name   VARCHAR(100);
BEGIN
    v_symbol := UPPER(TRIM(p_symbol));
    v_name   := TRIM(p_name);

    -- Mevcut mu kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.cryptocurrencies c WHERE c.symbol = v_symbol) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.cryptocurrency.not-found';
    END IF;

    -- İsim kontrolü
    IF p_name IS NULL OR LENGTH(v_name) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.cryptocurrency.name-invalid';
    END IF;

    -- Güncelle
    UPDATE catalog.cryptocurrencies c
    SET name       = v_name,
        name_full  = TRIM(p_name_full),
        max_supply = p_max_supply,
        icon_url   = TRIM(p_icon_url),
        is_active  = p_is_active,
        sort_order = p_sort_order,
        updated_at = NOW()
    WHERE c.symbol = v_symbol;
END;
$$;

COMMENT ON FUNCTION catalog.cryptocurrency_update IS 'Updates cryptocurrency details (name, icon, active status, sort order)';
