-- ================================================================
-- ADMIN_MESSAGE_RECALL: Yayınlanan mesajları geri çeker
-- draft_id ile bağlı tüm user_messages'ları soft delete eder
-- Sadece published durumundaki draft'lar recall edilebilir
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_recall(INTEGER);

CREATE OR REPLACE FUNCTION messaging.admin_message_recall(
    p_draft_id INTEGER  -- Geri çekilecek draft ID
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR(20);
    v_affected INTEGER;
BEGIN
    IF p_draft_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.draft-id-required';
    END IF;

    -- Draft durumunu kontrol et
    SELECT status INTO v_status
    FROM messaging.user_message_drafts
    WHERE id = p_draft_id
      AND is_deleted = FALSE;

    IF v_status IS NULL THEN
        RAISE EXCEPTION 'error.messaging.draft-not-found';
    END IF;

    IF v_status != 'published' THEN
        RAISE EXCEPTION 'error.messaging.draft-not-published';
    END IF;

    -- Tüm alıcı mesajlarını soft delete
    UPDATE messaging.user_messages
    SET is_deleted = TRUE,
        deleted_at = NOW()
    WHERE draft_id = p_draft_id
      AND is_deleted = FALSE;

    GET DIAGNOSTICS v_affected = ROW_COUNT;

    RETURN v_affected;
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_recall(INTEGER) IS 'Recall a published message. Soft deletes all user_messages linked to the draft. Only published drafts can be recalled. Returns number of affected messages.';
