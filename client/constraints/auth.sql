-- =============================================
-- Tenant Auth Schema Foreign Key Constraints
-- =============================================

-- player_classification -> players
ALTER TABLE auth.player_classification
    ADD CONSTRAINT fk_player_classification_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;

-- player_classification -> player_groups
ALTER TABLE auth.player_classification
    ADD CONSTRAINT fk_player_classification_group
    FOREIGN KEY (player_group_id) REFERENCES auth.player_groups(id) ON DELETE SET NULL;

-- player_classification -> player_categories
ALTER TABLE auth.player_classification
    ADD CONSTRAINT fk_player_classification_category
    FOREIGN KEY (player_category_id) REFERENCES auth.player_categories(id) ON DELETE SET NULL;

-- player_password_history -> players
ALTER TABLE auth.player_password_history
    ADD CONSTRAINT fk_player_password_history_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;

-- email_verification_tokens -> players
ALTER TABLE auth.email_verification_tokens
    ADD CONSTRAINT fk_email_verification_tokens_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;

-- password_reset_tokens -> players
ALTER TABLE auth.password_reset_tokens
    ADD CONSTRAINT fk_password_reset_tokens_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;

-- shadow_testers -> players (SHADOW_MODE)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_shadow_testers_player') THEN
        ALTER TABLE auth.shadow_testers ADD CONSTRAINT fk_shadow_testers_player
            FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;
    END IF;
END $$;

-- shadow_testers unique constraint (bir oyuncu sadece bir kez eklenebilir)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_shadow_testers_player') THEN
        ALTER TABLE auth.shadow_testers ADD CONSTRAINT uq_shadow_testers_player UNIQUE (player_id);
    END IF;
END $$;

