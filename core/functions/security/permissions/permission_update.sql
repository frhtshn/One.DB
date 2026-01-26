-- ================================================================
-- PERMISSION_UPDATE: Permission guncelle
-- Code DEGISTIRILEMEZ (immutable)
-- Returns: VOID - basarili ise hicbir sey donmez, hata varsa RAISE EXCEPTION
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_update(BIGINT, VARCHAR, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION security.permission_update(
    p_id BIGINT,
    p_name VARCHAR(150) DEFAULT NULL,
    p_description VARCHAR(500) DEFAULT NULL,
    p_category VARCHAR(50) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status SMALLINT;
BEGIN
    -- Permission'i bul
    SELECT status
    INTO v_current_status
    FROM security.permissions
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission.not-found';
    END IF;

    -- Silinmis permission guncellenemez
    IF v_current_status = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.permission.update.is-deleted';
    END IF;

    -- Guncelle (sadece verilen alanlar)
    UPDATE security.permissions
    SET
        name = COALESCE(NULLIF(TRIM(p_name), ''), name),
        description = CASE
            WHEN p_description IS NOT NULL THEN NULLIF(TRIM(p_description), '')
            ELSE description
        END,
        category = COALESCE(NULLIF(LOWER(TRIM(p_category)), ''), category),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION security.permission_update IS 'Updates permission details. Code is immutable.';
