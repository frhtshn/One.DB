-- ================================================================
-- NAVIGATION_DELETE: Menü öğesi sil
-- is_locked=TRUE ise silme engellenir
-- Alt öğeler varsa hata verir (önce alt öğeleri sil)
-- ================================================================

DROP FUNCTION IF EXISTS presentation.navigation_delete(BIGINT);

CREATE OR REPLACE FUNCTION presentation.navigation_delete(
    p_id                BIGINT              -- Öğe ID
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_is_locked BOOLEAN;
BEGIN
    -- Parametre doğrulama
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.navigation.id-required';
    END IF;

    -- Kayıt ve kilit kontrolü
    SELECT is_locked INTO v_is_locked
    FROM presentation.navigation
    WHERE id = p_id;

    IF v_is_locked IS NULL THEN
        RAISE EXCEPTION 'error.navigation.item-not-found';
    END IF;

    IF v_is_locked THEN
        RAISE EXCEPTION 'error.navigation.item-locked';
    END IF;

    -- Alt öğe kontrolü
    IF EXISTS (SELECT 1 FROM presentation.navigation WHERE parent_id = p_id) THEN
        RAISE EXCEPTION 'error.navigation.has-children';
    END IF;

    DELETE FROM presentation.navigation WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION presentation.navigation_delete(BIGINT) IS 'Delete navigation item. Locked items (from template) cannot be deleted. Items with children must be deleted bottom-up.';
