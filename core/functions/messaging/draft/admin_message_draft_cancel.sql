-- ================================================================
-- ADMIN_MESSAGE_DRAFT_CANCEL: Zamanlanmış mesajı iptal eder
-- Sadece draft veya scheduled durumundakiler iptal edilebilir
-- Ownership kontrolü: sender_id != p_caller_id AND NOT p_is_admin → RAISE
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_draft_cancel(INTEGER);
DROP FUNCTION IF EXISTS messaging.admin_message_draft_cancel(BIGINT, INTEGER, BOOLEAN);

CREATE OR REPLACE FUNCTION messaging.admin_message_draft_cancel(
    p_caller_id BIGINT,                    -- İşlemi yapan kullanıcı ID
    p_draft_id  INTEGER,                   -- İptal edilecek draft ID
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
    IF v_status = 'published' THEN
        RAISE EXCEPTION 'error.messaging.draft-already-published' USING ERRCODE = 'P0400';
    ELSIF v_status = 'cancelled' THEN
        RAISE EXCEPTION 'error.messaging.draft-already-cancelled' USING ERRCODE = 'P0409';
    ELSIF v_status NOT IN ('draft', 'scheduled') THEN
        RAISE EXCEPTION 'error.messaging.draft-not-editable' USING ERRCODE = 'P0400';
    END IF;

    -- İptal et
    UPDATE messaging.user_message_drafts
    SET status = 'cancelled',
        cancelled_by = p_caller_id,
        updated_at = NOW()
    WHERE id = p_draft_id;

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_draft_cancel(BIGINT, INTEGER, BOOLEAN) IS 'Cancel a draft or scheduled message with ownership validation. Only draft/scheduled status can be cancelled.';
