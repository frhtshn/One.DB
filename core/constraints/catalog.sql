-- Catalog Schema Foreign Key Constraints

-- games -> providers
ALTER TABLE catalog.games
    ADD CONSTRAINT fk_games_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- providers -> provider_types
ALTER TABLE catalog.providers
    ADD CONSTRAINT fk_providers_provider_type
    FOREIGN KEY (provider_type_id) REFERENCES catalog.provider_types(id);

-- provider_settings -> providers
ALTER TABLE catalog.provider_settings
    ADD CONSTRAINT fk_provider_settings_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- localization_values -> localization_keys
ALTER TABLE catalog.localization_values
    ADD CONSTRAINT fk_localization_values_key
    FOREIGN KEY (localization_key_id) REFERENCES catalog.localization_keys(id);

-- localization_values -> languages
ALTER TABLE catalog.localization_values
    ADD CONSTRAINT fk_localization_values_language
    FOREIGN KEY (language_code) REFERENCES catalog.languages(language_code);

-- Unique Constraints
ALTER TABLE catalog.localization_keys
    ADD CONSTRAINT uq_localization_keys_key UNIQUE (localization_key);
