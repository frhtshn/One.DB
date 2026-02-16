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

-- tenant_currencies unique constraint
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_tenant_currencies') THEN
        ALTER TABLE core.tenant_currencies ADD CONSTRAINT uq_tenant_currencies
            UNIQUE (tenant_id, currency_code);
    END IF;
END $$;

-- tenant_cryptocurrencies -> tenants
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_cryptocurrencies_tenant') THEN
        ALTER TABLE core.tenant_cryptocurrencies ADD CONSTRAINT fk_tenant_cryptocurrencies_tenant
            FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);
    END IF;
END $$;

-- tenant_cryptocurrencies -> cryptocurrencies
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_cryptocurrencies_symbol') THEN
        ALTER TABLE core.tenant_cryptocurrencies ADD CONSTRAINT fk_tenant_cryptocurrencies_symbol
            FOREIGN KEY (symbol) REFERENCES catalog.cryptocurrencies(symbol);
    END IF;
END $$;

-- tenant_cryptocurrencies unique constraint
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_tenant_cryptocurrencies') THEN
        ALTER TABLE core.tenant_cryptocurrencies ADD CONSTRAINT uq_tenant_cryptocurrencies
            UNIQUE (tenant_id, symbol);
    END IF;
END $$;

-- tenant_games -> tenants
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_games_tenant') THEN
        ALTER TABLE core.tenant_games ADD CONSTRAINT fk_tenant_games_tenant
            FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);
    END IF;
END $$;

-- tenant_games unique constraint
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_tenant_games') THEN
        ALTER TABLE core.tenant_games ADD CONSTRAINT uq_tenant_games UNIQUE (tenant_id, game_id);
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

-- tenant_languages unique constraint
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_tenant_languages') THEN
        ALTER TABLE core.tenant_languages ADD CONSTRAINT uq_tenant_languages
            UNIQUE (tenant_id, language_code);
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

-- tenant_providers unique constraint (formal — bir tenant'a aynı provider tekrar atanamaz)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_tenant_providers') THEN
        ALTER TABLE core.tenant_providers ADD CONSTRAINT uq_tenant_providers UNIQUE (tenant_id, provider_id);
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

-- tenant_payment_methods unique constraint
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_tenant_payment_methods') THEN
        ALTER TABLE core.tenant_payment_methods ADD CONSTRAINT uq_tenant_payment_methods UNIQUE (tenant_id, payment_method_id);
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

-- tenant_jurisdictions unique constraint (tenant + jurisdiction combination)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_tenant_jurisdictions') THEN
        ALTER TABLE core.tenant_jurisdictions ADD CONSTRAINT uq_tenant_jurisdictions
            UNIQUE (tenant_id, jurisdiction_id);
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

-- =============================================================================
-- Infrastructure / Provisioning Constraints
-- =============================================================================

-- infrastructure_servers unique server_code
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_infrastructure_servers_code') THEN
        ALTER TABLE core.infrastructure_servers ADD CONSTRAINT uq_infrastructure_servers_code UNIQUE (server_code);
    END IF;
END $$;

-- tenant_servers -> tenants
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_servers_tenant') THEN
        ALTER TABLE core.tenant_servers ADD CONSTRAINT fk_tenant_servers_tenant
            FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);
    END IF;
END $$;

-- tenant_servers -> infrastructure_servers
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_servers_server') THEN
        ALTER TABLE core.tenant_servers ADD CONSTRAINT fk_tenant_servers_server
            FOREIGN KEY (server_id) REFERENCES core.infrastructure_servers(id);
    END IF;
END $$;

-- tenant_servers unique (tenant + server + role)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_tenant_servers_role') THEN
        ALTER TABLE core.tenant_servers ADD CONSTRAINT uq_tenant_servers_role UNIQUE (tenant_id, server_id, server_role);
    END IF;
END $$;

-- tenant_provisioning_log -> tenants
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_provisioning_log_tenant') THEN
        ALTER TABLE core.tenant_provisioning_log ADD CONSTRAINT fk_provisioning_log_tenant
            FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);
    END IF;
END $$;

-- template_dumps unique (db_type + version)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_template_dumps_type_version') THEN
        ALTER TABLE core.template_dumps ADD CONSTRAINT uq_template_dumps_type_version UNIQUE (db_type, version);
    END IF;
END $$;

-- =============================================================================
-- Department Constraints
-- =============================================================================

-- departments -> companies
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_departments_company') THEN
        ALTER TABLE core.departments ADD CONSTRAINT fk_departments_company
            FOREIGN KEY (company_id) REFERENCES core.companies(id);
    END IF;
END $$;

-- departments -> departments (self-referencing hierarchy)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_departments_parent') THEN
        ALTER TABLE core.departments ADD CONSTRAINT fk_departments_parent
            FOREIGN KEY (parent_id) REFERENCES core.departments(id);
    END IF;
END $$;

-- departments unique code per company
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_departments_company_code') THEN
        ALTER TABLE core.departments ADD CONSTRAINT uq_departments_company_code
            UNIQUE (company_id, code);
    END IF;
END $$;

-- user_departments -> users
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_user_departments_user') THEN
        ALTER TABLE core.user_departments ADD CONSTRAINT fk_user_departments_user
            FOREIGN KEY (user_id) REFERENCES security.users(id) ON DELETE CASCADE;
    END IF;
END $$;

-- user_departments -> departments
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_user_departments_department') THEN
        ALTER TABLE core.user_departments ADD CONSTRAINT fk_user_departments_department
            FOREIGN KEY (department_id) REFERENCES core.departments(id) ON DELETE CASCADE;
    END IF;
END $$;

-- user_departments unique (one assignment per user per department)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_user_departments') THEN
        ALTER TABLE core.user_departments ADD CONSTRAINT uq_user_departments
            UNIQUE (user_id, department_id);
    END IF;
END $$;

-- =============================================================================
-- Platform Settings Constraints
-- =============================================================================

-- platform_settings unique (setting_key + environment)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_platform_settings_key_env') THEN
        ALTER TABLE core.platform_settings ADD CONSTRAINT uq_platform_settings_key_env
            UNIQUE (setting_key, environment);
    END IF;
END $$;
