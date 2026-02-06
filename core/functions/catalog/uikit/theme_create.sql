-- ================================================================
-- THEME_CREATE: Yeni tema oluşturur
-- ================================================================

DROP FUNCTION IF EXISTS catalog.theme_create(VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR, TEXT, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.theme_create(
    p_code VARCHAR(50),
    p_name VARCHAR(100),
    p_description TEXT DEFAULT NULL,
    p_version VARCHAR(20) DEFAULT '1.0.0',
    p_thumbnail_url VARCHAR(255) DEFAULT NULL,
    p_default_config TEXT DEFAULT '{}',
    p_is_premium BOOLEAN DEFAULT FALSE
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_code VARCHAR(50);
    v_name VARCHAR(100);
    v_new_id INT;
BEGIN
    -- Kod kontrolü
    IF p_code IS NULL OR LENGTH(TRIM(p_code)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.theme.code-invalid';
    END IF;

    -- İsim kontrolü
    IF p_name IS NULL OR LENGTH(TRIM(p_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.theme.name-invalid';
    END IF;

    v_code := LOWER(TRIM(p_code));
    v_name := TRIM(p_name);

    -- Mevcut kod kontrolü
    IF EXISTS(SELECT 1 FROM catalog.themes t WHERE t.code = v_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.theme.code-exists';
    END IF;

    -- Ekle
    INSERT INTO catalog.themes (
        code, name, description, version, thumbnail_url,
        default_config, is_active, is_premium, created_at, updated_at
    )
    VALUES (
        v_code, v_name, TRIM(p_description), COALESCE(p_version, '1.0.0'),
        TRIM(p_thumbnail_url), COALESCE(p_default_config, '{}')::jsonb,
        TRUE, COALESCE(p_is_premium, FALSE), NOW(), NOW()
    )
    RETURNING catalog.themes.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION catalog.theme_create IS 'Creates a new theme.';
