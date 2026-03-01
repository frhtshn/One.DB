-- ================================================================
-- PLAYER_GROUP_UPDATE: Oyuncu grubunu güncelle
-- ================================================================
-- Partial update: sadece gönderilen alanlar güncellenir.
-- Kayıt aktif olmalı (deaktif kayıt güncellenemez).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_group_update(BIGINT, VARCHAR, INT, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION auth.player_group_update(
    p_id BIGINT,
    p_group_name VARCHAR(100) DEFAULT NULL,
    p_level INT DEFAULT NULL,
    p_description VARCHAR(255) DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Aktif kayıt kontrolü
    IF NOT EXISTS (SELECT 1 FROM auth.player_groups WHERE id = p_id AND is_active = true) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-group.not-found';
    END IF;

    UPDATE auth.player_groups SET
        group_name = COALESCE(p_group_name, group_name),
        level = COALESCE(p_level, level),
        description = COALESCE(p_description, description),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION auth.player_group_update IS 'Updates a player group using partial update pattern. Only non-NULL parameters are applied.';
