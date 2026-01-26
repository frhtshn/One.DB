-- =============================================
-- Tablo: security.permissions
-- Açıklama: Yetki tanımları kataloğu
-- Sistemdeki tüm atomik yetkilerin listesi
-- Örnek: players.view, players.edit, transactions.refund
-- =============================================

DROP TABLE IF EXISTS security.permissions CASCADE;

CREATE TABLE security.permissions (
    code VARCHAR(100) PRIMARY KEY,                        -- Yetki kodu: players.view, reports.download
    description VARCHAR(255)                               -- Yetki açıklaması
);

COMMENT ON TABLE security.permissions IS 'Permission definitions catalog containing all atomic permissions such as players.view, transactions.refund';


