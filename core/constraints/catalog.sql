-- Catalog Schema Foreign Key Constraints
-- Using IF NOT EXISTS pattern for idempotent deploys

-- games -> providers
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_games_provider') THEN
        ALTER TABLE catalog.games ADD CONSTRAINT fk_games_provider
            FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);
    END IF;
END $$;

-- games unique constraints
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_games_provider_external') THEN
        ALTER TABLE catalog.games ADD CONSTRAINT uq_games_provider_external UNIQUE (provider_id, external_game_id);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_games_provider_code') THEN
        ALTER TABLE catalog.games ADD CONSTRAINT uq_games_provider_code UNIQUE (provider_id, game_code);
    END IF;
END $$;

-- providers -> provider_types
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_providers_provider_type') THEN
        ALTER TABLE catalog.providers ADD CONSTRAINT fk_providers_provider_type
            FOREIGN KEY (provider_type_id) REFERENCES catalog.provider_types(id);
    END IF;
END $$;

-- provider_settings -> providers
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_provider_settings_provider') THEN
        ALTER TABLE catalog.provider_settings ADD CONSTRAINT fk_provider_settings_provider
            FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);
    END IF;
END $$;

-- localization_values -> localization_keys
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_localization_values_key') THEN
        ALTER TABLE catalog.localization_values ADD CONSTRAINT fk_localization_values_key
            FOREIGN KEY (localization_key_id) REFERENCES catalog.localization_keys(id);
    END IF;
END $$;

-- localization_values -> languages
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_localization_values_language') THEN
        ALTER TABLE catalog.localization_values ADD CONSTRAINT fk_localization_values_language
            FOREIGN KEY (language_code) REFERENCES catalog.languages(language_code);
    END IF;
END $$;

-- Unique Constraints
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_localization_keys_key') THEN
        ALTER TABLE catalog.localization_keys ADD CONSTRAINT uq_localization_keys_key UNIQUE (localization_key);
    END IF;
END $$;

-- jurisdictions -> countries
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_jurisdictions_country') THEN
        ALTER TABLE catalog.jurisdictions ADD CONSTRAINT fk_jurisdictions_country
            FOREIGN KEY (country_code) REFERENCES catalog.countries(country_code);
    END IF;
END $$;

-- kyc_policies -> jurisdictions
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_kyc_policies_jurisdiction') THEN
        ALTER TABLE catalog.kyc_policies ADD CONSTRAINT fk_kyc_policies_jurisdiction
            FOREIGN KEY (jurisdiction_id) REFERENCES catalog.jurisdictions(id);
    END IF;
END $$;

-- kyc_document_requirements -> jurisdictions
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_kyc_document_requirements_jurisdiction') THEN
        ALTER TABLE catalog.kyc_document_requirements ADD CONSTRAINT fk_kyc_document_requirements_jurisdiction
            FOREIGN KEY (jurisdiction_id) REFERENCES catalog.jurisdictions(id);
    END IF;
END $$;

-- responsible_gaming_policies -> jurisdictions
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_responsible_gaming_policies_jurisdiction') THEN
        ALTER TABLE catalog.responsible_gaming_policies ADD CONSTRAINT fk_responsible_gaming_policies_jurisdiction
            FOREIGN KEY (jurisdiction_id) REFERENCES catalog.jurisdictions(id);
    END IF;
END $$;

-- Navigation Templates Constraints
-- navigation_template_items -> navigation_templates
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_navigation_template_items_template') THEN
        ALTER TABLE catalog.navigation_template_items ADD CONSTRAINT fk_navigation_template_items_template
            FOREIGN KEY (template_id) REFERENCES catalog.navigation_templates(id) ON DELETE CASCADE;
    END IF;
END $$;

-- navigation_template_items -> parent (Self Referencing)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_navigation_template_items_parent') THEN
        ALTER TABLE catalog.navigation_template_items ADD CONSTRAINT fk_navigation_template_items_parent
            FOREIGN KEY (parent_id) REFERENCES catalog.navigation_template_items(id) ON DELETE CASCADE;
    END IF;
END $$;

-- payment_methods -> providers
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_payment_methods_provider') THEN
        ALTER TABLE catalog.payment_methods ADD CONSTRAINT fk_payment_methods_provider
            FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);
    END IF;
END $$;

-- payment_methods unique constraint
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_payment_methods_provider_code') THEN
        ALTER TABLE catalog.payment_methods ADD CONSTRAINT uq_payment_methods_provider_code UNIQUE (provider_id, payment_method_code);
    END IF;
END $$;
