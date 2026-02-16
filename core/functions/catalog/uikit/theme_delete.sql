-- ================================================================
-- THEME_DELETE: Tema pasifleştir (soft delete)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.theme_delete(INT);

CREATE OR REPLACE FUNCTION catalog.theme_delete(
    p_id INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.theme.id-required';
    END IF;

    -- Pasifleştir
    UPDATE catalog.themes SET
        is_active = false,
        updated_at = NOW()
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.theme.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.theme_delete IS 'Soft-deletes a theme (is_active=false).';
