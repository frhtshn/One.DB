-- =============================================
-- Tablo: catalog.payment_method_currency_limits
-- Açıklama: Per-method, per-currency limit ve fee bilgileri
-- BO admin tarafından provider dokümantasyonu/paneli/
-- iletişimine dayanarak yönetilir.
-- catalog.payment_methods'deki min_deposit/max_deposit
-- referans olarak kalır, bu tablo detaylı limitleri tutar.
-- Limit hiyerarşisinin en üst katmanı (provider ceiling).
-- =============================================

DROP TABLE IF EXISTS catalog.payment_method_currency_limits CASCADE;

CREATE TABLE catalog.payment_method_currency_limits (
    id BIGSERIAL PRIMARY KEY,                                       -- Benzersiz limit kimliği
    payment_method_id BIGINT NOT NULL,                              -- Ödeme yöntemi ID (FK: catalog.payment_methods)
    currency_code VARCHAR(20) NOT NULL,                             -- Para birimi kodu: TRY, USD, BTC, ETH, DOGE
    currency_type SMALLINT NOT NULL DEFAULT 1,                      -- 1=Fiat, 2=Crypto

    -- Para Yatırma Limitleri
    min_deposit DECIMAL(18,8) NOT NULL,                             -- Minimum para yatırma
    max_deposit DECIMAL(18,8) NOT NULL,                             -- Maksimum para yatırma
    daily_deposit_limit DECIMAL(18,8),                              -- Günlük para yatırma limiti
    monthly_deposit_limit DECIMAL(18,8),                            -- Aylık para yatırma limiti

    -- Para Çekme Limitleri
    min_withdrawal DECIMAL(18,8) NOT NULL,                          -- Minimum para çekme
    max_withdrawal DECIMAL(18,8) NOT NULL,                          -- Maksimum para çekme
    daily_withdrawal_limit DECIMAL(18,8),                           -- Günlük para çekme limiti
    monthly_withdrawal_limit DECIMAL(18,8),                         -- Aylık para çekme limiti

    -- Ücret Yapısı (Para Yatırma)
    deposit_fee_percent DECIMAL(5,4) DEFAULT 0,                     -- Para yatırma yüzdesel komisyon
    deposit_fee_fixed DECIMAL(18,8) DEFAULT 0,                      -- Para yatırma sabit komisyon

    -- Ücret Yapısı (Para Çekme)
    withdrawal_fee_percent DECIMAL(5,4) DEFAULT 0,                  -- Para çekme yüzdesel komisyon
    withdrawal_fee_fixed DECIMAL(18,8) DEFAULT 0,                   -- Para çekme sabit komisyon

    is_active BOOLEAN NOT NULL DEFAULT true,                        -- Soft delete: provider artık desteklemiyorsa false
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                  -- Oluşturulma zamanı
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()                   -- Güncellenme zamanı
);

COMMENT ON TABLE catalog.payment_method_currency_limits IS 'Per-method, per-currency deposit/withdrawal limits and fees. Top layer of the limit hierarchy (provider ceiling). Supports both fiat (currency_type=1) and crypto (currency_type=2).';
