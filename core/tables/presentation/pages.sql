-- =============================================
-- Tablo: presentation.pages
-- Açıklama: Backoffice sayfa tanımları
-- Her sayfa ya bir ana menüye ya da alt menüye bağlıdır
-- Sayfa route'ları ve yetkileri burada tanımlanır
-- =============================================

DROP TABLE IF EXISTS presentation.pages CASCADE;

CREATE TABLE presentation.pages (
    id BIGSERIAL PRIMARY KEY,                              -- Benzersiz sayfa kimliği
    menu_id BIGINT,                                        -- Ana menü ID (FK: presentation.menus)
    submenu_id BIGINT,                                     -- Alt menü ID (FK: presentation.submenus)
    code VARCHAR(50) NOT NULL,                             -- Sayfa kodu: PLAYER_DETAIL, TRANSACTION_LIST
    route VARCHAR(200) NOT NULL,                           -- Yönlendirme adresi: /players/:id
    title_localization_key VARCHAR(150) NOT NULL,          -- Çeviri anahtarı: bo.page.player_detail
    required_permission VARCHAR(100) NOT NULL,             -- Gerekli yetki kodu
    is_active BOOLEAN NOT NULL DEFAULT true,               -- Aktif/pasif durumu

    -- Bir sayfa ya menüye ya da alt menüye bağlı olmalıdır (mutually exclusive)
    CHECK (
        (menu_id IS NOT NULL AND submenu_id IS NULL)
        OR
        (menu_id IS NULL AND submenu_id IS NOT NULL)
    )
);
