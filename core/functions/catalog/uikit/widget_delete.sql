-- ================================================================
-- WIDGET_DELETE: Widget siler
-- SuperAdmin kullanabilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.widget_delete(BIGINT, INT);

CREATE OR REPLACE FUNCTION catalog.widget_delete(
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

    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.widget.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.widgets w WHERE w.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.widget.not-found';
    END IF;

    -- Sil
    DELETE FROM catalog.widgets WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.widget_delete IS 'Deletes a widget. SuperAdmin only.';
