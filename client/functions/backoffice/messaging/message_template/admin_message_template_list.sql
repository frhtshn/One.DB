-- ================================================================
-- ADMIN_MESSAGE_TEMPLATE_LIST: Bildirim şablonu listesi
-- Kanal, kategori, durum ve arama filtreleme desteği
-- Sayfalama ile toplam sayı döner
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_template_list(INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION messaging.admin_message_template_list(
    p_user_id       INTEGER,                         -- İşlemi yapan kullanıcı ID
    p_channel_type  VARCHAR(10) DEFAULT NULL,         -- Kanal filtresi: email, sms
    p_category      VARCHAR(30) DEFAULT NULL,         -- Kategori filtresi
    p_status        VARCHAR(20) DEFAULT NULL,         -- Durum filtresi
    p_search        VARCHAR(200) DEFAULT NULL,        -- Ad/kod arama
    p_offset        INTEGER DEFAULT 0,                -- Sayfalama: başlangıç
    p_limit         INTEGER DEFAULT 20                -- Sayfalama: sayfa boyutu
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
      AND (p_category IS NULL OR t.category = p_category)
      AND (p_status IS NULL OR t.status = p_status)
      AND (p_search IS NULL OR t.name ILIKE '%' || p_search || '%' OR t.code ILIKE '%' || p_search || '%');

    -- Sayfalanmış liste
    SELECT COALESCE(jsonb_agg(row_data ORDER BY created_at DESC), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', t.id,
            'code', t.code,
            'name', t.name,
            'channelType', t.channel_type,
            'category', t.category,
            'description', t.description,
            'isSystem', t.is_system,
            'status', t.status,
            'createdAt', t.created_at,
            'createdBy', t.created_by,
            'updatedAt', t.updated_at
        ) AS row_data,
        t.created_at
        FROM messaging.message_templates t
        WHERE t.is_deleted = FALSE
          AND (p_channel_type IS NULL OR t.channel_type = p_channel_type)
          AND (p_category IS NULL OR t.category = p_category)
          AND (p_status IS NULL OR t.status = p_status)
          AND (p_search IS NULL OR t.name ILIKE '%' || p_search || '%' OR t.code ILIKE '%' || p_search || '%')
        ORDER BY t.created_at DESC
        OFFSET p_offset
        LIMIT p_limit
    ) sub;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count
    );
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_template_list(INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER) IS 'List tenant message templates with channel, category, status, and search filters. Returns paginated results with total count.';
