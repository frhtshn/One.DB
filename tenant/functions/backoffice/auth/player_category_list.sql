-- ================================================================
-- PLAYER_CATEGORY_LIST: Oyuncu kategorilerini listele
-- ================================================================
-- Opsiyonel is_active filtresi. Sonuçlar level'a göre sıralı.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_category_list(BOOLEAN);

CREATE OR REPLACE FUNCTION auth.player_category_list(
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', pc.id,
            'categoryCode', pc.category_code,
            'categoryName', pc.category_name,
            'level', pc.level,
            'description', pc.description,
            'isActive', pc.is_active,
            'playerCount', (
                SELECT COUNT(DISTINCT pcl.player_id)
                FROM auth.player_classification pcl
                WHERE pcl.player_category_id = pc.id
            ),
            'createdAt', pc.created_at,
            'updatedAt', pc.updated_at
        ) ORDER BY pc.level ASC
    ), '[]'::jsonb)
    INTO v_result
    FROM auth.player_categories pc
    WHERE (p_is_active IS NULL OR pc.is_active = p_is_active);

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION auth.player_category_list IS 'Lists player categories ordered by level. Optional is_active filter. Returns JSONB array with player counts.';
