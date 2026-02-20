-- ================================================================
-- PROMOTION_TYPE_UPSERT: Promosyon tipi oluştur/güncelle
-- Çeviriler dahil (DELETE + INSERT semantiği)
-- ================================================================

DROP FUNCTION IF EXISTS content.promotion_type_upsert(INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER, JSONB);

CREATE OR REPLACE FUNCTION content.promotion_type_upsert(
    p_id                INTEGER     DEFAULT NULL,
    p_code              VARCHAR(50) DEFAULT NULL,
    p_icon              VARCHAR(50) DEFAULT NULL,
    p_color             VARCHAR(20) DEFAULT NULL,
    p_badge_text        VARCHAR(30) DEFAULT NULL,
    p_sort_order        INTEGER     DEFAULT 0,
    p_user_id           INTEGER     DEFAULT NULL,
    p_translations      JSONB       DEFAULT NULL    -- [{languageCode, name, description}]
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INTEGER;
    v_item JSONB;
BEGIN
    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'error.promotion.user-id-required';
    END IF;

    IF p_id IS NOT NULL THEN
        UPDATE content.promotion_types
        SET code       = COALESCE(p_code, code),
            icon       = COALESCE(p_icon, icon),
            color      = COALESCE(p_color, color),
            badge_text = COALESCE(p_badge_text, badge_text),
            sort_order = COALESCE(p_sort_order, sort_order),
            updated_by = p_user_id, updated_at = NOW()
        WHERE id = p_id
        RETURNING id INTO v_id;

        IF v_id IS NULL THEN
            RAISE EXCEPTION 'error.promotion.type-not-found';
        END IF;
    ELSE
        IF p_code IS NULL OR p_code = '' THEN
            RAISE EXCEPTION 'error.promotion.type-code-required';
        END IF;

        INSERT INTO content.promotion_types (code, icon, color, badge_text, sort_order, created_by, updated_by)
        VALUES (p_code, p_icon, p_color, p_badge_text, COALESCE(p_sort_order, 0), p_user_id, p_user_id)
        RETURNING id INTO v_id;
    END IF;

    IF p_translations IS NOT NULL AND jsonb_array_length(p_translations) > 0 THEN
        DELETE FROM content.promotion_type_translations WHERE promotion_type_id = v_id;
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_translations)
        LOOP
            INSERT INTO content.promotion_type_translations (
                promotion_type_id, language_code, name, description, created_by, updated_by
            )
            VALUES (v_id, v_item ->> 'languageCode', v_item ->> 'name', v_item ->> 'description', p_user_id, p_user_id);
        END LOOP;
    END IF;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION content.promotion_type_upsert(INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER, JSONB) IS 'Create or update promotion type with translations.';
