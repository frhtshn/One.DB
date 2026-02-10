-- Security Schema Indexes
-- FK indexes for optimal JOIN performance

-- users.company_id -> companies.id
CREATE INDEX idx_users_company_id ON security.users USING btree(company_id);

-- users.email (unique lookup - user_authenticate function)
CREATE UNIQUE INDEX idx_users_email ON security.users USING btree(email);

-- users.status (frequent filter)
CREATE INDEX idx_users_status ON security.users USING btree(status);

-- roles.status (frequent filter in joins)
CREATE INDEX idx_roles_status ON security.roles USING btree(status);

-- roles.is_platform_role (user_authenticate filter)
CREATE INDEX idx_roles_platform ON security.roles USING btree(is_platform_role) WHERE is_platform_role = true;

-- permissions.status (frequent filter)
CREATE INDEX idx_permissions_status ON security.permissions USING btree(status);

-- permissions.code (unique lookup - permission_check function)
CREATE UNIQUE INDEX idx_permissions_code ON security.permissions USING btree(code);

-- role_permissions.role_id (FK index + JOIN performance)
CREATE INDEX idx_role_permissions_role_id ON security.role_permissions USING btree(role_id);

-- role_permissions.permission_id (FK index + JOIN performance)
CREATE INDEX idx_role_permissions_permission_id ON security.role_permissions USING btree(permission_id);

-- role_permissions (composite for permission lookup)
CREATE INDEX idx_role_permissions_lookup ON security.role_permissions USING btree(role_id, permission_id);

-- secrets_provider.provider_id -> providers.id
CREATE INDEX idx_secrets_provider_provider_id ON security.secrets_provider USING btree(provider_id);

-- secrets_tenant.tenant_id -> tenants.id
CREATE INDEX idx_secrets_tenant_tenant_id ON security.secrets_tenant USING btree(tenant_id);
-- user_roles.user_id (FK index + frequent JOIN)
CREATE INDEX idx_user_roles_user_id ON security.user_roles USING btree(user_id);

-- user_roles.role_id -> roles.id
CREATE INDEX idx_user_roles_role_id ON security.user_roles USING btree(role_id);

-- user_roles.tenant_id (FK index for tenant-specific roles)
CREATE INDEX idx_user_roles_tenant_id ON security.user_roles USING btree(tenant_id) WHERE tenant_id IS NOT NULL;

-- Partial Unique Index: Global roller için (tenant_id NULL)
CREATE UNIQUE INDEX idx_user_roles_unique_global
    ON security.user_roles(user_id, role_id)
    WHERE tenant_id IS NULL;

-- Partial Unique Index: Tenant rolleri için (tenant_id NOT NULL)
CREATE UNIQUE INDEX idx_user_roles_unique_tenant
    ON security.user_roles(user_id, role_id, tenant_id)
    WHERE tenant_id IS NOT NULL;

-- Lookup index (performans - user_authenticate, user_permission_list)
CREATE INDEX idx_user_roles_user_lookup ON security.user_roles USING btree(user_id, tenant_id);

-- user_sessions.id (tek session lookup - revoke, belongs_to, update_activity)
CREATE INDEX idx_user_sessions_id ON security.user_sessions USING btree(id);

-- user_sessions.user_id -> users.id
CREATE INDEX idx_user_sessions_user_id ON security.user_sessions USING btree(user_id);

-- user_sessions (active sessions lookup - session_list function)
CREATE INDEX idx_user_sessions_active ON security.user_sessions USING btree(user_id, is_revoked, expires_at) WHERE is_revoked = false;

-- user_sessions (expiry cleanup - session_cleanup_expired function)
CREATE INDEX idx_user_sessions_expires ON security.user_sessions USING btree(expires_at);

-- user_sessions (revoked cleanup - session_cleanup_expired function)
CREATE INDEX idx_user_sessions_revoked ON security.user_sessions USING btree(is_revoked, revoked_at) WHERE is_revoked = true;

-- user_sessions GeoIP ülke kodu (güvenlik analizi)
CREATE INDEX IF NOT EXISTS idx_user_sessions_country ON security.user_sessions USING btree(country_code) WHERE country_code IS NOT NULL;

-- user_sessions Proxy/VPN tespiti (fraud investigation)
CREATE INDEX IF NOT EXISTS idx_user_sessions_proxy ON security.user_sessions USING btree(is_proxy) WHERE is_proxy = true;

-- user_permission_overrides.user_id -> users.id
CREATE INDEX idx_user_permission_overrides_user_id ON security.user_permission_overrides USING btree(user_id);

-- user_permission_overrides.permission_id -> permissions.id
CREATE INDEX idx_user_permission_overrides_permission_id ON security.user_permission_overrides USING btree(permission_id);

-- user_permission_overrides (hybrid permission lookup - user_permission_list, user_authenticate)
CREATE INDEX idx_user_permission_overrides_lookup ON security.user_permission_overrides USING btree(user_id, tenant_id, is_granted);

-- user_permission_overrides (active check with expiry)
CREATE INDEX idx_user_permission_overrides_active ON security.user_permission_overrides USING btree(user_id, is_granted, expires_at);

-- user_allowed_tenants (user lookup - user_authenticate)
CREATE INDEX idx_user_allowed_tenants_user_id ON security.user_allowed_tenants USING btree(user_id);

-- user_allowed_tenants (tenant lookup - access helpers)
CREATE INDEX idx_user_allowed_tenants_tenant_id ON security.user_allowed_tenants USING btree(tenant_id);

-- user_allowed_tenants (composite lookup - user_can_access_tenant helper)
CREATE INDEX idx_user_allowed_tenants_lookup ON security.user_allowed_tenants USING btree(user_id, tenant_id);

-- user_password_history (son şifreleri hızlı çekmek için)
CREATE INDEX idx_user_password_history_lookup ON security.user_password_history USING btree(user_id, changed_at DESC);

