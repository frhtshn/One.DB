-- Core Schema Indexes
-- FK indexes for optimal JOIN performance
-- Using IF NOT EXISTS for idempotent deploys

-- companies.company_code (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_companies_code ON core.companies USING btree(company_code);

-- clients.client_code (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_clients_code ON core.clients USING btree(client_code);

-- clients.company_id -> companies.id
CREATE INDEX IF NOT EXISTS idx_clients_company_id ON core.clients USING btree(company_id);

-- client_currencies.client_id -> clients.id
CREATE INDEX IF NOT EXISTS idx_client_currencies_client_id ON core.client_currencies USING btree(client_id);

-- client_currencies (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_client_currencies_client_currency ON core.client_currencies USING btree(client_id, currency_code);

-- client_cryptocurrencies.client_id -> clients.id
CREATE INDEX IF NOT EXISTS idx_client_cryptocurrencies_client_id ON core.client_cryptocurrencies USING btree(client_id);

-- client_cryptocurrencies (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_client_cryptocurrencies_client_symbol ON core.client_cryptocurrencies USING btree(client_id, symbol);

-- client_games.client_id -> clients.id
CREATE INDEX IF NOT EXISTS idx_client_games_client_id ON core.client_games USING btree(client_id);

-- client_games.game_id -> games.id
CREATE INDEX IF NOT EXISTS idx_client_games_game_id ON core.client_games USING btree(game_id);

-- client_games (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_client_games_client_game ON core.client_games USING btree(client_id, game_id);

-- client_games (enabled games for lobby)
CREATE INDEX IF NOT EXISTS idx_client_games_enabled ON core.client_games USING btree(client_id, is_enabled) WHERE is_enabled = true;

-- client_games (featured games)
CREATE INDEX IF NOT EXISTS idx_client_games_featured ON core.client_games USING btree(client_id, is_featured) WHERE is_featured = true;

-- client_games (sync status for background jobs)
CREATE INDEX IF NOT EXISTS idx_client_games_sync_status ON core.client_games USING btree(sync_status) WHERE sync_status != 'SYNCED';

-- client_languages.client_id -> clients.id
CREATE INDEX IF NOT EXISTS idx_client_languages_client_id ON core.client_languages USING btree(client_id);

-- client_languages (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_client_languages_client_lang ON core.client_languages USING btree(client_id, language_code);

-- client_providers.client_id -> clients.id
CREATE INDEX IF NOT EXISTS idx_client_providers_client_id ON core.client_providers USING btree(client_id);

-- client_providers.provider_id -> providers.id
CREATE INDEX IF NOT EXISTS idx_client_providers_provider_id ON core.client_providers USING btree(provider_id);

-- client_providers (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_client_providers_client_provider ON core.client_providers USING btree(client_id, provider_id);

-- client_settings.client_id -> clients.id
CREATE INDEX IF NOT EXISTS idx_client_settings_client_id ON core.client_settings USING btree(client_id);

-- client_settings (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_client_settings_client_key ON core.client_settings USING btree(client_id, setting_key);

-- client_settings.setting_value (JSONB search performance)
CREATE INDEX IF NOT EXISTS idx_client_settings_value_gin ON core.client_settings USING gin(setting_value);

-- client_payment_methods.client_id -> clients.id
CREATE INDEX IF NOT EXISTS idx_client_payment_methods_client_id ON core.client_payment_methods USING btree(client_id);

-- client_payment_methods.payment_method_id -> payment_methods.id
CREATE INDEX IF NOT EXISTS idx_client_payment_methods_payment_method_id ON core.client_payment_methods USING btree(payment_method_id);

-- client_payment_methods (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_client_payment_methods_client_method ON core.client_payment_methods USING btree(client_id, payment_method_id);

-- client_payment_methods (enabled methods)
CREATE INDEX IF NOT EXISTS idx_client_payment_methods_enabled ON core.client_payment_methods USING btree(client_id, is_enabled) WHERE is_enabled = true;

-- client_payment_methods (featured methods)
CREATE INDEX IF NOT EXISTS idx_client_payment_methods_featured ON core.client_payment_methods USING btree(client_id, is_featured) WHERE is_featured = true;

-- client_payment_methods (sync status)
CREATE INDEX IF NOT EXISTS idx_client_payment_methods_sync_status ON core.client_payment_methods USING btree(sync_status) WHERE sync_status != 'SYNCED';

-- client_provider_limits.client_id -> clients.id
CREATE INDEX IF NOT EXISTS idx_client_provider_limits_client_id ON core.client_provider_limits USING btree(client_id);

-- client_provider_limits.provider_id -> providers.id
CREATE INDEX IF NOT EXISTS idx_client_provider_limits_provider_id ON core.client_provider_limits USING btree(provider_id);

-- client_provider_limits.payment_method_id -> payment_methods.id
CREATE INDEX IF NOT EXISTS idx_client_provider_limits_payment_method_id ON core.client_provider_limits USING btree(payment_method_id);

-- client_provider_limits (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_client_provider_limits_lookup ON core.client_provider_limits USING btree(client_id, provider_id, payment_method_id);

-- client_jurisdictions.client_id -> clients.id
CREATE INDEX IF NOT EXISTS idx_client_jurisdictions_client_id ON core.client_jurisdictions USING btree(client_id);

-- client_jurisdictions.jurisdiction_id -> jurisdictions.id
CREATE INDEX IF NOT EXISTS idx_client_jurisdictions_jurisdiction_id ON core.client_jurisdictions USING btree(jurisdiction_id);

-- client_jurisdictions (primary jurisdiction lookup)
CREATE INDEX IF NOT EXISTS idx_client_jurisdictions_primary ON core.client_jurisdictions USING btree(client_id) WHERE is_primary = true;

-- client_jurisdictions (active licenses)
CREATE INDEX IF NOT EXISTS idx_client_jurisdictions_active ON core.client_jurisdictions USING btree(status) WHERE status = 'ACTIVE';

-- client_jurisdictions (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_client_jurisdictions_client_jurisdiction ON core.client_jurisdictions USING btree(client_id, jurisdiction_id);

-- client_data_policies.client_id -> clients.id
CREATE INDEX IF NOT EXISTS idx_client_data_policies_client_id ON core.client_data_policies USING btree(client_id);

-- client_data_policies.data_category (Job performance)
CREATE INDEX IF NOT EXISTS idx_client_data_policies_category ON core.client_data_policies USING btree(data_category);

-- =============================================================================
-- Infrastructure / Provisioning Indexes
-- =============================================================================

-- infrastructure_servers (active sunucular)
CREATE INDEX IF NOT EXISTS idx_infrastructure_servers_status ON core.infrastructure_servers USING btree(status) WHERE status = 'active';

-- infrastructure_servers (tip filtresi)
CREATE INDEX IF NOT EXISTS idx_infrastructure_servers_type ON core.infrastructure_servers USING btree(server_type);

-- infrastructure_servers (region filtresi)
CREATE INDEX IF NOT EXISTS idx_infrastructure_servers_region ON core.infrastructure_servers USING btree(region);

-- infrastructure_servers (unique server_code)
CREATE UNIQUE INDEX IF NOT EXISTS idx_infrastructure_servers_code ON core.infrastructure_servers USING btree(server_code);

-- client_servers (client bazlı sorgu)
CREATE INDEX IF NOT EXISTS idx_client_servers_client ON core.client_servers USING btree(client_id);

-- client_servers (sunucu bazlı sorgu)
CREATE INDEX IF NOT EXISTS idx_client_servers_server ON core.client_servers USING btree(server_id);

-- client_servers (çalışan container'lar)
CREATE INDEX IF NOT EXISTS idx_client_servers_status ON core.client_servers USING btree(status) WHERE status = 'running';

-- client_servers (unique: client + server + role)
CREATE UNIQUE INDEX IF NOT EXISTS idx_client_servers_role ON core.client_servers USING btree(client_id, server_id, server_role);

-- client_provisioning_log (client bazlı geçmiş)
CREATE INDEX IF NOT EXISTS idx_provisioning_log_client ON core.client_provisioning_log USING btree(client_id);

-- client_provisioning_log (run bazlı sorgu)
CREATE INDEX IF NOT EXISTS idx_provisioning_log_run ON core.client_provisioning_log USING btree(provision_run_id);

-- client_provisioning_log (aktif/hatalı adımlar)
CREATE INDEX IF NOT EXISTS idx_provisioning_log_status ON core.client_provisioning_log USING btree(status) WHERE status IN ('running', 'failed');

-- template_dumps (aktif dump'lar)
CREATE INDEX IF NOT EXISTS idx_template_dumps_active ON core.template_dumps USING btree(status) WHERE status = 'active';

-- template_dumps (unique: db_type + version)
CREATE UNIQUE INDEX IF NOT EXISTS idx_template_dumps_type_version ON core.template_dumps USING btree(db_type, version);

-- =============================================================================
-- GIN Indexes for JSONB Columns
-- =============================================================================

-- core.client_jurisdictions (custom_settings)
CREATE INDEX IF NOT EXISTS idx_client_jurisdictions_settings_gin ON core.client_jurisdictions USING gin(custom_settings);

-- core.client_settings (setting_value) - note: already defined above but grouped here for clarity
-- CREATE INDEX IF NOT EXISTS idx_client_settings_value_gin ON core.client_settings USING gin(setting_value);

-- =============================================================================
-- Department Indexes
-- =============================================================================

-- departments.company_id -> companies.id (FK performance)
CREATE INDEX IF NOT EXISTS idx_departments_company_id ON core.departments USING btree(company_id);

-- departments.parent_id -> departments.id (FK performance, hierarchy queries)
CREATE INDEX IF NOT EXISTS idx_departments_parent_id ON core.departments USING btree(parent_id) WHERE parent_id IS NOT NULL;

-- departments (unique code per company)
CREATE UNIQUE INDEX IF NOT EXISTS idx_departments_company_code ON core.departments USING btree(company_id, code);

-- departments (active filter per company)
CREATE INDEX IF NOT EXISTS idx_departments_company_active ON core.departments USING btree(company_id, is_active);

-- user_departments.user_id -> users.id (FK performance)
CREATE INDEX IF NOT EXISTS idx_user_departments_user_id ON core.user_departments USING btree(user_id);

-- user_departments.department_id -> departments.id (FK performance)
CREATE INDEX IF NOT EXISTS idx_user_departments_department_id ON core.user_departments USING btree(department_id);

-- user_departments (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_departments_unique ON core.user_departments USING btree(user_id, department_id);

-- user_departments (primary department per user)
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_departments_primary ON core.user_departments USING btree(user_id) WHERE is_primary = true;

-- departments JSONB GIN indexes (multi-language search)
CREATE INDEX IF NOT EXISTS idx_departments_name_gin ON core.departments USING gin(name);
CREATE INDEX IF NOT EXISTS idx_departments_description_gin ON core.departments USING gin(description);

-- =============================================================================
-- Platform Settings Indexes
-- =============================================================================

-- platform_settings.setting_key (lookup by key)
CREATE INDEX IF NOT EXISTS idx_platform_settings_key ON core.platform_settings USING btree(setting_key);

-- platform_settings (unique lookup: key + environment)
CREATE UNIQUE INDEX IF NOT EXISTS idx_platform_settings_key_env ON core.platform_settings USING btree(setting_key, environment);

-- platform_settings (active services)
CREATE INDEX IF NOT EXISTS idx_platform_settings_active ON core.platform_settings USING btree(is_active) WHERE is_active = true;
