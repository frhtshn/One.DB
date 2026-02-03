-- ================================================================
-- UI_POSITION_DELETE: UI pozisyonu siler
-- SuperAdmin kullanabilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.ui_position_delete(BIGINT, INT);

CREATE OR REPLACE FUNCTION catalog.ui_position_delete(
    p_caller_id BIGINT,
    p_id INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- SuperAdmin kontrolü
    IF NOT EXISTS(
        SELECT 1 FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id
        WHERE ur.user_id = p_caller_id
          AND ur.tenant_id IS NULL
          AND r.code = 'superadmin'
          AND r.status = 1
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.ui-position.id-required';
    END IF;

    IF NOT EXISTS(SELECT 1 FROM catalog.ui_positions up WHERE up.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.ui-position.not-found';
    END IF;

    DELETE FROM catalog.ui_positions WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.ui_position_delete IS 'Deletes a UI position. SuperAdmin only.';
