-- ================================================================
-- THEME_UPDATE: Tema günceller
-- SuperAdmin kullanabilir
-- NULL geçilen alanlar güncellenmez
-- ================================================================

DROP FUNCTION IF EXISTS catalog.theme_update(BIGINT, INT, VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR, JSONB, BOOLEAN, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.theme_update(
    p_caller_id BIGINT,
    p_id INT,
    p_code VARCHAR(50) DEFAULT NULL,
    p_name VARCHAR(100) DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_version VARCHAR(20) DEFAULT NULL,
    p_thumbnail_url VARCHAR(255) DEFAULT NULL,
    p_default_config JSONB DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL,
    p_is_premium BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_code VARCHAR(50);
    v_existing_id INT;
BEGIN
    -- SuperAdmin kontrolü
    IF NOT EXISTS(
        SELECT 1 FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id
        WHERE ur.user_id = p_caller_id
          AND ur.tenant_id IS NULL
          AND r.code = 'superadmin'
          AND r.status = 1
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.theme.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.themes t WHERE t.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.theme.not-found';
    END IF;

    -- Kod değişiyorsa validasyon
    IF p_code IS NOT NULL THEN
        IF LENGTH(TRIM(p_code)) < 2 THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.theme.code-invalid';
        END IF;

        v_code := LOWER(TRIM(p_code));

        SELECT t.id INTO v_existing_id
        FROM catalog.themes t
        WHERE t.code = v_code AND t.id != p_id;

        IF v_existing_id IS NOT NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.theme.code-exists';
        END IF;
    END IF;

    -- İsim değişiyorsa validasyon
    IF p_name IS NOT NULL AND LENGTH(TRIM(p_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.theme.name-invalid';
    END IF;

    -- Güncelle
    UPDATE catalog.themes SET
        code = COALESCE(LOWER(TRIM(p_code)), code),
        name = COALESCE(TRIM(p_name), name),
        description = COALESCE(TRIM(p_description), description),
        version = COALESCE(p_version, version),
        thumbnail_url = COALESCE(TRIM(p_thumbnail_url), thumbnail_url),
        default_config = COALESCE(p_default_config, default_config),
        is_active = COALESCE(p_is_active, is_active),
        is_premium = COALESCE(p_is_premium, is_premium),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.theme_update IS 'Updates a theme. SuperAdmin only.';
