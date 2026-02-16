-- =============================================
-- Tenant Log - Game Log Schema Indexes
-- =============================================

-- game_rounds — yüksek hacim, kritik sorgular
CREATE INDEX IF NOT EXISTS idx_game_rounds_player ON game_log.game_rounds USING btree(player_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_game_rounds_provider ON game_log.game_rounds USING btree(provider_code, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_game_rounds_game ON game_log.game_rounds USING btree(game_code, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_game_rounds_ext_round ON game_log.game_rounds USING btree(external_round_id);
CREATE INDEX IF NOT EXISTS idx_game_rounds_status ON game_log.game_rounds USING btree(round_status, created_at DESC) WHERE round_status NOT IN ('closed');
CREATE INDEX IF NOT EXISTS idx_game_rounds_bonus ON game_log.game_rounds USING btree(bonus_award_id, created_at DESC) WHERE bonus_award_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_game_rounds_free ON game_log.game_rounds USING btree(player_id, created_at DESC) WHERE is_free_round = true;
CREATE INDEX IF NOT EXISTS idx_game_rounds_detail_gin ON game_log.game_rounds USING gin(round_detail);
