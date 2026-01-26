-- =============================================
-- Tenant Profile Schema Foreign Key Constraints
-- =============================================

-- player_profile -> players
ALTER TABLE profile.player_profile
    ADD CONSTRAINT fk_player_profile_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;

-- player_identity -> players
ALTER TABLE profile.player_identity
    ADD CONSTRAINT fk_player_identity_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;
