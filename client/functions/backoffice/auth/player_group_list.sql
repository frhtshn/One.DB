-- ================================================================
-- PLAYER_GROUP_LIST: Oyuncu gruplarını listele
-- ================================================================
-- Opsiyonel is_active filtresi. Sonuçlar level'a göre sıralı.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_group_list(BOOLEAN);

CREATE OR REPLACE FUNCTION auth.player_group_list(
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
            'id', pg.id,
            'groupCode', pg.group_code,
            'groupName', pg.group_name,
            'level', pg.level,
            'description', pg.description,
            'isActive', pg.is_active,
            'playerCount', (
                SELECT COUNT(DISTINCT pcl.player_id)
                FROM auth.player_classification pcl
                WHERE pcl.player_group_id = pg.id
            ),
            'createdAt', pg.created_at,
            'updatedAt', pg.updated_at
        ) ORDER BY pg.level ASC
    ), '[]'::jsonb)
    INTO v_result
    FROM auth.player_groups pg
    WHERE (p_is_active IS NULL OR pg.is_active = p_is_active);

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION auth.player_group_list IS 'Lists player groups ordered by level. Optional is_active filter. Returns JSONB array with player counts.';
