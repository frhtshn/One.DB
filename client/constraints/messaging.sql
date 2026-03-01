-- =============================================
-- Client Messaging Schema Foreign Key Constraints
-- =============================================

-- message_templates
ALTER TABLE messaging.message_templates
    ADD CONSTRAINT chk_msg_templates_channel CHECK (channel_type IN ('email', 'sms', 'local'));

ALTER TABLE messaging.message_templates
    ADD CONSTRAINT chk_msg_templates_category CHECK (category IN ('campaign', 'transactional', 'notification', 'marketing'));

ALTER TABLE messaging.message_templates
    ADD CONSTRAINT chk_msg_templates_status CHECK (status IN ('draft', 'active', 'archived'));

-- message_template_translations
ALTER TABLE messaging.message_template_translations
    ADD CONSTRAINT fk_msg_template_trans_template
    FOREIGN KEY (template_id) REFERENCES messaging.message_templates(id) ON DELETE CASCADE;

ALTER TABLE messaging.message_template_translations
    ADD CONSTRAINT uq_msg_template_trans UNIQUE (template_id, language_code);

-- message_campaigns
ALTER TABLE messaging.message_campaigns
    ADD CONSTRAINT chk_msg_campaigns_channel CHECK (channel_type IN ('email', 'sms', 'local'));

ALTER TABLE messaging.message_campaigns
    ADD CONSTRAINT chk_msg_campaigns_status CHECK (status IN ('draft', 'scheduled', 'processing', 'completed', 'failed', 'cancelled'));

ALTER TABLE messaging.message_campaigns
    ADD CONSTRAINT fk_msg_campaigns_template
    FOREIGN KEY (template_id) REFERENCES messaging.message_templates(id) ON DELETE SET NULL;

-- message_campaign_translations
ALTER TABLE messaging.message_campaign_translations
    ADD CONSTRAINT fk_msg_campaign_trans_campaign
    FOREIGN KEY (campaign_id) REFERENCES messaging.message_campaigns(id) ON DELETE CASCADE;

ALTER TABLE messaging.message_campaign_translations
    ADD CONSTRAINT uq_msg_campaign_trans UNIQUE (campaign_id, language_code);

-- message_campaign_segments
ALTER TABLE messaging.message_campaign_segments
    ADD CONSTRAINT fk_msg_campaign_segments_campaign
    FOREIGN KEY (campaign_id) REFERENCES messaging.message_campaigns(id) ON DELETE CASCADE;

ALTER TABLE messaging.message_campaign_segments
    ADD CONSTRAINT chk_msg_campaign_segments_type CHECK (segment_type IN ('player_category', 'player_group', 'country', 'gender', 'player_status', 'registration_date', 'last_login_date', 'deposit_count', 'custom'));

-- message_campaign_recipients
ALTER TABLE messaging.message_campaign_recipients
    ADD CONSTRAINT fk_msg_campaign_recipients_campaign
    FOREIGN KEY (campaign_id) REFERENCES messaging.message_campaigns(id) ON DELETE CASCADE;

ALTER TABLE messaging.message_campaign_recipients
    ADD CONSTRAINT chk_msg_recipients_status CHECK (status IN ('pending', 'sent', 'failed', 'delivered', 'opened', 'clicked'));

-- player_messages (PARTITIONED - aylık, PK: id + created_at)
-- NOT: FK FROM partitioned TO non-partitioned PG 12+ ile desteklenir
ALTER TABLE messaging.player_messages
    ADD CONSTRAINT fk_msg_player_messages_campaign
    FOREIGN KEY (campaign_id) REFERENCES messaging.message_campaigns(id) ON DELETE SET NULL;

ALTER TABLE messaging.player_messages
    ADD CONSTRAINT chk_msg_player_messages_type CHECK (message_type IN ('campaign', 'system', 'welcome', 'kyc', 'transaction', 'manual'));

-- player_message_preferences
ALTER TABLE messaging.player_message_preferences
    ADD CONSTRAINT chk_msg_preferences_channel CHECK (channel_type IN ('email', 'sms', 'local'));

ALTER TABLE messaging.player_message_preferences
    ADD CONSTRAINT uq_msg_player_preferences UNIQUE (player_id, channel_type);
