-- =============================================
-- Tablo: presentation.menu_groups
-- Açıklama: Menü Grup Tanımları
-- Yan menüdeki ana kategorileri belirler (Home, Operations, Documents vb.)
-- =============================================

DROP TABLE IF EXISTS presentation.menu_groups CASCADE;

CREATE TABLE presentation.menu_groups (
    id BIGSERIAL PRIMARY KEY,                              -- Benzersiz grup kimliği
    code VARCHAR(50) NOT NULL,                             -- Grup kodu
    title_localization_key VARCHAR(150) NOT NULL,          -- Çeviri anahtarı
    order_index INT NOT NULL,                              -- Sıralama indeksi
    required_permission VARCHAR(100),                      -- Gerekli yetki kodu
    is_active BOOLEAN NOT NULL DEFAULT true,               -- Aktif/pasif durumu
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Oluşturulma zamanı
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Güncellenme zamanı

    CONSTRAINT uq_menu_groups_code UNIQUE (code)
);

COMMENT ON TABLE presentation.menu_groups IS 'Main menu groups (Home, Operations, Documents...)';
