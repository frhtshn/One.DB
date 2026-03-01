-- ================================================================
-- CONTENT_TYPE_UPSERT: İçerik tipi oluştur/güncelle
-- Çeviriler dahil (DELETE + INSERT semantiği)
-- ================================================================

DROP FUNCTION IF EXISTS content.content_type_upsert(INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, BOOLEAN, BOOLEAN, BOOLEAN, INTEGER, INTEGER, JSONB);

CREATE OR REPLACE FUNCTION content.content_type_upsert(
    p_id                    INTEGER     DEFAULT NULL,   -- NULL = create, değer = update
    p_category_id           INTEGER     DEFAULT NULL,   -- Kategori ID
    p_code                  VARCHAR(50) DEFAULT NULL,    -- Benzersiz kod
    p_template_key          VARCHAR(100) DEFAULT NULL,   -- Şablon anahtarı
    p_icon                  VARCHAR(100) DEFAULT NULL,   -- İkon
    p_requires_acceptance   BOOLEAN     DEFAULT FALSE,   -- Kabul gerektirir mi (Terms vb.)
    p_show_in_footer        BOOLEAN     DEFAULT FALSE,   -- Footer'da göster
    p_show_in_menu          BOOLEAN     DEFAULT FALSE,   -- Menüde göster
    p_sort_order            INTEGER     DEFAULT 0,       -- Sıralama
    p_user_id               INTEGER     DEFAULT NULL,    -- İşlemi yapan kullanıcı
    p_translations          JSONB       DEFAULT NULL     -- [{languageCode, name, description}]
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
        UPDATE content.content_types
        SET category_id         = COALESCE(p_category_id, category_id),
            code                = COALESCE(p_code, code),
            template_key        = COALESCE(p_template_key, template_key),
            icon                = COALESCE(p_icon, icon),
            requires_acceptance = COALESCE(p_requires_acceptance, requires_acceptance),
            show_in_footer      = COALESCE(p_show_in_footer, show_in_footer),
            show_in_menu        = COALESCE(p_show_in_menu, show_in_menu),
            sort_order          = COALESCE(p_sort_order, sort_order),
            updated_by          = p_user_id,
            updated_at          = NOW()
        WHERE id = p_id
        RETURNING id INTO v_id;

        IF v_id IS NULL THEN
            RAISE EXCEPTION 'error.content.type-not-found';
        END IF;
    ELSE
        -- Create
        IF p_code IS NULL OR p_code = '' THEN
            RAISE EXCEPTION 'error.content.type-code-required';
        END IF;

        INSERT INTO content.content_types (
            category_id, code, template_key, icon,
            requires_acceptance, show_in_footer, show_in_menu,
            sort_order, created_by, updated_by
        )
        VALUES (
            p_category_id, p_code, p_template_key, p_icon,
            COALESCE(p_requires_acceptance, FALSE),
            COALESCE(p_show_in_footer, FALSE),
            COALESCE(p_show_in_menu, FALSE),
            COALESCE(p_sort_order, 0), p_user_id, p_user_id
        )
        RETURNING id INTO v_id;
    END IF;

    -- Çeviriler (varsa DELETE + INSERT)
    IF p_translations IS NOT NULL AND jsonb_array_length(p_translations) > 0 THEN
        DELETE FROM content.content_type_translations WHERE content_type_id = v_id;

        FOR v_item IN SELECT * FROM jsonb_array_elements(p_translations)
        LOOP
            INSERT INTO content.content_type_translations (
                content_type_id, language_code, name, description, created_by, updated_by
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

COMMENT ON FUNCTION content.content_type_upsert(INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, BOOLEAN, BOOLEAN, BOOLEAN, INTEGER, INTEGER, JSONB) IS 'Create or update content type with translations. Translations use delete+insert semantics.';
