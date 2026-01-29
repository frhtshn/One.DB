-- =============================================
-- Tablo: security.user_permission_overrides
-- Açıklama: Hybrid Permission (Yetki Ezme/Geçersiz Kılma)
-- Role bakılmaksızın kullanıcıya özel yetki verme veya alma
-- =============================================

DROP TABLE IF EXISTS security.user_permission_overrides CASCADE;

CREATE TABLE security.user_permission_overrides (
    id BIGSERIAL PRIMARY KEY,                              -- Kayıt ID
    user_id BIGINT NOT NULL,                               -- Kullanıcı ID (FK: security.users)
    permission_id BIGINT NOT NULL,                         -- Yetki ID (FK: security.permissions)
    tenant_id BIGINT,                                      -- Tenant ID (FK: core.tenants - opsiyonel)
    is_granted BOOLEAN NOT NULL DEFAULT TRUE,              -- Verildi (True) / Yasaklandı (False)
    reason VARCHAR(500),                                   -- Sebep
    assigned_by BIGINT,                                    -- Atayan kullanıcı (FK: security.users)
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),        -- Atanma zamanı
    expires_at TIMESTAMPTZ                                 -- Geçerlilik bitiş (opsiyonel)
);

COMMENT ON TABLE security.user_permission_overrides IS 'User specific permission overrides to grant or deny specific permissions regardless of roles';
