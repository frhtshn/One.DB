DROP TABLE IF EXISTS affiliate.payouts CASCADE;

-- Ödemeler (Gerçekleşen ödemeler)
-- Affiliate'lere yapılan gerçek ödemeler
CREATE TABLE affiliate.payouts (
    id bigserial PRIMARY KEY,
    affiliate_id bigint NOT NULL,           -- Affiliate referansı
    amount numeric(18,2) NOT NULL,          -- Ödeme tutarı
    currency char(3) NOT NULL,              -- Para birimi
    payout_date date,                       -- Ödeme tarihi
    status smallint NOT NULL,               -- CREATED / PAID
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
