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

-- user_roles -> tenants (nullable - global roller için NULL)
ALTER TABLE security.user_roles
    ADD CONSTRAINT fk_user_roles_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id) ON DELETE CASCADE;

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

-- user_password_history -> users
ALTER TABLE security.user_password_history
    ADD CONSTRAINT fk_user_password_history_user
    FOREIGN KEY (user_id) REFERENCES security.users(id) ON DELETE CASCADE;

-- company_password_policy -> companies
ALTER TABLE security.company_password_policy
    ADD CONSTRAINT fk_company_password_policy_company
    FOREIGN KEY (company_id) REFERENCES core.companies(id) ON DELETE CASCADE;

-- company_password_policy -> created_by
ALTER TABLE security.company_password_policy
    ADD CONSTRAINT fk_company_password_policy_created_by
    FOREIGN KEY (created_by) REFERENCES security.users(id);

-- company_password_policy -> updated_by
ALTER TABLE security.company_password_policy
    ADD CONSTRAINT fk_company_password_policy_updated_by
    FOREIGN KEY (updated_by) REFERENCES security.users(id);

-- company_password_policy check constraints
ALTER TABLE security.company_password_policy
    ADD CONSTRAINT chk_company_password_policy_expiry CHECK (expiry_days >= 0),
    ADD CONSTRAINT chk_company_password_policy_history CHECK (history_count >= 0 AND history_count <= 10);

-- user_permission_overrides -> contexts (Faz 2: context-scoped overrides)
ALTER TABLE security.user_permission_overrides
    ADD CONSTRAINT fk_user_permission_overrides_context
    FOREIGN KEY (context_id) REFERENCES presentation.contexts(id);

-- user_permission_overrides -> template_assignments (Faz 3: template kaynak takibi)
ALTER TABLE security.user_permission_overrides
    ADD CONSTRAINT fk_user_permission_overrides_template_assignment
    FOREIGN KEY (template_assignment_id) REFERENCES security.permission_template_assignments(id);

-- permission_templates -> companies
ALTER TABLE security.permission_templates
    ADD CONSTRAINT fk_permission_templates_company
    FOREIGN KEY (company_id) REFERENCES core.companies(id);

-- permission_templates -> created_by
ALTER TABLE security.permission_templates
    ADD CONSTRAINT fk_permission_templates_created_by
    FOREIGN KEY (created_by) REFERENCES security.users(id);

-- permission_templates -> updated_by
ALTER TABLE security.permission_templates
    ADD CONSTRAINT fk_permission_templates_updated_by
    FOREIGN KEY (updated_by) REFERENCES security.users(id);

-- permission_templates -> deleted_by
ALTER TABLE security.permission_templates
    ADD CONSTRAINT fk_permission_templates_deleted_by
    FOREIGN KEY (deleted_by) REFERENCES security.users(id);

-- permission_template_items -> templates
ALTER TABLE security.permission_template_items
    ADD CONSTRAINT fk_permission_template_items_template
    FOREIGN KEY (template_id) REFERENCES security.permission_templates(id) ON DELETE CASCADE;

-- permission_template_items -> permissions
ALTER TABLE security.permission_template_items
    ADD CONSTRAINT fk_permission_template_items_permission
    FOREIGN KEY (permission_id) REFERENCES security.permissions(id);

-- permission_template_items -> added_by
ALTER TABLE security.permission_template_items
    ADD CONSTRAINT fk_permission_template_items_added_by
    FOREIGN KEY (added_by) REFERENCES security.users(id);

-- permission_template_assignments -> users
ALTER TABLE security.permission_template_assignments
    ADD CONSTRAINT fk_permission_template_assignments_user
    FOREIGN KEY (user_id) REFERENCES security.users(id);

-- permission_template_assignments -> templates
ALTER TABLE security.permission_template_assignments
    ADD CONSTRAINT fk_permission_template_assignments_template
    FOREIGN KEY (template_id) REFERENCES security.permission_templates(id);

-- permission_template_assignments -> tenants
ALTER TABLE security.permission_template_assignments
    ADD CONSTRAINT fk_permission_template_assignments_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- permission_template_assignments -> assigned_by
ALTER TABLE security.permission_template_assignments
    ADD CONSTRAINT fk_permission_template_assignments_assigned_by
    FOREIGN KEY (assigned_by) REFERENCES security.users(id);

-- permission_template_assignments -> removed_by
ALTER TABLE security.permission_template_assignments
    ADD CONSTRAINT fk_permission_template_assignments_removed_by
    FOREIGN KEY (removed_by) REFERENCES security.users(id);
