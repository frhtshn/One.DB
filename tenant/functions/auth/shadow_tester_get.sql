-- ================================================================
-- SHADOW_TESTER_GET: Shadow tester detayı
-- ================================================================
-- player_id bazlı tekil shadow tester bilgisi.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.shadow_tester_get(BIGINT);

CREATE OR REPLACE FUNCTION auth.shadow_tester_get(
    p_player_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.shadow-tester.player-id-required';
    END IF;

    SELECT jsonb_build_object(
        'id', st.id,
        'playerId', st.player_id,
        'username', p.username,
        'note', st.note,
        'addedBy', st.added_by,
        'createdAt', st.created_at
    )
    INTO v_result
    FROM auth.shadow_testers st
    LEFT JOIN auth.players p ON p.id = st.player_id
    WHERE st.player_id = p_player_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.shadow-tester.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION auth.shadow_tester_get IS 'Returns shadow tester details by player ID. Raises exception if not found.';
