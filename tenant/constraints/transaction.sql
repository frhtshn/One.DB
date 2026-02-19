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

-- =============================================
-- Payment Sessions Constraints
-- =============================================

-- payment_sessions -> players
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_payment_sessions_player') THEN
        ALTER TABLE transaction.payment_sessions
            ADD CONSTRAINT fk_payment_sessions_player
            FOREIGN KEY (player_id) REFERENCES auth.players(id);
    END IF;
END $$;

-- payment_sessions -> payment_method_settings (ödeme yöntemi referansı, opsiyonel)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_payment_sessions_payment_method') THEN
        ALTER TABLE transaction.payment_sessions
            ADD CONSTRAINT fk_payment_sessions_payment_method
            FOREIGN KEY (payment_method_id) REFERENCES finance.payment_method_settings(id);
    END IF;
END $$;

-- payment_sessions — oturum tipi kontrolü
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_payment_sessions_type') THEN
        ALTER TABLE transaction.payment_sessions
            ADD CONSTRAINT chk_payment_sessions_type
            CHECK (session_type IN ('DEPOSIT', 'WITHDRAWAL'));
    END IF;
END $$;

-- payment_sessions — durum kontrolü
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_payment_sessions_status') THEN
        ALTER TABLE transaction.payment_sessions
            ADD CONSTRAINT chk_payment_sessions_status
            CHECK (status IN ('created', 'processing', 'redirected', 'pending_approval', 'completed', 'failed', 'cancelled', 'expired', 'rejected'));
    END IF;
END $$;

-- =============================================
-- Transaction Adjustments Constraints
-- =============================================

-- transaction_adjustments -> players
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tx_adjustments_player') THEN
        ALTER TABLE transaction.transaction_adjustments
            ADD CONSTRAINT fk_tx_adjustments_player
            FOREIGN KEY (player_id) REFERENCES auth.players(id);
    END IF;
END $$;

-- transaction_adjustments -> transaction_workflows
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tx_adjustments_workflow') THEN
        ALTER TABLE transaction.transaction_adjustments
            ADD CONSTRAINT fk_tx_adjustments_workflow
            FOREIGN KEY (workflow_id) REFERENCES transaction.transaction_workflows(id);
    END IF;
END $$;

-- transaction_adjustments — wallet type kontrolü
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_tx_adjustments_wallet_type') THEN
        ALTER TABLE transaction.transaction_adjustments
            ADD CONSTRAINT chk_tx_adjustments_wallet_type
            CHECK (wallet_type IN ('REAL', 'BONUS'));
    END IF;
END $$;

-- transaction_adjustments — direction kontrolü
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_tx_adjustments_direction') THEN
        ALTER TABLE transaction.transaction_adjustments
            ADD CONSTRAINT chk_tx_adjustments_direction
            CHECK (direction IN ('CREDIT', 'DEBIT'));
    END IF;
END $$;

-- transaction_adjustments — adjustment type kontrolü
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_tx_adjustments_type') THEN
        ALTER TABLE transaction.transaction_adjustments
            ADD CONSTRAINT chk_tx_adjustments_type
            CHECK (adjustment_type IN ('GAME_CORRECTION', 'BONUS_CORRECTION', 'FRAUD', 'MANUAL'));
    END IF;
END $$;

-- transaction_adjustments — status kontrolü
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_tx_adjustments_status') THEN
        ALTER TABLE transaction.transaction_adjustments
            ADD CONSTRAINT chk_tx_adjustments_status
            CHECK (status IN ('PENDING', 'APPLIED', 'CANCELLED'));
    END IF;
END $$;
