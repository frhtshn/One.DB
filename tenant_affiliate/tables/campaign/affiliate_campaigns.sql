DROP TABLE IF EXISTS affiliate.affiliate_campaigns CASCADE;

-- Affiliate-Kampanya eşleşmesi
-- Hangi affiliate'in hangi kampanyayı hangi komisyon planıyla çalıştırdığını tutar
CREATE TABLE affiliate.affiliate_campaigns (
    id bigserial PRIMARY KEY,
    affiliate_id bigint NOT NULL,           -- Affiliate referansı
    campaign_id bigint NOT NULL,            -- core.campaigns referansı
    commission_plan_id bigint NOT NULL,     -- Komisyon planı referansı
    start_date date NOT NULL,               -- Başlangıç tarihi
    end_date date,                          -- Bitiş tarihi (NULL = süresiz)
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
