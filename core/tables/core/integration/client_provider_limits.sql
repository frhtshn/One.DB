-- =============================================
-- Tablo: core.client_provider_limits
-- Açıklama: Client provider limit tanımları
-- Her client/provider/ödeme yöntemi kombinasyonu için
-- para yatırma ve çekme limitleri
-- decimal(18,8) — crypto hassasiyeti desteği
-- =============================================

DROP TABLE IF EXISTS core.client_provider_limits CASCADE;

CREATE TABLE core.client_provider_limits (
    id bigserial PRIMARY KEY,                              -- Benzersiz limit kimliği
    client_id bigint NOT NULL,                             -- Client ID (FK: core.clients)
    provider_id bigint NOT NULL,                           -- Provider ID (FK: catalog.providers)
    payment_method_id bigint NOT NULL,                     -- Ödeme yöntemi ID (FK: catalog.payment_methods)

    -- Para yatırma limitleri
    min_deposit decimal(18,8),                             -- Minimum para yatırma tutarı
    max_deposit decimal(18,8),                             -- Maksimum para yatırma tutarı

    -- Para çekme limitleri
    min_withdrawal decimal(18,8),                          -- Minimum para çekme tutarı
    max_withdrawal decimal(18,8),                          -- Maksimum para çekme tutarı

    -- Periyodik limitler (opsiyonel)
    daily_deposit_limit decimal(18,8),                     -- Günlük maksimum yatırım tutarı
    daily_withdrawal_limit decimal(18,8),                  -- Günlük maksimum çekim tutarı
    monthly_deposit_limit decimal(18,8),                   -- Aylık maksimum yatırım tutarı
    monthly_withdrawal_limit decimal(18,8),                -- Aylık maksimum çekim tutarı

    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

COMMENT ON TABLE core.client_provider_limits IS 'Client provider limit definitions for deposit and withdrawal limits per provider and payment method combination';
