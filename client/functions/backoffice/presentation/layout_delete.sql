-- ================================================================
-- LAYOUT_DELETE: Sayfa yerleşimi sil
-- Hard delete — layout verisi geri alınamaz
-- ================================================================

DROP FUNCTION IF EXISTS presentation.layout_delete(BIGINT);

CREATE OR REPLACE FUNCTION presentation.layout_delete(
    p_id                BIGINT              -- Layout ID
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Parametre doğrulama
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.layout.id-required';
    END IF;

    -- Kayıt kontrolü ve silme
    DELETE FROM presentation.layouts WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'error.layout.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION presentation.layout_delete(BIGINT) IS 'Delete a page layout permanently.';
