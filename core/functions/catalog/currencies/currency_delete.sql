-- ================================================================
-- CURRENCY_DELETE: Para birimini siler (Soft Delete)
-- Aktif durumunu false yapar. Client'ta kullanılıyorsa silmez.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.currency_delete(CHAR(3));

CREATE OR REPLACE FUNCTION catalog.currency_delete(p_code CHAR(3))
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_code CHAR(3);
    v_usage_count INT;
BEGIN
    v_code := UPPER(TRIM(p_code));

    -- Mevcut mu kontrolu
    IF NOT EXISTS(SELECT 1 FROM catalog.currencies c WHERE c.currency_code = v_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.currency.not-found';
    END IF;

    -- Referans kontrolu: Bu para birimi client'larda kullanılıyor mu?
    SELECT COUNT(*) INTO v_usage_count
    FROM core.client_currencies tc
    WHERE tc.currency_code = v_code;

    IF v_usage_count > 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.currency.delete.in-use';
    END IF;

    -- Base currency olarak kullanılıyor mu?
    SELECT COUNT(*) INTO v_usage_count
    FROM core.clients t
    WHERE t.base_currency = v_code;

    IF v_usage_count > 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.currency.delete.is-base-currency';
    END IF;

    -- Soft delete (idempotent - zaten pasifse de hata vermez)
    UPDATE catalog.currencies c
    SET is_active = FALSE
    WHERE c.currency_code = v_code;
END;
$$;

COMMENT ON FUNCTION catalog.currency_delete IS 'Soft deletes a currency by setting is_active to false (checks for usage first)';
