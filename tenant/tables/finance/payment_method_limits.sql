-- =============================================
-- Tablo: finance.payment_method_limits
-- Açıklama: Ödeme yöntemi limitleri
-- Ödeme yöntemi + Currency bazlı işlem limitleri
-- Her yöntem-currency kombinasyonu için ayrı kayıt
-- =============================================

DROP TABLE IF EXISTS finance.payment_method_limits CASCADE;

CREATE TABLE finance.payment_method_limits (
    id BIGSERIAL PRIMARY KEY,

    -- Ödeme yöntemi referansı
    payment_method_id BIGINT NOT NULL,                              -- Core DB'deki ödeme yöntemi ID

    -- Para birimi
    currency_code CHAR(3) NOT NULL,                                 -- Para birimi kodu: TRY, USD, EUR

    -- Para Yatırma Limitleri
    min_deposit DECIMAL(18,8) NOT NULL,                             -- Minimum para yatırma
    max_deposit DECIMAL(18,8) NOT NULL,                             -- Maksimum para yatırma
    daily_deposit_limit DECIMAL(18,8),                              -- Günlük para yatırma limiti
    weekly_deposit_limit DECIMAL(18,8),                             -- Haftalık para yatırma limiti
    monthly_deposit_limit DECIMAL(18,8),                            -- Aylık para yatırma limiti

    -- Para Çekme Limitleri
    min_withdrawal DECIMAL(18,8) NOT NULL,                          -- Minimum para çekme
    max_withdrawal DECIMAL(18,8) NOT NULL,                          -- Maksimum para çekme
    daily_withdrawal_limit DECIMAL(18,8),                           -- Günlük para çekme limiti
    weekly_withdrawal_limit DECIMAL(18,8),                          -- Haftalık para çekme limiti
    monthly_withdrawal_limit DECIMAL(18,8),                         -- Aylık para çekme limiti

    -- Ücret Yapısı (Para Yatırma)
    deposit_fee_percent DECIMAL(5,4) DEFAULT 0,                     -- Para yatırma yüzdesel komisyon
    deposit_fee_fixed DECIMAL(18,8) DEFAULT 0,                      -- Para yatırma sabit komisyon
    deposit_fee_min DECIMAL(18,8),                                  -- Minimum komisyon tutarı
    deposit_fee_max DECIMAL(18,8),                                  -- Maksimum komisyon tutarı

    -- Ücret Yapısı (Para Çekme)
    withdrawal_fee_percent DECIMAL(5,4) DEFAULT 0,                  -- Para çekme yüzdesel komisyon
    withdrawal_fee_fixed DECIMAL(18,8) DEFAULT 0,                   -- Para çekme sabit komisyon
    withdrawal_fee_min DECIMAL(18,8),                               -- Minimum komisyon tutarı
    withdrawal_fee_max DECIMAL(18,8),                               -- Maksimum komisyon tutarı

    -- Audit
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

COMMENT ON TABLE finance.payment_method_limits IS 'Currency-specific limits and fees for each payment method with deposit and withdrawal configurations';
