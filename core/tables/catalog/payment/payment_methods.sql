-- =============================================
-- Tablo: catalog.payment_methods
-- Açıklama: Ödeme yöntemi kataloğu
-- Her ödeme provider'ının sunduğu ödeme yöntemleri
-- Örnek: PayTR > Kredi Kartı, Papara > Papara Cüzdan
-- =============================================

DROP TABLE IF EXISTS catalog.payment_methods CASCADE;

CREATE TABLE catalog.payment_methods (
    id bigserial PRIMARY KEY,                              -- Benzersiz yöntem kimliği
    provider_id bigint NOT NULL,                           -- Ödeme sağlayıcı ID (FK: catalog.providers)
    payment_method_code varchar(100) NOT NULL,             -- Yöntem kodu: CREDIT_CARD, PAPARA, BANK_TRANSFER
    payment_method_name varchar(255) NOT NULL,             -- Görünen ad: Kredi Kartı, Papara Cüzdan
    payment_type varchar(50),                              -- Tip: CARD, EWALLET, BANK, CRYPTO
    is_active boolean NOT NULL DEFAULT true,               -- Aktif/pasif durumu
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

COMMENT ON TABLE catalog.payment_methods IS 'Payment method catalog listing available methods per payment provider such as credit card, e-wallet, bank transfer';
