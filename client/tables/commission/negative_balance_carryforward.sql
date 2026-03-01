-- =============================================
-- Tablo: commission.negative_balance_carryforward
-- Açıklama: Negatif NGR taşıma kayıtları
-- Bir dönemdeki negatif NGR sonraki dönemlere taşınır
-- Pozitif NGR'dan mahsup edilene kadar devam eder
-- =============================================

DROP TABLE IF EXISTS commission.negative_balance_carryforward CASCADE;

CREATE TABLE commission.negative_balance_carryforward (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    affiliate_id bigint NOT NULL,                          -- Affiliate ID
    currency varchar(20) NOT NULL,                          -- Para birimi (Fiat: TRY, Crypto: BTC)

    -- Kaynak Dönem (negatif NGR'ın oluştuğu dönem)
    source_year smallint NOT NULL,                         -- Kaynak yıl
    source_month smallint NOT NULL,                        -- Kaynak ay
    original_negative_amount numeric(18,2) NOT NULL,       -- Orijinal negatif tutar

    -- Kalan Bakiye
    remaining_amount numeric(18,2) NOT NULL,               -- Kalan (mahsup edilmemiş) tutar

    -- Mahsup Geçmişi
    deductions jsonb,                                      -- Mahsup detayları: [{period, amount, date}, ...]
    total_deducted numeric(18,2) NOT NULL DEFAULT 0,       -- Toplam mahsup edilen

    -- Durum
    status smallint NOT NULL DEFAULT 0,                    -- 0=Aktif, 1=Tamamen Mahsup, 2=Süresi Doldu, 3=Affedildi
    expires_at date,                                       -- Taşıma süresi bitiş tarihi
    closed_at timestamp without time zone,                 -- Kapanma zamanı
    closed_reason varchar(50),                             -- Kapanma sebebi: FULLY_DEDUCTED, EXPIRED, FORGIVEN

    -- Meta
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone,

    CONSTRAINT uq_negative_carryforward UNIQUE (affiliate_id, currency, source_year, source_month)
);

COMMENT ON TABLE commission.negative_balance_carryforward IS 'Negative NGR carryforward records - tracks negative balances to be deducted from future positive NGR';

-- =============================================
-- Örnek Senaryo:
--
-- Ocak 2026: NGR = -$500 (oyuncu çok kazandı)
--   → negative_balance_carryforward kaydı oluşur
--   → remaining_amount = $500
--
-- Şubat 2026: NGR = +$800
--   → $500 mahsup edilir
--   → Net komisyon hesaplaması: $800 - $500 = $300 üzerinden
--   → Carryforward kaydı status=1 (Tamamen Mahsup)
--
-- VEYA
--
-- Şubat 2026: NGR = +$200
--   → $200 mahsup edilir
--   → Komisyon = $0 (çünkü hala -$300 kaldı)
--   → remaining_amount = $300 (sonraki aya devir)
--
-- Mart 2026: NGR = +$400
--   → $300 mahsup edilir
--   → Net komisyon: $400 - $300 = $100 üzerinden
--   → Carryforward kaydı kapanır
-- =============================================
