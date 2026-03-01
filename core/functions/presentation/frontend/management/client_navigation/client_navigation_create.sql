-- ================================================================
-- CLIENT_NAVIGATION_CREATE: Yeni navigasyon öğesi ekle
-- ================================================================
-- Açıklama:
--   Client için yeni bir custom navigasyon öğesi oluşturur.
--   Template'den gelmeyen, client'ın kendi eklediği öğeler.
-- Erişim:
--   - Platform Admin: Tüm client'lar
--   - CompanyAdmin: Kendi company'sindeki client'lar
--   - ClientAdmin: user_allowed_clients'taki client'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.client_navigation_create(
    BIGINT, BIGINT, VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR, VARCHAR,
    VARCHAR, VARCHAR, VARCHAR, BOOLEAN, BIGINT, INT, BOOLEAN, BOOLEAN,
    BOOLEAN, VARCHAR[], VARCHAR, VARCHAR
);

CREATE OR REPLACE FUNCTION presentation.client_navigation_create(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_menu_location VARCHAR(50),
    p_translation_key VARCHAR(100) DEFAULT NULL,
    p_custom_label TEXT DEFAULT NULL,
    p_icon VARCHAR(50) DEFAULT NULL,
    p_badge_text VARCHAR(20) DEFAULT NULL,
    p_badge_color VARCHAR(20) DEFAULT NULL,
    p_target_type VARCHAR(20) DEFAULT 'internal',
    p_target_url VARCHAR(255) DEFAULT NULL,
    p_target_action VARCHAR(50) DEFAULT NULL,
    p_open_in_new_tab BOOLEAN DEFAULT FALSE,
    p_parent_id BIGINT DEFAULT NULL,
    p_display_order INT DEFAULT 0,
    p_is_visible BOOLEAN DEFAULT TRUE,
    p_requires_auth BOOLEAN DEFAULT FALSE,
    p_requires_guest BOOLEAN DEFAULT FALSE,
    p_required_roles VARCHAR(50)[] DEFAULT NULL,
    p_device_visibility VARCHAR(20) DEFAULT 'all',
    p_custom_css_class VARCHAR(100) DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = presentation, core, security, pg_temp
AS $$
DECLARE
    v_new_id BIGINT;
BEGIN
    -- 1. Client varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM core.clients WHERE id = p_client_id AND status = 1) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- 2. Client erişim kontrolü
    PERFORM security.user_assert_access_client(p_caller_id, p_client_id);

    -- ========================================
    -- 3. PARENT VARLIK KONTROLÜ
    -- ========================================
    IF p_parent_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM presentation.client_navigation
            WHERE id = p_parent_id AND client_id = p_client_id
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.client-navigation.parent-not-found';
        END IF;
    END IF;

    -- ========================================
    -- 5. NAVİGASYON ÖĞESİ OLUŞTUR
    -- ========================================
    INSERT INTO presentation.client_navigation (
        client_id,
        template_item_id,
        menu_location,
        translation_key,
        custom_label,
        icon,
        badge_text,
        badge_color,
        target_type,
        target_url,
        target_action,
        open_in_new_tab,
        parent_id,
        display_order,
        is_visible,
        requires_auth,
        requires_guest,
        required_roles,
        device_visibility,
        is_locked,
        is_readonly,
        custom_css_class,
        created_at,
        updated_at
    )
    VALUES (
        p_client_id,
        NULL,                    -- template_item_id = NULL (custom item)
        p_menu_location,
        p_translation_key,
        p_custom_label::jsonb,
        p_icon,
        p_badge_text,
        p_badge_color,
        p_target_type,
        p_target_url,
        p_target_action,
        p_open_in_new_tab,
        p_parent_id,
        p_display_order,
        p_is_visible,
        p_requires_auth,
        p_requires_guest,
        p_required_roles,
        p_device_visibility,
        FALSE,                   -- is_locked = FALSE (custom items can be deleted)
        FALSE,                   -- is_readonly = FALSE (custom items are fully editable)
        p_custom_css_class,
        NOW(),
        NOW()
    )
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION presentation.client_navigation_create IS
'Creates a new custom navigation item for a client.
Custom items have is_locked=FALSE and is_readonly=FALSE (fully editable and deletable).
Access: Platform Admin (all), CompanyAdmin (own company), ClientAdmin (allowed clients).';
