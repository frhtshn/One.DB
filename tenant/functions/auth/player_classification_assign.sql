-- ================================================================
-- PLAYER_CLASSIFICATION_ASSIGN: Oyuncuya kategori/grup ata
-- ================================================================
-- Kategori: tek atama (mevcut varsa güncelle, yoksa ekle).
-- Grup: çoklu atama (ON CONFLICT DO NOTHING, idempotent).
-- En az biri (group_id veya category_id) zorunlu.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_classification_assign(BIGINT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION auth.player_classification_assign(
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

    -- En az bir atama gerekli
    IF p_group_id IS NULL AND p_category_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-classification.no-assignment';
    END IF;

    -- Kategori atama
    IF p_category_id IS NOT NULL THEN
        -- Kategori aktif mi kontrol et
        IF NOT EXISTS (SELECT 1 FROM auth.player_categories WHERE id = p_category_id AND is_active = true) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-classification.category-not-found';
        END IF;

        -- Mevcut kategori kaydı varsa güncelle, yoksa ekle
        IF EXISTS (SELECT 1 FROM auth.player_classification WHERE player_id = p_player_id AND player_category_id IS NOT NULL AND player_group_id IS NULL) THEN
            UPDATE auth.player_classification SET
                player_category_id = p_category_id,
                updated_at = NOW()
            WHERE player_id = p_player_id AND player_category_id IS NOT NULL AND player_group_id IS NULL;
        ELSE
            INSERT INTO auth.player_classification (player_id, player_category_id, player_group_id, updated_at)
            VALUES (p_player_id, p_category_id, NULL, NOW());
        END IF;
    END IF;

    -- Grup atama
    IF p_group_id IS NOT NULL THEN
        -- Grup aktif mi kontrol et
        IF NOT EXISTS (SELECT 1 FROM auth.player_groups WHERE id = p_group_id AND is_active = true) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-classification.group-not-found';
        END IF;

        -- İdempotent ekleme
        INSERT INTO auth.player_classification (player_id, player_group_id, player_category_id, updated_at)
        VALUES (p_player_id, p_group_id, NULL, NOW())
        ON CONFLICT (player_id, player_category_id, player_group_id) DO NOTHING;
    END IF;
END;
$$;

COMMENT ON FUNCTION auth.player_classification_assign IS 'Assigns a player to a category and/or group. Category is single assignment (upsert), group is additive (idempotent).';
