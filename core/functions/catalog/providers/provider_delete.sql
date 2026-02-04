-- ================================================================
-- PROVIDER_DELETE: Provider siler
-- Sadece SuperAdmin kullanabilir (IDOR korumalı)
-- Bağlı kayıt varsa silme engellenir (games, payment_methods, settings)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_delete(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION catalog.provider_delete(
    p_caller_id BIGINT,
    p_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- SuperAdmin check
    PERFORM security.user_assert_superadmin(p_caller_id);

    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.providers p WHERE p.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider.not-found';
    END IF;

    -- Bağlı oyun kontrolü
    IF EXISTS(SELECT 1 FROM catalog.games g WHERE g.provider_id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.provider.has-games';
    END IF;

    -- Bağlı ödeme yöntemi kontrolü
    IF EXISTS(SELECT 1 FROM catalog.payment_methods pm WHERE pm.provider_id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.provider.has-payment-methods';
    END IF;

    -- Bağlı ayar kontrolü - önce ayarları sil (cascade mantığı)
    DELETE FROM catalog.provider_settings WHERE provider_id = p_id;

    -- Sil
    DELETE FROM catalog.providers WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.provider_delete IS 'Deletes a provider. SuperAdmin only. Fails if games/payment_methods exist. Settings are cascade deleted.';
