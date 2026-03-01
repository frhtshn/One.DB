-- ================================================================
-- NAVIGATION_CREATE: Yeni menü öğesi oluştur
-- Client'ın kendi öğeleri (is_locked=FALSE, is_readonly=FALSE)
-- Template'den gelen öğeler provisioning ile eklenir
-- ================================================================

DROP FUNCTION IF EXISTS presentation.navigation_create(VARCHAR, JSONB, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, BOOLEAN, BIGINT, INT, BOOLEAN, BOOLEAN, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION presentation.navigation_create(
    p_menu_location     VARCHAR(50),        -- Menü konumu: main_header, footer_col_1, sidebar, mobile_bottom
    p_custom_label      JSONB,              -- {"en": "My Link", "tr": "Benim Linkim"}
    p_icon              VARCHAR(50)     DEFAULT NULL,    -- İkon kodu
    p_badge_text        VARCHAR(20)     DEFAULT NULL,    -- Badge metni (NEW, HOT)
    p_badge_color       VARCHAR(20)     DEFAULT NULL,    -- Badge rengi
    p_target_type       VARCHAR(20)     DEFAULT 'internal', -- internal, external, action, route
    p_target_url        VARCHAR(255)    DEFAULT NULL,    -- Link URL
    p_target_action     VARCHAR(50)     DEFAULT NULL,    -- Aksiyon kodu
    p_open_in_new_tab   BOOLEAN         DEFAULT FALSE,   -- Yeni sekmede aç
    p_parent_id         BIGINT          DEFAULT NULL,    -- Üst menü ID (alt menü için)
    p_display_order     INT             DEFAULT 0,       -- Sıralama
    p_requires_auth     BOOLEAN         DEFAULT FALSE,   -- Sadece giriş yapmış kullanıcılara
    p_requires_guest    BOOLEAN         DEFAULT FALSE,   -- Sadece giriş yapmamış kullanıcılara
    p_device_visibility VARCHAR(20)     DEFAULT 'all',   -- all, mobile_only, desktop_only
    p_custom_css_class  VARCHAR(100)    DEFAULT NULL     -- Özel CSS sınıfı
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    -- Parametre doğrulama
    IF p_menu_location IS NULL OR p_menu_location = '' THEN
        RAISE EXCEPTION 'error.navigation.location-required';
    END IF;

    IF p_custom_label IS NULL OR p_custom_label = '{}'::JSONB THEN
        RAISE EXCEPTION 'error.navigation.label-required';
    END IF;

    -- Parent kontrolü
    IF p_parent_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM presentation.navigation WHERE id = p_parent_id) THEN
            RAISE EXCEPTION 'error.navigation.parent-not-found';
        END IF;
    END IF;

    INSERT INTO presentation.navigation (
        menu_location, custom_label, icon, badge_text, badge_color,
        target_type, target_url, target_action, open_in_new_tab,
        parent_id, display_order,
        requires_auth, requires_guest, device_visibility, custom_css_class,
        is_locked, is_readonly, template_item_id
    )
    VALUES (
        p_menu_location, p_custom_label, p_icon, p_badge_text, p_badge_color,
        COALESCE(p_target_type, 'internal'), p_target_url, p_target_action, COALESCE(p_open_in_new_tab, FALSE),
        p_parent_id, COALESCE(p_display_order, 0),
        COALESCE(p_requires_auth, FALSE), COALESCE(p_requires_guest, FALSE),
        COALESCE(p_device_visibility, 'all'), p_custom_css_class,
        FALSE, FALSE, NULL
    )
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION presentation.navigation_create(VARCHAR, JSONB, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, BOOLEAN, BIGINT, INT, BOOLEAN, BOOLEAN, VARCHAR, VARCHAR) IS 'Create a new client-owned navigation item. Items created by client are never locked or readonly.';
