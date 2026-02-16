-- ================================================================
-- PROVIDER_DELETE: Provider pasifleştir (soft delete)
-- ================================================================
-- is_active = false yapar. Ayarlar olduğu gibi kalır
-- (provider inactive olduğunda zaten anlamsız).
-- Games/payment_methods kontrolü backend'de yapılır (cross-DB).
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_delete(BIGINT);

CREATE OR REPLACE FUNCTION catalog.provider_delete(
    p_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.id-required';
    END IF;

    -- Provider'ı pasifleştir
    UPDATE catalog.providers SET
        is_active = false
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.provider_delete(BIGINT) IS 'Soft-deletes a provider (is_active=false). Settings remain intact (irrelevant when provider is inactive). Games/payment_methods checks done by backend (cross-DB).';
