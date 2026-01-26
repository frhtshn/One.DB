-- =============================================
-- Transactions (Finansal İşlemler)
-- Tüm para hareketlerinin kaydı
-- Append-only tablo - güncelleme/silme yok
-- =============================================

DROP TABLE IF EXISTS transaction.transactions CASCADE;

CREATE TABLE transaction.transactions (
    id bigserial PRIMARY KEY,

    player_id bigint NOT NULL,                    -- Oyuncu ID
    wallet_id bigint NOT NULL,                    -- Cüzdan ID

    transaction_type_id smallint NOT NULL,        -- İşlem tipi (deposit, withdraw, bet, win vb.)
    operation_type_id   smallint NOT NULL,        -- Operasyon tipi (credit, debit)

    amount numeric(18,8) NOT NULL,                -- İşlem tutarı
    balance_after numeric(18,8) NOT NULL,         -- İşlem sonrası bakiye

    related_transaction_id bigint,                -- İlişkili işlem (rollback, bonus için)
    idempotency_key varchar(100),                 -- Tekrar eden işlemleri önlemek için

    source varchar(30) NOT NULL,                  -- Kaynak: GAME, PAYMENT, BONUS, ADMIN, MIGRATION

    metadata jsonb,                               -- Ek bilgiler (oyun ID, provider vb.)

    created_at timestamptz NOT NULL DEFAULT now() -- İşlem zamanı
);
