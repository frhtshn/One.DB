-- Security Schema Indexes
-- FK indexes for optimal JOIN performance

-- users.company_id -> companies.id
CREATE INDEX idx_users_company_id ON security.users USING btree(company_id);

-- users.status (frequent filter)
CREATE INDEX idx_users_status ON security.users USING btree(status);

-- role_permissions.permission_code -> permissions.code
CREATE INDEX idx_role_permissions_permission_code ON security.role_permissions USING btree(permission_code);

-- secrets_provider.provider_id -> providers.id
CREATE INDEX idx_secrets_provider_provider_id ON security.secrets_provider USING btree(provider_id);

-- secrets_tenant.tenant_id -> tenants.id
CREATE INDEX idx_secrets_tenant_tenant_id ON security.secrets_tenant USING btree(tenant_id);

-- tenant_roles.tenant_id -> tenants.id
CREATE INDEX idx_tenant_roles_tenant_id ON security.tenant_roles USING btree(tenant_id);

-- user_roles.tenant_id -> tenants.id
CREATE INDEX idx_user_roles_tenant_id ON security.user_roles USING btree(tenant_id);

-- user_roles.role_id -> tenant_roles.id
CREATE INDEX idx_user_roles_role_id ON security.user_roles USING btree(role_id);
