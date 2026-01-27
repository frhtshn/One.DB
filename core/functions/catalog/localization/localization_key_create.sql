-- ================================================================
-- LOCALIZATION_KEY_CREATE: Yeni Çeviri Anahtarı Oluşturma
-- ================================================================

DROP FUNCTION IF EXISTS catalog.localization_key_create(VARCHAR, VARCHAR, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION catalog.localization_key_create(
    p_key VARCHAR,
    p_domain VARCHAR,
    p_category VARCHAR,
    p_description VARCHAR DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id BIGINT;
    v_key VARCHAR;
BEGIN
    v_key := LOWER(TRIM(p_key));

    -- Validation
    IF v_key IS NULL OR LENGTH(v_key) < 3 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.localization.key.invalid';
    END IF;

    IF p_domain IS NULL OR LENGTH(TRIM(p_domain)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.localization.domain-invalid';
    END IF;

    -- Duplicate check
    IF EXISTS(SELECT 1 FROM catalog.localization_keys k WHERE k.localization_key = v_key) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.localization.key.exists';
    END IF;

    INSERT INTO catalog.localization_keys (localization_key, domain, category, description)
    VALUES (v_key, LOWER(TRIM(p_domain)), LOWER(TRIM(p_category)), TRIM(p_description))
    RETURNING catalog.localization_keys.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION catalog.localization_key_create(VARCHAR, VARCHAR, VARCHAR, VARCHAR) IS 'Creates a new localization key.';
