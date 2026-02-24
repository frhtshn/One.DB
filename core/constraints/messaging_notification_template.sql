-- =============================================
-- Core Mesaj Şablonu Constraint'leri
-- =============================================

-- message_templates
ALTER TABLE messaging.message_templates
    ADD CONSTRAINT chk_msg_templates_channel CHECK (channel_type IN ('email', 'sms'));

ALTER TABLE messaging.message_templates
    ADD CONSTRAINT chk_msg_templates_category CHECK (category IN ('transactional', 'notification', 'system'));

ALTER TABLE messaging.message_templates
    ADD CONSTRAINT chk_msg_templates_status CHECK (status IN ('draft', 'active', 'archived'));

-- message_template_translations
ALTER TABLE messaging.message_template_translations
    ADD CONSTRAINT fk_msg_template_trans_template
    FOREIGN KEY (template_id) REFERENCES messaging.message_templates(id) ON DELETE CASCADE;

ALTER TABLE messaging.message_template_translations
    ADD CONSTRAINT uq_msg_template_trans UNIQUE (template_id, language_code);
