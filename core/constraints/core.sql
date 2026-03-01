-- Core Schema Foreign Key Constraints
-- Using IF NOT EXISTS pattern for idempotent deploys

-- clients -> companies
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_clients_company') THEN
        ALTER TABLE core.clients ADD CONSTRAINT fk_clients_company
            FOREIGN KEY (company_id) REFERENCES core.companies(id);
    END IF;
END $$;

-- clients -> currencies (base_currency)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_clients_base_currency') THEN
        ALTER TABLE core.clients ADD CONSTRAINT fk_clients_base_currency
            FOREIGN KEY (base_currency) REFERENCES catalog.currencies(currency_code);
    END IF;
END $$;

-- clients -> languages (default_language)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_clients_default_language') THEN
        ALTER TABLE core.clients ADD CONSTRAINT fk_clients_default_language
            FOREIGN KEY (default_language) REFERENCES catalog.languages(language_code);
    END IF;
END $$;

-- clients -> countries (default_country)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_clients_default_country') THEN
        ALTER TABLE core.clients ADD CONSTRAINT fk_clients_default_country
            FOREIGN KEY (default_country) REFERENCES catalog.countries(country_code);
    END IF;
END $$;

-- client_currencies -> clients
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_currencies_client') THEN
        ALTER TABLE core.client_currencies ADD CONSTRAINT fk_client_currencies_client
            FOREIGN KEY (client_id) REFERENCES core.clients(id);
    END IF;
END $$;

-- client_currencies -> currencies
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_currencies_currency') THEN
        ALTER TABLE core.client_currencies ADD CONSTRAINT fk_client_currencies_currency
            FOREIGN KEY (currency_code) REFERENCES catalog.currencies(currency_code);
    END IF;
END $$;

-- client_currencies unique constraint
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_client_currencies') THEN
        ALTER TABLE core.client_currencies ADD CONSTRAINT uq_client_currencies
            UNIQUE (client_id, currency_code);
    END IF;
END $$;

-- client_cryptocurrencies -> clients
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_cryptocurrencies_client') THEN
        ALTER TABLE core.client_cryptocurrencies ADD CONSTRAINT fk_client_cryptocurrencies_client
            FOREIGN KEY (client_id) REFERENCES core.clients(id);
    END IF;
END $$;

-- client_cryptocurrencies -> cryptocurrencies
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_cryptocurrencies_symbol') THEN
        ALTER TABLE core.client_cryptocurrencies ADD CONSTRAINT fk_client_cryptocurrencies_symbol
            FOREIGN KEY (symbol) REFERENCES catalog.cryptocurrencies(symbol);
    END IF;
END $$;

-- client_cryptocurrencies unique constraint
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_client_cryptocurrencies') THEN
        ALTER TABLE core.client_cryptocurrencies ADD CONSTRAINT uq_client_cryptocurrencies
            UNIQUE (client_id, symbol);
    END IF;
END $$;

-- client_games -> clients
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_games_client') THEN
        ALTER TABLE core.client_games ADD CONSTRAINT fk_client_games_client
            FOREIGN KEY (client_id) REFERENCES core.clients(id);
    END IF;
END $$;

-- client_games unique constraint
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_client_games') THEN
        ALTER TABLE core.client_games ADD CONSTRAINT uq_client_games UNIQUE (client_id, game_id);
    END IF;
END $$;

-- client_languages -> clients
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_languages_client') THEN
        ALTER TABLE core.client_languages ADD CONSTRAINT fk_client_languages_client
            FOREIGN KEY (client_id) REFERENCES core.clients(id);
    END IF;
END $$;

-- client_languages -> languages
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_languages_language') THEN
        ALTER TABLE core.client_languages ADD CONSTRAINT fk_client_languages_language
            FOREIGN KEY (language_code) REFERENCES catalog.languages(language_code);
    END IF;
END $$;

-- client_languages unique constraint
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_client_languages') THEN
        ALTER TABLE core.client_languages ADD CONSTRAINT uq_client_languages
            UNIQUE (client_id, language_code);
    END IF;
END $$;

-- client_providers -> clients
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_providers_client') THEN
        ALTER TABLE core.client_providers ADD CONSTRAINT fk_client_providers_client
            FOREIGN KEY (client_id) REFERENCES core.clients(id);
    END IF;
