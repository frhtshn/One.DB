-- =============================================
-- Tenant Transaction Schema Foreign Key Constraints
-- =============================================
-- NOT: transactions tablosu PARTITION BY RANGE (created_at) ile partitioned.
-- PK artık (id, created_at) composite. Bu nedenle sadece transactions(id)
-- referans alan FK'lar kaldırılmıştır. Bütünlük application-level'da sağlanır.

-- transactions -> players (partitioned tablodan regular tabloya FK = OK)
ALTER TABLE transaction.transactions
    ADD CONSTRAINT fk_transactions_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id);

-- transactions -> wallets (partitioned tablodan regular tabloya FK = OK)
ALTER TABLE transaction.transactions
    ADD CONSTRAINT fk_transactions_wallet
    FOREIGN KEY (wallet_id) REFERENCES wallet.wallets(id);

-- transactions -> transaction_types (partitioned tablodan regular tabloya FK = OK)
ALTER TABLE transaction.transactions
    ADD CONSTRAINT fk_transactions_type
    FOREIGN KEY (transaction_type_id) REFERENCES finance.transaction_types(id);

-- transactions -> operation_types (partitioned tablodan regular tabloya FK = OK)
ALTER TABLE transaction.transactions
    ADD CONSTRAINT fk_transactions_operation
    FOREIGN KEY (operation_type_id) REFERENCES finance.operation_types(id);

-- KALDIRILDI: transactions -> related_transaction (self-reference)
-- Sebep: Partitioned tablolarda self-reference FK, composite PK (id, created_at)
-- gerektirdiğinden doğrudan desteklenmez. İlişkili işlem referansı
-- application-level'da (Dapper/backend) kontrol edilir.
-- ALTER TABLE transaction.transactions
--     ADD CONSTRAINT fk_transactions_related
--     FOREIGN KEY (related_transaction_id) REFERENCES transaction.transactions(id);

-- KALDIRILDI: transaction_workflows -> transactions
-- Sebep: Partitioned tablo PK'sı (id, created_at) olduğundan, sadece (id)
-- üzerinden FK tanımlanamaz. İlişki application-level'da kontrol edilir.
-- ALTER TABLE transaction.transaction_workflows
--     ADD CONSTRAINT fk_transaction_workflows_transaction
--     FOREIGN KEY (transaction_id) REFERENCES transaction.transactions(id) ON DELETE CASCADE;

-- transaction_workflow_actions -> transaction_workflows (regular tabloya FK = OK)
ALTER TABLE transaction.transaction_workflow_actions
    ADD CONSTRAINT fk_workflow_actions_workflow
    FOREIGN KEY (workflow_id) REFERENCES transaction.transaction_workflows(id) ON DELETE CASCADE;
