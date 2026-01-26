-- =============================================
-- Tablo: presentation.menu_groups
-- Açıklama: Backoffice menü grup tanımları
-- Yan menüdeki ana kategorileri belirler
-- Örnek: HOME, PLAYERS, REPORTS, FINANCE, SETTINGS
-- =============================================

DROP TABLE IF EXISTS presentation.menu_groups CASCADE;

CREATE TABLE presentation.menu_groups (
    id BIGSERIAL PRIMARY KEY,                              -- Benzersiz grup kimliği
    code VARCHAR(50) NOT NULL UNIQUE,                      -- Grup kodu: HOME, PLAYERS, REPORTS
    title_localization_key VARCHAR(150) NOT NULL,          -- Çeviri anahtarı: bo.menu_group.home
    order_index INT NOT NULL,                              -- Sıralama indeksi (küçükten büyüğe)
    required_permission VARCHAR(100),                      -- Gerekli yetki kodu (opsiyonel)
    is_active BOOLEAN NOT NULL DEFAULT true                -- Aktif/pasif durumu
);
