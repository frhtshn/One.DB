-- ================================================================
-- CONTENT_CATEGORY_UPSERT: İçerik kategorisi oluştur/güncelle
-- Çeviriler dahil (DELETE + INSERT semantiği)
-- ================================================================

DROP FUNCTION IF EXISTS content.content_category_upsert(INTEGER, VARCHAR, VARCHAR, INTEGER, INTEGER, JSONB);

CREATE OR REPLACE FUNCTION content.content_category_upsert(
    p_id                INTEGER     DEFAULT NULL,   -- NULL = create, değer = update
    p_code              VARCHAR(50) DEFAULT NULL,    -- Benzersiz kod
    p_icon              VARCHAR(100) DEFAULT NULL,   -- İkon
    p_sort_order        INTEGER     DEFAULT 0,       -- Sıralama
    p_user_id           INTEGER     DEFAULT NULL,    -- İşlemi yapan kullanıcı
    p_translations      JSONB       DEFAULT NULL     -- [{languageCode, name, description}]
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INTEGER;
    v_item JSONB;
BEGIN
    -- Parametre doğrulama
    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'error.content.user-id-required';
    END IF;

    IF p_id IS NOT NULL THEN
        -- Update
        UPDATE content.content_categories
        SET code       = COALESCE(p_code, code),
            icon       = COALESCE(p_icon, icon),
            sort_order = COALESCE(p_sort_order, sort_order),
            updated_by = p_user_id,
            updated_at = NOW()
        WHERE id = p_id
        RETURNING id INTO v_id;

        IF v_id IS NULL THEN
            RAISE EXCEPTION 'error.content.category-not-found';
        END IF;
    ELSE
        -- Create
        IF p_code IS NULL OR p_code = '' THEN
            RAISE EXCEPTION 'error.content.category-code-required';
        END IF;

        INSERT INTO content.content_categories (code, icon, sort_order, created_by, updated_by)
        VALUES (p_code, p_icon, COALESCE(p_sort_order, 0), p_user_id, p_user_id)
        RETURNING id INTO v_id;
    END IF;

    -- Çeviriler (varsa DELETE + INSERT)
    IF p_translations IS NOT NULL AND jsonb_array_length(p_translations) > 0 THEN
        DELETE FROM content.content_category_translations WHERE category_id = v_id;

        FOR v_item IN SELECT * FROM jsonb_array_elements(p_translations)
        LOOP
            INSERT INTO content.content_category_translations (
                category_id, language_code, name, description, created_by, updated_by
            )
            VALUES (
                v_id,
                v_item ->> 'languageCode',
                v_item ->> 'name',
                v_item ->> 'description',
                p_user_id,
                p_user_id
            );
        END LOOP;
    END IF;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION content.content_category_upsert(INTEGER, VARCHAR, VARCHAR, INTEGER, INTEGER, JSONB) IS 'Create or update content category with translations. Translations use delete+insert semantics.';
