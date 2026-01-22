-- Tenant Komisyonları
-- Hesaplanan komisyon tutarlarının kaydedildiği tablo
-- Dönemsel olarak (aylık/haftalık) hesaplanan GGR/NGR komisyonları

DROP TABLE IF EXISTS billing.tenant_commissions CASCADE;

CREATE TABLE billing.tenant_commissions (
    id bigserial PRIMARY KEY,
    tenant_id bigint NOT NULL,                  -- Tenant ID
    provider_code varchar(50) NOT NULL,         -- Provider kodu
    product_code varchar(30) NOT NULL,          -- Ürün kodu
    commission_type varchar(20) NOT NULL,       -- Komisyon tipi: GGR, NGR, TURNOVER
    base_amount numeric(18,6) NOT NULL,         -- Baz tutar (komisyon hesaplanan miktar)
    rate numeric(5,2) NOT NULL,                 -- Uygulanan komisyon oranı
    commission_amount numeric(18,6) NOT NULL,   -- Hesaplanan komisyon tutarı
    currency character(3) NOT NULL,             -- Para birimi: TRY, EUR, USD
    period_start date NOT NULL,                 -- Dönem başlangıç tarihi
    period_end date NOT NULL,                   -- Dönem bitiş tarihi
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
