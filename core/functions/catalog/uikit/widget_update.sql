-- ================================================================
-- WIDGET_UPDATE: Widget günceller
-- SuperAdmin kullanabilir
-- NULL geçilen alanlar güncellenmez
-- ================================================================

DROP FUNCTION IF EXISTS catalog.widget_update(BIGINT, INT, VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR, JSONB, BOOLEAN);
DROP FUNCTION IF EXISTS catalog.widget_update(BIGINT, INT, VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR, TEXT, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.widget_update(
    p_caller_id BIGINT,
    p_id INT,
    p_code VARCHAR(50) DEFAULT NULL,
    p_name VARCHAR(100) DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_category VARCHAR(30) DEFAULT NULL,
    p_component_name VARCHAR(100) DEFAULT NULL,
    p_default_props TEXT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_code VARCHAR(50);
    v_existing_id INT;
BEGIN
    -- SuperAdmin check
    PERFORM security.user_assert_superadmin(p_caller_id);

    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.widget.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.widgets w WHERE w.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.widget.not-found';
    END IF;

    -- Kod değişiyorsa validasyon
    IF p_code IS NOT NULL THEN
        IF LENGTH(TRIM(p_code)) < 2 THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.widget.code-invalid';
        END IF;

        v_code := LOWER(TRIM(p_code));

        SELECT w.id INTO v_existing_id
        FROM catalog.widgets w
        WHERE w.code = v_code AND w.id != p_id;

        IF v_existing_id IS NOT NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.widget.code-exists';
        END IF;
    END IF;

    -- İsim validasyonu
    IF p_name IS NOT NULL AND LENGTH(TRIM(p_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.widget.name-invalid';
    END IF;

    -- Kategori validasyonu
    IF p_category IS NOT NULL AND p_category NOT IN ('CONTENT', 'GAME', 'ACCOUNT', 'NAVIGATION') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.widget.category-invalid';
    END IF;

    -- Component name validasyonu
    IF p_component_name IS NOT NULL AND LENGTH(TRIM(p_component_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.widget.component-name-invalid';
    END IF;

    -- Güncelle
    UPDATE catalog.widgets SET
        code = COALESCE(LOWER(TRIM(p_code)), code),
        name = COALESCE(TRIM(p_name), name),
        description = COALESCE(TRIM(p_description), description),
        category = COALESCE(p_category, category),
        component_name = COALESCE(TRIM(p_component_name), component_name),
        default_props = COALESCE(p_default_props::jsonb, default_props),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.widget_update IS 'Updates a widget. SuperAdmin only.';
