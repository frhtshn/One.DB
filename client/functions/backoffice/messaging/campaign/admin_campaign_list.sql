-- ================================================================
-- ADMIN_CAMPAIGN_LIST: Kampanya listesi (filtreleme destekli)
-- Kanal, durum ve arama bazlı filtreleme
-- Sayfalama desteği (offset/limit)
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_campaign_list(VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION messaging.admin_campaign_list(
    p_channel_type      VARCHAR(10) DEFAULT NULL,  -- Kanal filtresi
    p_status            VARCHAR(20) DEFAULT NULL,  -- Durum filtresi
    p_search            VARCHAR(200) DEFAULT NULL,  -- Ad arama
    p_offset            INTEGER DEFAULT 0,          -- Sayfalama: başlangıç
    p_limit             INTEGER DEFAULT 20          -- Sayfalama: sayfa boyutu
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count INTEGER;
    v_items JSONB;
BEGIN
    -- Toplam sayı
    SELECT COUNT(*) INTO v_total_count
    FROM messaging.message_campaigns c
    WHERE c.is_deleted = FALSE
      AND (p_channel_type IS NULL OR c.channel_type = p_channel_type)
      AND (p_status IS NULL OR c.status = p_status)
      AND (p_search IS NULL OR c.name ILIKE '%' || p_search || '%');

    -- Sayfalanmış liste
    SELECT COALESCE(jsonb_agg(row_data ORDER BY created_at DESC), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', c.id,
            'name', c.name,
            'channel_type', c.channel_type,
            'status', c.status,
            'template_id', c.template_id,
            'scheduled_at', c.scheduled_at,
            'published_at', c.published_at,
            'completed_at', c.completed_at,
            'total_recipients', c.total_recipients,
            'sent_count', c.sent_count,
            'failed_count', c.failed_count,
            'created_at', c.created_at,
            'created_by', c.created_by
        ) AS row_data,
        c.created_at
        FROM messaging.message_campaigns c
        WHERE c.is_deleted = FALSE
          AND (p_channel_type IS NULL OR c.channel_type = p_channel_type)
          AND (p_status IS NULL OR c.status = p_status)
          AND (p_search IS NULL OR c.name ILIKE '%' || p_search || '%')
        ORDER BY c.created_at DESC
        OFFSET p_offset
        LIMIT p_limit
    ) sub;

    RETURN jsonb_build_object(
        'items', v_items,
        'total_count', v_total_count
    );
END;
$$;

COMMENT ON FUNCTION messaging.admin_campaign_list(VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER) IS 'List campaigns with channel, status, and search filters. Returns paginated results with total count.';
