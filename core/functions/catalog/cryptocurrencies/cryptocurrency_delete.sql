-- ================================================================
-- CRYPTOCURRENCY_DELETE: Kripto para birimini siler (Soft Delete)
-- Aktif durumunu false yapar. Client'ta kullanılıyorsa silmez.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.cryptocurrency_delete(VARCHAR);

CREATE OR REPLACE FUNCTION catalog.cryptocurrency_delete(p_symbol VARCHAR(20))
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_symbol      VARCHAR(20);
    v_usage_count INT;
BEGIN
    v_symbol := UPPER(TRIM(p_symbol));

    -- Mevcut mu kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.cryptocurrencies c WHERE c.symbol = v_symbol) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.cryptocurrency.not-found';
    END IF;

    -- Referans kontrolü: Bu kripto client'larda kullanılıyor mu?
    SELECT COUNT(*) INTO v_usage_count
    FROM core.client_cryptocurrencies tc
    WHERE tc.symbol = v_symbol;

    IF v_usage_count > 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.cryptocurrency.delete.in-use';
    END IF;

    -- Soft delete (idempotent - zaten pasifse de hata vermez)
    UPDATE catalog.cryptocurrencies c
    SET is_active  = FALSE,
        updated_at = NOW()
    WHERE c.symbol = v_symbol;
END;
$$;

COMMENT ON FUNCTION catalog.cryptocurrency_delete(VARCHAR) IS 'Soft deletes a cryptocurrency by setting is_active to false (checks for client usage first)';
