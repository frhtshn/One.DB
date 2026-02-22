-- ================================================================
-- LOBBY_SECTION_DELETE: Lobi bölümünü pasife al (soft delete)
-- ================================================================

DROP FUNCTION IF EXISTS game.delete_lobby_section(BIGINT, INTEGER);

CREATE OR REPLACE FUNCTION game.delete_lobby_section(
    p_id        BIGINT,
    p_user_id   INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.lobby-section.id-required';
    END IF;

    UPDATE game.lobby_sections
    SET
        is_active  = FALSE,
        updated_by = p_user_id,
        updated_at = NOW()
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'error.lobby-section.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION game.delete_lobby_section(BIGINT, INTEGER) IS 'Soft-delete a lobby section by setting is_active = FALSE. Game assignments preserved.';
