-- =============================================
-- Tenant Bonus Request Schema Indexes
-- =============================================

-- bonus_requests
CREATE INDEX IF NOT EXISTS idx_bonus_requests_player ON bonus.bonus_requests USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_bonus_requests_status ON bonus.bonus_requests USING btree(status);
CREATE INDEX IF NOT EXISTS idx_bonus_requests_assigned ON bonus.bonus_requests USING btree(assigned_to_id) WHERE assigned_to_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_bonus_requests_source ON bonus.bonus_requests USING btree(request_source);
CREATE INDEX IF NOT EXISTS idx_bonus_requests_type ON bonus.bonus_requests USING btree(request_type);
CREATE INDEX IF NOT EXISTS idx_bonus_requests_created ON bonus.bonus_requests USING btree(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_bonus_requests_pending ON bonus.bonus_requests USING btree(status, created_at) WHERE status IN ('pending', 'assigned');
CREATE INDEX IF NOT EXISTS idx_bonus_requests_player_type ON bonus.bonus_requests USING btree(player_id, request_type, status);
CREATE INDEX IF NOT EXISTS idx_bonus_requests_expires ON bonus.bonus_requests USING btree(expires_at) WHERE status IN ('pending', 'assigned') AND expires_at IS NOT NULL;

-- bonus_request_actions
CREATE INDEX IF NOT EXISTS idx_bonus_request_actions_request ON bonus.bonus_request_actions USING btree(request_id);
CREATE INDEX IF NOT EXISTS idx_bonus_request_actions_created ON bonus.bonus_request_actions USING btree(request_id, created_at);

-- bonus_request_settings
CREATE INDEX IF NOT EXISTS idx_bonus_request_settings_type ON bonus.bonus_request_settings USING btree(bonus_type_code) WHERE is_active = true;
