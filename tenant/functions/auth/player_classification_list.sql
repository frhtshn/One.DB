-- ================================================================
-- PLAYER_CLASSIFICATION_LIST: Oyuncunun kategori ve gruplarını getir
-- ================================================================
-- Tek kategori (veya null) + grup dizisi döner.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_classification_list(BIGINT);

CREATE OR REPLACE FUNCTION auth.player_classification_list(
    p_player_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_category JSONB;
    v_groups JSONB;
BEGIN
    -- Oyuncu kontrolü
    IF NOT EXISTS (SELECT 1 FROM auth.players WHERE id = p_player_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-classification.player-not-found';
    END IF;

    -- Kategori (tek kayıt veya null)
    SELECT jsonb_build_object(
        'id', pc.id,
        'code', pc.category_code,
        'name', pc.category_name,
        'level', pc.level
    )
    INTO v_category
    FROM auth.player_classification pcl
    JOIN auth.player_categories pc ON pc.id = pcl.player_category_id
    WHERE pcl.player_id = p_player_id
      AND pcl.player_category_id IS NOT NULL
      AND pcl.player_group_id IS NULL
    LIMIT 1;

    -- Gruplar (dizi)
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', pg.id,
            'code', pg.group_code,
            'name', pg.group_name,
            'level', pg.level
        ) ORDER BY pg.level ASC
    ), '[]'::jsonb)
    INTO v_groups
    FROM auth.player_classification pcl
    JOIN auth.player_groups pg ON pg.id = pcl.player_group_id
    WHERE pcl.player_id = p_player_id
      AND pcl.player_group_id IS NOT NULL;

    RETURN jsonb_build_object(
        'playerId', p_player_id,
        'category', v_category,
        'groups', v_groups
    );
END;
$$;

COMMENT ON FUNCTION auth.player_classification_list IS 'Returns player classification with single category (or null) and array of groups as JSONB.';
