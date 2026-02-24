-- ================================================================
-- ADMIN_MESSAGE_DRAFT_UNSCHEDULE: Scheduled draft'ı draft'a döndürür
-- scheduled_at = NULL, status = 'draft'
-- Ownership kontrolü: sender_id != p_caller_id AND NOT p_is_admin → RAISE
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_draft_unschedule(BIGINT, INTEGER, BOOLEAN);

CREATE OR REPLACE FUNCTION messaging.admin_message_draft_unschedule(
    p_caller_id BIGINT,                    -- İşlemi yapan kullanıcı ID
    p_draft_id  INTEGER,                   -- Unschedule edilecek draft ID
    p_is_admin  BOOLEAN DEFAULT FALSE      -- SuperAdmin bypass
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_sender_id BIGINT;
    v_status VARCHAR(20);
BEGIN
    IF p_draft_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.draft-id-required' USING ERRCODE = 'P0400';
    END IF;

    -- Draft bilgilerini al
    SELECT sender_id, status INTO v_sender_id, v_status
    FROM messaging.user_message_drafts
    WHERE id = p_draft_id
      AND is_deleted = FALSE;

    IF v_sender_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.draft-not-found' USING ERRCODE = 'P0404';
    END IF;

    -- Ownership kontrolü
    IF v_sender_id != p_caller_id AND NOT p_is_admin THEN
        RAISE EXCEPTION 'error.messaging.not-draft-owner' USING ERRCODE = 'P0403';
    END IF;

    -- Status kontrolü
    IF v_status != 'scheduled' THEN
        RAISE EXCEPTION 'error.messaging.draft-not-scheduled' USING ERRCODE = 'P0400';
    END IF;

    -- Unschedule: scheduled_at = NULL, status = draft
    UPDATE messaging.user_message_drafts
    SET scheduled_at = NULL,
        status = 'draft',
        updated_at = NOW()
    WHERE id = p_draft_id;

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_draft_unschedule(BIGINT, INTEGER, BOOLEAN) IS 'Unschedule a scheduled draft — sets scheduled_at to NULL and status back to draft. Only scheduled drafts can be unscheduled.';
