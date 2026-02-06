-- =============================================
-- Tablo: core.user_departments
-- Açıklama: Kullanıcı-Departman ilişki tablosu
-- Bir kullanıcı birden fazla departmana atanabilir
-- is_primary ile ana departman belirlenir
-- =============================================

DROP TABLE IF EXISTS core.user_departments CASCADE;

CREATE TABLE core.user_departments (
    id BIGSERIAL PRIMARY KEY,                              -- Kayıt ID
    user_id BIGINT NOT NULL,                               -- Kullanıcı ID (FK: security.users)
    department_id BIGINT NOT NULL,                         -- Departman ID (FK: core.departments)
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,             -- Ana departman mı?
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),        -- Atanma zamanı
    assigned_by BIGINT                                     -- Atayan kullanıcı
);

COMMENT ON TABLE core.user_departments IS 'Many-to-many relationship between users and departments. is_primary marks the main department assignment';
