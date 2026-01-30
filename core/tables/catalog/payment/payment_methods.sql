-- =============================================
-- Tablo: catalog.payment_methods
-- Açıklama: Ödeme yöntemi kataloğu
-- Her ödeme provider'ının sunduğu ödeme yöntemleri
-- Örnek: PayTR > Kredi Kartı, Papara > Papara Cüzdan
-- Provider API'lerinden senkronize edilir
-- =============================================

DROP TABLE IF EXISTS catalog.payment_methods CASCADE;

CREATE TABLE catalog.payment_methods (
    -- Kimlik
    id BIGSERIAL PRIMARY KEY,                                       -- Dahili benzersiz yöntem kimliği
    provider_id BIGINT NOT NULL,                                    -- Ödeme sağlayıcı ID (FK: catalog.providers)
    external_method_id VARCHAR(100),                                -- Provider'ın kendi yöntem ID'si
    payment_method_code VARCHAR(100) NOT NULL,                      -- Normalize edilmiş yöntem kodu (papara_wallet, credit_card)

    -- Temel Bilgiler
    payment_method_name VARCHAR(255) NOT NULL,                      -- Görünen ad: Kredi Kartı, Papara Cüzdan
    description TEXT,                                               -- Yöntem açıklaması

    -- Kategorilendirme
    payment_type VARCHAR(50) NOT NULL,                              -- Ana tip: CARD, EWALLET, BANK, CRYPTO, MOBILE, VOUCHER
    payment_subtype VARCHAR(50),                                    -- Alt tip: CREDIT, DEBIT, PREPAID, WIRE, INSTANT
    channel VARCHAR(50) DEFAULT 'ONLINE',                           -- Kanal: ONLINE, OFFLINE, MOBILE, POS

    -- Görseller
    icon_url VARCHAR(500),                                          -- Yöntem ikonu
    logo_url VARCHAR(500),                                          -- Yöntem logosu
    banner_url VARCHAR(500),                                        -- Promosyon banner

    -- İşlem Yönleri
    supports_deposit BOOLEAN NOT NULL DEFAULT true,                 -- Para yatırma destekler mi
    supports_withdrawal BOOLEAN NOT NULL DEFAULT true,              -- Para çekme destekler mi
    supports_refund BOOLEAN NOT NULL DEFAULT false,                 -- İade destekler mi

    -- İşlem Limitleri (Provider varsayılanları)
    min_deposit DECIMAL(18,8),                                      -- Minimum para yatırma
    max_deposit DECIMAL(18,8),                                      -- Maksimum para yatırma
    min_withdrawal DECIMAL(18,8),                                   -- Minimum para çekme
    max_withdrawal DECIMAL(18,8),                                   -- Maksimum para çekme

    -- Ücret Yapısı (Provider varsayılanları)
    deposit_fee_percent DECIMAL(5,4),                               -- Para yatırma yüzdesel komisyon
    deposit_fee_fixed DECIMAL(18,8),                                -- Para yatırma sabit komisyon
    withdrawal_fee_percent DECIMAL(5,4),                            -- Para çekme yüzdesel komisyon
    withdrawal_fee_fixed DECIMAL(18,8),                             -- Para çekme sabit komisyon

    -- İşlem Süreleri
    deposit_processing_time VARCHAR(50),                            -- Para yatırma süresi: INSTANT, 1-2_HOURS, 1-3_DAYS
    withdrawal_processing_time VARCHAR(50),                         -- Para çekme süresi: INSTANT, 1-24_HOURS, 1-3_DAYS

    -- Desteklenen Ayarlar
    supported_currencies CHAR(3)[] DEFAULT '{}',                    -- Desteklenen para birimleri
    blocked_countries CHAR(2)[] DEFAULT '{}',                       -- Engelli ülkeler

    -- Güvenlik Gereksinimleri
    requires_kyc_level SMALLINT DEFAULT 0,                          -- Gereken KYC seviyesi (0=yok, 1=basic, 2=verified, 3=full)
    requires_3ds BOOLEAN DEFAULT false,                             -- 3D Secure gerekli mi
    requires_verification BOOLEAN DEFAULT false,                    -- İşlem doğrulaması gerekli mi

    -- Özellikler
    features VARCHAR(50)[] DEFAULT '{}',                            -- Özellikler: INSTANT, RECURRING, TOKENIZATION, APPLE_PAY, GOOGLE_PAY
    supports_recurring BOOLEAN NOT NULL DEFAULT false,              -- Tekrarlayan ödeme destekler mi
    supports_tokenization BOOLEAN NOT NULL DEFAULT false,           -- Kart tokenizasyon destekler mi
    supports_partial_refund BOOLEAN NOT NULL DEFAULT false,         -- Kısmi iade destekler mi

    -- Platform Desteği
    is_mobile BOOLEAN NOT NULL DEFAULT true,                        -- Mobil uyumlu mu
    is_desktop BOOLEAN NOT NULL DEFAULT true,                       -- Desktop uyumlu mu
    is_app BOOLEAN NOT NULL DEFAULT true,                           -- Uygulama içi uyumlu mu

    -- Sıralama ve Popülerlik
    sort_order INTEGER DEFAULT 0,                                   -- Manuel sıralama
    popularity_score INTEGER DEFAULT 0,                             -- Popülerlik puanı

    -- Tarihler
    provider_updated_at TIMESTAMP,                                  -- Provider'dan son güncelleme
    is_active BOOLEAN NOT NULL DEFAULT true,                        -- Aktif/pasif durumu
    created_at TIMESTAMP NOT NULL DEFAULT now(),                    -- Kayıt oluşturma zamanı
    updated_at TIMESTAMP NOT NULL DEFAULT now()                     -- Son güncelleme zamanı
);

COMMENT ON TABLE catalog.payment_methods IS 'Payment method catalog listing available methods per payment provider with limits, fees, and features';
