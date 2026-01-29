-- Core Schema Foreign Key Constraints
-- Using IF NOT EXISTS pattern for idempotent deploys

-- tenants -> companies
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenants_company') THEN
        ALTER TABLE core.tenants ADD CONSTRAINT fk_tenants_company
            FOREIGN KEY (company_id) REFERENCES core.companies(id);
    END IF;
END $$;

-- tenants -> currencies (base_currency)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenants_base_currency') THEN
        ALTER TABLE core.tenants ADD CONSTRAINT fk_tenants_base_currency
            FOREIGN KEY (base_currency) REFERENCES catalog.currencies(currency_code);
    END IF;
END $$;

-- tenants -> languages (default_language)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenants_default_language') THEN
        ALTER TABLE core.tenants ADD CONSTRAINT fk_tenants_default_language
            FOREIGN KEY (default_language) REFERENCES catalog.languages(language_code);
    END IF;
END $$;

-- tenants -> countries (default_country)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenants_default_country') THEN
        ALTER TABLE core.tenants ADD CONSTRAINT fk_tenants_default_country
            FOREIGN KEY (default_country) REFERENCES catalog.countries(country_code);
    END IF;
END $$;

-- tenant_currencies -> tenants
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_currencies_tenant') THEN
        ALTER TABLE core.tenant_currencies ADD CONSTRAINT fk_tenant_currencies_tenant
            FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);
    END IF;
END $$;

-- tenant_currencies -> currencies
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_currencies_currency') THEN
        ALTER TABLE core.tenant_currencies ADD CONSTRAINT fk_tenant_currencies_currency
            FOREIGN KEY (currency_code) REFERENCES catalog.currencies(currency_code);
    END IF;
END $$;

-- tenant_games -> tenants
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_games_tenant') THEN
        ALTER TABLE core.tenant_games ADD CONSTRAINT fk_tenant_games_tenant
            FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);
    END IF;
END $$;

-- tenant_games -> games
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_games_game') THEN
        ALTER TABLE core.tenant_games ADD CONSTRAINT fk_tenant_games_game
            FOREIGN KEY (game_id) REFERENCES catalog.games(id);
    END IF;
END $$;

-- tenant_languages -> tenants
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_languages_tenant') THEN
        ALTER TABLE core.tenant_languages ADD CONSTRAINT fk_tenant_languages_tenant
            FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);
    END IF;
END $$;

-- tenant_languages -> languages
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_languages_language') THEN
        ALTER TABLE core.tenant_languages ADD CONSTRAINT fk_tenant_languages_language
            FOREIGN KEY (language_code) REFERENCES catalog.languages(language_code);
    END IF;
END $$;

-- tenant_providers -> tenants
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_providers_tenant') THEN
        ALTER TABLE core.tenant_providers ADD CONSTRAINT fk_tenant_providers_tenant
            FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);
    END IF;
END $$;

-- tenant_providers -> providers
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_providers_provider') THEN
        ALTER TABLE core.tenant_providers ADD CONSTRAINT fk_tenant_providers_provider
            FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);
    END IF;
END $$;

-- tenant_settings -> tenants
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_settings_tenant') THEN
        ALTER TABLE core.tenant_settings ADD CONSTRAINT fk_tenant_settings_tenant
            FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);
    END IF;
END $$;

-- tenant_payment_methods -> tenants
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_payment_methods_tenant') THEN
        ALTER TABLE core.tenant_payment_methods ADD CONSTRAINT fk_tenant_payment_methods_tenant
            FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);
    END IF;
END $$;

-- tenant_payment_methods -> payment_methods
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_payment_methods_payment_method') THEN
        ALTER TABLE core.tenant_payment_methods ADD CONSTRAINT fk_tenant_payment_methods_payment_method
            FOREIGN KEY (payment_method_id) REFERENCES catalog.payment_methods(id);
    END IF;
END $$;

-- tenant_provider_limits -> tenants
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_provider_limits_tenant') THEN
        ALTER TABLE core.tenant_provider_limits ADD CONSTRAINT fk_tenant_provider_limits_tenant
            FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);
    END IF;
END $$;

-- tenant_provider_limits -> providers
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_provider_limits_provider') THEN
        ALTER TABLE core.tenant_provider_limits ADD CONSTRAINT fk_tenant_provider_limits_provider
            FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);
    END IF;
END $$;

-- tenant_provider_limits -> payment_methods
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_provider_limits_payment_method') THEN
        ALTER TABLE core.tenant_provider_limits ADD CONSTRAINT fk_tenant_provider_limits_payment_method
            FOREIGN KEY (payment_method_id) REFERENCES catalog.payment_methods(id);
    END IF;
END $$;

-- tenant_jurisdictions -> tenants
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_jurisdictions_tenant') THEN
        ALTER TABLE core.tenant_jurisdictions ADD CONSTRAINT fk_tenant_jurisdictions_tenant
            FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);
    END IF;
END $$;

-- tenant_jurisdictions -> jurisdictions
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_jurisdictions_jurisdiction') THEN
        ALTER TABLE core.tenant_jurisdictions ADD CONSTRAINT fk_tenant_jurisdictions_jurisdiction
            FOREIGN KEY (jurisdiction_id) REFERENCES catalog.jurisdictions(id);
    END IF;
END $$;

-- tenant_data_policies -> tenants
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_data_policies_tenant') THEN
        ALTER TABLE core.tenant_data_policies ADD CONSTRAINT fk_tenant_data_policies_tenant
            FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);
    END IF;
END $$;

-- tenant_data_policies -> UNIQUE(tenant_id, data_category)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_tenant_data_policies_category') THEN
        ALTER TABLE core.tenant_data_policies ADD CONSTRAINT uq_tenant_data_policies_category
            UNIQUE (tenant_id, data_category);
    END IF;
END $$;
