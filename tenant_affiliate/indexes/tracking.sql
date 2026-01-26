-- =============================================
-- Tenant Affiliate - Tracking Schema Indexes
-- =============================================

-- player_affiliate_current
CREATE INDEX idx_player_affiliate_current_affiliate ON tracking.player_affiliate_current USING btree(affiliate_id);
CREATE INDEX idx_player_affiliate_current_campaign ON tracking.player_affiliate_current USING btree(campaign_id) WHERE campaign_id IS NOT NULL;
CREATE INDEX idx_player_affiliate_current_assigned ON tracking.player_affiliate_current USING btree(assigned_at DESC);

-- player_affiliate_history
CREATE INDEX idx_player_affiliate_history_player ON tracking.player_affiliate_history USING btree(player_id);
CREATE INDEX idx_player_affiliate_history_affiliate ON tracking.player_affiliate_history USING btree(affiliate_id) WHERE affiliate_id IS NOT NULL;
CREATE INDEX idx_player_affiliate_history_campaign ON tracking.player_affiliate_history USING btree(campaign_id) WHERE campaign_id IS NOT NULL;
CREATE INDEX idx_player_affiliate_history_action ON tracking.player_affiliate_history USING btree(action);
CREATE INDEX idx_player_affiliate_history_validity ON tracking.player_affiliate_history USING btree(valid_from, valid_to);
CREATE INDEX idx_player_affiliate_history_active ON tracking.player_affiliate_history USING btree(player_id, valid_from DESC) WHERE valid_to IS NULL;
CREATE INDEX idx_player_affiliate_history_performer ON tracking.player_affiliate_history USING btree(performed_by_type, performed_by_id) WHERE performed_by_id IS NOT NULL;
