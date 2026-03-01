-- ================================================================
-- LAYOUT_GET: Tek yerleşim detay getir
-- ID ile doğrudan erişim
-- ================================================================

DROP FUNCTION IF EXISTS presentation.layout_get(BIGINT);

CREATE OR REPLACE FUNCTION presentation.layout_get(
    p_id                BIGINT              -- Layout ID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- Parametre doğrulama
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.layout.id-required';
    END IF;

    SELECT jsonb_build_object(
        'id', l.id,
        'layoutName', l.layout_name,
        'pageId', l.page_id,
        'structure', l.structure,
        'isActive', l.is_active,
        'createdAt', l.created_at,
        'updatedAt', l.updated_at
    ) INTO v_result
    FROM presentation.layouts l
    WHERE l.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION 'error.layout.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.layout_get(BIGINT) IS 'Get single layout detail by ID with full JSONB structure.';
