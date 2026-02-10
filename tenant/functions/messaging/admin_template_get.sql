-- ================================================================
-- TEMPLATE_GET: Şablon detaylarını getirme
-- Şablon ve çevirileriyle birlikte döner
-- JSON formatında zengin yanıt
-- ================================================================

DROP FUNCTION IF EXISTS messaging.template_get(INTEGER);

CREATE OR REPLACE FUNCTION messaging.template_get(
    p_template_id       INTEGER             -- Şablon ID
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
        'channel_type', t.channel_type,
        'description', t.description,
        'status', t.status,
        'created_at', t.created_at,
        'created_by', t.created_by,
        'updated_at', t.updated_at,
        'translations', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', tt.id,
                'language_code', tt.language_code,
                'subject', tt.subject,
                'body', tt.body,
                'preview_text', tt.preview_text
            ) ORDER BY tt.language_code)
            FROM messaging.message_template_translations tt
            WHERE tt.template_id = t.id
        ), '[]'::JSONB)
    ) INTO v_result
    FROM messaging.message_templates t
    WHERE t.id = p_template_id AND t.is_deleted = FALSE;

    IF v_result IS NULL THEN
        RAISE EXCEPTION 'error.messaging.template-not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION messaging.template_get(INTEGER) IS 'Get template details with translations as a single JSON response';
