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
    p_category VARCHAR(50) DEFAULT NULL,
    p_status SMALLINT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Permission var mi kontrol et
    IF NOT EXISTS (SELECT 1 FROM security.permissions WHERE id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission.not-found';
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
        status = COALESCE(p_status, status),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION security.permission_update IS 'Updates permission details. Code is immutable.';
