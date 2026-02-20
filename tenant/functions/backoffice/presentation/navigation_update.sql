-- ================================================================
-- NAVIGATION_UPDATE: Menü öğesi güncelle
-- is_readonly=TRUE ise target alanları korunur (COALESCE)
-- Serbest alanlar her zaman güncellenebilir
-- ================================================================

DROP FUNCTION IF EXISTS presentation.navigation_update(BIGINT, JSONB, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, BOOLEAN, BOOLEAN, BOOLEAN, BOOLEAN, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION presentation.navigation_update(
    p_id                BIGINT,             -- Öğe ID
    p_custom_label      JSONB           DEFAULT NULL,   -- Label override
    p_icon              VARCHAR(50)     DEFAULT NULL,    -- İkon
    p_badge_text        VARCHAR(20)     DEFAULT NULL,    -- Badge
    p_badge_color       VARCHAR(20)     DEFAULT NULL,    -- Badge rengi
    p_target_type       VARCHAR(20)     DEFAULT NULL,    -- ⚠️ is_readonly=TRUE ise yoksayılır
    p_target_url        VARCHAR(255)    DEFAULT NULL,    -- ⚠️ is_readonly=TRUE ise yoksayılır
    p_target_action     VARCHAR(50)     DEFAULT NULL,    -- ⚠️ is_readonly=TRUE ise yoksayılır
    p_open_in_new_tab   BOOLEAN         DEFAULT NULL,    -- Yeni sekme
    p_is_visible        BOOLEAN         DEFAULT NULL,    -- Görünürlük
    p_requires_auth     BOOLEAN         DEFAULT NULL,    -- Auth filtresi
    p_requires_guest    BOOLEAN         DEFAULT NULL,    -- Guest filtresi
    p_device_visibility VARCHAR(20)     DEFAULT NULL,    -- Cihaz görünürlüğü
    p_custom_css_class  VARCHAR(100)    DEFAULT NULL     -- CSS sınıfı
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Parametre doğrulama
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.navigation.id-required';
    END IF;

    -- Kayıt kontrolü
    IF NOT EXISTS (SELECT 1 FROM presentation.navigation WHERE id = p_id) THEN
        RAISE EXCEPTION 'error.navigation.item-not-found';
    END IF;

    -- Güncelleme: is_readonly kontrolü ile korumalı alanlar
    UPDATE presentation.navigation
    SET
        -- Serbest alanlar: her zaman güncellenebilir
        custom_label      = COALESCE(p_custom_label, custom_label),
        icon              = COALESCE(p_icon, icon),
        badge_text        = COALESCE(p_badge_text, badge_text),
        badge_color       = COALESCE(p_badge_color, badge_color),
        open_in_new_tab   = COALESCE(p_open_in_new_tab, open_in_new_tab),
        is_visible        = COALESCE(p_is_visible, is_visible),
        requires_auth     = COALESCE(p_requires_auth, requires_auth),
        requires_guest    = COALESCE(p_requires_guest, requires_guest),
        device_visibility = COALESCE(p_device_visibility, device_visibility),
        custom_css_class  = COALESCE(p_custom_css_class, custom_css_class),
        -- Korumalı alanlar: is_readonly=TRUE ise mevcut değer korunur
        target_type       = CASE WHEN is_readonly THEN target_type ELSE COALESCE(p_target_type, target_type) END,
        target_url        = CASE WHEN is_readonly THEN target_url ELSE COALESCE(p_target_url, target_url) END,
        target_action     = CASE WHEN is_readonly THEN target_action ELSE COALESCE(p_target_action, target_action) END,
        updated_at        = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION presentation.navigation_update(BIGINT, JSONB, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, BOOLEAN, BOOLEAN, BOOLEAN, BOOLEAN, VARCHAR, VARCHAR) IS 'Update navigation item. Readonly items preserve target_type/url/action fields while allowing label/visibility changes.';
