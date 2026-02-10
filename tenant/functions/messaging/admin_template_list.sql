-- ================================================================
-- ADMIN_TEMPLATE_LIST: Şablon listesi (filtreleme destekli)
-- Kanal ve durum bazlı filtreleme, sayfalama desteği
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_template_list(VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION messaging.admin_template_list(
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
    FROM messaging.message_templates t
    WHERE t.is_deleted = FALSE
      AND (p_channel_type IS NULL OR t.channel_type = p_channel_type)
      AND (p_status IS NULL OR t.status = p_status)
      AND (p_search IS NULL OR t.name ILIKE '%' || p_search || '%');

    -- Sayfalanmış liste
    SELECT COALESCE(jsonb_agg(row_data ORDER BY created_at DESC), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', t.id,
            'code', t.code,
            'name', t.name,
            'channel_type', t.channel_type,
            'description', t.description,
            'status', t.status,
            'created_at', t.created_at,
            'created_by', t.created_by
        ) AS row_data,
        t.created_at
        FROM messaging.message_templates t
        WHERE t.is_deleted = FALSE
          AND (p_channel_type IS NULL OR t.channel_type = p_channel_type)
          AND (p_status IS NULL OR t.status = p_status)
          AND (p_search IS NULL OR t.name ILIKE '%' || p_search || '%')
        ORDER BY t.created_at DESC
        OFFSET p_offset
        LIMIT p_limit
    ) sub;

    RETURN jsonb_build_object(
        'items', v_items,
        'total_count', v_total_count
    );
END;
$$;

COMMENT ON FUNCTION messaging.admin_template_list(VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER) IS 'List message templates with channel, status, and search filters. Returns paginated results with total count.';
