-- =============================================
-- Core Messaging Schema Indexes
-- =============================================

-- user_message_drafts
CREATE INDEX idx_user_message_drafts_sender ON messaging.user_message_drafts(sender_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_user_message_drafts_status ON messaging.user_message_drafts(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_user_message_drafts_scheduled ON messaging.user_message_drafts(scheduled_at) WHERE status = 'scheduled' AND is_deleted = FALSE;
CREATE INDEX idx_user_message_drafts_created ON messaging.user_message_drafts(created_at DESC) WHERE is_deleted = FALSE;

-- user_messages
CREATE INDEX idx_user_messages_recipient ON messaging.user_messages(recipient_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_user_messages_inbox ON messaging.user_messages(recipient_id, created_at DESC) WHERE is_deleted = FALSE;
CREATE INDEX idx_user_messages_unread ON messaging.user_messages(recipient_id) WHERE is_read = FALSE AND is_deleted = FALSE;
CREATE INDEX idx_user_messages_draft ON messaging.user_messages(draft_id) WHERE draft_id IS NOT NULL;
CREATE INDEX idx_user_messages_priority ON messaging.user_messages(recipient_id, priority) WHERE is_deleted = FALSE;
CREATE INDEX idx_user_messages_type ON messaging.user_messages(recipient_id, message_type) WHERE is_deleted = FALSE;
CREATE INDEX IF NOT EXISTS idx_user_messages_expires ON messaging.user_messages(expires_at) WHERE expires_at IS NOT NULL AND is_deleted = FALSE;
