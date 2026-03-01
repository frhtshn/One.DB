-- =============================================
-- Tablo: core.client_payment_methods
-- Açıklama: Client ödeme yöntemi etkinleştirme tablosu
-- Her client'in hangi ödeme yöntemlerini sunacağını belirler
-- Client DB'deki finance.payment_method_settings ile senkronize edilir
-- Denormalize alanlar: BO listesinde cross-DB JOIN yerine
-- doğrudan gösterilir (backend seed/sync sırasında doldurur)
-- payment_method_id FK yok — catalog.payment_methods Finance DB'de (cross-DB)
-- =============================================

DROP TABLE IF EXISTS core.client_payment_methods CASCADE;

CREATE TABLE core.client_payment_methods (
    id BIGSERIAL PRIMARY KEY,                                       -- Benzersiz kayıt kimliği
    client_id BIGINT NOT NULL,                                      -- Client ID (FK: core.clients)
    payment_method_id BIGINT NOT NULL,                              -- Ödeme yöntemi ID (Finance DB — FK yok, cross-DB, backend doğrular)

    -- Denormalize Alanlar (Finance DB'den — cross-DB JOIN yerine BO listesinde gösterilir)
    payment_method_name VARCHAR(255),                               -- Görünen ad: Kredi Kartı, Papara Cüzdan
    payment_method_code VARCHAR(100),                               -- Normalize edilmiş yöntem kodu (papara_wallet)
    provider_code VARCHAR(50),                                      -- Provider kodu (PAYTR, MPAY, PAPARA)
    payment_type VARCHAR(50),                                       -- Ana tip: CARD, EWALLET, BANK, CRYPTO
    icon_url VARCHAR(500),                                          -- Yöntem ikonu

    -- Etkinleştirme Durumu
    is_enabled BOOLEAN NOT NULL DEFAULT true,                       -- Yöntem aktif mi
    enabled_at TIMESTAMP,                                           -- Aktifleştirme tarihi
    disabled_at TIMESTAMP,                                          -- Pasifleştirme tarihi
    disabled_reason VARCHAR(255),                                   -- Pasifleştirme nedeni

    -- Görünürlük Ayarları
    is_visible BOOLEAN NOT NULL DEFAULT true,                       -- Görünür mü
    is_featured BOOLEAN NOT NULL DEFAULT false,                     -- Öne çıkarılmış mı
    display_order INTEGER DEFAULT 0,                                -- Sıralama

    -- Client Özelleştirmeleri
    custom_name VARCHAR(255),                                       -- Özel görünen ad
    custom_icon_url VARCHAR(500),                                   -- Özel ikon URL
    custom_description TEXT,                                        -- Özel açıklama

    -- İşlem Yönleri Override
    allow_deposit BOOLEAN DEFAULT true,                             -- Para yatırmaya izin ver
    allow_withdrawal BOOLEAN DEFAULT true,                          -- Para çekmeye izin ver

    -- Limit Override (Client seviyesinde)
    override_min_deposit DECIMAL(18,8),                             -- Override min para yatırma
    override_max_deposit DECIMAL(18,8),                             -- Override max para yatırma
    override_min_withdrawal DECIMAL(18,8),                          -- Override min para çekme
    override_max_withdrawal DECIMAL(18,8),                          -- Override max para çekme
    override_daily_deposit_limit DECIMAL(18,8),                     -- Günlük para yatırma limiti
    override_daily_withdrawal_limit DECIMAL(18,8),                  -- Günlük para çekme limiti

    -- Ücret Override (Client seviyesinde)
    override_deposit_fee_percent DECIMAL(5,4),                      -- Override para yatırma komisyon %
    override_deposit_fee_fixed DECIMAL(18,8),                       -- Override para yatırma sabit komisyon
    override_withdrawal_fee_percent DECIMAL(5,4),                   -- Override para çekme komisyon %
    override_withdrawal_fee_fixed DECIMAL(18,8),                    -- Override para çekme sabit komisyon

    -- Güvenlik Override
    override_kyc_level SMALLINT,                                    -- Override KYC seviyesi

    -- Platform Kısıtlamaları
    allowed_platforms VARCHAR(20)[] DEFAULT '{web,mobile,app}',     -- İzin verilen platformlar

    -- Coğrafi Kısıtlamalar
    blocked_countries CHAR(2)[] DEFAULT '{}',                       -- Engelli ülkeler
    allowed_countries CHAR(2)[] DEFAULT '{}',                       -- Sadece izin verilen ülkeler

    -- Zamanlama
    available_from TIMESTAMP,                                       -- Ne zamandan itibaren mevcut
    available_until TIMESTAMP,                                      -- Ne zamana kadar mevcut

    -- Senkronizasyon
    sync_status VARCHAR(20) DEFAULT 'pending',                      -- Client DB senkronizasyon durumu
    last_synced_at TIMESTAMP,                                       -- Son senkronizasyon tarihi

    -- Audit
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now(),
    created_by BIGINT,                                              -- Oluşturan kullanıcı
    updated_by BIGINT                                               -- Güncelleyen kullanıcı
);

COMMENT ON TABLE core.client_payment_methods IS 'Client payment method enablement with limit/fee overrides. Denormalized fields from Finance DB catalog for cross-DB BO listing without JOINs. payment_method_id has no FK (cross-DB, backend validates).';
