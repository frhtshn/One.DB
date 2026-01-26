-- =============================================
-- Transaction Types (İşlem Tipleri)
-- Finansal işlem kategorileri
-- Deposit, Withdraw, Bet, Win, Bonus vb.
-- =============================================

DROP TABLE IF EXISTS finance.transaction_types CASCADE;

CREATE TABLE finance.transaction_types (
    id              smallserial PRIMARY KEY,
    code            varchar(50) NOT NULL UNIQUE,   -- Tip kodu: DEPOSIT, WITHDRAW, BET, WIN
    category        varchar(30) NOT NULL,          -- Kategori: PAYMENT, GAME, BONUS, ADMIN
    product         varchar(30),                   -- Ürün: CASINO, SPORTS, POKER (opsiyonel)
    is_bonus        boolean NOT NULL,              -- Bonus işlemi mi?
    is_free         boolean NOT NULL,              -- Ücretsiz işlem mi? (free spin vb.)
    is_rollback     boolean NOT NULL,              -- Geri alma işlemi mi?
    is_winning      boolean NOT NULL,              -- Kazanç işlemi mi?
    is_reportable   boolean NOT NULL,              -- Raporlara dahil mi?
    is_active       boolean NOT NULL DEFAULT true  -- Aktif mi?
);

COMMENT ON TABLE finance.transaction_types IS 'Financial transaction type catalog for deposits, withdrawals, bets, wins, bonuses, and adjustments';
