-- =============================================
-- Core Mesaj Şablonu Index'leri
-- =============================================

-- message_templates
CREATE UNIQUE INDEX IF NOT EXISTS idx_msg_templates_code ON messaging.message_templates(code) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_msg_templates_channel ON messaging.message_templates(channel_type) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_msg_templates_category ON messaging.message_templates(category) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_msg_templates_status ON messaging.message_templates(status) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_msg_templates_active ON messaging.message_templates(code) WHERE is_active = TRUE AND status = 'active';

-- message_template_translations
CREATE INDEX IF NOT EXISTS idx_msg_template_trans_template ON messaging.message_template_translations(template_id);
CREATE INDEX IF NOT EXISTS idx_msg_template_trans_language ON messaging.message_template_translations(language_code);
