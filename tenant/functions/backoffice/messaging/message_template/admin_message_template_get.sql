-- ================================================================
-- ADMIN_MESSAGE_TEMPLATE_GET: Bildirim şablonu detayları
-- Şablon ve çevirileriyle birlikte döner
-- JSON formatında zengin yanıt
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_template_get(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION messaging.admin_message_template_get(
    p_user_id       INTEGER,                         -- İşlemi yapan kullanıcı ID
    p_id            INTEGER                          -- Şablon ID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', t.id,
        'code', t.code,
        'name', t.name,
        'channelType', t.channel_type,
        'category', t.category,
        'description', t.description,
        'variables', t.variables,
        'isSystem', t.is_system,
        'status', t.status,
        'createdAt', t.created_at,
        'createdBy', t.created_by,
        'updatedAt', t.updated_at,
        'updatedBy', t.updated_by,
        'translations', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', tt.id,
                'languageCode', tt.language_code,
                'subject', tt.subject,
                'bodyHtml', tt.body_html,
                'bodyText', tt.body_text,
                'previewText', tt.preview_text
            ) ORDER BY tt.language_code)
            FROM messaging.message_template_translations tt
            WHERE tt.template_id = t.id
        ), '[]'::JSONB)
    ) INTO v_result
    FROM messaging.message_templates t
    WHERE t.id = p_id AND t.is_deleted = FALSE;

    IF v_result IS NULL THEN
        RAISE EXCEPTION 'error.notification-template.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_template_get(INTEGER, INTEGER) IS 'Get tenant message template details with all translations as a single JSON response.';
