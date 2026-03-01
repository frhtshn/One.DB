-- =============================================
-- Transactions (Finansal İşlemler)
-- Tüm para hareketlerinin kaydı
-- Append-only tablo - güncelleme/silme yok
-- =============================================

DROP TABLE IF EXISTS transaction.transactions CASCADE;

CREATE TABLE transaction.transactions (
    id bigserial,

    player_id bigint NOT NULL,                    -- Oyuncu ID
    wallet_id bigint NOT NULL,                    -- Cüzdan ID

    transaction_type_id smallint NOT NULL,        -- İşlem tipi (deposit, withdraw, bet, win vb.)
    operation_type_id   smallint NOT NULL,        -- Operasyon tipi (credit, debit)

    amount numeric(18,8) NOT NULL,                -- İşlem tutarı
    balance_after numeric(18,8) NOT NULL,         -- İşlem sonrası bakiye

    -- İlişki ve Takip
    related_transaction_id bigint,                -- İlişkili işlem (rollback, bonus için)
    bonus_award_id bigint,                        -- Hangi bonus award'dan harcandığı (NULL = bonus işlemi değil)
    idempotency_key varchar(100),                 -- Tekrar eden işlemleri önlemek için
    external_reference_id varchar(100),           -- Dış sistem referans ID (Provider ID vb.)

    -- Kaynak ve Detay
    source varchar(30) NOT NULL,                  -- Kaynak: GAME, PAYMENT, BONUS, ADMIN, MIGRATION
    description varchar(255),                     -- İnsan tarafından okunabilir açıklama
    metadata jsonb,                               -- Ek bilgiler (oyun ID, provider vb.)

    -- Zamanlama
    requested_at timestamptz,                     -- İşlemin talep edildiği zaman (ilk başlama)
    processed_at timestamptz,                     -- İşlemin işlendiği zaman (gateway vs.)
    confirmed_at timestamptz,                     -- İşlemin onaylandığı zaman (tamamlanma)

    -- Kayıt Zamanı
    created_at timestamptz NOT NULL DEFAULT now(), -- DB kayıt zamanı

    PRIMARY KEY (id, created_at)                     -- Partition key PK'ya dahil
) PARTITION BY RANGE (created_at);

CREATE TABLE transaction.transactions_default PARTITION OF transaction.transactions DEFAULT;

COMMENT ON TABLE transaction.transactions IS 'Append-only financial transaction ledger. Partitioned monthly by created_at. All money movements with full audit trail.';
