-- ================================================================
-- SHADOW_TESTER_LIST: Shadow tester listesi
-- ================================================================
-- Tüm shadow test kullanıcılarını listeler.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.shadow_tester_list();

CREATE OR REPLACE FUNCTION auth.shadow_tester_list()
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', st.id,
            'playerId', st.player_id,
            'username', p.username,
            'note', st.note,
            'addedBy', st.added_by,
            'createdAt', st.created_at
        ) ORDER BY st.created_at DESC
    ), '[]'::jsonb)
    INTO v_result
    FROM auth.shadow_testers st
    LEFT JOIN auth.players p ON p.id = st.player_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION auth.shadow_tester_list IS 'Lists all shadow testers with player username. Returns JSONB array ordered by creation date.';
