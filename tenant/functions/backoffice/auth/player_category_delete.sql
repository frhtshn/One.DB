-- ================================================================
-- PLAYER_CATEGORY_DELETE: Oyuncu kategorisini deaktif et
-- ================================================================
-- Soft delete: is_active = false olarak işaretler.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_category_delete(BIGINT);

CREATE OR REPLACE FUNCTION auth.player_category_delete(
    p_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_is_active BOOLEAN;
BEGIN
    SELECT is_active INTO v_is_active
    FROM auth.player_categories
    WHERE id = p_id;

    -- Kayıt bulunamadı
    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-category.not-found';
    END IF;

    -- Zaten deaktif
    IF NOT v_is_active THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-category.already-inactive';
    END IF;

    UPDATE auth.player_categories SET
        is_active = false,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION auth.player_category_delete IS 'Soft deletes a player category by setting is_active to false.';
