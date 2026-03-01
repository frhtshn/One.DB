-- =============================================
-- Tablo: billing_report.monthly_invoices
-- Açıklama: Ay sonu faturalandırma ve komisyon hesaplama tablosu.
-- Client/Company bazlı net gelir ve kesintileri tutar.
-- =============================================

DROP TABLE IF EXISTS billing_report.monthly_invoices CASCADE;

CREATE TABLE billing_report.monthly_invoices (
    id bigserial,
    period_year int NOT NULL,                              -- Yıl (Örn: 2026)
    period_month int NOT NULL,                             -- Ay (Örn: 1)

    company_id bigint NOT NULL,
    client_id bigint NOT NULL,
    currency varchar(20) NOT NULL,                          -- Para birimi (Fiat: TRY, Crypto: BTC)

    -- Gelir Kalemleri
    gross_revenue numeric(18, 8) DEFAULT 0,                -- Toplam GGR

    -- Gider/Kesinti Kalemleri
    bonus_cost numeric(18, 8) DEFAULT 0,                   -- Bonus maliyeti
    provider_cost numeric(18, 8) DEFAULT 0,                -- Sağlayıcı maliyeti (Rake/Royalty)
    payment_cost numeric(18, 8) DEFAULT 0,                 -- Ödeme sistemi komisyonları
    platform_fee numeric(18, 8) DEFAULT 0,                 -- Platform kullanım Bedeli

    -- Sonuç
    net_revenue numeric(18, 8) DEFAULT 0,                  -- GGR - (Bonus + Costs)
    commission_rate numeric(5, 2) DEFAULT 0,               -- Anlaşılan komisyon oranı (%)
    invoice_amount numeric(18, 8) DEFAULT 0,               -- Kesilecek fatura tutarı

    -- Durum
    status smallint DEFAULT 0,                             -- 0:Draft, 1:Finalized, 2:Invoiced, 3:Paid

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone,

    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE billing_report.monthly_invoices_default PARTITION OF billing_report.monthly_invoices DEFAULT;

COMMENT ON TABLE billing_report.monthly_invoices IS 'Monthly billing and commission summary for clients, partitioned monthly by created_at';
