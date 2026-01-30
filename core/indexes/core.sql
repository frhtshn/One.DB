-- Core Schema Indexes
-- FK indexes for optimal JOIN performance
-- Using IF NOT EXISTS for idempotent deploys

-- companies.company_code (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_companies_code ON core.companies USING btree(company_code);

-- tenants.tenant_code (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_tenants_code ON core.tenants USING btree(tenant_code);

-- tenants.company_id -> companies.id
CREATE INDEX IF NOT EXISTS idx_tenants_company_id ON core.tenants USING btree(company_id);

-- tenant_currencies.tenant_id -> tenants.id
CREATE INDEX IF NOT EXISTS idx_tenant_currencies_tenant_id ON core.tenant_currencies USING btree(tenant_id);

-- tenant_currencies (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_tenant_currencies_tenant_currency ON core.tenant_currencies USING btree(tenant_id, currency_code);

-- tenant_games.tenant_id -> tenants.id
CREATE INDEX IF NOT EXISTS idx_tenant_games_tenant_id ON core.tenant_games USING btree(tenant_id);

-- tenant_games.game_id -> games.id
CREATE INDEX IF NOT EXISTS idx_tenant_games_game_id ON core.tenant_games USING btree(game_id);

-- tenant_games (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_tenant_games_tenant_game ON core.tenant_games USING btree(tenant_id, game_id);

-- tenant_games (enabled games for lobby)
CREATE INDEX IF NOT EXISTS idx_tenant_games_enabled ON core.tenant_games USING btree(tenant_id, is_enabled) WHERE is_enabled = true;

-- tenant_games (featured games)
CREATE INDEX IF NOT EXISTS idx_tenant_games_featured ON core.tenant_games USING btree(tenant_id, is_featured) WHERE is_featured = true;

-- tenant_games (sync status for background jobs)
CREATE INDEX IF NOT EXISTS idx_tenant_games_sync_status ON core.tenant_games USING btree(sync_status) WHERE sync_status != 'SYNCED';

-- tenant_languages.tenant_id -> tenants.id
CREATE INDEX IF NOT EXISTS idx_tenant_languages_tenant_id ON core.tenant_languages USING btree(tenant_id);

-- tenant_languages (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_tenant_languages_tenant_lang ON core.tenant_languages USING btree(tenant_id, language_code);

-- tenant_providers.tenant_id -> tenants.id
CREATE INDEX IF NOT EXISTS idx_tenant_providers_tenant_id ON core.tenant_providers USING btree(tenant_id);

-- tenant_providers.provider_id -> providers.id
CREATE INDEX IF NOT EXISTS idx_tenant_providers_provider_id ON core.tenant_providers USING btree(provider_id);

-- tenant_providers (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_tenant_providers_tenant_provider ON core.tenant_providers USING btree(tenant_id, provider_id);

-- tenant_settings.tenant_id -> tenants.id
CREATE INDEX IF NOT EXISTS idx_tenant_settings_tenant_id ON core.tenant_settings USING btree(tenant_id);

-- tenant_settings (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_tenant_settings_tenant_key ON core.tenant_settings USING btree(tenant_id, setting_key);

-- tenant_settings.setting_value (JSONB search performance)
CREATE INDEX IF NOT EXISTS idx_tenant_settings_value_gin ON core.tenant_settings USING gin(setting_value);

-- tenant_payment_methods.tenant_id -> tenants.id
CREATE INDEX IF NOT EXISTS idx_tenant_payment_methods_tenant_id ON core.tenant_payment_methods USING btree(tenant_id);

-- tenant_payment_methods.payment_method_id -> payment_methods.id
CREATE INDEX IF NOT EXISTS idx_tenant_payment_methods_payment_method_id ON core.tenant_payment_methods USING btree(payment_method_id);

-- tenant_payment_methods (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_tenant_payment_methods_tenant_method ON core.tenant_payment_methods USING btree(tenant_id, payment_method_id);

-- tenant_payment_methods (enabled methods)
CREATE INDEX IF NOT EXISTS idx_tenant_payment_methods_enabled ON core.tenant_payment_methods USING btree(tenant_id, is_enabled) WHERE is_enabled = true;

-- tenant_payment_methods (featured methods)
CREATE INDEX IF NOT EXISTS idx_tenant_payment_methods_featured ON core.tenant_payment_methods USING btree(tenant_id, is_featured) WHERE is_featured = true;

-- tenant_payment_methods (sync status)
CREATE INDEX IF NOT EXISTS idx_tenant_payment_methods_sync_status ON core.tenant_payment_methods USING btree(sync_status) WHERE sync_status != 'SYNCED';

-- tenant_provider_limits.tenant_id -> tenants.id
CREATE INDEX IF NOT EXISTS idx_tenant_provider_limits_tenant_id ON core.tenant_provider_limits USING btree(tenant_id);

-- tenant_provider_limits.provider_id -> providers.id
CREATE INDEX IF NOT EXISTS idx_tenant_provider_limits_provider_id ON core.tenant_provider_limits USING btree(provider_id);

-- tenant_provider_limits.payment_method_id -> payment_methods.id
CREATE INDEX IF NOT EXISTS idx_tenant_provider_limits_payment_method_id ON core.tenant_provider_limits USING btree(payment_method_id);

-- tenant_provider_limits (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_tenant_provider_limits_lookup ON core.tenant_provider_limits USING btree(tenant_id, provider_id, payment_method_id);

-- tenant_jurisdictions.tenant_id -> tenants.id
CREATE INDEX IF NOT EXISTS idx_tenant_jurisdictions_tenant_id ON core.tenant_jurisdictions USING btree(tenant_id);

-- tenant_jurisdictions.jurisdiction_id -> jurisdictions.id
CREATE INDEX IF NOT EXISTS idx_tenant_jurisdictions_jurisdiction_id ON core.tenant_jurisdictions USING btree(jurisdiction_id);

-- tenant_jurisdictions (primary jurisdiction lookup)
CREATE INDEX IF NOT EXISTS idx_tenant_jurisdictions_primary ON core.tenant_jurisdictions USING btree(tenant_id) WHERE is_primary = true;

-- tenant_jurisdictions (active licenses)
CREATE INDEX IF NOT EXISTS idx_tenant_jurisdictions_active ON core.tenant_jurisdictions USING btree(status) WHERE status = 'ACTIVE';

-- tenant_jurisdictions (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_tenant_jurisdictions_tenant_jurisdiction ON core.tenant_jurisdictions USING btree(tenant_id, jurisdiction_id);

-- tenant_data_policies.tenant_id -> tenants.id
CREATE INDEX IF NOT EXISTS idx_tenant_data_policies_tenant_id ON core.tenant_data_policies USING btree(tenant_id);

-- tenant_data_policies.data_category (Job performance)
CREATE INDEX IF NOT EXISTS idx_tenant_data_policies_category ON core.tenant_data_policies USING btree(data_category);

-- =============================================================================
-- GIN Indexes for JSONB Columns
-- =============================================================================

-- core.tenant_jurisdictions (custom_settings)
CREATE INDEX IF NOT EXISTS idx_tenant_jurisdictions_settings_gin ON core.tenant_jurisdictions USING gin(custom_settings);

-- core.tenant_settings (setting_value) - note: already defined above but grouped here for clarity
-- CREATE INDEX IF NOT EXISTS idx_tenant_settings_value_gin ON core.tenant_settings USING gin(setting_value);
