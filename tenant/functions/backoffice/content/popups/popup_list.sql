-- ================================================================
-- POPUP_LIST: Popup listesi (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır (user_assert_access_tenant)
-- Bu function sadece iş mantığını içerir.
-- ================================================================

DROP FUNCTION IF EXISTS content.popup_list(INTEGER, INTEGER, INTEGER, VARCHAR, BOOLEAN, TEXT);

CREATE OR REPLACE FUNCTION content.popup_list(
    p_page INTEGER DEFAULT 1,
    p_page_size INTEGER DEFAULT 20,
    p_popup_type_id INTEGER DEFAULT NULL,
    p_trigger_type VARCHAR(30) DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL,
    p_search TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_offset INTEGER;
    v_total_count INTEGER;
    v_items JSONB;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    -- Total count
    SELECT COUNT(*) INTO v_total_count
    FROM content.popups p
    WHERE p.is_deleted = FALSE
      AND (p_popup_type_id IS NULL OR p.popup_type_id = p_popup_type_id)
      AND (p_trigger_type IS NULL OR p.trigger_type = p_trigger_type)
      AND (p_is_active IS NULL OR p.is_active = p_is_active)
      AND (p_search IS NULL OR p.code ILIKE '%' || p_search || '%');

    -- Items with type info
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', p.id,
            'code', p.code,
            'popupTypeId', p.popup_type_id,
            'popupTypeCode', pt.code,
            'triggerType', p.trigger_type,
            'triggerDelay', p.trigger_delay,
            'frequencyType', p.frequency_type,
            'displayDuration', p.display_duration,
            'priority', p.priority,
            'startDate', p.start_date,
            'endDate', p.end_date,
            'isActive', p.is_active,
            'createdAt', p.created_at,
            'updatedAt', p.updated_at,
            -- İlk resim (thumbnail için)
            'thumbnail', (
                SELECT pi.image_url
                FROM content.popup_images pi
                WHERE pi.popup_id = p.id AND pi.is_active = TRUE
                ORDER BY pi.sort_order, pi.id
                LIMIT 1
            )
        ) ORDER BY p.priority DESC, p.created_at DESC
    ), '[]'::jsonb)
    INTO v_items
    FROM (
        SELECT * FROM content.popups
        WHERE is_deleted = FALSE
          AND (p_popup_type_id IS NULL OR popup_type_id = p_popup_type_id)
          AND (p_trigger_type IS NULL OR trigger_type = p_trigger_type)
          AND (p_is_active IS NULL OR is_active = p_is_active)
          AND (p_search IS NULL OR code ILIKE '%' || p_search || '%')
        ORDER BY priority DESC, created_at DESC
        LIMIT p_page_size OFFSET v_offset
    ) p
    LEFT JOIN content.popup_types pt ON pt.id = p.popup_type_id;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count,
        'page', p_page,
        'pageSize', p_page_size
    );
END;
$$;

COMMENT ON FUNCTION content.popup_list IS 'Lists popups for backoffice. Auth check done in Core DB.';
