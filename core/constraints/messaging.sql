-- =============================================
-- Core Messaging Schema Foreign Key & Check Constraints
-- =============================================

-- user_message_broadcasts
ALTER TABLE messaging.user_message_broadcasts
    ADD CONSTRAINT chk_user_broadcasts_message_type CHECK (message_type IN ('announcement', 'maintenance', 'policy', 'system'));

ALTER TABLE messaging.user_message_broadcasts
    ADD CONSTRAINT chk_user_broadcasts_priority CHECK (priority IN ('normal', 'important', 'urgent'));

-- user_messages (PARTITIONED - aylık, PK: id + created_at)
-- NOT: FK FROM partitioned TO non-partitioned PG 12+ ile desteklenir
ALTER TABLE messaging.user_messages
    ADD CONSTRAINT fk_user_messages_broadcast
    FOREIGN KEY (broadcast_id) REFERENCES messaging.user_message_broadcasts(id) ON DELETE SET NULL;

ALTER TABLE messaging.user_messages
    ADD CONSTRAINT chk_user_messages_message_type CHECK (message_type IN ('direct', 'announcement', 'maintenance', 'policy', 'system'));

ALTER TABLE messaging.user_messages
    ADD CONSTRAINT chk_user_messages_priority CHECK (priority IN ('normal', 'important', 'urgent'));
