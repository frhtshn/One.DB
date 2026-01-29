-- =============================================
-- Tablo: security.permissions
-- Açıklama: Yetki tanımları kataloğu
-- Sistemdeki tüm atomik yetkilerin listesi
-- Örnek: players.view, players.edit
-- =============================================

DROP TABLE IF EXISTS security.permissions CASCADE;

CREATE TABLE security.permissions (
    id BIGSERIAL PRIMARY KEY,                              -- Yetki ID
    code VARCHAR(100) NOT NULL,                            -- Yetki kodu
    name VARCHAR(150) NOT NULL,                            -- Yetki adı
    description VARCHAR(500),                              -- Yetki açıklaması
    category VARCHAR(50) NOT NULL,                         -- Kategori (Players, Reports vb.)
    status SMALLINT NOT NULL DEFAULT 1,                    -- Durum
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Oluşturulma zamanı
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Güncellenme zamanı

    CONSTRAINT uq_permissions_code UNIQUE (code)
);

COMMENT ON TABLE security.permissions IS 'Permission definitions catalog containing all atomic permissions';
