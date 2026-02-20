-- ================================================================
-- ADMIN_MESSAGE_RECALL: Yayınlanan mesajları geri çeker
-- draft_id ile bağlı tüm user_messages'ları soft delete eder
-- Sadece published durumundaki draft'lar recall edilebilir
-- Draft status → cancelled olarak güncellenir
-- Ownership kontrolü: sender_id != p_caller_id AND NOT p_is_admin → RAISE
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_recall(INTEGER);
DROP FUNCTION IF EXISTS messaging.admin_message_recall(BIGINT, INTEGER, BOOLEAN);

CREATE OR REPLACE FUNCTION messaging.admin_message_recall(
    p_caller_id BIGINT,                    -- İşlemi yapan kullanıcı ID
    p_draft_id  INTEGER,                   -- Geri çekilecek draft ID
    p_is_admin  BOOLEAN DEFAULT FALSE      -- SuperAdmin bypass
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_sender_id BIGINT;
    v_status VARCHAR(20);
    v_affected INTEGER;
    v_total INTEGER := 0;
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
    IF v_status != 'published' THEN
        RAISE EXCEPTION 'error.messaging.draft-not-published' USING ERRCODE = 'P0400';
    END IF;

    -- Tüm alıcı mesajlarını batch bazlı soft delete
    LOOP
        UPDATE messaging.user_messages
        SET is_deleted = TRUE,
            deleted_at = NOW()
        WHERE ctid IN (
            SELECT ctid FROM messaging.user_messages
            WHERE draft_id = p_draft_id
              AND is_deleted = FALSE
            LIMIT 1000
        );

        GET DIAGNOSTICS v_affected = ROW_COUNT;
        v_total := v_total + v_affected;
        EXIT WHEN v_affected = 0;
    END LOOP;

    -- Draft status'ü cancelled olarak güncelle
    UPDATE messaging.user_message_drafts
    SET status = 'cancelled',
        cancelled_by = p_caller_id,
        updated_at = NOW()
    WHERE id = p_draft_id;

    RETURN v_total;
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_recall(BIGINT, INTEGER, BOOLEAN) IS 'Recall a published message with ownership validation. Soft deletes all user_messages linked to the draft and sets draft status to cancelled. Returns number of affected messages.';
