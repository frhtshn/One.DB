-- ================================================================
-- PLAYER_GROUP_CREATE: Yeni oyuncu grubu oluştur
-- ================================================================
-- Grup kodu UPPER(TRIM) ile normalize edilir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_group_create(VARCHAR, VARCHAR, INT, VARCHAR);

CREATE OR REPLACE FUNCTION auth.player_group_create(
    p_group_code VARCHAR(50),
    p_group_name VARCHAR(100),
    p_level INT DEFAULT 0,
    p_description VARCHAR(255) DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id BIGINT;
    v_code VARCHAR(50);
BEGIN
    -- Kod zorunlu
    IF p_group_code IS NULL OR TRIM(p_group_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-group.code-required';
    END IF;

    -- Ad zorunlu
    IF p_group_name IS NULL OR TRIM(p_group_name) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-group.name-required';
    END IF;

    v_code := UPPER(TRIM(p_group_code));

    -- Kod tekrarı kontrolü
    IF EXISTS (SELECT 1 FROM auth.player_groups WHERE group_code = v_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-group.code-exists';
    END IF;

    INSERT INTO auth.player_groups (group_code, group_name, level, description)
    VALUES (v_code, TRIM(p_group_name), COALESCE(p_level, 0), p_description)
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION auth.player_group_create IS 'Creates a new player group with normalized uppercase code. Returns the new group ID.';
