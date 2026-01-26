-- Security Schema Foreign Key Constraints

-- users -> companies
ALTER TABLE security.users
    ADD CONSTRAINT fk_users_company
    FOREIGN KEY (company_id) REFERENCES core.companies(id);

-- role_permissions -> roles
ALTER TABLE security.role_permissions
    ADD CONSTRAINT fk_role_permissions_role
    FOREIGN KEY (role_id) REFERENCES security.roles(id) ON DELETE CASCADE;

-- role_permissions -> permissions
ALTER TABLE security.role_permissions
    ADD CONSTRAINT fk_role_permissions_permission
    FOREIGN KEY (permission_id) REFERENCES security.permissions(id) ON DELETE CASCADE;

-- secrets_provider -> providers
ALTER TABLE security.secrets_provider
    ADD CONSTRAINT fk_secrets_provider_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- secrets_tenant -> tenants
ALTER TABLE security.secrets_tenant
    ADD CONSTRAINT fk_secrets_tenant_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- user_roles -> users
ALTER TABLE security.user_roles
    ADD CONSTRAINT fk_user_roles_user
    FOREIGN KEY (user_id) REFERENCES security.users(id) ON DELETE CASCADE;

-- user_roles -> roles
ALTER TABLE security.user_roles
    ADD CONSTRAINT fk_user_roles_role
    FOREIGN KEY (role_id) REFERENCES security.roles(id) ON DELETE CASCADE;

-- user_tenant_roles -> tenants
ALTER TABLE security.user_tenant_roles
    ADD CONSTRAINT fk_user_tenant_roles_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- user_tenant_roles -> users
ALTER TABLE security.user_tenant_roles
    ADD CONSTRAINT fk_user_tenant_roles_user
    FOREIGN KEY (user_id) REFERENCES security.users(id) ON DELETE CASCADE;

-- user_tenant_roles -> roles
ALTER TABLE security.user_tenant_roles
    ADD CONSTRAINT fk_user_tenant_roles_role
    FOREIGN KEY (role_id) REFERENCES security.roles(id) ON DELETE CASCADE;

-- user_sessions -> users
ALTER TABLE security.user_sessions
    ADD CONSTRAINT fk_user_sessions_user
    FOREIGN KEY (user_id) REFERENCES security.users(id) ON DELETE CASCADE;

-- user_permission_overrides -> tenants
ALTER TABLE security.user_permission_overrides
    ADD CONSTRAINT fk_user_permission_overrides_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- user_permission_overrides -> users
ALTER TABLE security.user_permission_overrides
    ADD CONSTRAINT fk_user_permission_overrides_user
    FOREIGN KEY (user_id) REFERENCES security.users(id) ON DELETE CASCADE;

-- user_permission_overrides -> permissions
ALTER TABLE security.user_permission_overrides
    ADD CONSTRAINT fk_user_permission_overrides_permission
    FOREIGN KEY (permission_id) REFERENCES security.permissions(id) ON DELETE CASCADE;

-- user_permission_overrides -> assigned_by
ALTER TABLE security.user_permission_overrides
    ADD CONSTRAINT fk_user_permission_overrides_assigned_by
    FOREIGN KEY (assigned_by) REFERENCES security.users(id) ON DELETE SET NULL;

-- user_allowed_tenants -> users
ALTER TABLE security.user_allowed_tenants
    ADD CONSTRAINT fk_user_allowed_tenants_user
    FOREIGN KEY (user_id) REFERENCES security.users(id) ON DELETE CASCADE;

-- user_allowed_tenants -> tenants
ALTER TABLE security.user_allowed_tenants
    ADD CONSTRAINT fk_user_allowed_tenants_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id) ON DELETE CASCADE;

-- user_allowed_tenants -> created_by
ALTER TABLE security.user_allowed_tenants
    ADD CONSTRAINT fk_user_allowed_tenants_created_by
    FOREIGN KEY (created_by) REFERENCES security.users(id);
