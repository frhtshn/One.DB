-- =============================================
-- Tablo: presentation.submenus
-- Açıklama: Alt Menü Öğeleri
-- Ana menülere bağlı alt menüler (Player List, Player Search vb.)
-- =============================================

DROP TABLE IF EXISTS presentation.submenus CASCADE;

CREATE TABLE presentation.submenus (
    id BIGSERIAL PRIMARY KEY,                              -- Benzersiz alt menü kimliği
    menu_id BIGINT NOT NULL,                               -- Ana menü ID
    code VARCHAR(50) NOT NULL,                             -- Alt menü kodu
    title_localization_key VARCHAR(150) NOT NULL,          -- Çeviri anahtarı
    route VARCHAR(200),                                    -- Yönlendirme adresi
    order_index INT NOT NULL,                              -- Sıralama indeksi
    required_permission VARCHAR(100) NOT NULL,             -- Gerekli yetki kodu
    is_active BOOLEAN NOT NULL DEFAULT true,               -- Aktif/pasif durumu
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Oluşturulma zamanı
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Güncellenme zamanı

    CONSTRAINT uq_submenus_menu_code UNIQUE (menu_id, code)
);

COMMENT ON TABLE presentation.submenus IS 'Submenu items (Player List, Player Search...)';
