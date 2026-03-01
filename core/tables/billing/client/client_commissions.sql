-- =============================================
-- Tablo: billing.client_commissions
-- Açıklama: Hesaplanan client komisyonları
-- Worker tarafından upsert ile güncellenir
-- Anlık veya dönemsel hesaplama destekler
-- Kademeli komisyon için tier bazında ayrı satırlar
-- =============================================

DROP TABLE IF EXISTS billing.client_commissions CASCADE;

CREATE TABLE billing.client_commissions (
    id bigserial PRIMARY KEY,                              -- Benzersiz komisyon kimliği
    client_id bigint NOT NULL,                             -- Client ID (FK: core.clients)
    provider_id bigint NOT NULL,                           -- Provider ID (FK: catalog.providers)
    product_code varchar(30) NOT NULL,                     -- Ürün kodu: GAME, SPORTS, PAYMENT
    commission_type varchar(20) NOT NULL,                  -- Komisyon tipi: GGR, NGR, TURNOVER

    -- Dönem bilgileri
    period_type varchar(10) NOT NULL,                      -- Dönem tipi: MONTHLY, WEEKLY, DAILY
    period_key varchar(20) NOT NULL,                       -- Dönem anahtarı: 2026-01, 2026-W04
    period_start date NOT NULL,                            -- Dönem başlangıcı
    period_end date NOT NULL,                              -- Dönem bitişi

    -- Kademe bilgisi (tiered için)
    tier_order smallint NOT NULL DEFAULT 0,                -- Kademe sırası (0 = flat rate)
    tier_from numeric(18,2) NOT NULL DEFAULT 0,            -- Kademe alt limiti
    tier_to numeric(18,2),                                 -- Kademe üst limiti (NULL = sınırsız)

    -- Hesaplama detayları
    base_amount numeric(18,6) NOT NULL,                    -- Bu kademeye düşen baz tutar
    rate numeric(5,2) NOT NULL,                            -- Uygulanan komisyon oranı (%)
    commission_amount numeric(18,6) NOT NULL,              -- Hesaplanan komisyon tutarı
    currency character(3) NOT NULL,                        -- Para birimi: TRY, EUR, USD

    -- EUR cinsinden (raporlama için)
    base_amount_eur numeric(18,6),                         -- Baz tutar EUR karşılığı
    commission_amount_eur numeric(18,6),                   -- Komisyon EUR karşılığı
    eur_rate numeric(18,8),                                -- Kullanılan EUR kuru

    -- Kaynak bilgisi
    aggregate_id bigint,                                   -- Aggregate kaydı ID (FK: billing.client_commission_aggregates)
    commission_plan_source varchar(20) NOT NULL,           -- Kaynak: PROVIDER_DEFAULT, CLIENT_CUSTOM
    commission_plan_id bigint,                             -- Kullanılan plan ID

    -- Durum ve onay süreci
    status smallint NOT NULL DEFAULT 0,                    -- 0=Hesaplandı, 1=Onaylandı, 2=Faturaya Eklendi
    approved_by bigint,                                    -- Onaylayan kullanıcı ID (FK: security.users)
    approved_at timestamp without time zone,               -- Onay zamanı

    -- Fatura ilişkisi
    invoice_id bigint,                                     -- Fatura ID (FK: billing.invoices)
    invoice_item_id bigint,                                -- Fatura kalemi ID (FK: billing.invoice_items)

    -- Worker bilgileri
    calculated_at timestamp without time zone NOT NULL DEFAULT now(), -- Hesaplama zamanı
    calculation_version int NOT NULL DEFAULT 1,            -- Hesaplama versiyonu

    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now() -- Son güncelleme zamanı


);

COMMENT ON TABLE billing.client_commissions IS 'Calculated client commissions with tier-based breakdowns updated by workers for real-time or periodic billing';

-- Worker upsert örneği:
-- Her kademe için ayrı satır:
-- Kademe 1 (0-200K): base_amount=200000, rate=20, commission=40000
-- Kademe 2 (200K-400K): base_amount=150000, rate=18, commission=27000
-- Toplam GGR=350K, Toplam Komisyon=67000
