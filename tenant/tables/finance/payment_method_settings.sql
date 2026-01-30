-- =============================================
-- Tablo: finance.payment_method_settings
-- Açıklama: Tenant ödeme yöntemi ayarları
-- Core DB'den denormalize edilmiş ödeme yöntemi bilgileri + tenant özelleştirmeleri
-- catalog.payment_methods + core.tenant_payment_methods verilerinin tenant kopyası
-- =============================================

DROP TABLE IF EXISTS finance.payment_method_settings CASCADE;

CREATE TABLE finance.payment_method_settings (
    id BIGSERIAL PRIMARY KEY,

    -- Core DB Referansları
    payment_method_id BIGINT NOT NULL,                              -- Core DB'deki ödeme yöntemi ID
    provider_id BIGINT NOT NULL,                                    -- Provider ID (Papara, PayFix vb.)

    -- Denormalize Edilmiş Bilgiler (catalog.payment_methods'dan)
    external_method_id VARCHAR(100),                                -- Provider'ın yöntem ID'si
    payment_method_code VARCHAR(100) NOT NULL,                      -- Normalize edilmiş yöntem kodu
    payment_method_name VARCHAR(255) NOT NULL,                      -- Yöntem görünen adı
    provider_code VARCHAR(50) NOT NULL,                             -- Provider kodu

    -- Kategorilendirme (catalog.payment_methods'dan)
    payment_type VARCHAR(50) NOT NULL,                              -- Ana tip: CARD, EWALLET, BANK, CRYPTO
    payment_subtype VARCHAR(50),                                    -- Alt tip: CREDIT, DEBIT, PREPAID
    channel VARCHAR(50) DEFAULT 'ONLINE',                           -- Kanal: ONLINE, OFFLINE, MOBILE

    -- Görseller (catalog veya tenant override)
    icon_url VARCHAR(500),                                          -- Yöntem ikonu
    logo_url VARCHAR(500),                                          -- Yöntem logosu

    -- İşlem Yönleri (tenant seviyesinde)
    allow_deposit BOOLEAN NOT NULL DEFAULT true,                    -- Para yatırmaya izin ver
    allow_withdrawal BOOLEAN NOT NULL DEFAULT true,                 -- Para çekmeye izin ver
    supports_refund BOOLEAN NOT NULL DEFAULT false,                 -- İade destekler mi

    -- Özellikler (catalog.payment_methods'dan)
    features VARCHAR(50)[] DEFAULT '{}',                            -- Özellikler: INSTANT, RECURRING, TOKENIZATION
    supports_recurring BOOLEAN NOT NULL DEFAULT false,              -- Tekrarlayan ödeme
    supports_tokenization BOOLEAN NOT NULL DEFAULT false,           -- Kart tokenizasyon

    -- Güvenlik Gereksinimleri
    requires_kyc_level SMALLINT DEFAULT 0,                          -- Gereken KYC seviyesi
    requires_3ds BOOLEAN DEFAULT false,                             -- 3D Secure gerekli mi
    requires_verification BOOLEAN DEFAULT false,                    -- İşlem doğrulaması

    -- Platform Desteği
    is_mobile BOOLEAN NOT NULL DEFAULT true,                        -- Mobil uyumlu mu
    is_desktop BOOLEAN NOT NULL DEFAULT true,                       -- Desktop uyumlu mu

    -- Tenant Görünüm Ayarları (core.tenant_payment_methods override)
    display_order INTEGER DEFAULT 0,                                -- Sıralama
    is_visible BOOLEAN NOT NULL DEFAULT true,                       -- Görünür mü
    is_enabled BOOLEAN NOT NULL DEFAULT true,                       -- Aktif mi
    is_featured BOOLEAN NOT NULL DEFAULT false,                     -- Öne çıkarılmış mı

    -- Tenant Özelleştirmeleri
    custom_name VARCHAR(255),                                       -- Özel görünen ad
    custom_icon_url VARCHAR(500),                                   -- Özel ikon URL
    custom_description TEXT,                                        -- Özel açıklama

    -- Platform Kısıtlamaları
    allowed_platforms VARCHAR(20)[] DEFAULT '{WEB,MOBILE,APP}',     -- İzin verilen platformlar

    -- Coğrafi Kısıtlamalar
    blocked_countries CHAR(2)[] DEFAULT '{}',                       -- Engelli ülkeler

    -- Zamanlama
    available_from TIMESTAMP,                                       -- Ne zamandan itibaren mevcut
    available_until TIMESTAMP,                                      -- Ne zamana kadar mevcut

    -- İşlem Süreleri (tenant override edilebilir)
    deposit_processing_time VARCHAR(50),                            -- Para yatırma süresi
    withdrawal_processing_time VARCHAR(50),                         -- Para çekme süresi

    -- Popülerlik (Hesaplanan)
    popularity_score INTEGER DEFAULT 0,                             -- Popülerlik puanı
    usage_count BIGINT DEFAULT 0,                                   -- Toplam kullanım sayısı

    -- Senkronizasyon
    core_synced_at TIMESTAMP,                                       -- Core DB'den son sync tarihi

    -- Audit
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

COMMENT ON TABLE finance.payment_method_settings IS 'Tenant payment method configurations with denormalized data from core, display settings, and platform restrictions';
