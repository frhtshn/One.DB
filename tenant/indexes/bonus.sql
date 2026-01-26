-- =============================================
-- Tenant Bonus Schema Indexes
-- =============================================

-- bonus_awards
CREATE INDEX idx_bonus_awards_player ON bonus.bonus_awards USING btree(player_id);
CREATE INDEX idx_bonus_awards_rule ON bonus.bonus_awards USING btree(bonus_rule_id);
CREATE INDEX idx_bonus_awards_status ON bonus.bonus_awards USING btree(status);
CREATE INDEX idx_bonus_awards_type ON bonus.bonus_awards USING btree(bonus_type_code);
CREATE INDEX idx_bonus_awards_expires ON bonus.bonus_awards USING btree(expires_at) WHERE expires_at IS NOT NULL;
CREATE INDEX idx_bonus_awards_active ON bonus.bonus_awards USING btree(player_id, status) WHERE status IN ('pending', 'active');
CREATE INDEX idx_bonus_awards_wagering ON bonus.bonus_awards USING btree(wagering_completed) WHERE wagering_completed = false AND status = 'active';

-- promo_redemptions
CREATE INDEX idx_promo_redemptions_player ON bonus.promo_redemptions USING btree(player_id);
CREATE INDEX idx_promo_redemptions_code ON bonus.promo_redemptions USING btree(promo_code_id);
CREATE INDEX idx_promo_redemptions_status ON bonus.promo_redemptions USING btree(status);
CREATE UNIQUE INDEX idx_promo_redemptions_player_code ON bonus.promo_redemptions USING btree(player_id, promo_code_id);
