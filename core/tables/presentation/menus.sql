-- =============================================
-- Tablo: presentation.menus
-- Açıklama: Backoffice ana menü öğeleri
-- Her menü bir gruba bağlı olabilir veya bağımsız olabilir
-- Örnek: Players, Transactions, Reports, Settings
-- =============================================

DROP TABLE IF EXISTS presentation.menus CASCADE;

CREATE TABLE presentation.menus (
    id BIGSERIAL PRIMARY KEY,                              -- Benzersiz menü kimliği
    menu_group_id BIGINT,                                  -- Bağlı grup ID (FK: presentation.menu_groups)
    code VARCHAR(50) NOT NULL UNIQUE,                      -- Menü kodu: PLAYERS, TRANSACTIONS
    title_localization_key VARCHAR(150) NOT NULL,          -- Çeviri anahtarı: bo.menu.players
    icon VARCHAR(50),                                      -- Menü ikonu: users, credit-card, chart
    order_index INT NOT NULL,                              -- Sıralama indeksi
    required_permission VARCHAR(100) NOT NULL,             -- Gerekli yetki kodu
    is_active BOOLEAN NOT NULL DEFAULT true                -- Aktif/pasif durumu
);

COMMENT ON TABLE presentation.menus IS 'BackOffice main menu items with localization, icons, ordering, and permission requirements';
