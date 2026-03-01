-- ================================================================
-- PROMOTION_TYPE_LIST: Promosyon tipleri listele
-- ================================================================

DROP FUNCTION IF EXISTS content.promotion_type_list(CHAR);

CREATE OR REPLACE FUNCTION content.promotion_type_list(
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
        'color', pt.color,
        'badgeText', pt.badge_text,
        'sortOrder', pt.sort_order,
        'name', t.name,
        'description', t.description
    ) ORDER BY pt.sort_order, pt.id), '[]'::JSONB)
    INTO v_result
    FROM content.promotion_types pt
    LEFT JOIN content.promotion_type_translations t
        ON t.promotion_type_id = pt.id AND t.language_code = p_language_code
    WHERE pt.is_active = TRUE;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.promotion_type_list(CHAR) IS 'List active promotion types with translations.';
