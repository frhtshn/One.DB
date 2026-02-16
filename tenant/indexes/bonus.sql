-- =============================================
-- Tenant Bonus Schema Indexes
-- =============================================

-- bonus_awards — temel indexler
CREATE INDEX IF NOT EXISTS idx_bonus_awards_player ON bonus.bonus_awards USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_bonus_awards_rule ON bonus.bonus_awards USING btree(bonus_rule_id);
CREATE INDEX IF NOT EXISTS idx_bonus_awards_status ON bonus.bonus_awards USING btree(status);
CREATE INDEX IF NOT EXISTS idx_bonus_awards_type ON bonus.bonus_awards USING btree(bonus_type_code);
CREATE INDEX IF NOT EXISTS idx_bonus_awards_expires ON bonus.bonus_awards USING btree(expires_at) WHERE expires_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_bonus_awards_active ON bonus.bonus_awards USING btree(player_id, status) WHERE status IN ('pending', 'active');
CREATE INDEX IF NOT EXISTS idx_bonus_awards_wagering ON bonus.bonus_awards USING btree(wagering_completed) WHERE wagering_completed = false AND status = 'active';

-- bonus_awards — yeni indexler (JSON-driven engine)
CREATE INDEX IF NOT EXISTS idx_bonus_awards_player_rule ON bonus.bonus_awards USING btree(player_id, bonus_rule_id);
CREATE INDEX IF NOT EXISTS idx_bonus_awards_campaign ON bonus.bonus_awards USING btree(campaign_id) WHERE campaign_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_bonus_awards_awarded_at ON bonus.bonus_awards USING btree(awarded_at DESC);
CREATE INDEX IF NOT EXISTS idx_bonus_awards_usage ON bonus.bonus_awards USING gin(usage_criteria);
CREATE INDEX IF NOT EXISTS idx_bonus_awards_subtype ON bonus.bonus_awards USING btree(bonus_subtype) WHERE bonus_subtype IS NOT NULL;

-- promo_redemptions
CREATE INDEX IF NOT EXISTS idx_promo_redemptions_player ON bonus.promo_redemptions USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_promo_redemptions_code ON bonus.promo_redemptions USING btree(promo_code_id);
CREATE INDEX IF NOT EXISTS idx_promo_redemptions_status ON bonus.promo_redemptions USING btree(status);
-- UNIQUE kaldırıldı — max_per_player > 1 desteği için normal index
CREATE INDEX IF NOT EXISTS idx_promo_redemptions_player_code ON bonus.promo_redemptions USING btree(player_id, promo_code_id);
