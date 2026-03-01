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

-- crypto_rates unique constraint (dedup: aynı provider+base+symbol+timestamp atla)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_crypto_rates_lookup') THEN
        ALTER TABLE finance.crypto_rates ADD CONSTRAINT uq_crypto_rates_lookup
            UNIQUE (provider, base_currency, symbol, rate_timestamp);
    END IF;
END $$;

-- payment_player_limits unique constraint (per-currency — fiat/crypto ayrı limitler)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_payment_player_limits_player_method_currency') THEN
        ALTER TABLE finance.payment_player_limits ADD CONSTRAINT uq_payment_player_limits_player_method_currency UNIQUE (player_id, payment_method_id, currency_code);
    END IF;
END $$;

-- player_financial_limits unique constraint (per-currency, per-type — self_imposed ve admin_imposed ayrı)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_player_financial_limits_player_currency_type') THEN
        ALTER TABLE finance.player_financial_limits ADD CONSTRAINT uq_player_financial_limits_player_currency_type UNIQUE (player_id, currency_code, limit_type);
    END IF;
END $$;
