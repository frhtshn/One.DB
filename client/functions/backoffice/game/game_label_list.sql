-- ================================================================
-- GAME_LABEL_LIST: Oyuna ait etiketleri listele
-- Süresi dolmamış aktif etiketler (veya tüm etiketler)
-- ================================================================

DROP FUNCTION IF EXISTS game.list_game_labels(BIGINT, BOOLEAN);

CREATE OR REPLACE FUNCTION game.list_game_labels(
    p_game_id           BIGINT,
    p_include_expired   BOOLEAN DEFAULT FALSE
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_game_id IS NULL THEN
        RAISE EXCEPTION 'error.game-label.game-id-required';
    END IF;

    RETURN (
        SELECT COALESCE(jsonb_agg(jsonb_build_object(
            'id',           id,
            'labelType',    label_type,
            'labelColor',   label_color,
            'expiresAt',    expires_at,
            'isActive',     is_active,
            'createdAt',    created_at,
            'updatedAt',    updated_at
        ) ORDER BY label_type), '[]'::JSONB)
        FROM game.game_labels
        WHERE game_id = p_game_id
          AND is_active = TRUE
          AND (p_include_expired OR expires_at IS NULL OR expires_at > NOW())
    );
END;
$$;

COMMENT ON FUNCTION game.list_game_labels(BIGINT, BOOLEAN) IS 'List active labels for a game. By default excludes expired labels (expires_at <= NOW()). Returns JSONB array.';
