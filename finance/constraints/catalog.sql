-- Catalog Schema Foreign Key Constraints (Finance DB)
-- Using IF NOT EXISTS pattern for idempotent deploys

-- payment_providers unique constraint (provider_code)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_payment_providers_code') THEN
        ALTER TABLE catalog.payment_providers ADD CONSTRAINT uq_payment_providers_code UNIQUE (provider_code);
    END IF;
END $$;

-- payment_methods -> payment_providers
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_payment_methods_provider') THEN
        ALTER TABLE catalog.payment_methods ADD CONSTRAINT fk_payment_methods_provider
            FOREIGN KEY (provider_id) REFERENCES catalog.payment_providers(id);
    END IF;
END $$;

-- payment_methods unique constraint (provider + payment_method_code)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_payment_methods_provider_code') THEN
        ALTER TABLE catalog.payment_methods ADD CONSTRAINT uq_payment_methods_provider_code UNIQUE (provider_id, payment_method_code);
    END IF;
END $$;

-- payment_method_currency_limits -> payment_methods (CASCADE: yöntem silinince limitler de silinir)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_pm_currency_limits_method') THEN
        ALTER TABLE catalog.payment_method_currency_limits ADD CONSTRAINT fk_pm_currency_limits_method
            FOREIGN KEY (payment_method_id) REFERENCES catalog.payment_methods(id) ON DELETE CASCADE;
    END IF;
END $$;

-- payment_method_currency_limits unique constraint (method + currency)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_pm_currency_limits') THEN
        ALTER TABLE catalog.payment_method_currency_limits ADD CONSTRAINT uq_pm_currency_limits UNIQUE (payment_method_id, currency_code);
    END IF;
END $$;
