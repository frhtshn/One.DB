-- Catalog Schema Indexes
-- FK indexes for optimal JOIN performance

-- games.provider_id -> providers.id
CREATE INDEX IF NOT EXISTS idx_games_provider_id ON catalog.games USING btree(provider_id);

-- games.game_code (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_games_provider_game_code ON catalog.games USING btree(provider_id, game_code);

-- providers.provider_type_id -> provider_types.id
CREATE INDEX IF NOT EXISTS idx_providers_provider_type_id ON catalog.providers USING btree(provider_type_id);

-- providers.provider_code (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_providers_provider_code ON catalog.providers USING btree(provider_code);

-- provider_settings.provider_id -> providers.id
CREATE INDEX IF NOT EXISTS idx_provider_settings_provider_id ON catalog.provider_settings USING btree(provider_id);

-- localization_values.localization_key_id -> localization_keys.id
CREATE INDEX IF NOT EXISTS idx_localization_values_key_id ON catalog.localization_values USING btree(localization_key_id);

-- localization_values.language_code (localization_messages_get, localization_export functions)
CREATE INDEX IF NOT EXISTS idx_localization_values_language ON catalog.localization_values USING btree(language_code);

-- localization_values (lookup by key + language)
CREATE UNIQUE INDEX IF NOT EXISTS idx_localization_values_key_lang ON catalog.localization_values USING btree(localization_key_id, language_code);

-- localization_keys.localization_key (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_localization_keys_key ON catalog.localization_keys USING btree(localization_key);

-- localization_keys (lookup by domain/category)
CREATE INDEX IF NOT EXISTS idx_localization_keys_domain ON catalog.localization_keys USING btree(domain);
CREATE INDEX IF NOT EXISTS idx_localization_keys_category ON catalog.localization_keys USING btree(category);

-- transaction_types.category (frequent filter)
CREATE INDEX IF NOT EXISTS idx_transaction_types_category ON catalog.transaction_types USING btree(category);

-- jurisdictions
CREATE INDEX IF NOT EXISTS idx_jurisdictions_country ON catalog.jurisdictions USING btree(country_code);
CREATE INDEX IF NOT EXISTS idx_jurisdictions_active ON catalog.jurisdictions USING btree(is_active) WHERE is_active = true;

-- kyc_policies
CREATE INDEX IF NOT EXISTS idx_kyc_policies_jurisdiction ON catalog.kyc_policies USING btree(jurisdiction_id);
CREATE INDEX IF NOT EXISTS idx_kyc_policies_active ON catalog.kyc_policies USING btree(is_active) WHERE is_active = true;

-- kyc_document_requirements
CREATE INDEX IF NOT EXISTS idx_kyc_doc_req_jurisdiction ON catalog.kyc_document_requirements USING btree(jurisdiction_id);

-- responsible_gaming_policies
CREATE INDEX IF NOT EXISTS idx_rg_policies_jurisdiction ON catalog.responsible_gaming_policies USING btree(jurisdiction_id);
CREATE INDEX IF NOT EXISTS idx_rg_policies_active ON catalog.responsible_gaming_policies USING btree(is_active) WHERE is_active = true;
