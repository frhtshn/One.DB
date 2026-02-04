-- ================================================================
-- NAVIGATION_TEMPLATE_ITEM_DELETE: Şablon öğesi siler
-- SuperAdmin kullanabilir
-- Alt öğe varsa silme engellenir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.navigation_template_item_delete(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION catalog.navigation_template_item_delete(
    p_caller_id BIGINT,
    p_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- SuperAdmin check
    PERFORM security.user_assert_superadmin(p_caller_id);

    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.navigation-template-item.id-required';
    END IF;

    IF NOT EXISTS(SELECT 1 FROM catalog.navigation_template_items nti WHERE nti.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.navigation-template-item.not-found';
    END IF;

    -- Alt öğe kontrolü
    IF EXISTS(SELECT 1 FROM catalog.navigation_template_items nti WHERE nti.parent_id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.navigation-template-item.has-children';
    END IF;

    DELETE FROM catalog.navigation_template_items WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.navigation_template_item_delete IS 'Deletes a navigation template item. SuperAdmin only. Fails if children exist.';
