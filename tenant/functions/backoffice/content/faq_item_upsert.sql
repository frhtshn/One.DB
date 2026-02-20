-- ================================================================
-- FAQ_ITEM_UPSERT: FAQ sorusu oluştur/güncelle
-- Çeviriler dahil (DELETE + INSERT semantiği)
-- ================================================================

DROP FUNCTION IF EXISTS content.faq_item_upsert(INTEGER, INTEGER, INTEGER, BOOLEAN, INTEGER, JSONB);

CREATE OR REPLACE FUNCTION content.faq_item_upsert(
    p_id                INTEGER     DEFAULT NULL,   -- NULL = create, değer = update
    p_category_id       INTEGER     DEFAULT NULL,   -- Kategori ID
    p_sort_order        INTEGER     DEFAULT 0,       -- Sıralama
    p_is_featured       BOOLEAN     DEFAULT FALSE,   -- Öne çıkan
    p_user_id           INTEGER     DEFAULT NULL,    -- İşlemi yapan kullanıcı
    p_translations      JSONB       DEFAULT NULL     -- [{languageCode, question, answer, status}]
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INTEGER;
    v_item JSONB;
BEGIN
    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'error.faq.user-id-required';
    END IF;

    IF p_id IS NOT NULL THEN
        UPDATE content.faq_items
        SET category_id = COALESCE(p_category_id, category_id),
            sort_order  = COALESCE(p_sort_order, sort_order),
            is_featured = COALESCE(p_is_featured, is_featured),
            updated_by  = p_user_id,
            updated_at  = NOW()
        WHERE id = p_id
        RETURNING id INTO v_id;

        IF v_id IS NULL THEN
            RAISE EXCEPTION 'error.faq.item-not-found';
        END IF;
    ELSE
        INSERT INTO content.faq_items (
            category_id, sort_order, is_featured, created_by, updated_by
        )
        VALUES (
            p_category_id, COALESCE(p_sort_order, 0),
            COALESCE(p_is_featured, FALSE), p_user_id, p_user_id
        )
        RETURNING id INTO v_id;
    END IF;

    -- Çeviriler
    IF p_translations IS NOT NULL AND jsonb_array_length(p_translations) > 0 THEN
        DELETE FROM content.faq_item_translations WHERE faq_item_id = v_id;

        FOR v_item IN SELECT * FROM jsonb_array_elements(p_translations)
        LOOP
            INSERT INTO content.faq_item_translations (
                faq_item_id, language_code, question, answer, status, created_by, updated_by
            )
            VALUES (
                v_id,
                v_item ->> 'languageCode',
                v_item ->> 'question',
                v_item ->> 'answer',
                COALESCE(v_item ->> 'status', 'published'),
                p_user_id,
                p_user_id
            );
        END LOOP;
    END IF;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION content.faq_item_upsert(INTEGER, INTEGER, INTEGER, BOOLEAN, INTEGER, JSONB) IS 'Create or update FAQ item with multilingual question/answer translations.';
