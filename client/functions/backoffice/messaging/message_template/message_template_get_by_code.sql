-- ================================================================
-- MESSAGE_TEMPLATE_GET_BY_CODE: Kod ile şablon getirme
-- Backend internal kullanım (auth kontrolü yok)
-- Sadece aktif şablonları döner
-- Belirtilen dildeki çeviriyi döner
-- ================================================================

DROP FUNCTION IF EXISTS messaging.message_template_get_by_code(VARCHAR, CHAR);

CREATE OR REPLACE FUNCTION messaging.message_template_get_by_code(
    p_code          VARCHAR(100),                    -- Şablon kodu
    p_language_code CHAR(2)                          -- İstenen dil kodu
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_template_id INTEGER;
    v_channel_type VARCHAR(10);
    v_variables JSONB;
    v_result JSONB;
BEGIN
    -- Aktif şablon bul
    SELECT id, channel_type, variables
    INTO v_template_id, v_channel_type, v_variables
    FROM messaging.message_templates
    WHERE code = p_code AND status = 'active' AND is_deleted = FALSE;

    IF v_template_id IS NULL THEN
        RAISE EXCEPTION 'error.notification-template.not-found';
    END IF;

    -- Belirtilen dildeki çeviriyi getir
    SELECT jsonb_build_object(
        'code', p_code,
        'channelType', v_channel_type,
        'variables', v_variables,
        'subject', tt.subject,
        'bodyHtml', tt.body_html,
        'bodyText', tt.body_text,
        'previewText', tt.preview_text
    ) INTO v_result
    FROM messaging.message_template_translations tt
    WHERE tt.template_id = v_template_id AND tt.language_code = p_language_code;

    IF v_result IS NULL THEN
        RAISE EXCEPTION 'error.notification-template.translation-not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION messaging.message_template_get_by_code(VARCHAR, CHAR) IS 'Get active client message template content by code and language. Used by backend for rendering. No auth check.';
