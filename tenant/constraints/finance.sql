-- =============================================
-- Tenant Finance Schema Constraints
-- =============================================

-- payment_method_settings unique constraint
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_payment_method_settings_method') THEN
        ALTER TABLE finance.payment_method_settings ADD CONSTRAINT uq_payment_method_settings_method UNIQUE (payment_method_id);
    END IF;
END $$;

-- payment_method_limits unique constraint
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_payment_method_limits_method_currency') THEN
        ALTER TABLE finance.payment_method_limits ADD CONSTRAINT uq_payment_method_limits_method_currency UNIQUE (payment_method_id, currency_code);
    END IF;
END $$;

-- payment_method_limits -> payment_method_settings (FK)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_payment_method_limits_method') THEN
        ALTER TABLE finance.payment_method_limits ADD CONSTRAINT fk_payment_method_limits_method
            FOREIGN KEY (payment_method_id) REFERENCES finance.payment_method_settings(payment_method_id) ON DELETE CASCADE;
    END IF;
END $$;

-- payment_player_limits unique constraint
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_payment_player_limits_player_method') THEN
        ALTER TABLE finance.payment_player_limits ADD CONSTRAINT uq_payment_player_limits_player_method UNIQUE (player_id, payment_method_id);
    END IF;
END $$;