END $$;

-- client_providers -> providers
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_providers_provider') THEN
        ALTER TABLE core.client_providers ADD CONSTRAINT fk_client_providers_provider
            FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);
    END IF;
END $$;

-- client_providers unique constraint (formal — bir client'a aynı provider tekrar atanamaz)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_client_providers') THEN
        ALTER TABLE core.client_providers ADD CONSTRAINT uq_client_providers UNIQUE (client_id, provider_id);
    END IF;
END $$;

-- client_settings -> clients
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_settings_client') THEN
        ALTER TABLE core.client_settings ADD CONSTRAINT fk_client_settings_client
            FOREIGN KEY (client_id) REFERENCES core.clients(id);
    END IF;
END $$;

-- client_payment_methods -> clients
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_payment_methods_client') THEN
        ALTER TABLE core.client_payment_methods ADD CONSTRAINT fk_client_payment_methods_client
            FOREIGN KEY (client_id) REFERENCES core.clients(id);
    END IF;
END $$;

-- client_payment_methods unique constraint
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_client_payment_methods') THEN
        ALTER TABLE core.client_payment_methods ADD CONSTRAINT uq_client_payment_methods UNIQUE (client_id, payment_method_id);
    END IF;
END $$;

-- client_provider_limits -> clients
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_provider_limits_client') THEN
        ALTER TABLE core.client_provider_limits ADD CONSTRAINT fk_client_provider_limits_client
            FOREIGN KEY (client_id) REFERENCES core.clients(id);
    END IF;
END $$;

-- client_provider_limits -> providers
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_provider_limits_provider') THEN
        ALTER TABLE core.client_provider_limits ADD CONSTRAINT fk_client_provider_limits_provider
            FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);
    END IF;
END $$;

-- client_jurisdictions -> clients
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_jurisdictions_client') THEN
        ALTER TABLE core.client_jurisdictions ADD CONSTRAINT fk_client_jurisdictions_client
            FOREIGN KEY (client_id) REFERENCES core.clients(id);
    END IF;
END $$;

-- client_jurisdictions -> jurisdictions
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_jurisdictions_jurisdiction') THEN
        ALTER TABLE core.client_jurisdictions ADD CONSTRAINT fk_client_jurisdictions_jurisdiction
            FOREIGN KEY (jurisdiction_id) REFERENCES catalog.jurisdictions(id);
    END IF;
END $$;

-- client_jurisdictions unique constraint (client + jurisdiction combination)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_client_jurisdictions') THEN
        ALTER TABLE core.client_jurisdictions ADD CONSTRAINT uq_client_jurisdictions
            UNIQUE (client_id, jurisdiction_id);
    END IF;
END $$;

-- client_data_policies -> clients
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_data_policies_client') THEN
        ALTER TABLE core.client_data_policies ADD CONSTRAINT fk_client_data_policies_client
            FOREIGN KEY (client_id) REFERENCES core.clients(id);
    END IF;
END $$;

-- client_data_policies -> UNIQUE(client_id, data_category)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_client_data_policies_category') THEN
        ALTER TABLE core.client_data_policies ADD CONSTRAINT uq_client_data_policies_category
            UNIQUE (client_id, data_category);
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

-- client_servers -> clients
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_servers_client') THEN
        ALTER TABLE core.client_servers ADD CONSTRAINT fk_client_servers_client
            FOREIGN KEY (client_id) REFERENCES core.clients(id);
    END IF;
END $$;

-- client_servers -> infrastructure_servers
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_servers_server') THEN
        ALTER TABLE core.client_servers ADD CONSTRAINT fk_client_servers_server
            FOREIGN KEY (server_id) REFERENCES core.infrastructure_servers(id);
    END IF;
END $$;

-- client_servers unique (client + server + role)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_client_servers_role') THEN
        ALTER TABLE core.client_servers ADD CONSTRAINT uq_client_servers_role UNIQUE (client_id, server_id, server_role);
    END IF;
END $$;

-- client_provisioning_log -> clients
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_provisioning_log_client') THEN
        ALTER TABLE core.client_provisioning_log ADD CONSTRAINT fk_provisioning_log_client
            FOREIGN KEY (client_id) REFERENCES core.clients(id);
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
