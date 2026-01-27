-- ================================================================
-- PAGE_DELETE: Sayfa sil (soft delete)
-- ================================================================

DROP FUNCTION IF EXISTS presentation.page_delete CASCADE;
CREATE OR REPLACE FUNCTION presentation.page_delete(
    p_page_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Sayfa var mı kontrol et
    IF NOT EXISTS (SELECT 1 FROM presentation.pages WHERE id = p_page_id AND is_active) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.page.not-found';
    END IF;

    -- Soft delete işlemi
    UPDATE presentation.pages
    SET is_active = FALSE,
        updated_at = NOW()
    WHERE id = p_page_id;
END;
$$;

COMMENT ON FUNCTION presentation.page_delete IS 'Soft deletes a page by setting is_active to FALSE and updating updated_at.';
