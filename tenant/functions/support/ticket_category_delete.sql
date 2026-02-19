-- ================================================================
-- TICKET_CATEGORY_DELETE: Ticket kategorisi sil
-- ================================================================
-- Soft delete: is_active = false.
-- Alt kategorisi varsa silinemez.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_category_delete(BIGINT);

CREATE OR REPLACE FUNCTION support.ticket_category_delete(
    p_category_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists    BOOLEAN;
BEGIN
    -- Kategori mevcut mu kontrol
    IF NOT EXISTS (SELECT 1 FROM support.ticket_categories WHERE id = p_category_id AND is_active = true) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.category-not-found';
    END IF;

    -- Alt kategorisi var mı kontrol
    SELECT EXISTS (
        SELECT 1 FROM support.ticket_categories
        WHERE parent_id = p_category_id AND is_active = true
    ) INTO v_exists;

    IF v_exists THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.category-has-children';
    END IF;

    -- Soft delete
    UPDATE support.ticket_categories
    SET is_active  = false,
        updated_at = NOW()
    WHERE id = p_category_id;
END;
$$;

COMMENT ON FUNCTION support.ticket_category_delete IS 'Soft-deletes a ticket category. Fails if category has active children.';
