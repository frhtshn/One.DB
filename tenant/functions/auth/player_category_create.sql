-- ================================================================
-- PLAYER_CATEGORY_CREATE: Yeni oyuncu kategorisi oluştur
-- ================================================================
-- Kategori kodu UPPER(TRIM) ile normalize edilir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_category_create(VARCHAR, VARCHAR, INT, VARCHAR);

CREATE OR REPLACE FUNCTION auth.player_category_create(
    p_category_code VARCHAR(50),
    p_category_name VARCHAR(100),
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
    IF p_category_code IS NULL OR TRIM(p_category_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-category.code-required';
    END IF;

    -- Ad zorunlu
    IF p_category_name IS NULL OR TRIM(p_category_name) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-category.name-required';
    END IF;

    v_code := UPPER(TRIM(p_category_code));

    -- Kod tekrarı kontrolü
    IF EXISTS (SELECT 1 FROM auth.player_categories WHERE category_code = v_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-category.code-exists';
    END IF;

    INSERT INTO auth.player_categories (category_code, category_name, level, description)
    VALUES (v_code, TRIM(p_category_name), COALESCE(p_level, 0), p_description)
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION auth.player_category_create IS 'Creates a new player category with normalized uppercase code. Returns the new category ID.';
