-- =============================================
-- Tablo: presentation.submenus
-- Açıklama: Backoffice alt menü öğeleri
-- Her alt menü bir ana menüye bağlıdır
-- Örnek: Players > Player List, Player Search
-- =============================================

DROP TABLE IF EXISTS presentation.submenus CASCADE;

CREATE TABLE presentation.submenus (
    id BIGSERIAL PRIMARY KEY,                              -- Benzersiz alt menü kimliği
    menu_id BIGINT NOT NULL,                               -- Ana menü ID (FK: presentation.menus)
    code VARCHAR(50) NOT NULL,                             -- Alt menü kodu: PLAYER_LIST, PLAYER_SEARCH
    title_localization_key VARCHAR(150) NOT NULL,          -- Çeviri anahtarı: bo.submenu.player_list
    route VARCHAR(200),                                    -- Yönlendirme adresi: /players/list
    order_index INT NOT NULL,                              -- Sıralama indeksi
    required_permission VARCHAR(100) NOT NULL,             -- Gerekli yetki kodu
    is_active BOOLEAN NOT NULL DEFAULT true,               -- Aktif/pasif durumu
    UNIQUE (menu_id, code)                                 -- Menü başına benzersiz alt menü kodu
);
