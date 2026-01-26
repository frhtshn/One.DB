-- =============================================
-- Tablo: presentation.menus
-- Açıklama: Menü Öğeleri
-- Gruplara bağlı veya bağımsız menüler (Dashboard, Players, Deposits vb.)
-- =============================================

DROP TABLE IF EXISTS presentation.menus CASCADE;

CREATE TABLE presentation.menus (
    id BIGSERIAL PRIMARY KEY,                              -- Benzersiz menü kimliği
    menu_group_id BIGINT NOT NULL,                         -- Bağlı grup ID
    code VARCHAR(50) NOT NULL,                             -- Menü kodu
    title_localization_key VARCHAR(150) NOT NULL,          -- Çeviri anahtarı
    icon VARCHAR(50),                                      -- Menü ikonu
    order_index INT NOT NULL,                              -- Sıralama indeksi
    required_permission VARCHAR(100) NOT NULL,             -- Gerekli yetki kodu
    is_active BOOLEAN NOT NULL DEFAULT true,               -- Aktif/pasif durumu
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Oluşturulma zamanı
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Güncellenme zamanı

    CONSTRAINT uq_menus_code UNIQUE (code)
);

COMMENT ON TABLE presentation.menus IS 'Menu items (Dashboard, Players, Deposits...)';
