-- ================================================================
-- PROVIDER_UPDATE: Provider gunceller
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_update(BIGINT, BIGINT, VARCHAR, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.provider_update(
    p_id BIGINT,
    p_type_id BIGINT,
    p_code VARCHAR(50),
    p_name VARCHAR(255),
    p_is_active BOOLEAN
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_code VARCHAR(50);
    v_name VARCHAR(255);
    v_existing_id BIGINT;
BEGIN
    -- ID kontrolu
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.id-required';
    END IF;

    -- Mevcut kayit kontrolu
    IF NOT EXISTS(SELECT 1 FROM catalog.providers p WHERE p.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider.not-found';
    END IF;

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

    -- Kod unique kontrolu (baska kayitta ayni kod var mi)
    SELECT p.id INTO v_existing_id
    FROM catalog.providers p
    WHERE p.provider_code = v_code AND p.id != p_id;

    IF v_existing_id IS NOT NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.provider.code-exists';
    END IF;

    -- Guncelle
    UPDATE catalog.providers
    SET provider_type_id = p_type_id,
        provider_code = v_code,
        provider_name = v_name,
        is_active = COALESCE(p_is_active, is_active)
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.provider_update IS 'Updates a provider.';
