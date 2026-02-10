-- =============================================
-- Core Messaging Schema Check & FK Constraints
-- =============================================

-- user_message_drafts
ALTER TABLE messaging.user_message_drafts
    ADD CONSTRAINT chk_user_message_drafts_message_type CHECK (message_type IN ('announcement', 'maintenance', 'policy', 'system'));

ALTER TABLE messaging.user_message_drafts
    ADD CONSTRAINT chk_user_message_drafts_priority CHECK (priority IN ('normal', 'important', 'urgent'));

ALTER TABLE messaging.user_message_drafts
    ADD CONSTRAINT chk_user_message_drafts_status CHECK (status IN ('draft', 'scheduled', 'published', 'cancelled'));

-- user_messages (PARTITIONED - aylık, PK: id + created_at)
ALTER TABLE messaging.user_messages
    ADD CONSTRAINT fk_user_messages_draft
    FOREIGN KEY (draft_id) REFERENCES messaging.user_message_drafts(id) ON DELETE SET NULL;

ALTER TABLE messaging.user_messages
    ADD CONSTRAINT chk_user_messages_message_type CHECK (message_type IN ('direct', 'announcement', 'maintenance', 'policy', 'system'));

ALTER TABLE messaging.user_messages
    ADD CONSTRAINT chk_user_messages_priority CHECK (priority IN ('normal', 'important', 'urgent'));
