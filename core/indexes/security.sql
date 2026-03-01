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

-- secrets_client.client_id -> clients.id
CREATE INDEX idx_secrets_client_client_id ON security.secrets_client USING btree(client_id);
-- user_roles.user_id (FK index + frequent JOIN)
CREATE INDEX idx_user_roles_user_id ON security.user_roles USING btree(user_id);

-- user_roles.role_id -> roles.id
CREATE INDEX idx_user_roles_role_id ON security.user_roles USING btree(role_id);

-- user_roles.client_id (FK index for client-specific roles)
CREATE INDEX idx_user_roles_client_id ON security.user_roles USING btree(client_id) WHERE client_id IS NOT NULL;

-- Partial Unique Index: Global roller için (client_id NULL)
CREATE UNIQUE INDEX idx_user_roles_unique_global
    ON security.user_roles(user_id, role_id)
    WHERE client_id IS NULL;

-- Partial Unique Index: Client rolleri için (client_id NOT NULL)
CREATE UNIQUE INDEX idx_user_roles_unique_client
    ON security.user_roles(user_id, role_id, client_id)
    WHERE client_id IS NOT NULL;

-- Lookup index (performans - user_authenticate, user_permission_list)
CREATE INDEX idx_user_roles_user_lookup ON security.user_roles USING btree(user_id, client_id);

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
CREATE INDEX idx_user_permission_overrides_lookup ON security.user_permission_overrides USING btree(user_id, client_id, is_granted);

-- user_permission_overrides (active check with expiry)
CREATE INDEX idx_user_permission_overrides_active ON security.user_permission_overrides USING btree(user_id, is_granted, expires_at);

-- user_allowed_clients (user lookup - user_authenticate)
CREATE INDEX idx_user_allowed_clients_user_id ON security.user_allowed_clients USING btree(user_id);

-- user_allowed_clients (client lookup - access helpers)
CREATE INDEX idx_user_allowed_clients_client_id ON security.user_allowed_clients USING btree(client_id);

-- user_allowed_clients (composite lookup - user_can_access_client helper)
CREATE INDEX idx_user_allowed_clients_lookup ON security.user_allowed_clients USING btree(user_id, client_id);

-- user_password_history (son şifreleri hızlı çekmek için)
CREATE INDEX idx_user_password_history_lookup ON security.user_password_history USING btree(user_id, changed_at DESC);

-- user_permission_overrides (context-scoped override lookup - Faz 2)
CREATE INDEX idx_upo_context_id ON security.user_permission_overrides USING btree(context_id) WHERE context_id IS NOT NULL;

-- user_permission_overrides (template assignment kaynak takibi - Faz 3)
CREATE INDEX idx_upo_template_assignment_id ON security.user_permission_overrides USING btree(template_assignment_id) WHERE template_assignment_id IS NOT NULL;

-- permission_templates (platform-level code unique)
CREATE UNIQUE INDEX uix_pt_platform_code ON security.permission_templates(code) WHERE company_id IS NULL AND deleted_at IS NULL;

-- permission_templates (company-scoped code unique)
CREATE UNIQUE INDEX uix_pt_company_code ON security.permission_templates(company_id, code) WHERE company_id IS NOT NULL AND deleted_at IS NULL;

-- permission_templates (company lookup)
CREATE INDEX idx_pt_company_id ON security.permission_templates USING btree(company_id) WHERE company_id IS NOT NULL;

-- permission_template_assignments (user lookup)
CREATE INDEX idx_pta_user_id ON security.permission_template_assignments USING btree(user_id);

-- permission_template_assignments (template lookup)
CREATE INDEX idx_pta_template_id ON security.permission_template_assignments USING btree(template_id);

-- permission_template_assignments (duplicate assignment kontrolü - unique active)
CREATE UNIQUE INDEX uix_pta_active ON security.permission_template_assignments(user_id, template_id) WHERE removed_at IS NULL;

-- permission_template_items (permission lookup - JOIN performance)
CREATE INDEX IF NOT EXISTS idx_pti_permission_id ON security.permission_template_items USING btree(permission_id);

-- permission_template_assignments (cleanup expired - permission_template_cleanup_expired)
CREATE INDEX IF NOT EXISTS idx_pta_expires_at ON security.permission_template_assignments USING btree(expires_at) WHERE expires_at IS NOT NULL;

-- auth_tokens (user lookup - auth_user_tokens_list)
CREATE INDEX IF NOT EXISTS idx_auth_tokens_user_id ON security.auth_tokens USING btree(user_id);

-- auth_tokens (session lookup)
CREATE INDEX IF NOT EXISTS idx_auth_tokens_session_id ON security.auth_tokens USING btree(session_id);

-- auth_tokens (user+client lookup - auth_user_tokens_list with client filter)
CREATE INDEX IF NOT EXISTS idx_auth_tokens_user_client ON security.auth_tokens USING btree(user_id, client_id) WHERE client_id IS NOT NULL;

-- auth_tokens (cleanup - auth_token_cleanup, expires_at < NOW())
CREATE INDEX IF NOT EXISTS idx_auth_tokens_expires_at ON security.auth_tokens USING btree(expires_at);

