-- ================================================================
-- PROVIDER_CREATE: Yeni provider olusturur
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_create(BIGINT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION catalog.provider_create(
    p_type_id BIGINT,
    p_code VARCHAR(50),
    p_name VARCHAR(255)
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_code VARCHAR(50);
    v_name VARCHAR(255);
    v_new_id BIGINT;
BEGIN
    -- Type ID kontrolu
    IF p_type_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.type-required';
    END IF;

    -- Provider type varlik kontrolu
    IF NOT EXISTS(SELECT 1 FROM catalog.provider_types pt WHERE pt.id = p_type_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider-type.not-found';
    END IF;

    -- Kod kontrolu
    IF p_code IS NULL OR LENGTH(TRIM(p_code)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.code-invalid';
    END IF;

    -- Isim kontrolu
    IF p_name IS NULL OR LENGTH(TRIM(p_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.name-invalid';
    END IF;

    v_code := UPPER(TRIM(p_code));
    v_name := TRIM(p_name);

    -- Mevcut kod kontrolu (ayni type icinde unique)
    IF EXISTS(
        SELECT 1 FROM catalog.providers p
        WHERE p.provider_code = v_code
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.provider.code-exists';
    END IF;

    -- Ekle
    INSERT INTO catalog.providers (provider_type_id, provider_code, provider_name, is_active, created_at)
    VALUES (p_type_id, v_code, v_name, TRUE, NOW())
    RETURNING catalog.providers.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION catalog.provider_create IS 'Creates a new provider.';
