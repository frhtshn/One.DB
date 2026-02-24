-- ================================================================
-- ADMIN_CAMPAIGN_GET: Kampanya detaylarını getirme
-- Kampanya, çeviriler ve segmentlerle birlikte döner
-- JSON formatında zengin yanıt
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_campaign_get(INTEGER);

CREATE OR REPLACE FUNCTION messaging.admin_campaign_get(
    p_campaign_id       INTEGER             -- Kampanya ID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', c.id,
        'name', c.name,
        'channel_type', c.channel_type,
        'template_id', c.template_id,
        'status', c.status,
        'scheduled_at', c.scheduled_at,
        'published_at', c.published_at,
        'processing_started_at', c.processing_started_at,
        'completed_at', c.completed_at,
        'total_recipients', c.total_recipients,
        'sent_count', c.sent_count,
        'failed_count', c.failed_count,
        'created_at', c.created_at,
        'created_by', c.created_by,
        'updated_at', c.updated_at,
        'translations', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', ct.id,
                'language_code', ct.language_code,
                'subject', ct.subject,
                'body', ct.body,
                'preview_text', ct.preview_text
            ) ORDER BY ct.language_code)
            FROM messaging.message_campaign_translations ct
            WHERE ct.campaign_id = c.id
        ), '[]'::JSONB),
        'segments', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', cs.id,
                'segment_type', cs.segment_type,
                'segment_value', cs.segment_value,
                'is_include', cs.is_include
            ) ORDER BY cs.segment_type)
            FROM messaging.message_campaign_segments cs
            WHERE cs.campaign_id = c.id
        ), '[]'::JSONB)
    ) INTO v_result
    FROM messaging.message_campaigns c
    WHERE c.id = p_campaign_id AND c.is_deleted = FALSE;

    IF v_result IS NULL THEN
        RAISE EXCEPTION 'error.messaging.campaign-not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION messaging.admin_campaign_get(INTEGER) IS 'Get campaign details with translations and segments as a single JSON response';
