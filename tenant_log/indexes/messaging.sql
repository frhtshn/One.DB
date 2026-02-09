-- =============================================
-- Tenant Log - Messaging Schema Indexes
-- =============================================

-- message_delivery_logs
CREATE INDEX IF NOT EXISTS idx_msg_delivery_campaign ON messaging_log.message_delivery_logs USING btree(campaign_id);
CREATE INDEX IF NOT EXISTS idx_msg_delivery_recipient ON messaging_log.message_delivery_logs USING btree(recipient_id);
CREATE INDEX IF NOT EXISTS idx_msg_delivery_player ON messaging_log.message_delivery_logs USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_msg_delivery_channel ON messaging_log.message_delivery_logs USING btree(channel_type);
CREATE INDEX IF NOT EXISTS idx_msg_delivery_status ON messaging_log.message_delivery_logs USING btree(status);
CREATE INDEX IF NOT EXISTS idx_msg_delivery_date ON messaging_log.message_delivery_logs USING btree(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_msg_delivery_failed ON messaging_log.message_delivery_logs(campaign_id, created_at DESC) WHERE status = 'failed';
CREATE INDEX IF NOT EXISTS idx_msg_delivery_campaign_status ON messaging_log.message_delivery_logs USING btree(campaign_id, status);

-- JSONB
CREATE INDEX IF NOT EXISTS idx_msg_delivery_response_gin ON messaging_log.message_delivery_logs USING gin(provider_response);
