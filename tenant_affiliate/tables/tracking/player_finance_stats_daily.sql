-- =============================================
-- Tablo: tracking.player_finance_stats_daily
-- Açıklama: Oyuncu günlük finansal istatistikleri
-- Deposit/Withdrawal işlemleri ve maliyetleri
-- NGR hesaplamasında finans maliyeti olarak kullanılır
-- =============================================

DROP TABLE IF EXISTS tracking.player_finance_stats_daily CASCADE;

CREATE TABLE tracking.player_finance_stats_daily (
    id bigserial,                              -- Benzersiz kayıt kimliği
    player_id bigint NOT NULL,                             -- Oyuncu ID
    affiliate_id bigint NOT NULL,                          -- O günkü affiliate ID (snapshot)
    stats_date date NOT NULL,                              -- İstatistik tarihi
    currency char(3) NOT NULL,                             -- Oyuncunun para birimi

    -- Depozit Metrikleri
    deposit_count int NOT NULL DEFAULT 0,                  -- Depozit sayısı
    deposit_amount numeric(18,2) NOT NULL DEFAULT 0,       -- Toplam depozit tutarı
    deposit_fee_amount numeric(18,2) NOT NULL DEFAULT 0,   -- Ödeme sağlayıcı komisyonu (PSP fee)
    deposit_processing_cost numeric(18,2) NOT NULL DEFAULT 0, -- İşlem maliyeti

    -- Çekim Metrikleri
    withdrawal_count int NOT NULL DEFAULT 0,               -- Çekim sayısı
    withdrawal_amount numeric(18,2) NOT NULL DEFAULT 0,    -- Toplam çekim tutarı
    withdrawal_fee_amount numeric(18,2) NOT NULL DEFAULT 0, -- Ödeme sağlayıcı komisyonu
    withdrawal_processing_cost numeric(18,2) NOT NULL DEFAULT 0, -- İşlem maliyeti

    -- Toplam Finans Maliyeti (Affiliate'e yansıtılacak)
    total_finance_cost numeric(18,2) NOT NULL DEFAULT 0,   -- deposit_fee + deposit_processing + withdrawal_fee + withdrawal_processing

    -- Ödeme Yöntemi Breakdown
    payment_method_breakdown jsonb,                        -- Yöntem bazlı: [{method, count, amount, fee}, ...]

    -- Meta
    first_transaction_at timestamp without time zone,      -- İlk işlem zamanı
    last_transaction_at timestamp without time zone,       -- Son işlem zamanı
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now(),

    PRIMARY KEY (id, stats_date),                                -- Partition key PK'ya dahil
    CONSTRAINT uq_player_finance_daily UNIQUE (player_id, stats_date)
) PARTITION BY RANGE (stats_date);

CREATE TABLE tracking.player_finance_stats_daily_default PARTITION OF tracking.player_finance_stats_daily DEFAULT;

COMMENT ON TABLE tracking.player_finance_stats_daily IS 'Daily player financial statistics. Partitioned monthly by stats_date. Deposit/withdrawal amounts and processing costs for NGR.';
COMMENT ON COLUMN tracking.player_finance_stats_daily.total_finance_cost IS 'Total payment processing cost to be deducted from GGR for NGR calculation';

-- =============================================
-- Örnek Veri:
--
-- | player_id | stats_date | deposit_amount | deposit_fee | withdrawal_amount | withdrawal_fee | total_finance_cost |
-- |-----------|------------|----------------|-------------|-------------------|----------------|-------------------|
-- | 1001      | 2026-01-15 | 5,000.00       | 150.00      | 0.00              | 0.00           | 150.00            |
-- | 1001      | 2026-01-20 | 0.00           | 0.00        | 2,000.00          | 50.00          | 50.00             |
--
-- payment_method_breakdown örnek:
-- [
--   {"method": "CREDIT_CARD", "deposit_count": 2, "deposit_amount": 3000, "deposit_fee": 90},
--   {"method": "BANK_TRANSFER", "deposit_count": 1, "deposit_amount": 2000, "deposit_fee": 60}
-- ]
-- =============================================
