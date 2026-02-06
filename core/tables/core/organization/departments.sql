-- =============================================
-- Tablo: core.departments
-- Açıklama: Departman tablosu
-- Şirket bazında organizasyonel birim tanımları
-- Hiyerarşik yapı: parent_id ile alt departmanlar
-- Çoklu dil desteği: name ve description JSONB formatında
-- Örnek: {"en": "IT Department", "tr": "Bilgi Teknolojileri"}
-- =============================================

DROP TABLE IF EXISTS core.departments CASCADE;

CREATE TABLE core.departments (
    id BIGSERIAL PRIMARY KEY,                              -- Benzersiz departman kimliği
    company_id BIGINT NOT NULL,                            -- Bağlı şirket ID (FK: core.companies)
    parent_id BIGINT,                                      -- Üst departman ID (FK: self, hiyerarşi için)
    code VARCHAR(50) NOT NULL,                             -- Departman kodu (company bazında unique): IT, HR, FIN
    name JSONB NOT NULL DEFAULT '{}',                      -- Departman adı (çoklu dil): {"en": "IT", "tr": "BT"}
    description JSONB DEFAULT '{}',                        -- Departman açıklaması (çoklu dil)
    is_active BOOLEAN NOT NULL DEFAULT TRUE,               -- Aktif mi?
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Kayıt oluşturma zamanı
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()          -- Son güncelleme zamanı
);

COMMENT ON TABLE core.departments IS 'Department definitions per company with hierarchical structure via parent_id. name and description support multi-language via JSONB (e.g. {"en": "IT", "tr": "BT"})';
