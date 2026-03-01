-- ================================================================
-- PUBLIC_NAVIGATION_GET: Frontend aktif menü yapısını getir
-- Location bazlı, auth/guest filtreli, cihaz filtreli
-- Hiyerarşik tree döner (children[] iç içe)
-- ================================================================

DROP FUNCTION IF EXISTS presentation.public_navigation_get(VARCHAR, BOOLEAN, VARCHAR, CHAR);

CREATE OR REPLACE FUNCTION presentation.public_navigation_get(
    p_menu_location     VARCHAR(50),        -- Menü konumu
    p_is_authenticated  BOOLEAN,            -- Kullanıcı giriş yapmış mı
    p_device_type       VARCHAR(20) DEFAULT NULL, -- desktop, mobile (NULL = all)
    p_language_code     CHAR(2)     DEFAULT 'en'  -- Dil kodu (custom_label'dan çekilir)
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- Parametre doğrulama
    IF p_menu_location IS NULL OR p_menu_location = '' THEN
        RETURN '[]'::JSONB;
    END IF;

    -- Hiyerarşik menü ağacı (sadece görünür öğeler)
    WITH visible_items AS (
        SELECT *
        FROM presentation.navigation n
        WHERE n.menu_location = p_menu_location
          AND n.is_visible = TRUE
          -- Auth filtresi
          AND (
              (n.requires_auth = FALSE AND n.requires_guest = FALSE)      -- Herkese göster
              OR (n.requires_auth = TRUE AND p_is_authenticated = TRUE)   -- Sadece giriş yapanlara
              OR (n.requires_guest = TRUE AND p_is_authenticated = FALSE) -- Sadece misafirlere
          )
          -- Cihaz filtresi
          AND (
              n.device_visibility = 'all'
              OR p_device_type IS NULL
              OR n.device_visibility = p_device_type || '_only'
          )
    ),
    -- Root öğeler ile children
    root_items AS (
        SELECT
            v.id,
            v.translation_key,
            COALESCE(v.custom_label ->> p_language_code, v.custom_label ->> 'en', v.translation_key) AS label,
            v.icon,
            v.badge_text,
            v.badge_color,
            v.target_type,
            v.target_url,
            v.target_action,
            v.open_in_new_tab,
            v.display_order,
            v.custom_css_class,
            COALESCE(
                (SELECT jsonb_agg(jsonb_build_object(
                    'id', c.id,
                    'label', COALESCE(c.custom_label ->> p_language_code, c.custom_label ->> 'en', c.translation_key),
                    'icon', c.icon,
                    'badgeText', c.badge_text,
                    'badgeColor', c.badge_color,
                    'targetType', c.target_type,
                    'targetUrl', c.target_url,
                    'targetAction', c.target_action,
                    'openInNewTab', c.open_in_new_tab,
                    'customCssClass', c.custom_css_class
                ) ORDER BY c.display_order)
                FROM visible_items c
                WHERE c.parent_id = v.id
                ),
                '[]'::JSONB
            ) AS children
        FROM visible_items v
        WHERE v.parent_id IS NULL
    )
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', r.id,
        'label', r.label,
        'icon', r.icon,
        'badgeText', r.badge_text,
        'badgeColor', r.badge_color,
        'targetType', r.target_type,
        'targetUrl', r.target_url,
        'targetAction', r.target_action,
        'openInNewTab', r.open_in_new_tab,
        'customCssClass', r.custom_css_class,
        'children', r.children
    ) ORDER BY r.display_order), '[]'::JSONB)
    INTO v_result
    FROM root_items r;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.public_navigation_get(VARCHAR, BOOLEAN, VARCHAR, CHAR) IS 'Get active navigation tree for frontend rendering. Filters by visibility, auth state, and device type. Returns hierarchical menu with resolved labels.';
