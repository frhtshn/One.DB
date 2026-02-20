-- ================================================================
-- POPUP_TYPE_LIST: Popup tipleri listele
-- ================================================================

DROP FUNCTION IF EXISTS content.popup_type_list(CHAR);

CREATE OR REPLACE FUNCTION content.popup_type_list(
    p_language_code     CHAR(2) DEFAULT 'en'
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', pt.id,
        'code', pt.code,
        'icon', pt.icon,
        'defaultWidth', pt.default_width,
        'defaultHeight', pt.default_height,
        'hasOverlay', pt.has_overlay,
        'canClose', pt.can_close,
        'closeOnOverlayClick', pt.close_on_overlay_click,
        'sortOrder', pt.sort_order,
        'name', t.name,
        'description', t.description
    ) ORDER BY pt.sort_order, pt.id), '[]'::JSONB)
    INTO v_result
    FROM content.popup_types pt
    LEFT JOIN content.popup_type_translations t
        ON t.popup_type_id = pt.id AND t.language_code = p_language_code
    WHERE pt.is_active = TRUE;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.popup_type_list(CHAR) IS 'List active popup types with translations.';
