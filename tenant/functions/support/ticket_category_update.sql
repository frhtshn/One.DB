-- ================================================================
-- TICKET_CATEGORY_UPDATE: Ticket kategorisi güncelle
-- ================================================================
-- Mevcut kategori bilgilerini günceller.
-- Sadece verilen parametreler güncellenir (COALESCE).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_category_update(BIGINT, TEXT, TEXT, INT);

CREATE OR REPLACE FUNCTION support.ticket_category_update(
    p_category_id   BIGINT,
    p_name          TEXT DEFAULT NULL,
    p_description   TEXT DEFAULT NULL,
    p_display_order INT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_category      RECORD;
    v_name_jsonb    JSONB := NULL;
    v_desc_jsonb    JSONB := NULL;
BEGIN
    -- Kategori mevcut mu kontrol
    SELECT id, name, description, display_order INTO v_category
    FROM support.ticket_categories
    WHERE id = p_category_id AND is_active = true;

    IF v_category.id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.category-not-found';
    END IF;

    -- En az bir alan değişmeli
    IF p_name IS NULL AND p_description IS NULL AND p_display_order IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.no-fields-to-update';
    END IF;

    -- Name JSONB parse (verilmişse)
    IF p_name IS NOT NULL AND TRIM(p_name) != '' THEN
        BEGIN
            v_name_jsonb := p_name::JSONB;
        EXCEPTION WHEN OTHERS THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.invalid-category-name-format';
        END;
    END IF;

    -- Description JSONB parse (verilmişse)
    IF p_description IS NOT NULL AND TRIM(p_description) != '' THEN
        BEGIN
            v_desc_jsonb := p_description::JSONB;
        EXCEPTION WHEN OTHERS THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.invalid-category-description-format';
        END;
    END IF;

    -- Güncelle
    UPDATE support.ticket_categories
    SET name          = COALESCE(v_name_jsonb, name),
        description   = COALESCE(v_desc_jsonb, description),
        display_order = COALESCE(p_display_order, display_order),
        updated_at    = NOW()
    WHERE id = p_category_id;
END;
$$;

COMMENT ON FUNCTION support.ticket_category_update IS 'Updates ticket category name, description, or display order. Only provided fields are changed.';
