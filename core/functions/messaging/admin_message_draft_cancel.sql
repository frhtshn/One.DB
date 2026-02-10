-- ================================================================
-- ADMIN_MESSAGE_DRAFT_CANCEL: Zamanlanmış mesajı iptal eder
-- Sadece draft veya scheduled durumundakiler iptal edilebilir
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_draft_cancel(INTEGER);

CREATE OR REPLACE FUNCTION messaging.admin_message_draft_cancel(
    p_draft_id INTEGER  -- İptal edilecek draft ID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_updated INTEGER;
BEGIN
    IF p_draft_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.draft-id-required';
    END IF;

    -- Sadece draft/scheduled iptal edilebilir
    UPDATE messaging.user_message_drafts
    SET status = 'cancelled',
        updated_at = NOW()
    WHERE id = p_draft_id
      AND status IN ('draft', 'scheduled')
      AND is_deleted = FALSE;

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    RETURN v_updated > 0;
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_draft_cancel(INTEGER) IS 'Cancel a draft or scheduled message. Only draft/scheduled status can be cancelled.';
