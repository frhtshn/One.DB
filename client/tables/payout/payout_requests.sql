-- =============================================
-- Tablo: payout.payout_requests
-- Açıklama: Affiliate ödeme talepleri
-- Affiliate tarafından panelden oluşturulan talepler
-- Onay süreci ve ödeme durumu takibi
-- =============================================

DROP TABLE IF EXISTS payout.payout_requests CASCADE;

CREATE TABLE payout.payout_requests (
    id bigserial PRIMARY KEY,                              -- Benzersiz talep kimliği
    affiliate_id bigint NOT NULL,                          -- Affiliate ID (FK: affiliate.affiliates)
    requested_amount numeric(18,2) NOT NULL,               -- Talep edilen tutar
    currency varchar(20) NOT NULL,                          -- Para birimi (Fiat: TRY, Crypto: BTC)
    status smallint NOT NULL,                              -- Durum: 0=Talep, 1=Onaylandı, 2=Reddedildi, 3=Ödendi
    requested_at timestamp without time zone NOT NULL DEFAULT now(), -- Talep zamanı
    processed_at timestamp without time zone               -- İşlem (onay/red) zamanı
);

COMMENT ON TABLE payout.payout_requests IS 'Affiliate payout requests submitted through partner portal with approval workflow';
