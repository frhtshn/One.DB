-- Catalog Schema Indexes
-- FK indexes for optimal JOIN performance

-- games.provider_id -> providers.id
CREATE INDEX idx_games_provider_id ON catalog.games USING btree(provider_id);

-- games.game_code (unique lookup)
CREATE UNIQUE INDEX idx_games_provider_game_code ON catalog.games USING btree(provider_id, game_code);

-- providers.provider_type_id -> provider_types.id
CREATE INDEX idx_providers_provider_type_id ON catalog.providers USING btree(provider_type_id);

-- providers.provider_code (unique lookup)
CREATE UNIQUE INDEX idx_providers_provider_code ON catalog.providers USING btree(provider_code);

-- provider_settings.provider_id -> providers.id
CREATE INDEX idx_provider_settings_provider_id ON catalog.provider_settings USING btree(provider_id);

-- localization_values.localization_key_id -> localization_keys.id
CREATE INDEX idx_localization_values_key_id ON catalog.localization_values USING btree(localization_key_id);

-- localization_values.language_code (localization_messages_get, localization_export functions)
CREATE INDEX idx_localization_values_language ON catalog.localization_values USING btree(language_code);

-- localization_values (lookup by key + language)
CREATE UNIQUE INDEX idx_localization_values_key_lang ON catalog.localization_values USING btree(localization_key_id, language_code);

-- localization_keys.localization_key (unique lookup)
CREATE UNIQUE INDEX idx_localization_keys_key ON catalog.localization_keys USING btree(localization_key);

-- localization_keys (lookup by domain/category)
CREATE INDEX idx_localization_keys_domain ON catalog.localization_keys USING btree(domain);
CREATE INDEX idx_localization_keys_category ON catalog.localization_keys USING btree(category);

-- transaction_types.category (frequent filter)
CREATE INDEX idx_transaction_types_category ON catalog.transaction_types USING btree(category);
