-- =============================================
-- Tenant Transaction Schema Foreign Key Constraints
-- =============================================

-- transactions -> players
ALTER TABLE transaction.transactions
    ADD CONSTRAINT fk_transactions_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id);

-- transactions -> wallets
ALTER TABLE transaction.transactions
    ADD CONSTRAINT fk_transactions_wallet
    FOREIGN KEY (wallet_id) REFERENCES wallet.wallets(id);

-- transactions -> transaction_types
ALTER TABLE transaction.transactions
    ADD CONSTRAINT fk_transactions_type
    FOREIGN KEY (transaction_type_id) REFERENCES finance.transaction_types(id);

-- transactions -> operation_types
ALTER TABLE transaction.transactions
    ADD CONSTRAINT fk_transactions_operation
    FOREIGN KEY (operation_type_id) REFERENCES finance.operation_types(id);

-- transactions -> related_transaction (self-reference)
ALTER TABLE transaction.transactions
    ADD CONSTRAINT fk_transactions_related
    FOREIGN KEY (related_transaction_id) REFERENCES transaction.transactions(id);

-- transaction_workflows -> transactions
ALTER TABLE transaction.transaction_workflows
    ADD CONSTRAINT fk_transaction_workflows_transaction
    FOREIGN KEY (transaction_id) REFERENCES transaction.transactions(id) ON DELETE CASCADE;

-- transaction_workflow_actions -> transaction_workflows
ALTER TABLE transaction.transaction_workflow_actions
    ADD CONSTRAINT fk_workflow_actions_workflow
    FOREIGN KEY (workflow_id) REFERENCES transaction.transaction_workflows(id) ON DELETE CASCADE;
