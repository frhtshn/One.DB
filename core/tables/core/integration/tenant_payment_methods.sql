-- =============================================
-- Tablo: core.tenant_payment_methods
-- Açıklama: Tenant ödeme yöntemi etkinleştirme tablosu
-- Her tenant'in hangi ödeme yöntemlerini sunacağını belirler
-- Tenant DB'deki finance.payment_method_settings ile senkronize edilir
-- =============================================

DROP TABLE IF EXISTS core.tenant_payment_methods CASCADE;

CREATE TABLE core.tenant_payment_methods (
    id BIGSERIAL PRIMARY KEY,                                       -- Benzersiz kayıt kimliği
    tenant_id BIGINT NOT NULL,                                      -- Tenant ID (FK: core.tenants)
    payment_method_id BIGINT NOT NULL,                              -- Ödeme yöntemi ID (FK: catalog.payment_methods)

    -- Etkinleştirme Durumu
    is_enabled BOOLEAN NOT NULL DEFAULT true,                       -- Yöntem aktif mi
    enabled_at TIMESTAMP,                                           -- Aktifleştirme tarihi
    disabled_at TIMESTAMP,                                          -- Pasifleştirme tarihi
    disabled_reason VARCHAR(255),                                   -- Pasifleştirme nedeni

    -- Görünürlük Ayarları
    is_visible BOOLEAN NOT NULL DEFAULT true,                       -- Görünür mü
    is_featured BOOLEAN NOT NULL DEFAULT false,                     -- Öne çıkarılmış mı
    display_order INTEGER DEFAULT 0,                                -- Sıralama

    -- Tenant Özelleştirmeleri
    custom_name VARCHAR(255),                                       -- Özel görünen ad
    custom_icon_url VARCHAR(500),                                   -- Özel ikon URL
    custom_description TEXT,                                        -- Özel açıklama

    -- İşlem Yönleri Override
    allow_deposit BOOLEAN DEFAULT true,                             -- Para yatırmaya izin ver
    allow_withdrawal BOOLEAN DEFAULT true,                          -- Para çekmeye izin ver

    -- Limit Override (Tenant seviyesinde)
    override_min_deposit DECIMAL(18,8),                             -- Override min para yatırma
    override_max_deposit DECIMAL(18,8),                             -- Override max para yatırma
    override_min_withdrawal DECIMAL(18,8),                          -- Override min para çekme
    override_max_withdrawal DECIMAL(18,8),                          -- Override max para çekme
    override_daily_deposit_limit DECIMAL(18,8),                     -- Günlük para yatırma limiti
    override_daily_withdrawal_limit DECIMAL(18,8),                  -- Günlük para çekme limiti

    -- Ücret Override (Tenant seviyesinde)
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
    sync_status VARCHAR(20) DEFAULT 'pending',                      -- Tenant DB senkronizasyon durumu
    last_synced_at TIMESTAMP,                                       -- Son senkronizasyon tarihi

    -- Audit
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now(),
    created_by BIGINT,                                              -- Oluşturan kullanıcı
    updated_by BIGINT                                               -- Güncelleyen kullanıcı
);

COMMENT ON TABLE core.tenant_payment_methods IS 'Tenant payment method enablement with limit/fee overrides and visibility settings';
