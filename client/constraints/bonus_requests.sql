-- =============================================
-- Client Bonus Request Schema Foreign Key Constraints
-- =============================================

-- bonus_request_actions → bonus_requests
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_request_actions_request') THEN
        ALTER TABLE bonus.bonus_request_actions
            ADD CONSTRAINT fk_request_actions_request
            FOREIGN KEY (request_id) REFERENCES bonus.bonus_requests(id);
    END IF;
END $$;

-- bonus_awards → bonus_requests (opsiyonel referans)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_bonus_awards_request') THEN
        ALTER TABLE bonus.bonus_awards
            ADD CONSTRAINT fk_bonus_awards_request
            FOREIGN KEY (bonus_request_id) REFERENCES bonus.bonus_requests(id);
    END IF;
END $$;

-- bonus_requests → players
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_bonus_requests_player') THEN
        ALTER TABLE bonus.bonus_requests
            ADD CONSTRAINT fk_bonus_requests_player
            FOREIGN KEY (player_id) REFERENCES auth.players(id);
    END IF;
END $$;

-- bonus_request_settings — unique type code kontrolü
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_bonus_request_settings_type') THEN
        ALTER TABLE bonus.bonus_request_settings
            ADD CONSTRAINT uq_bonus_request_settings_type
            UNIQUE (bonus_type_code);
    END IF;
END $$;
