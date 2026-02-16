-- ================================================================
-- NAVIGATION_TEMPLATE_DELETE: Navigasyon şablonu pasifleştir (soft delete)
-- Bağlı aktif item varsa engellenir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.navigation_template_delete(INT);

CREATE OR REPLACE FUNCTION catalog.navigation_template_delete(
    p_id INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.navigation-template.id-required';
    END IF;

    -- Bağlı aktif item kontrolü
    IF EXISTS(SELECT 1 FROM catalog.navigation_template_items nti WHERE nti.template_id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.navigation-template.has-items';
    END IF;

    -- Pasifleştir
    UPDATE catalog.navigation_templates SET
        is_active = false,
        updated_at = NOW()
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.navigation-template.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.navigation_template_delete IS 'Soft-deletes a navigation template (is_active=false). Fails if items exist.';
