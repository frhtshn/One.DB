-- =============================================
-- Client Log Messaging Schema Constraints
-- =============================================
-- NOT: Cross-DB foreign key tanımlanamaz.
-- campaign_id, recipient_id, player_id referansları
-- dokümente edilmiştir ancak DB seviyesinde zorlanmaz.
-- Referans bütünlüğü uygulama katmanında sağlanmalıdır.

-- message_delivery_logs
ALTER TABLE messaging_log.message_delivery_logs
    ADD CONSTRAINT chk_msg_delivery_channel CHECK (channel_type IN ('email', 'sms', 'local'));

ALTER TABLE messaging_log.message_delivery_logs
    ADD CONSTRAINT chk_msg_delivery_status CHECK (status IN ('queued', 'sending', 'sent', 'delivered', 'failed', 'bounced', 'rejected'));
