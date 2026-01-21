-- Security Schema Foreign Key Constraints

-- users -> companies
ALTER TABLE security.users
    ADD CONSTRAINT fk_users_company
    FOREIGN KEY (company_id) REFERENCES core.companies(id);

-- role_permissions -> tenant_roles
ALTER TABLE security.role_permissions
    ADD CONSTRAINT fk_role_permissions_role
    FOREIGN KEY (role_id) REFERENCES security.tenant_roles(id);

-- role_permissions -> permissions
ALTER TABLE security.role_permissions
    ADD CONSTRAINT fk_role_permissions_permission
    FOREIGN KEY (permission_code) REFERENCES security.permissions(code);

-- secrets_provider -> providers
ALTER TABLE security.secrets_provider
    ADD CONSTRAINT fk_secrets_provider_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- secrets_tenant -> tenants
ALTER TABLE security.secrets_tenant
    ADD CONSTRAINT fk_secrets_tenant_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- tenant_roles -> tenants
ALTER TABLE security.tenant_roles
    ADD CONSTRAINT fk_tenant_roles_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- user_roles -> users
ALTER TABLE security.user_roles
    ADD CONSTRAINT fk_user_roles_user
    FOREIGN KEY (user_id) REFERENCES security.users(id);

-- user_roles -> tenants
ALTER TABLE security.user_roles
    ADD CONSTRAINT fk_user_roles_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- user_roles -> tenant_roles
ALTER TABLE security.user_roles
    ADD CONSTRAINT fk_user_roles_role
    FOREIGN KEY (role_id) REFERENCES security.tenant_roles(id);
