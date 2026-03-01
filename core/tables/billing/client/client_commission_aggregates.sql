-- =============================================
-- Tablo: billing.tenant_commission_aggregates
-- Açıklama: Dönem içi kümülatif GGR/NGR toplamları
-- Worker her işlemde bu tabloyu günceller (upsert)
-- Kademeli komisyon hesaplaması için dönem içi toplam takibi
-- =============================================

DROP TABLE IF EXISTS billing.tenant_commission_aggregates CASCADE;

CREATE TABLE billing.tenant_commission_aggregates (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    tenant_id bigint NOT NULL,                             -- Tenant ID (FK: core.tenants)
    provider_id bigint NOT NULL,                           -- Provider ID (FK: catalog.providers)
    product_code varchar(30) NOT NULL,                     -- Ürün kodu: GAME, SPORTS

    -- Dönem bilgileri
    period_type varchar(10) NOT NULL,                      -- Dönem tipi: MONTHLY, WEEKLY, DAILY
    period_key varchar(20) NOT NULL,                       -- Dönem anahtarı: 2026-01, 2026-W04, 2026-01-26
    period_start date NOT NULL,                            -- Dönem başlangıcı
    period_end date NOT NULL,                              -- Dönem bitişi

    -- Kümülatif metrikler (worker her işlemde günceller)
    total_bet numeric(18,6) NOT NULL DEFAULT 0,            -- Toplam bahis tutarı
    total_win numeric(18,6) NOT NULL DEFAULT 0,            -- Toplam kazanç tutarı
    total_ggr numeric(18,6) NOT NULL DEFAULT 0,            -- Toplam GGR (bet - win)
    total_ngr numeric(18,6) NOT NULL DEFAULT 0,            -- Toplam NGR (GGR - bonus)
    total_turnover numeric(18,6) NOT NULL DEFAULT 0,       -- Toplam ciro
    total_bonus_cost numeric(18,6) NOT NULL DEFAULT 0,     -- Toplam bonus maliyeti

    -- İşlem sayıları
    bet_count bigint NOT NULL DEFAULT 0,                   -- Bahis sayısı
    win_count bigint NOT NULL DEFAULT 0,                   -- Kazanç sayısı
    player_count int NOT NULL DEFAULT 0,                   -- Unique oyuncu sayısı (isteğe bağlı)

    -- Para birimi
    currency character(3) NOT NULL,                        -- Orijinal para birimi

    -- EUR cinsinden toplamlar (kademe hesaplaması için)
    total_ggr_eur numeric(18,6) NOT NULL DEFAULT 0,        -- GGR EUR karşılığı
    total_ngr_eur numeric(18,6) NOT NULL DEFAULT 0,        -- NGR EUR karşılığı
    eur_rate numeric(18,8),                                -- Kullanılan EUR kuru

    -- Worker bilgileri
    last_transaction_id bigint,                            -- Son işlenen transaction ID
    last_calculated_at timestamp without time zone,        -- Son hesaplama zamanı
    calculation_version int NOT NULL DEFAULT 1,            -- Hesaplama versiyonu (tutarsızlık kontrolü)

    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now() -- Son güncelleme zamanı


);

COMMENT ON TABLE billing.tenant_commission_aggregates IS 'Cumulative GGR/NGR totals within billing periods updated by workers for tiered commission calculations';

-- Worker upsert örneği:
-- INSERT INTO billing.tenant_commission_aggregates (...)
-- VALUES (...)
-- ON CONFLICT (tenant_id, provider_id, product_code, period_key, currency)
-- DO UPDATE SET
--   total_bet = tenant_commission_aggregates.total_bet + EXCLUDED.total_bet,
--   total_ggr = tenant_commission_aggregates.total_ggr + EXCLUDED.total_ggr,
--   ...
--   updated_at = now();
