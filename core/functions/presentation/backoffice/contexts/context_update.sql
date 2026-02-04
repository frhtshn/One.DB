-- ================================================================
-- CONTEXT_UPDATE: Context Güncelleme
-- NULL gelen alanlar güncellenmez (Partial Update).
-- ================================================================

DROP FUNCTION IF EXISTS presentation.context_update CASCADE;

CREATE OR REPLACE FUNCTION presentation.context_update(
    p_id BIGINT,
    p_page_id BIGINT DEFAULT NULL,
    p_code VARCHAR DEFAULT NULL,
    p_type VARCHAR DEFAULT NULL,
    p_label VARCHAR DEFAULT NULL,
    p_permission_edit VARCHAR DEFAULT NULL,
    p_permission_readonly VARCHAR DEFAULT NULL,
    p_permission_mask VARCHAR DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
) RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check existence
    IF NOT EXISTS (SELECT 1 FROM presentation.contexts WHERE id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.context.not-found';
    END IF;

    -- Partial update with soft status change
    UPDATE presentation.contexts SET
        page_id = COALESCE(p_page_id, page_id),
        code = COALESCE(p_code, code),
        context_type = COALESCE(p_type, context_type),
        label_localization_key = COALESCE(p_label, label_localization_key),
        permission_edit = COALESCE(p_permission_edit, permission_edit),
        permission_readonly = COALESCE(p_permission_readonly, permission_readonly),
        permission_mask = COALESCE(p_permission_mask, permission_mask),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION presentation.context_update IS 'Updates a context. Partial update supported. Returns VOID.';
