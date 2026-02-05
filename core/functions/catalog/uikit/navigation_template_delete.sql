-- ================================================================
-- NAVIGATION_TEMPLATE_DELETE: Navigasyon şablonu siler
-- Bağlı item varsa silme engellenir
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

COMMENT ON FUNCTION catalog.navigation_template_delete IS 'Deletes a navigation template. Fails if items exist.';
