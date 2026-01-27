-- ================================================================
-- PERMISSION_CREATE: Yeni permission olustur
-- Code otomatik lowercase yapilir
-- Ayni code silinmis olarak varsa hata doner (restore kullanilmali)
-- Returns: TABLE(id) - sadece olusturulan ID
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_create(VARCHAR, VARCHAR, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION security.permission_create(
    p_code VARCHAR(100),
    p_name VARCHAR(150),
    p_description VARCHAR(500) DEFAULT NULL,
    p_category VARCHAR(50) DEFAULT 'general'
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_normalized_code VARCHAR(100);
    v_existing_id BIGINT;
    v_existing_status SMALLINT;
    v_new_id INT;
BEGIN
    -- Code'u normalize et
    v_normalized_code := LOWER(TRIM(p_code));

    -- Bos code kontrolu
    IF v_normalized_code IS NULL OR v_normalized_code = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.permission.create.code-required';
    END IF;

    -- Mevcut kayit kontrolu (aktif veya silinmis)
    SELECT p.id, p.status
    INTO v_existing_id, v_existing_status
    FROM security.permissions p
    WHERE p.code = v_normalized_code;

    IF v_existing_id IS NOT NULL THEN
        IF v_existing_status = 0 THEN
            -- Silinmis kayit var, restore kullanilmali
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.permission.create.code-deleted';
        ELSE
            -- Aktif kayit var
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.permission.create.code-exists';
        END IF;
    END IF;

    -- Yeni permission olustur
    INSERT INTO security.permissions (code, name, description, category, status)
    VALUES (v_normalized_code, TRIM(p_name), NULLIF(TRIM(p_description), ''), LOWER(TRIM(p_category)), 1)
    RETURNING security.permissions.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION security.permission_create IS 'Creates a new permission. Returns ID. Code is normalized to lowercase.';
