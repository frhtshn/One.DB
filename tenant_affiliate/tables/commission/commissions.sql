-- =============================================
-- Tablo: commission.commissions
-- Açıklama: Hesaplanan affiliate komisyonları
-- Dönemsel olarak hesaplanan komisyon kayıtları
-- Audit ve ödeme takibi için kullanılır
-- =============================================

DROP TABLE IF EXISTS commission.commissions CASCADE;

CREATE TABLE commission.commissions (
    id bigserial PRIMARY KEY,                              -- Benzersiz komisyon kimliği
    affiliate_id bigint NOT NULL,                          -- Komisyon sahibi affiliate ID
    source_affiliate_id bigint,                            -- Network ise kaynak alt affiliate ID
    commission_type varchar(20) NOT NULL,                  -- Komisyon tipi: DIRECT, NETWORK
    period_start date NOT NULL,                            -- Dönem başlangıç tarihi
    period_end date NOT NULL,                              -- Dönem bitiş tarihi
    amount numeric(18,2) NOT NULL,                         -- Komisyon tutarı
    currency char(3) NOT NULL,                             -- Para birimi (TRY, EUR, USD)
    status smallint NOT NULL,                              -- Durum: 0=Hesaplandı, 1=Onaylandı, 2=Ödendi
    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);
