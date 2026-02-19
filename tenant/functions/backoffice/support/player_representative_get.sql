-- ================================================================
-- PLAYER_REPRESENTATIVE_GET: Temsilci bilgisi getir
-- ================================================================
-- Bir oyuncunun atanmış temsilci bilgisini döner.
-- Atama yoksa NULL döner (hata fırlatmaz).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.player_representative_get(BIGINT);

CREATE OR REPLACE FUNCTION support.player_representative_get(
    p_player_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result    JSONB;
BEGIN
    SELECT jsonb_build_object(
        'playerId', pr.player_id,
        'representativeId', pr.representative_id,
        'assignedBy', pr.assigned_by,
        'note', pr.note,
        'assignedAt', pr.assigned_at
    ) INTO v_result
    FROM support.player_representatives pr
    WHERE pr.player_id = p_player_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION support.player_representative_get IS 'Returns the current representative assignment for a player. Returns NULL if no representative is assigned.';
