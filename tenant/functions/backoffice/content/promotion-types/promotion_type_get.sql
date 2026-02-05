-- ================================================================
-- PROMOTION_TYPE_GET: Tek promosyon türü detayı (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır
-- Translations dahil döner
-- ================================================================

DROP FUNCTION IF EXISTS content.promotion_type_get(INTEGER);

CREATE OR REPLACE FUNCTION content.promotion_type_get(
    p_id INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', pt.id,
        'code', pt.code,
        'icon', pt.icon,
        'color', pt.color,
        'badgeText', pt.badge_text,
        'sortOrder', pt.sort_order,
        'isActive', pt.is_active,
        'createdAt', pt.created_at,
        'createdBy', pt.created_by,
        'updatedAt', pt.updated_at,
        'updatedBy', pt.updated_by,
        -- Translations
        'translations', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', t.id,
                'languageCode', t.language_code,
                'name', t.name,
                'description', t.description
            ) ORDER BY t.language_code)
            FROM content.promotion_type_translations t
            WHERE t.promotion_type_id = pt.id
        ), '[]'::jsonb)
    )
    INTO v_result
    FROM content.promotion_types pt
    WHERE pt.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.promotion-type.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.promotion_type_get IS 'Returns single promotion type with translations. Auth check done in Core DB.';
