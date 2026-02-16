-- ================================================================
-- SHADOW_TESTER_ADD: Shadow tester ekle (idempotent)
-- ================================================================
-- ON CONFLICT (player_id) DO NOTHING ile idempotent.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.shadow_tester_add(BIGINT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION auth.shadow_tester_add(
    p_player_id BIGINT,
    p_note VARCHAR(255) DEFAULT NULL,
    p_added_by VARCHAR(100) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.shadow-tester.player-id-required';
    END IF;

    INSERT INTO auth.shadow_testers (player_id, note, added_by, created_at)
    VALUES (p_player_id, p_note, p_added_by, NOW())
    ON CONFLICT (player_id) DO NOTHING;
END;
$$;

COMMENT ON FUNCTION auth.shadow_tester_add IS 'Adds a player as shadow tester (idempotent). Shadow testers can see games in shadow rollout status. Auth-agnostic.';
