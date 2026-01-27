-- ================================================================
-- USER_DELETE: Kullanıcı sil (soft delete)
-- Status = -1 olarak işaretler
-- ================================================================

DROP FUNCTION IF EXISTS security.user_delete(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_delete(
    p_user_id BIGINT,
    p_deleted_by BIGINT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status SMALLINT;
BEGIN
    -- Kullanıcı var mı kontrol et
    SELECT status
    INTO v_current_status
    FROM security.users
    WHERE id = p_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- Zaten silinmiş mi kontrol et
    IF v_current_status = -1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.user.delete.already-deleted';
    END IF;

    -- Soft delete: status = -1
    UPDATE security.users
    SET status = -1,
        updated_at = NOW(),
        updated_by = p_deleted_by
    WHERE id = p_user_id;
END;
$$;

COMMENT ON FUNCTION security.user_delete IS 'Soft deletes a user by setting status to -1';
