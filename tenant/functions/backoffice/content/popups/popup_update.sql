-- ================================================================
-- POPUP_UPDATE: Popup güncelle (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır (user_assert_access_tenant)
-- Bu function sadece iş mantığını içerir.
-- Partial update: NULL değerler mevcut değeri korur.
-- ================================================================

DROP FUNCTION IF EXISTS content.popup_update(
    INTEGER, INTEGER, VARCHAR, INTEGER, BOOLEAN, INTEGER, INTEGER,
    VARCHAR, INTEGER, INTEGER, BOOLEAN,
    VARCHAR, INTEGER, INTEGER,
    VARCHAR, VARCHAR,
    TIMESTAMP, TIMESTAMP,
    INTEGER[], CHAR(2)[], CHAR(2)[],
    TEXT[], TEXT[],
    INTEGER, BOOLEAN, INTEGER
);

CREATE OR REPLACE FUNCTION content.popup_update(
    p_id INTEGER,
    p_popup_type_id INTEGER DEFAULT NULL,
    p_code VARCHAR(50) DEFAULT NULL,
    -- Görüntüleme
    p_display_duration INTEGER DEFAULT NULL,
    p_auto_close BOOLEAN DEFAULT NULL,
    p_width INTEGER DEFAULT NULL,
    p_height INTEGER DEFAULT NULL,
    -- Tetikleyici
    p_trigger_type VARCHAR(30) DEFAULT NULL,
    p_trigger_delay INTEGER DEFAULT NULL,
    p_trigger_scroll_percent INTEGER DEFAULT NULL,
    p_trigger_exit_intent BOOLEAN DEFAULT NULL,
    -- Sıklık
    p_frequency_type VARCHAR(30) DEFAULT NULL,
    p_frequency_cap INTEGER DEFAULT NULL,
    p_frequency_hours INTEGER DEFAULT NULL,
    -- Link
    p_link_url VARCHAR(500) DEFAULT NULL,
    p_link_target VARCHAR(20) DEFAULT NULL,
    -- Tarihler
    p_start_date TIMESTAMP DEFAULT NULL,
    p_end_date TIMESTAMP DEFAULT NULL,
    -- Hedefleme
    p_segment_ids INTEGER[] DEFAULT NULL,
    p_country_codes CHAR(2)[] DEFAULT NULL,
    p_excluded_country_codes CHAR(2)[] DEFAULT NULL,
    p_page_urls TEXT[] DEFAULT NULL,
    p_excluded_page_urls TEXT[] DEFAULT NULL,
    -- Diğer
    p_priority INTEGER DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL,
    p_operator_id INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Popup var mı kontrolü
    IF NOT EXISTS (SELECT 1 FROM content.popups WHERE id = p_id AND is_deleted = FALSE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.popup.not-found';
    END IF;

    -- Popup type kontrolü
    IF p_popup_type_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM content.popup_types WHERE id = p_popup_type_id AND is_active = TRUE
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.popup.invalid-popup-type';
    END IF;

    -- Code benzersizlik kontrolü
    IF p_code IS NOT NULL AND EXISTS (
        SELECT 1 FROM content.popups WHERE code = p_code AND id != p_id AND is_deleted = FALSE
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.popup.code-exists';
    END IF;

    UPDATE content.popups
    SET popup_type_id = COALESCE(p_popup_type_id, popup_type_id),
        code = COALESCE(p_code, code),
        display_duration = COALESCE(p_display_duration, display_duration),
        auto_close = COALESCE(p_auto_close, auto_close),
        width = COALESCE(p_width, width),
        height = COALESCE(p_height, height),
        trigger_type = COALESCE(p_trigger_type, trigger_type),
        trigger_delay = COALESCE(p_trigger_delay, trigger_delay),
        trigger_scroll_percent = COALESCE(p_trigger_scroll_percent, trigger_scroll_percent),
        trigger_exit_intent = COALESCE(p_trigger_exit_intent, trigger_exit_intent),
        frequency_type = COALESCE(p_frequency_type, frequency_type),
        frequency_cap = COALESCE(p_frequency_cap, frequency_cap),
        frequency_hours = COALESCE(p_frequency_hours, frequency_hours),
        link_url = COALESCE(p_link_url, link_url),
        link_target = COALESCE(p_link_target, link_target),
        start_date = COALESCE(p_start_date, start_date),
        end_date = COALESCE(p_end_date, end_date),
        segment_ids = COALESCE(p_segment_ids, segment_ids),
        country_codes = COALESCE(p_country_codes, country_codes),
        excluded_country_codes = COALESCE(p_excluded_country_codes, excluded_country_codes),
        page_urls = COALESCE(p_page_urls, page_urls),
        excluded_page_urls = COALESCE(p_excluded_page_urls, excluded_page_urls),
        priority = COALESCE(p_priority, priority),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW(),
        updated_by = p_operator_id
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION content.popup_update IS 'Updates popup with partial update support. Auth check done in Core DB.';
