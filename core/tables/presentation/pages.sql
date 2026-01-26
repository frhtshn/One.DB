-- =============================================
-- Tablo: presentation.pages
-- Açıklama: Sayfa Tanımları ve Rotalar
-- Sistemdeki sayfalar ve erişim yolları
-- =============================================

DROP TABLE IF EXISTS presentation.pages CASCADE;

CREATE TABLE presentation.pages (
    id BIGSERIAL PRIMARY KEY,                              -- Benzersiz sayfa kimliği
    menu_id BIGINT,                                        -- Ana menü ID
    submenu_id BIGINT,                                     -- Alt menü ID
    code VARCHAR(50) NOT NULL,                             -- Sayfa kodu
    route VARCHAR(200) NOT NULL,                           -- Yönlendirme adresi
    title_localization_key VARCHAR(150) NOT NULL,          -- Çeviri anahtarı
    required_permission VARCHAR(100) NOT NULL,             -- Gerekli yetki kodu
    is_active BOOLEAN NOT NULL DEFAULT true,               -- Aktif/pasif durumu
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Oluşturulma zamanı
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Güncellenme zamanı

    CONSTRAINT chk_pages_parent CHECK (
        (menu_id IS NOT NULL AND submenu_id IS NULL) OR
        (menu_id IS NULL AND submenu_id IS NOT NULL)
    )
);

COMMENT ON TABLE presentation.pages IS 'Page definitions with routes';
