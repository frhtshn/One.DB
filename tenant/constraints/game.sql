-- =============================================
-- Tenant Game Schema Constraints
-- =============================================

-- game_settings unique constraint
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_game_settings_game') THEN
        ALTER TABLE game.game_settings ADD CONSTRAINT uq_game_settings_game UNIQUE (game_id);
    END IF;
END $$;

-- game_limits unique constraint
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_game_limits_game_currency') THEN
        ALTER TABLE game.game_limits ADD CONSTRAINT uq_game_limits_game_currency UNIQUE (game_id, currency_code);
    END IF;
END $$;

-- game_limits -> game_settings (FK)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_game_limits_game') THEN
        ALTER TABLE game.game_limits ADD CONSTRAINT fk_game_limits_game
            FOREIGN KEY (game_id) REFERENCES game.game_settings(game_id) ON DELETE CASCADE;
    END IF;
END $$;

-- game_sessions -> players (FK)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_game_sessions_player') THEN
        ALTER TABLE game.game_sessions ADD CONSTRAINT fk_game_sessions_player
            FOREIGN KEY (player_id) REFERENCES auth.players(id);
    END IF;
END $$;

-- game_sessions durum kontrolü
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_game_sessions_status') THEN
        ALTER TABLE game.game_sessions ADD CONSTRAINT chk_game_sessions_status
            CHECK (status IN ('active', 'expired', 'closed'));
    END IF;
END $$;

-- game_sessions mod kontrolü
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_game_sessions_mode') THEN
        ALTER TABLE game.game_sessions ADD CONSTRAINT chk_game_sessions_mode
            CHECK (mode IN ('real', 'demo', 'fun'));
    END IF;
END $$;
