-- ================================================================
-- PLAYER_CATEGORY_GET: Oyuncu kategorisi detayını getir
-- ================================================================
-- Aktif oyuncu sayısı (playerCount) dahil edilir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_category_get(BIGINT);

CREATE OR REPLACE FUNCTION auth.player_category_get(
    p_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
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
    )
    INTO v_result
    FROM auth.player_categories pc
    WHERE pc.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-category.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION auth.player_category_get IS 'Returns player category details including active player count as JSONB.';
