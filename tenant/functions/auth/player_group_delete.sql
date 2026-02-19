-- ================================================================
-- PLAYER_GROUP_DELETE: Oyuncu grubunu deaktif et
-- ================================================================
-- Soft delete: is_active = false olarak işaretler.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_group_delete(BIGINT);

CREATE OR REPLACE FUNCTION auth.player_group_delete(
    p_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_is_active BOOLEAN;
BEGIN
    SELECT is_active INTO v_is_active
    FROM auth.player_groups
    WHERE id = p_id;

    -- Kayıt bulunamadı
    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-group.not-found';
    END IF;

    -- Zaten deaktif
    IF NOT v_is_active THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-group.already-inactive';
    END IF;

    UPDATE auth.player_groups SET
        is_active = false,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION auth.player_group_delete IS 'Soft deletes a player group by setting is_active to false.';
