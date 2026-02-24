-- ================================================================
-- ADMIN_MESSAGE_DRAFT_LIST_DUE_SCHEDULED: Zamanı gelmiş scheduled draft'ları listeler
-- Parametresiz: scheduled_at <= NOW() olan tüm draft'ları döner
-- ScheduledPublishService tarafından periyodik olarak çağrılır
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_draft_list_due_scheduled();

CREATE OR REPLACE FUNCTION messaging.admin_message_draft_list_due_scheduled()
RETURNS JSONB
AS $$
BEGIN
    RETURN (
        SELECT COALESCE(jsonb_agg(jsonb_build_object(
            'id', d.id,
            'message_type', d.message_type,
            'priority', d.priority
        )), '[]'::JSONB)
        FROM messaging.user_message_drafts d
        WHERE d.is_deleted = FALSE
          AND d.status = 'scheduled'
          AND d.scheduled_at <= NOW()
    );
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION messaging.admin_message_draft_list_due_scheduled() IS 'Returns scheduled drafts whose scheduled_at has passed. Used by ScheduledPublishService for automatic publishing.';
