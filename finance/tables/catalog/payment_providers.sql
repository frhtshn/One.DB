-- =============================================
-- Tablo: catalog.payment_providers
-- Açıklama: Payment-type provider referans tablosu
-- Core DB'deki catalog.providers tablosunun
-- PAYMENT tipli alt kümesinin hafif kopyası.
-- Aynı ID'ler kullanılır (BIGINT PK, SERIAL değil).
-- Backend payment_provider_sync ile senkronize edilir.
-- =============================================

DROP TABLE IF EXISTS catalog.payment_providers CASCADE;

CREATE TABLE catalog.payment_providers (
    id BIGINT PRIMARY KEY,                                     -- Core catalog.providers.id ile aynı (SERIAL değil)
    provider_code VARCHAR(50) NOT NULL,                        -- Provider kodu: PAYTR, MPAY, PAPARA
    provider_name VARCHAR(255) NOT NULL,                       -- Görünen ad: PayTR, mPay, Papara
    is_active BOOLEAN NOT NULL DEFAULT true,                   -- Aktif/pasif durumu
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),             -- Oluşturulma zamanı
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()              -- Güncellenme zamanı
);

COMMENT ON TABLE catalog.payment_providers IS 'Lightweight reference of payment-type providers synced from Core DB. Uses same IDs as catalog.providers for cross-DB consistency.';
