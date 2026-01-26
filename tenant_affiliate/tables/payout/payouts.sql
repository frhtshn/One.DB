-- =============================================
-- Tablo: payout.payouts
-- Açıklama: Affiliate ödeme kayıtları
-- Affiliate'lere yapılan gerçek ödemeler
-- Onaylanan komisyonların ödeme takibi
-- =============================================

DROP TABLE IF EXISTS payout.payouts CASCADE;

CREATE TABLE payout.payouts (
    id bigserial PRIMARY KEY,                              -- Benzersiz ödeme kimliği
    affiliate_id bigint NOT NULL,                          -- Affiliate ID (FK: affiliate.affiliates)
    amount numeric(18,2) NOT NULL,                         -- Ödeme tutarı
    currency char(3) NOT NULL,                             -- Para birimi (TRY, EUR, USD)
    payout_date date,                                      -- Ödeme tarihi
    status smallint NOT NULL,                              -- Durum: 0=Oluşturuldu, 1=Ödendi
    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);

COMMENT ON TABLE payout.payouts IS 'Affiliate payout records tracking actual payments made for approved commissions';
