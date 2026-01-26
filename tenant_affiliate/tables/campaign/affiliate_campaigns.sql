-- =============================================
-- Tablo: affiliate.affiliate_campaigns
-- Açıklama: Affiliate-kampanya eşleştirmesi
-- Hangi affiliate'in hangi kampanyayı çalıştırdığını tutar
-- Komisyon planı ilişkilendirmesi de burada yapılır
-- =============================================

DROP TABLE IF EXISTS affiliate.affiliate_campaigns CASCADE;

CREATE TABLE affiliate.affiliate_campaigns (
    id bigserial PRIMARY KEY,                              -- Benzersiz eşleşme kimliği
    affiliate_id bigint NOT NULL,                          -- Affiliate ID (FK: affiliate.affiliates)
    campaign_id bigint NOT NULL,                           -- Kampanya ID (FK: campaign.campaigns)
    commission_plan_id bigint NOT NULL,                    -- Komisyon planı ID (FK: commission.commission_plans)
    start_date date NOT NULL,                              -- Eşleşme başlangıç tarihi
    end_date date,                                         -- Eşleşme bitiş tarihi (NULL = süresiz)
    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);
