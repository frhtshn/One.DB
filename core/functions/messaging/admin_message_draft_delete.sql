-- ================================================================
-- ADMIN_MESSAGE_DRAFT_DELETE: Draft taslağı siler (soft delete)
-- Sadece draft, scheduled veya cancelled durumundakiler silinebilir
-- Published olanlar silinemez (recall kullanılmalı)
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_draft_delete(INTEGER, BIGINT);

CREATE OR REPLACE FUNCTION messaging.admin_message_draft_delete(
    p_draft_id   INTEGER,  -- Silinecek draft ID
    p_deleted_by BIGINT    -- Silen kullanıcı ID
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

    -- Published olanlar silinemez
    UPDATE messaging.user_message_drafts
    SET is_deleted = TRUE,
        deleted_at = NOW(),
        updated_at = NOW()
    WHERE id = p_draft_id
      AND status IN ('draft', 'scheduled', 'cancelled')
      AND is_deleted = FALSE;

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    RETURN v_updated > 0;
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_draft_delete(INTEGER, BIGINT) IS 'Soft delete a message draft. Only draft, scheduled or cancelled drafts can be deleted. Published drafts cannot be deleted (use recall instead).';
