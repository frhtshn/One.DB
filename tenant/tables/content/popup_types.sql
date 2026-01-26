-- =============================================
-- Popup Types (Popup Türleri)
-- Popup davranış ve görünüm türleri
-- =============================================

DROP TABLE IF EXISTS content.popup_types CASCADE;

CREATE TABLE content.popup_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL,                    -- Benzersiz tür kodu
    icon VARCHAR(50),                             -- Tür ikonu
    default_width INTEGER,                        -- Varsayılan genişlik (px)
    default_height INTEGER,                       -- Varsayılan yükseklik (px)
    has_overlay BOOLEAN NOT NULL DEFAULT TRUE,    -- Arkaplan overlay var mı
    can_close BOOLEAN NOT NULL DEFAULT TRUE,      -- Kapatılabilir mi
    close_on_overlay_click BOOLEAN NOT NULL DEFAULT TRUE, -- Overlay'e tıklayınca kapansın mı
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER
);

COMMENT ON TABLE content.popup_types IS 'Popup behavior and appearance type definitions';

-- Örnek popup türleri:
-- modal: Klasik modal popup (ortalanmış, overlay)
-- fullscreen: Tam ekran popup
-- banner_top: Üst banner popup
-- banner_bottom: Alt banner popup
-- slide_in_right: Sağdan kayarak gelen
-- slide_in_left: Soldan kayarak gelen
-- corner_bottom_right: Sağ alt köşe
-- toast: Bildirim tarzı küçük popup
