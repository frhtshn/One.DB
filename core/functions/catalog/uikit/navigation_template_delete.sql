-- ================================================================
-- NAVIGATION_TEMPLATE_DELETE: Navigasyon şablonu siler
-- SuperAdmin kullanabilir
-- Bağlı item varsa silme engellenir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.navigation_template_delete(BIGINT, INT);

CREATE OR REPLACE FUNCTION catalog.navigation_template_delete(
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
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.navigation-template.id-required';
    END IF;

    IF NOT EXISTS(SELECT 1 FROM catalog.navigation_templates nt WHERE nt.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.navigation-template.not-found';
    END IF;

    -- Bağlı item kontrolü
    IF EXISTS(SELECT 1 FROM catalog.navigation_template_items nti WHERE nti.template_id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.navigation-template.has-items';
    END IF;

    DELETE FROM catalog.navigation_templates WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.navigation_template_delete IS 'Deletes a navigation template. SuperAdmin only. Fails if items exist.';
