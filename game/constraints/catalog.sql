-- Catalog Schema Foreign Key Constraints (Game DB)
-- Using IF NOT EXISTS pattern for idempotent deploys

-- game_providers unique constraint (provider_code)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_game_providers_code') THEN
        ALTER TABLE catalog.game_providers ADD CONSTRAINT uq_game_providers_code UNIQUE (provider_code);
    END IF;
END $$;

-- games -> game_providers
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_games_provider') THEN
        ALTER TABLE catalog.games ADD CONSTRAINT fk_games_provider
            FOREIGN KEY (provider_id) REFERENCES catalog.game_providers(id);
    END IF;
END $$;

-- games unique constraints (provider + external_game_id)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_games_provider_external') THEN
        ALTER TABLE catalog.games ADD CONSTRAINT uq_games_provider_external UNIQUE (provider_id, external_game_id);
    END IF;
END $$;

-- games unique constraints (provider + game_code)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_games_provider_code') THEN
        ALTER TABLE catalog.games ADD CONSTRAINT uq_games_provider_code UNIQUE (provider_id, game_code);
    END IF;
END $$;

-- game_currency_limits -> games (CASCADE: oyun silinince limitler de silinir)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_game_currency_limits_game') THEN
        ALTER TABLE catalog.game_currency_limits ADD CONSTRAINT fk_game_currency_limits_game
            FOREIGN KEY (game_id) REFERENCES catalog.games(id) ON DELETE CASCADE;
    END IF;
END $$;

-- game_currency_limits unique constraint (game + currency)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_game_currency_limits') THEN
        ALTER TABLE catalog.game_currency_limits ADD CONSTRAINT uq_game_currency_limits UNIQUE (game_id, currency_code);
    END IF;
END $$;
