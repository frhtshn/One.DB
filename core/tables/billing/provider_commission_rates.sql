-- Provider Komisyon Oranları
-- Her provider için ürün bazlı komisyon oranlarını tanımlar
-- Örnek: Pragmatic oyunları için %12.50 GGR komisyonu

DROP TABLE IF EXISTS billing.provider_commission_rates CASCADE;

CREATE TABLE billing.provider_commission_rates (
    id bigserial PRIMARY KEY,
    product_code varchar(30) NOT NULL,     -- Ürün kodu: GAME, SPORTS, FINANCE
    provider_code varchar(50) NOT NULL,    -- Provider kodu: PRAGMATIC, NETENT, PAYTR
    commission_type varchar(20) NOT NULL,  -- Komisyon tipi: GGR, NGR, TURNOVER
    rate numeric(5,2) NOT NULL,            -- Komisyon oranı: %12.50
    valid_from date NOT NULL,              -- Geçerlilik başlangıç tarihi
    valid_to date,                         -- Geçerlilik bitiş tarihi (NULL = süresiz)
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
