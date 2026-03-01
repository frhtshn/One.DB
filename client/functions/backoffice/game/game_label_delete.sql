-- ================================================================
-- GAME_LABEL_DELETE: Oyun etiketini devre dışı bırak (soft delete)
-- is_active = FALSE yapar, fiziksel silme yok
-- ================================================================

DROP FUNCTION IF EXISTS game.delete_game_label(BIGINT, INTEGER);

CREATE OR REPLACE FUNCTION game.delete_game_label(
    p_id        BIGINT,
    p_user_id   INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.game-label.id-required';
    END IF;

    UPDATE game.game_labels SET
        is_active  = FALSE,
        updated_by = p_user_id,
        updated_at = NOW()
    WHERE id = p_id
      AND is_active = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'error.game-label.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION game.delete_game_label(BIGINT, INTEGER) IS 'Soft-delete a game label by setting is_active = FALSE. Raises error if label not found or already inactive.';
