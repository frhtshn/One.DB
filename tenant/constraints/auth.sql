-- =============================================
-- Tenant Auth Schema Foreign Key Constraints
-- =============================================

-- player_credentials -> players
ALTER TABLE auth.player_credentials
    ADD CONSTRAINT fk_player_credentials_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;

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

