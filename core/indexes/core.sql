-- Core Schema Indexes
-- FK indexes for optimal JOIN performance

-- tenants.company_id -> companies.id
CREATE INDEX idx_tenants_company_id ON core.tenants USING btree(company_id);

-- tenant_currencies.tenant_id -> tenants.id
CREATE INDEX idx_tenant_currencies_tenant_id ON core.tenant_currencies USING btree(tenant_id);

-- tenant_currencies (unique lookup)
CREATE UNIQUE INDEX idx_tenant_currencies_tenant_currency ON core.tenant_currencies USING btree(tenant_id, currency_code);

-- tenant_games.tenant_id -> tenants.id
CREATE INDEX idx_tenant_games_tenant_id ON core.tenant_games USING btree(tenant_id);

-- tenant_games.game_id -> games.id
CREATE INDEX idx_tenant_games_game_id ON core.tenant_games USING btree(game_id);

-- tenant_games (unique lookup)
CREATE UNIQUE INDEX idx_tenant_games_tenant_game ON core.tenant_games USING btree(tenant_id, game_id);

-- tenant_languages.tenant_id -> tenants.id
CREATE INDEX idx_tenant_languages_tenant_id ON core.tenant_languages USING btree(tenant_id);

-- tenant_languages (unique lookup)
CREATE UNIQUE INDEX idx_tenant_languages_tenant_lang ON core.tenant_languages USING btree(tenant_id, language_code);

-- tenant_providers.tenant_id -> tenants.id
CREATE INDEX idx_tenant_providers_tenant_id ON core.tenant_providers USING btree(tenant_id);

-- tenant_providers.provider_id -> providers.id
CREATE INDEX idx_tenant_providers_provider_id ON core.tenant_providers USING btree(provider_id);

-- tenant_providers (unique lookup)
CREATE UNIQUE INDEX idx_tenant_providers_tenant_provider ON core.tenant_providers USING btree(tenant_id, provider_id);

-- tenant_settings.tenant_id -> tenants.id
CREATE INDEX idx_tenant_settings_tenant_id ON core.tenant_settings USING btree(tenant_id);

-- tenant_settings (unique lookup)
CREATE UNIQUE INDEX idx_tenant_settings_tenant_key ON core.tenant_settings USING btree(tenant_id, setting_key);
