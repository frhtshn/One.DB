-- ================================================================
-- TICKET_CATEGORY_CREATE: Ticket kategorisi oluştur
-- ================================================================
-- Hiyerarşik kategori ağacına yeni kategori ekler.
-- JSONB name ile çoklu dil desteği.
-- parent_id ile alt kategori tanımlanabilir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_category_create(VARCHAR, TEXT, BIGINT, TEXT, INT);

CREATE OR REPLACE FUNCTION support.ticket_category_create(
    p_code          VARCHAR(50),
    p_name          TEXT,
    p_parent_id     BIGINT DEFAULT NULL,
    p_description   TEXT DEFAULT NULL,
    p_display_order INT DEFAULT 0
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_category_id   BIGINT;
    v_name_jsonb    JSONB;
    v_desc_jsonb    JSONB;
BEGIN
    -- Code validasyonu
    IF p_code IS NULL OR TRIM(p_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.category-code-required';
    END IF;

    -- Name JSONB parse
    IF p_name IS NULL OR TRIM(p_name) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.category-name-required';
    END IF;

    BEGIN
        v_name_jsonb := p_name::JSONB;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.invalid-category-name-format';
    END;

    -- Description JSONB parse (opsiyonel)
    IF p_description IS NOT NULL AND TRIM(p_description) != '' THEN
        BEGIN
            v_desc_jsonb := p_description::JSONB;
        EXCEPTION WHEN OTHERS THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.invalid-category-description-format';
        END;
    END IF;

    -- Aktif kategorilerde kod benzersizliği
    IF EXISTS (SELECT 1 FROM support.ticket_categories WHERE code = TRIM(p_code) AND is_active = true) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.category-code-exists';
    END IF;

    -- Üst kategori kontrolü (varsa aktif mi?)
    IF p_parent_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM support.ticket_categories WHERE id = p_parent_id AND is_active = true) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.parent-category-not-found';
        END IF;
    END IF;

    -- Kategori oluştur
    INSERT INTO support.ticket_categories (
        parent_id, code, name, description, display_order,
        is_active, created_at, updated_at
    ) VALUES (
        p_parent_id, TRIM(p_code), v_name_jsonb, v_desc_jsonb, p_display_order,
        true, NOW(), NOW()
    )
    RETURNING id INTO v_category_id;

    RETURN v_category_id;
END;
$$;

COMMENT ON FUNCTION support.ticket_category_create IS 'Creates a ticket category with multi-language name (JSONB). Supports hierarchical structure via parent_id.';
