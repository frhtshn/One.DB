-- ================================================================
-- PLAYER_CLASSIFICATION_BULK_ASSIGN: Toplu kategori/grup atama
-- ================================================================
-- Birden fazla oyuncuya aynı anda kategori veya grup atar.
-- Set-bazlı işlem, ON CONFLICT DO NOTHING (idempotent).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_classification_bulk_assign(BIGINT[], BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION auth.player_classification_bulk_assign(
    p_player_ids BIGINT[],
    p_group_id BIGINT DEFAULT NULL,
    p_category_id BIGINT DEFAULT NULL
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_affected INT := 0;
    v_player_id BIGINT;
BEGIN
    -- Boş dizi kontrolü
    IF p_player_ids IS NULL OR array_length(p_player_ids, 1) IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-classification.no-players';
    END IF;

    -- En az bir atama gerekli
    IF p_group_id IS NULL AND p_category_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-classification.no-assignment';
    END IF;

    -- Kategori aktif mi kontrol et
    IF p_category_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM auth.player_categories WHERE id = p_category_id AND is_active = true) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-classification.category-not-found';
        END IF;
    END IF;

    -- Grup aktif mi kontrol et
    IF p_group_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM auth.player_groups WHERE id = p_group_id AND is_active = true) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-classification.group-not-found';
        END IF;
    END IF;

    -- Kategori toplu atama
    IF p_category_id IS NOT NULL THEN
        FOREACH v_player_id IN ARRAY p_player_ids LOOP
            -- Mevcut kategori kaydı varsa güncelle
            IF EXISTS (SELECT 1 FROM auth.player_classification WHERE player_id = v_player_id AND player_category_id IS NOT NULL AND player_group_id IS NULL) THEN
                UPDATE auth.player_classification SET
                    player_category_id = p_category_id,
                    updated_at = NOW()
                WHERE player_id = v_player_id AND player_category_id IS NOT NULL AND player_group_id IS NULL;
            ELSE
                INSERT INTO auth.player_classification (player_id, player_category_id, player_group_id, updated_at)
                VALUES (v_player_id, p_category_id, NULL, NOW())
                ON CONFLICT (player_id, player_category_id, player_group_id) DO NOTHING;
            END IF;
            v_affected := v_affected + 1;
        END LOOP;
    END IF;

    -- Grup toplu atama
    IF p_group_id IS NOT NULL THEN
        INSERT INTO auth.player_classification (player_id, player_group_id, player_category_id, updated_at)
        SELECT pid, p_group_id, NULL, NOW()
        FROM unnest(p_player_ids) AS pid
        ON CONFLICT (player_id, player_category_id, player_group_id) DO NOTHING;

        GET DIAGNOSTICS v_affected = ROW_COUNT;
    END IF;

    RETURN v_affected;
END;
$$;

COMMENT ON FUNCTION auth.player_classification_bulk_assign IS 'Bulk assigns a category or group to multiple players. Returns affected row count. Idempotent via ON CONFLICT.';
