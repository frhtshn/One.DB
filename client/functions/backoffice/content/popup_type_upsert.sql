-- ================================================================
-- POPUP_TYPE_UPSERT: Popup tipi oluştur/güncelle
-- Çeviriler dahil (DELETE + INSERT semantiği)
-- ================================================================

DROP FUNCTION IF EXISTS content.popup_type_upsert(INTEGER, VARCHAR, VARCHAR, INTEGER, INTEGER, BOOLEAN, BOOLEAN, BOOLEAN, INTEGER, INTEGER, JSONB);

CREATE OR REPLACE FUNCTION content.popup_type_upsert(
    p_id                    INTEGER     DEFAULT NULL,
    p_code                  VARCHAR(50) DEFAULT NULL,
    p_icon                  VARCHAR(50) DEFAULT NULL,
    p_default_width         INTEGER     DEFAULT NULL,
    p_default_height        INTEGER     DEFAULT NULL,
    p_has_overlay           BOOLEAN     DEFAULT TRUE,
    p_can_close             BOOLEAN     DEFAULT TRUE,
    p_close_on_overlay_click BOOLEAN    DEFAULT TRUE,
    p_sort_order            INTEGER     DEFAULT 0,
    p_user_id               INTEGER     DEFAULT NULL,
    p_translations          JSONB       DEFAULT NULL    -- [{languageCode, name, description}]
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INTEGER;
    v_item JSONB;
BEGIN
    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'error.popup.user-id-required';
    END IF;

    IF p_id IS NOT NULL THEN
        UPDATE content.popup_types
        SET code                   = COALESCE(p_code, code),
            icon                   = COALESCE(p_icon, icon),
            default_width          = COALESCE(p_default_width, default_width),
            default_height         = COALESCE(p_default_height, default_height),
            has_overlay            = COALESCE(p_has_overlay, has_overlay),
            can_close              = COALESCE(p_can_close, can_close),
            close_on_overlay_click = COALESCE(p_close_on_overlay_click, close_on_overlay_click),
            sort_order             = COALESCE(p_sort_order, sort_order)
        WHERE id = p_id
        RETURNING id INTO v_id;

        IF v_id IS NULL THEN
            RAISE EXCEPTION 'error.popup.type-not-found';
        END IF;
    ELSE
        IF p_code IS NULL OR p_code = '' THEN
            RAISE EXCEPTION 'error.popup.type-code-required';
        END IF;

        INSERT INTO content.popup_types (
            code, icon, default_width, default_height,
            has_overlay, can_close, close_on_overlay_click, sort_order, created_by
        )
        VALUES (
            p_code, p_icon, p_default_width, p_default_height,
            COALESCE(p_has_overlay, TRUE), COALESCE(p_can_close, TRUE),
            COALESCE(p_close_on_overlay_click, TRUE), COALESCE(p_sort_order, 0), p_user_id
        )
        RETURNING id INTO v_id;
    END IF;

    IF p_translations IS NOT NULL AND jsonb_array_length(p_translations) > 0 THEN
        DELETE FROM content.popup_type_translations WHERE popup_type_id = v_id;

        FOR v_item IN SELECT * FROM jsonb_array_elements(p_translations)
        LOOP
            INSERT INTO content.popup_type_translations (
                popup_type_id, language_code, name, description, created_by
            )
            VALUES (v_id, v_item ->> 'languageCode', v_item ->> 'name', v_item ->> 'description', p_user_id);
        END LOOP;
    END IF;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION content.popup_type_upsert(INTEGER, VARCHAR, VARCHAR, INTEGER, INTEGER, BOOLEAN, BOOLEAN, BOOLEAN, INTEGER, INTEGER, JSONB) IS 'Create or update popup type with translations and default display settings.';
