-- =============================================
-- Tablo: billing.monthly_invoices
-- Açıklama: Ay sonu faturalandırma ve komisyon hesaplama tablosu.
-- Tenant/Company bazlı net gelir ve kesintileri tutar.
-- =============================================

DROP TABLE IF EXISTS billing.monthly_invoices CASCADE;

CREATE TABLE billing.monthly_invoices (
    id bigserial PRIMARY KEY,
    period_year int NOT NULL,                              -- Yıl (Örn: 2026)
    period_month int NOT NULL,                             -- Ay (Örn: 1)

    tenant_id bigint NOT NULL,
    company_id bigint NOT NULL,
    currency char(3) NOT NULL,

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
    updated_at timestamp without time zone
);

COMMENT ON TABLE billing.monthly_invoices IS 'Monthly billing and commission summary for tenants';
