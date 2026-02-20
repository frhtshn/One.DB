-- ================================================================
-- ADMIN_MESSAGE_DRAFT_DELETE: Draft taslağı siler (soft delete)
-- Sadece draft, scheduled veya cancelled durumundakiler silinebilir
-- Published olanlar silinemez (recall kullanılmalı)
-- Ownership kontrolü: sender_id != p_caller_id AND NOT p_is_admin → RAISE
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_draft_delete(INTEGER, BIGINT);
DROP FUNCTION IF EXISTS messaging.admin_message_draft_delete(BIGINT, INTEGER, BOOLEAN);

CREATE OR REPLACE FUNCTION messaging.admin_message_draft_delete(
    p_caller_id BIGINT,                    -- İşlemi yapan kullanıcı ID
    p_draft_id  INTEGER,                   -- Silinecek draft ID
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

    -- Status kontrolü: published silinemez
    IF v_status = 'published' THEN
        RAISE EXCEPTION 'error.messaging.draft-already-published' USING ERRCODE = 'P0400';
    END IF;

    -- Soft delete
    UPDATE messaging.user_message_drafts
    SET is_deleted = TRUE,
        deleted_at = NOW(),
        deleted_by = p_caller_id,
        updated_at = NOW()
    WHERE id = p_draft_id;

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_draft_delete(BIGINT, INTEGER, BOOLEAN) IS 'Soft delete a message draft with ownership validation. Only draft, scheduled or cancelled drafts can be deleted. Published drafts cannot be deleted (use recall instead).';
