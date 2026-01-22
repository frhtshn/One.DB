DROP TABLE IF EXISTS affiliate.commissions CASCADE;

-- Hesaplanan komisyonlar (Output / Audit)
-- Dönemsel olarak hesaplanan affiliate komisyonları
CREATE TABLE affiliate.commissions (
    id bigserial PRIMARY KEY,
    affiliate_id bigint NOT NULL,           -- Komisyon sahibi affiliate
    source_affiliate_id bigint,             -- Network ise kaynak alt affiliate
    commission_type varchar(20) NOT NULL,   -- DIRECT / NETWORK
    period_start date NOT NULL,             -- Dönem başlangıcı
    period_end date NOT NULL,               -- Dönem bitişi
    amount numeric(18,2) NOT NULL,          -- Komisyon tutarı
    currency char(3) NOT NULL,              -- Para birimi
    status smallint NOT NULL,               -- CALCULATED / APPROVED / PAID
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
