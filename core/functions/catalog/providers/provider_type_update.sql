-- ================================================================
-- PROVIDER_TYPE_UPDATE: Provider tipi gunceller
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_type_update(BIGINT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION catalog.provider_type_update(
    p_id BIGINT,
    p_code VARCHAR(30),
    p_name VARCHAR(100)
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_code VARCHAR(30);
    v_name VARCHAR(100);
    v_existing_id BIGINT;
BEGIN
    -- ID kontrolu
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider-type.id-required';
    END IF;

    -- Mevcut kayit kontrolu
    IF NOT EXISTS(SELECT 1 FROM catalog.provider_types pt WHERE pt.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider-type.not-found';
    END IF;

    -- Kod kontrolu
    IF p_code IS NULL OR LENGTH(TRIM(p_code)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider-type.code-invalid';
    END IF;

    -- Isim kontrolu
    IF p_name IS NULL OR LENGTH(TRIM(p_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider-type.name-invalid';
    END IF;

    v_code := UPPER(TRIM(p_code));
    v_name := TRIM(p_name);

    -- Kod unique kontrolu (baska kayitta ayni kod var mi)
    SELECT pt.id INTO v_existing_id
    FROM catalog.provider_types pt
    WHERE pt.provider_type_code = v_code AND pt.id != p_id;

    IF v_existing_id IS NOT NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.provider-type.code-exists';
    END IF;

    -- Guncelle
    UPDATE catalog.provider_types
    SET provider_type_code = v_code,
        provider_type_name = v_name
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.provider_type_update IS 'Updates a provider type.';
