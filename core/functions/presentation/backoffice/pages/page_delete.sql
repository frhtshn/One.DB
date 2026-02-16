-- ================================================================
-- PAGE_DELETE: Sayfa Silme (Soft Delete)
-- Sayfayı pasif duruma getirir.
-- ================================================================

DROP FUNCTION IF EXISTS presentation.page_delete CASCADE;

CREATE OR REPLACE FUNCTION presentation.page_delete(
    p_page_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_is_active BOOLEAN;
BEGIN
    -- Sayfa var mı kontrol et
    SELECT is_active INTO v_is_active FROM presentation.pages WHERE id = p_page_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.page.not-found';
    END IF;

    IF v_is_active = FALSE THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.page.delete.already-deleted';
    END IF;

    -- Soft delete işlemi
    UPDATE presentation.pages
    SET is_active = FALSE,
        updated_at = NOW()
    WHERE id = p_page_id;
END;
$$;

COMMENT ON FUNCTION presentation.page_delete IS 'Soft deletes a page by setting is_active to FALSE and updating updated_at.';
