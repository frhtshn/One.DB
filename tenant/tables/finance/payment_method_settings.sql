-- =============================================
-- Payment Method Settings (Ödeme Yöntemi Ayarları)
-- Tenant'ın kullandığı ödeme yöntemleri
-- Core DB'den denormalize edilmiş + tenant özelleştirmeleri
-- =============================================

DROP TABLE IF EXISTS finance.payment_method_settings CASCADE;

CREATE TABLE finance.payment_method_settings (
    id bigserial PRIMARY KEY,

    -- Core DB'den denormalize edilmiş alanlar (catalog.payment_methods + catalog.providers)
    payment_method_id bigint NOT NULL,            -- Core DB'deki ödeme yöntemi ID
    payment_method_code varchar(100) NOT NULL,    -- Yöntem kodu: bank_transfer, credit_card
    payment_method_name varchar(255) NOT NULL,    -- Yöntem adı
    provider_id bigint NOT NULL,                  -- Provider ID (Papara, PayFix vb.)
    provider_code varchar(50) NOT NULL,           -- Provider kodu

    -- Tenant'a özel görünüm ayarları
    display_order int,                            -- Sıralama
    is_visible boolean NOT NULL DEFAULT true,     -- Görünür mü?
    is_featured boolean NOT NULL DEFAULT false,   -- Öne çıkarılsın mı?

    -- Tenant'a özel özelleştirmeler
    custom_name varchar(255),                     -- Özel isim
    custom_icon_url varchar(500),                 -- Özel ikon URL

    -- Ek metadata
    tags jsonb,                                   -- Etiketler
    metadata jsonb,                               -- Ek bilgiler

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
