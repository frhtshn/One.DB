DROP TABLE IF EXISTS affiliate.payout_requests CASCADE;

-- Ödeme talepleri (Affiliate Panel)
-- Affiliate'lerin yaptığı para çekme talepleri
CREATE TABLE affiliate.payout_requests (
    id bigserial PRIMARY KEY,
    affiliate_id bigint NOT NULL,           -- Affiliate referansı
    requested_amount numeric(18,2) NOT NULL, -- Talep edilen tutar
    currency char(3) NOT NULL,              -- Para birimi
    status smallint NOT NULL,               -- REQUESTED / APPROVED / REJECTED / PAID
    requested_at timestamp without time zone NOT NULL DEFAULT now(),  -- Talep zamanı
    processed_at timestamp without time zone  -- İşlem zamanı
);
