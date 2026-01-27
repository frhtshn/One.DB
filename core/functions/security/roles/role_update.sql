-- =============================================
-- 4. ROLE_UPDATE: Rol guncelle
-- Returns: VOID - Permission pattern
-- =============================================

DROP FUNCTION IF EXISTS security.role_update(BIGINT, VARCHAR, VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION security.role_update(
    p_id BIGINT,
    p_name VARCHAR DEFAULT NULL,
    p_description VARCHAR DEFAULT NULL,
    p_updated_by BIGINT DEFAULT NULL,
    p_status SMALLINT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_current_code VARCHAR;
BEGIN
    -- Role var mi kontrol et
    SELECT code INTO v_current_code
    FROM security.roles
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.role.not-found';
    END IF;

    -- Protect system roles
    IF security.is_system_role(v_current_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.role.system-protected';
    END IF;

    -- Guncelle (sadece verilen alanlar)
    UPDATE security.roles
    SET
        name = COALESCE(NULLIF(TRIM(p_name), ''), name),
        description = CASE
            WHEN p_description IS NOT NULL THEN NULLIF(TRIM(p_description), '')
            ELSE description
        END,
        status = COALESCE(p_status, status),
        updated_at = NOW(),
        updated_by = COALESCE(p_updated_by, updated_by),
        -- Restore durumunda deleted bilgilerini temizle
        deleted_at = CASE WHEN p_status = 1 THEN NULL ELSE deleted_at END,
        deleted_by = CASE WHEN p_status = 1 THEN NULL ELSE deleted_by END
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION security.role_update IS 'Updates role details. System roles cannot be updated.';
