-- ================================================================
-- GAME_LABEL_UPSERT: Oyun etiketi ekle / güncelle
-- (game_id, label_type) üzerinden UPSERT yapılır
-- game_id backend'de core DB'ye karşı doğrulanmalıdır
-- ================================================================

DROP FUNCTION IF EXISTS game.upsert_game_label(BIGINT, VARCHAR, VARCHAR, TIMESTAMPTZ, INTEGER);

CREATE OR REPLACE FUNCTION game.upsert_game_label(
    p_game_id       BIGINT,
    p_label_type    VARCHAR(30),
    p_label_color   VARCHAR(7)      DEFAULT NULL,
    p_expires_at    TIMESTAMPTZ     DEFAULT NULL,
    p_user_id       INTEGER         DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    IF p_game_id IS NULL THEN
        RAISE EXCEPTION 'error.game-label.game-id-required';
    END IF;
    IF p_label_type IS NULL OR TRIM(p_label_type) = '' THEN
        RAISE EXCEPTION 'error.game-label.label-type-required';
    END IF;
    IF p_expires_at IS NOT NULL AND p_expires_at <= NOW() THEN
        RAISE EXCEPTION 'error.game-label.expires-in-past';
    END IF;

    INSERT INTO game.game_labels (
        game_id, label_type, label_color, expires_at, created_by, updated_by
    )
    VALUES (
        p_game_id, LOWER(TRIM(p_label_type)), p_label_color, p_expires_at, p_user_id, p_user_id
    )
    ON CONFLICT ON CONSTRAINT uq_game_label DO UPDATE SET
        label_color = EXCLUDED.label_color,
        expires_at  = EXCLUDED.expires_at,
        is_active   = TRUE,
        updated_by  = EXCLUDED.updated_by,
        updated_at  = NOW()
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION game.upsert_game_label(BIGINT, VARCHAR, VARCHAR, TIMESTAMPTZ, INTEGER) IS 'Insert or update a badge/label for a game. game_id must be validated by backend against core DB. Reactivates existing label on conflict. Returns the label ID.';
