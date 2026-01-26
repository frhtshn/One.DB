-- ================================================================
-- PERMISSION_RESTORE: Silinmis permission'i geri yukle
-- Returns: VOID - basarili ise hicbir sey donmez, hata varsa RAISE EXCEPTION
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_restore(BIGINT);

CREATE OR REPLACE FUNCTION security.permission_restore(
    p_id BIGINT
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

    -- Zaten aktif mi?
    IF v_current_status = 1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.permission.restore.not-deleted';
    END IF;

    -- Geri yukle (status = 1)
    UPDATE security.permissions
    SET status = 1, updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION security.permission_restore IS 'Restores a soft-deleted permission.';
