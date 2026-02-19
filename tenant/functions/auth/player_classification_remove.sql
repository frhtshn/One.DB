-- ================================================================
-- PLAYER_CLASSIFICATION_REMOVE: Oyuncudan kategori/grup kaldır
-- ================================================================
-- Grup: ilgili satırı siler.
-- Kategori: kategori referansını NULL yapar.
-- En az biri (group_id veya category_id) zorunlu.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_classification_remove(BIGINT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION auth.player_classification_remove(
    p_player_id BIGINT,
    p_group_id BIGINT DEFAULT NULL,
    p_category_id BIGINT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Oyuncu kontrolü
    IF NOT EXISTS (SELECT 1 FROM auth.players WHERE id = p_player_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-classification.player-not-found';
    END IF;

    -- En az bir kaldırma gerekli
    IF p_group_id IS NULL AND p_category_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-classification.no-assignment';
    END IF;

    -- Grup kaldırma
    IF p_group_id IS NOT NULL THEN
        DELETE FROM auth.player_classification
        WHERE player_id = p_player_id AND player_group_id = p_group_id;
    END IF;

    -- Kategori kaldırma (NULL'a çevir)
    IF p_category_id IS NOT NULL THEN
        UPDATE auth.player_classification SET
            player_category_id = NULL,
            updated_at = NOW()
        WHERE player_id = p_player_id AND player_category_id = p_category_id;
    END IF;
END;
$$;

COMMENT ON FUNCTION auth.player_classification_remove IS 'Removes a player from a group (delete row) or category (set NULL). At least one parameter required.';
