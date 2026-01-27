-- =============================================
-- Tablo: payout.payouts
-- Açıklama: Affiliate ödeme kayıtları
-- Affiliate'lere yapılan gerçek ödemeler
-- Onaylanan komisyonların ödeme takibi
-- Network affiliate'lere ayrı ayrı ödeme çıkar
-- =============================================

DROP TABLE IF EXISTS payout.payouts CASCADE;

CREATE TABLE payout.payouts (
    id bigserial PRIMARY KEY,                              -- Benzersiz ödeme kimliği
    affiliate_id bigint NOT NULL,                          -- Affiliate ID (FK: affiliate.affiliates)
    payout_request_id bigint,                              -- Talep ID (NULL = otomatik ödeme)
    amount numeric(18,2) NOT NULL,                         -- Ödeme tutarı
    currency char(3) NOT NULL,                             -- Para birimi (TRY, EUR, USD)
    period_start date NOT NULL,                            -- Komisyon dönemi başlangıç
    period_end date NOT NULL,                              -- Komisyon dönemi bitiş
    commission_count int NOT NULL DEFAULT 0,               -- Dahil edilen komisyon sayısı
    direct_amount numeric(18,2) NOT NULL DEFAULT 0,        -- Direkt komisyon tutarı
    network_amount numeric(18,2) NOT NULL DEFAULT 0,       -- Network komisyon tutarı
    payment_method varchar(30),                            -- Ödeme yöntemi: BANK, CRYPTO, EWALLET
    payment_reference varchar(100),                        -- Ödeme referans numarası
    payout_date date,                                      -- Ödeme tarihi
    status smallint NOT NULL DEFAULT 0,                    -- Durum: 0=Beklemede, 1=Onaylandı, 2=İşleniyor, 3=Ödendi, 4=İptal
    processed_by bigint,                                   -- İşlemi yapan kullanıcı ID
    notes text,                                            -- Ödeme notları
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone                 -- Son güncelleme zamanı
);

COMMENT ON TABLE payout.payouts IS 'Affiliate payout records tracking actual payments - each affiliate in network receives separate payment';
COMMENT ON COLUMN payout.payouts.direct_amount IS 'Sum of DIRECT type commissions in this payout';
COMMENT ON COLUMN payout.payouts.network_amount IS 'Sum of NETWORK type commissions from sub-affiliates';

-- =============================================
-- Örnek Network Ödeme Senaryosu:
--
-- Dönem: 2026-01 | NGR: $10,000 | Base Rate: %30
--
-- Player → Affiliate D → Affiliate C → Affiliate B
--
-- Payout #1 (Affiliate D - direkt getiren):
--   direct_amount: $1,800 (10000 * 18%)
--   network_amount: $0
--   amount: $1,800
--
-- Payout #2 (Affiliate C - bir üst):
--   direct_amount: $0
--   network_amount: $600 (10000 * 6%)
--   amount: $600
--
-- Payout #3 (Affiliate B - iki üst):
--   direct_amount: $0
--   network_amount: $360 (10000 * 3.6%)
--   amount: $360
-- =============================================
