-- =============================================
-- Client Messaging Schema Indexes
-- =============================================

-- message_templates
CREATE UNIQUE INDEX idx_msg_templates_code ON messaging.message_templates(code) WHERE is_deleted = FALSE;
CREATE INDEX idx_msg_templates_channel ON messaging.message_templates(channel_type);
CREATE INDEX idx_msg_templates_category ON messaging.message_templates(category) WHERE is_deleted = FALSE;
CREATE INDEX idx_msg_templates_status ON messaging.message_templates(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_msg_templates_active ON messaging.message_templates(channel_type, status) WHERE status = 'active' AND is_deleted = FALSE;
CREATE INDEX idx_msg_templates_active_code ON messaging.message_templates(code) WHERE is_deleted = FALSE AND status = 'active';

-- message_template_translations
CREATE INDEX idx_msg_template_trans_template ON messaging.message_template_translations(template_id);
CREATE INDEX idx_msg_template_trans_language ON messaging.message_template_translations(language_code);

-- message_campaigns
CREATE INDEX idx_msg_campaigns_channel ON messaging.message_campaigns(channel_type) WHERE is_deleted = FALSE;
CREATE INDEX idx_msg_campaigns_status ON messaging.message_campaigns(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_msg_campaigns_scheduled ON messaging.message_campaigns(scheduled_at) WHERE status = 'scheduled' AND is_deleted = FALSE;
CREATE INDEX idx_msg_campaigns_template ON messaging.message_campaigns(template_id) WHERE template_id IS NOT NULL;
CREATE INDEX idx_msg_campaigns_created ON messaging.message_campaigns(created_at DESC) WHERE is_deleted = FALSE;

-- message_campaign_translations
CREATE INDEX idx_msg_campaign_trans_campaign ON messaging.message_campaign_translations(campaign_id);
CREATE INDEX idx_msg_campaign_trans_language ON messaging.message_campaign_translations(language_code);

-- message_campaign_segments
CREATE INDEX idx_msg_campaign_segments_campaign ON messaging.message_campaign_segments(campaign_id);
CREATE INDEX idx_msg_campaign_segments_type ON messaging.message_campaign_segments(segment_type, segment_value);

-- message_campaign_recipients
CREATE INDEX idx_msg_recipients_campaign ON messaging.message_campaign_recipients(campaign_id);
CREATE INDEX idx_msg_recipients_player ON messaging.message_campaign_recipients(player_id);
CREATE INDEX idx_msg_recipients_status ON messaging.message_campaign_recipients(campaign_id, status);
CREATE INDEX idx_msg_recipients_pending ON messaging.message_campaign_recipients(campaign_id) WHERE status = 'pending';
CREATE UNIQUE INDEX idx_msg_recipients_unique ON messaging.message_campaign_recipients(campaign_id, player_id);

-- player_messages
CREATE INDEX idx_msg_player_messages_player ON messaging.player_messages(player_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_msg_player_messages_inbox ON messaging.player_messages(player_id, created_at DESC) WHERE is_deleted = FALSE;
CREATE INDEX idx_msg_player_messages_unread ON messaging.player_messages(player_id) WHERE is_read = FALSE AND is_deleted = FALSE;
CREATE INDEX idx_msg_player_messages_campaign ON messaging.player_messages(campaign_id) WHERE campaign_id IS NOT NULL;
CREATE INDEX idx_msg_player_messages_type ON messaging.player_messages(player_id, message_type) WHERE is_deleted = FALSE;

-- player_message_preferences
CREATE INDEX idx_msg_preferences_player ON messaging.player_message_preferences(player_id);
