-- =============================================
-- Client Profile Schema Indexes
-- =============================================

-- player_profile
CREATE UNIQUE INDEX idx_player_profile_player ON profile.player_profile USING btree(player_id);
CREATE INDEX idx_player_profile_first_name_hash ON profile.player_profile USING btree(first_name_hash) WHERE first_name_hash IS NOT NULL;
CREATE INDEX idx_player_profile_last_name_hash ON profile.player_profile USING btree(last_name_hash) WHERE last_name_hash IS NOT NULL;
CREATE INDEX idx_player_profile_phone_hash ON profile.player_profile USING btree(phone_hash) WHERE phone_hash IS NOT NULL;
CREATE INDEX idx_player_profile_gsm_hash ON profile.player_profile USING btree(gsm_hash) WHERE gsm_hash IS NOT NULL;
CREATE INDEX idx_player_profile_country ON profile.player_profile USING btree(country_code) WHERE country_code IS NOT NULL;

-- player_identity
CREATE UNIQUE INDEX idx_player_identity_player ON profile.player_identity USING btree(player_id);
CREATE INDEX idx_player_identity_hash ON profile.player_identity USING btree(identity_no_hash) WHERE identity_no_hash IS NOT NULL;
CREATE INDEX idx_player_identity_confirmed ON profile.player_identity USING btree(identity_confirmed) WHERE identity_confirmed = true;
