-- ================================================================
-- PLAYER_GROUP_GET: Oyuncu grubu detayını getir
-- ================================================================
-- Aktif oyuncu sayısı (playerCount) dahil edilir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_group_get(BIGINT);

CREATE OR REPLACE FUNCTION auth.player_group_get(
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
    )
    INTO v_result
    FROM auth.player_groups pg
    WHERE pg.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-group.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION auth.player_group_get IS 'Returns player group details including active player count as JSONB.';
