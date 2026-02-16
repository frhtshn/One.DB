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

-- transaction_workflow_actions -> transaction_workflows (regular tabloya FK = OK)
ALTER TABLE transaction.transaction_workflow_actions
    ADD CONSTRAINT fk_workflow_actions_workflow
    FOREIGN KEY (workflow_id) REFERENCES transaction.transaction_workflows(id) ON DELETE CASCADE;
