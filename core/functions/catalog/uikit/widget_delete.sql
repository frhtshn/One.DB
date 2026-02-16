-- ================================================================
-- WIDGET_DELETE: Widget pasifleştir (soft delete)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.widget_delete(INT);

CREATE OR REPLACE FUNCTION catalog.widget_delete(
    p_id INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.widget.id-required';
    END IF;

    -- Pasifleştir
    UPDATE catalog.widgets SET
        is_active = false,
        updated_at = NOW()
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.widget.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.widget_delete IS 'Soft-deletes a widget (is_active=false).';
