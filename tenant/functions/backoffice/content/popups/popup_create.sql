-- ================================================================
-- POPUP_CREATE: Popup oluştur (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır (user_assert_access_tenant)
-- Bu function sadece iş mantığını içerir.
-- ================================================================

DROP FUNCTION IF EXISTS content.popup_create(
    INTEGER, VARCHAR, INTEGER, BOOLEAN, INTEGER, INTEGER,
    VARCHAR, INTEGER, INTEGER, BOOLEAN,
    VARCHAR, INTEGER, INTEGER,
    VARCHAR, VARCHAR,
    TIMESTAMP, TIMESTAMP,
    INTEGER[], CHAR(2)[], CHAR(2)[],
    TEXT[], TEXT[],
    INTEGER, BOOLEAN, INTEGER
);

CREATE OR REPLACE FUNCTION content.popup_create(
    p_popup_type_id INTEGER,
    p_code VARCHAR(50) DEFAULT NULL,
    -- Görüntüleme
    p_display_duration INTEGER DEFAULT NULL,
    p_auto_close BOOLEAN DEFAULT FALSE,
    p_width INTEGER DEFAULT NULL,
    p_height INTEGER DEFAULT NULL,
    -- Tetikleyici
    p_trigger_type VARCHAR(30) DEFAULT 'immediate',
    p_trigger_delay INTEGER DEFAULT 0,
    p_trigger_scroll_percent INTEGER DEFAULT NULL,
    p_trigger_exit_intent BOOLEAN DEFAULT FALSE,
    -- Sıklık
    p_frequency_type VARCHAR(30) DEFAULT 'once_per_session',
    p_frequency_cap INTEGER DEFAULT NULL,
    p_frequency_hours INTEGER DEFAULT NULL,
    -- Link
    p_link_url VARCHAR(500) DEFAULT NULL,
    p_link_target VARCHAR(20) DEFAULT '_self',
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
    p_priority INTEGER DEFAULT 0,
    p_is_active BOOLEAN DEFAULT TRUE,
    p_operator_id INTEGER DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INTEGER;
BEGIN
    -- Popup type kontrolü
    IF NOT EXISTS (SELECT 1 FROM content.popup_types WHERE id = p_popup_type_id AND is_active = TRUE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.popup.invalid-popup-type';
    END IF;

    -- Code benzersizlik kontrolü
    IF p_code IS NOT NULL AND EXISTS (
        SELECT 1 FROM content.popups WHERE code = p_code AND is_deleted = FALSE
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.popup.code-exists';
    END IF;

    INSERT INTO content.popups (
        popup_type_id,
        code,
        display_duration,
        auto_close,
        width,
        height,
        trigger_type,
        trigger_delay,
        trigger_scroll_percent,
        trigger_exit_intent,
        frequency_type,
        frequency_cap,
        frequency_hours,
        link_url,
        link_target,
        start_date,
        end_date,
        segment_ids,
        country_codes,
        excluded_country_codes,
        page_urls,
        excluded_page_urls,
        priority,
        is_active,
        created_at,
        created_by
    )
    VALUES (
        p_popup_type_id,
        p_code,
        p_display_duration,
        p_auto_close,
        p_width,
        p_height,
        p_trigger_type,
        p_trigger_delay,
        p_trigger_scroll_percent,
        p_trigger_exit_intent,
        p_frequency_type,
        p_frequency_cap,
        p_frequency_hours,
        p_link_url,
        p_link_target,
        p_start_date,
        p_end_date,
        p_segment_ids,
        p_country_codes,
        p_excluded_country_codes,
        p_page_urls,
        p_excluded_page_urls,
        p_priority,
        p_is_active,
        NOW(),
        p_operator_id
    )
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION content.popup_create IS 'Creates a new popup. Auth check done in Core DB. Returns new popup ID.';
