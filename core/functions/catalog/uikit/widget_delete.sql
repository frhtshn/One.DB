-- ================================================================
-- WIDGET_DELETE: Widget siler
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

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.widgets w WHERE w.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.widget.not-found';
    END IF;

    -- Sil
    DELETE FROM catalog.widgets WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.widget_delete IS 'Deletes a widget.';
