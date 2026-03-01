-- =============================================
-- Tablo: security.permission_template_assignments
-- Açıklama: Template atama kayıtları
-- Snapshot model: atama anında template durumu JSONB olarak kaydedilir
-- Soft-delete: removed_at/removed_by ile audit trail korunur
-- =============================================

DROP TABLE IF EXISTS security.permission_template_assignments CASCADE;

CREATE TABLE security.permission_template_assignments (
    id BIGSERIAL PRIMARY KEY,                              -- Atama ID
    user_id BIGINT NOT NULL,                               -- Atanan kullanıcı ID
    template_id BIGINT NOT NULL,                                -- Template ID (FK: security.permission_templates)
    client_id BIGINT NULL,                                 -- Atama scope'u (audit metadata, scope limiter DEĞİL)
    template_snapshot JSONB NOT NULL,                       -- Template'in atama anındaki hali (code, name, description)
    assigned_permissions JSONB NOT NULL,                    -- Gerçekte verilen permission'lar
    skipped_permissions JSONB,                              -- Rol'de veya override'da zaten olan
    assigned_by BIGINT NOT NULL,                            -- Atayan kullanıcı ID
    assigned_at TIMESTAMPTZ DEFAULT NOW(),                  -- Atanma zamanı
    expires_at TIMESTAMPTZ NULL,                            -- Geçerlilik bitiş (NULL=süresiz)
    reason TEXT,                                            -- Atama sebebi
    removed_at TIMESTAMPTZ NULL,                            -- Kaldırma zamanı (soft-delete)
    removed_by BIGINT NULL,                                -- Kaldıran kullanıcı ID
    removal_reason TEXT,                                    -- Kaldırma sebebi

    CONSTRAINT chk_removal CHECK (removed_at IS NULL OR removed_by IS NOT NULL)
);

COMMENT ON TABLE security.permission_template_assignments IS 'Template assignment records with snapshot model. Stores template state at assignment time for audit trail. Soft-delete only, hard delete is prohibited';
