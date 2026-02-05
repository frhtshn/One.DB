-- ================================================================
-- PROVIDER_DELETE: Provider siler
-- Bagli kayit varsa silme engellenir (games, payment_methods, settings)
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
    -- ID kontrolu
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.id-required';
    END IF;

    -- Mevcut kayit kontrolu
    IF NOT EXISTS(SELECT 1 FROM catalog.providers p WHERE p.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider.not-found';
    END IF;

    -- Bagli oyun kontrolu
    IF EXISTS(SELECT 1 FROM catalog.games g WHERE g.provider_id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.provider.has-games';
    END IF;

    -- Bagli odeme yontemi kontrolu
    IF EXISTS(SELECT 1 FROM catalog.payment_methods pm WHERE pm.provider_id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.provider.has-payment-methods';
    END IF;

    -- Bagli ayar kontrolu - once ayarlari sil (cascade mantigi)
    DELETE FROM catalog.provider_settings WHERE provider_id = p_id;

    -- Sil
    DELETE FROM catalog.providers WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.provider_delete IS 'Deletes a provider. Fails if games/payment_methods exist. Settings are cascade deleted.';
