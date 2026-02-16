-- ================================================================
-- SHADOW_TESTER_REMOVE: Shadow tester çıkar
-- ================================================================
-- player_id bazlı DELETE.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.shadow_tester_remove(BIGINT);

CREATE OR REPLACE FUNCTION auth.shadow_tester_remove(
    p_player_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.shadow-tester.player-id-required';
    END IF;

    DELETE FROM auth.shadow_testers WHERE player_id = p_player_id;
END;
$$;

COMMENT ON FUNCTION auth.shadow_tester_remove(BIGINT) IS 'Removes a player from shadow testers. Auth-agnostic.';
