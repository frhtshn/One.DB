-- =============================================
-- Core Messaging Schema Indexes
-- =============================================

-- user_message_broadcasts
CREATE INDEX idx_user_broadcasts_sender ON messaging.user_message_broadcasts(sender_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_user_broadcasts_company ON messaging.user_message_broadcasts(company_id) WHERE is_deleted = FALSE AND company_id IS NOT NULL;
CREATE INDEX idx_user_broadcasts_tenant ON messaging.user_message_broadcasts(tenant_id) WHERE is_deleted = FALSE AND tenant_id IS NOT NULL;
CREATE INDEX idx_user_broadcasts_created ON messaging.user_message_broadcasts(created_at DESC) WHERE is_deleted = FALSE;
CREATE INDEX idx_user_broadcasts_type ON messaging.user_message_broadcasts(message_type) WHERE is_deleted = FALSE;

-- user_messages
CREATE INDEX idx_user_messages_recipient ON messaging.user_messages(recipient_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_user_messages_inbox ON messaging.user_messages(recipient_id, created_at DESC) WHERE is_deleted = FALSE;
CREATE INDEX idx_user_messages_unread ON messaging.user_messages(recipient_id) WHERE is_read = FALSE AND is_deleted = FALSE;
CREATE INDEX idx_user_messages_broadcast ON messaging.user_messages(broadcast_id) WHERE broadcast_id IS NOT NULL;
CREATE INDEX idx_user_messages_priority ON messaging.user_messages(recipient_id, priority) WHERE is_deleted = FALSE;
CREATE INDEX idx_user_messages_type ON messaging.user_messages(recipient_id, message_type) WHERE is_deleted = FALSE;
