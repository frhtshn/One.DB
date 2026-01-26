-- Core Schema Foreign Key Constraints

-- tenants -> companies
ALTER TABLE core.tenants
    ADD CONSTRAINT fk_tenants_company
    FOREIGN KEY (company_id) REFERENCES core.companies(id);

-- tenants -> currencies (base_currency)
ALTER TABLE core.tenants
    ADD CONSTRAINT fk_tenants_base_currency
    FOREIGN KEY (base_currency) REFERENCES catalog.currencies(currency_code);

-- tenants -> languages (default_language)
ALTER TABLE core.tenants
    ADD CONSTRAINT fk_tenants_default_language
    FOREIGN KEY (default_language) REFERENCES catalog.languages(language_code);

-- tenants -> countries (default_country)
ALTER TABLE core.tenants
    ADD CONSTRAINT fk_tenants_default_country
    FOREIGN KEY (default_country) REFERENCES catalog.countries(country_code);

-- tenant_currencies -> tenants
ALTER TABLE core.tenant_currencies
    ADD CONSTRAINT fk_tenant_currencies_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- tenant_currencies -> currencies
ALTER TABLE core.tenant_currencies
    ADD CONSTRAINT fk_tenant_currencies_currency
    FOREIGN KEY (currency_code) REFERENCES catalog.currencies(currency_code);

-- tenant_games -> tenants
ALTER TABLE core.tenant_games
    ADD CONSTRAINT fk_tenant_games_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- tenant_games -> games
ALTER TABLE core.tenant_games
    ADD CONSTRAINT fk_tenant_games_game
    FOREIGN KEY (game_id) REFERENCES catalog.games(id);

-- tenant_languages -> tenants
ALTER TABLE core.tenant_languages
    ADD CONSTRAINT fk_tenant_languages_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- tenant_languages -> languages
ALTER TABLE core.tenant_languages
    ADD CONSTRAINT fk_tenant_languages_language
    FOREIGN KEY (language_code) REFERENCES catalog.languages(language_code);

-- tenant_providers -> tenants
ALTER TABLE core.tenant_providers
    ADD CONSTRAINT fk_tenant_providers_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- tenant_providers -> providers
ALTER TABLE core.tenant_providers
    ADD CONSTRAINT fk_tenant_providers_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- tenant_settings -> tenants
ALTER TABLE core.tenant_settings
    ADD CONSTRAINT fk_tenant_settings_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- tenant_payment_methods -> tenants
ALTER TABLE core.tenant_payment_methods
    ADD CONSTRAINT fk_tenant_payment_methods_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- tenant_payment_methods -> payment_methods
ALTER TABLE core.tenant_payment_methods
    ADD CONSTRAINT fk_tenant_payment_methods_payment_method
    FOREIGN KEY (payment_method_id) REFERENCES catalog.payment_methods(id);

-- tenant_provider_limits -> tenants
ALTER TABLE core.tenant_provider_limits
    ADD CONSTRAINT fk_tenant_provider_limits_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- tenant_provider_limits -> providers
ALTER TABLE core.tenant_provider_limits
    ADD CONSTRAINT fk_tenant_provider_limits_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- tenant_provider_limits -> payment_methods
ALTER TABLE core.tenant_provider_limits
    ADD CONSTRAINT fk_tenant_provider_limits_payment_method
    FOREIGN KEY (payment_method_id) REFERENCES catalog.payment_methods(id);
