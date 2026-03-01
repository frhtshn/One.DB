-- ================================================================
-- POPUP_LIST: Popup listesi
-- Tip, durum filtreli, sayfalanmış
-- ================================================================

DROP FUNCTION IF EXISTS content.popup_list(INTEGER, BOOLEAN, CHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.popup_list(
    p_popup_type_id     INTEGER     DEFAULT NULL,   -- Tip filtresi
    p_is_active         BOOLEAN     DEFAULT NULL,    -- Aktiflik filtresi
    p_language_code     CHAR(2)     DEFAULT 'en',    -- Dil kodu
    p_offset            INTEGER     DEFAULT 0,
    p_limit             INTEGER     DEFAULT 20
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count INTEGER;
    v_items JSONB;
BEGIN
    SELECT COUNT(*) INTO v_total_count
    FROM content.popups p
    WHERE p.is_deleted = FALSE
      AND (p_popup_type_id IS NULL OR p.popup_type_id = p_popup_type_id)
      AND (p_is_active IS NULL OR p.is_active = p_is_active);

    SELECT COALESCE(jsonb_agg(row_data ORDER BY priority DESC, created_at DESC), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', p.id,
            'popupTypeId', p.popup_type_id,
            'code', p.code,
            'triggerType', p.trigger_type,
            'frequencyType', p.frequency_type,
            'startDate', p.start_date,
            'endDate', p.end_date,
            'priority', p.priority,
            'isActive', p.is_active,
            'title', t.title,
            'createdAt', p.created_at
        ) AS row_data,
        p.priority, p.created_at
        FROM content.popups p
        LEFT JOIN content.popup_translations t
            ON t.popup_id = p.id AND t.language_code = p_language_code
        WHERE p.is_deleted = FALSE
          AND (p_popup_type_id IS NULL OR p.popup_type_id = p_popup_type_id)
          AND (p_is_active IS NULL OR p.is_active = p_is_active)
        ORDER BY p.priority DESC, p.created_at DESC
        OFFSET p_offset
        LIMIT p_limit
    ) sub;

    RETURN jsonb_build_object('items', v_items, 'totalCount', v_total_count);
END;
$$;

COMMENT ON FUNCTION content.popup_list(INTEGER, BOOLEAN, CHAR, INTEGER, INTEGER) IS 'List popups with type and active status filters. Paginated.';
