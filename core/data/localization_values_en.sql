-- ============================================================================
-- LOCALIZATION VALUES - ENGLISH (en)
-- ============================================================================

DELETE FROM catalog.localization_values WHERE language_code = 'en';

INSERT INTO catalog.localization_values (localization_key_id, language_code, localized_text, created_at)
SELECT k.id, 'en', v.text, NOW()
FROM catalog.localization_keys k
JOIN (VALUES
    -- Validation (LocalizedValidator)
    ('validation.summary', 'Validation failed: {0} error(s)'),
    ('validation.field.required', '{0} is required'),
    ('validation.field.max-length', '{0} cannot exceed {1} characters'),
    ('validation.field.min-length', '{0} must be at least {1} characters'),
    ('validation.field.length', '{0} must be between {1} and {2} characters'),
    ('validation.field.exact-length', '{0} must be exactly {1} characters'),
    ('validation.format.email-invalid', '{0} is not a valid email address'),
    ('validation.format.url-invalid', '{0} is not a valid URL'),
    ('validation.format.invalid', '{0} has invalid format'),
    ('validation.format.timezone-invalid', '{0} is not a valid timezone'),
    ('validation.range.greater-than-zero', '{0} must be greater than zero'),
    ('validation.range.between', '{0} must be between {1} and {2}'),
    ('validation.range.min', '{0} must be at least {1}'),
    ('validation.filter.sort-field-invalid', '{0} must be one of: {1}'),
    ('validation.filter.sort-order-invalid', '{0} must be ''asc'' or ''desc'''),
    ('validation.request.invalid', 'Invalid request'),
    ('validation.password.required', 'Password is required'),
    ('validation.password.min-length', 'Password must be at least {0} characters'),
    ('validation.password.max-length', 'Password cannot exceed {0} characters'),
    ('validation.password.require-uppercase', 'Password must contain at least one uppercase letter'),
    ('validation.password.require-lowercase', 'Password must contain at least one lowercase letter'),
    ('validation.password.require-digit', 'Password must contain at least one digit'),
    ('validation.password.require-special', 'Password must contain at least one special character'),

    -- Error Messages - Logs
    ('error.logs.errornotfound', 'Error log not found'),
    ('error.logs.deadletternotfound', 'Dead letter not found'),
    ('error.logs.auditnotfound', 'Audit log not found'),

    -- Error Messages - Auth Account Status
    ('error.auth.account-inactive', 'Account is inactive'),

    -- Error Messages - Field
    ('error.field.missing', 'Required field is missing: ''{0}'''),
    ('error.field.invalid', 'Invalid field ''{0}'': {1}'),

    -- Error Messages - CRUD
    ('error.crud.create-failed', '{0} creation failed'),
    ('error.crud.update-failed', '{0} update failed'),

    -- Error Messages - Business
    ('error.business.insufficient-balance', 'Insufficient balance. Required: {0}, Available: {1}'),
    ('error.business.invalid-status-transition', 'Cannot transition from {0} to {1}'),

    -- Error Messages - System Cache
    ('error.system.cache.connection-failed', 'Cache connection failed'),
    ('error.system.cache.operation-failed', 'Cache operation failed: {0}'),

    -- Error Messages - System Circuit Breaker
    ('error.system.circuit-breaker.database', 'Database circuit breaker is open'),
    ('error.system.circuit-breaker.cache', 'Cache circuit breaker is open'),
    ('error.system.circuit-breaker.external-api', 'Circuit breaker is open for {0}'),
    ('error.system.circuit-breaker.messaging', 'Messaging circuit breaker is open for {0}'),

    -- Error Messages - Conflict
    ('error.conflict.duplicate', '{0} already exists: {1}'),
    ('error.conflict.concurrency', '{0} {1} was modified by another process'),

    -- Error Messages - System Database
    ('error.system.database.connection-failed', 'Database connection failed'),
    ('error.system.database.query-failed', 'Database query failed: {0}'),
    ('error.system.database.invalid-tenant-id', 'Invalid tenant ID: {0}'),
    ('error.system.database.command-failed', 'Database operation failed: {0}'),

    -- Error Messages - Forbidden
    ('error.forbidden.resource', 'You do not have permission to access {0}. Required permission: {1}'),
    ('error.tenant.access-denied', 'Access denied for tenant {0}'),
    ('error.access.company-scope-denied', 'Operation not allowed outside company scope'),
    ('error.access.tenant-scope-denied', 'Operation not allowed outside tenant scope'),
    ('error.access.hierarchy-violation', 'Hierarchy violation - unauthorized operation'),
    ('error.access.denied', 'Access denied'),
    ('error.access.unauthorized', 'Unauthorized access'),

    -- Error Messages - Caller
    ('error.caller.not-found', 'Caller user not found'),
    ('error.caller.locked', 'Your account is locked'),

    -- Error Messages - System Grain
    ('error.system.grain.activation-failed', 'Grain activation failed: {0} (key: {1})'),
    ('error.system.grain.operation-failed', 'Grain operation failed: {0}'),

    -- Error Messages - System Operation
    ('error.system.operation.timeout', 'Operation ''{0}'' timed out after {1} seconds'),
    ('error.system.rate-limit.exceeded', 'Rate limit exceeded (client: ''{0}''): {1}/{2}. Retry after {3} seconds.'),

    -- Error Messages - System Silo
    ('error.system.silo.unavailable', 'Silo is unavailable'),
    ('error.system.silo.cluster-unavailable', 'Orleans cluster is unavailable'),
    ('error.system.silo.auth-init-failed', 'Auth infrastructure initialization failed'),

    -- Error Messages - Tenant
    ('error.tenant.not-active', 'Tenant {0} is not active'),
        ('error.tenant.configuration-invalid', 'Tenant {0} configuration is invalid: {1}'),
    ('error.tenant.code-exists', 'Tenant code already exists'),
    ('error.tenant.not-found', 'Tenant not found'),
    ('error.tenant.already-deleted', 'Tenant already deleted'),

    -- Error Messages - Resource
    ('error.resource.not-found', '{0} not found: {1}'),

    -- Error Messages - Config
    ('error.config.missing-required', 'Required configuration is missing: {0}'),
    ('error.config.cannot-resolve-hostname', 'Cannot resolve hostname: {0}'),
    ('error.config.invalid-value', 'Invalid configuration value ''{0}'': {1}'),

    -- Error Messages - System Replica
    ('error.system.replica.write-not-allowed', 'Write operation not allowed on replica. Identifier: {0}, Operation: {1}. Use primary instance.'),

    -- Error Messages - Auth Token
    ('error.auth.token.missing', 'Authentication token is required'),
    ('error.auth.token.invalid', 'Invalid authentication token: {0}'),
    ('error.auth.token.expired', 'Authentication token has expired'),
    ('error.auth.token.revoked', 'Token has been revoked'),
    ('error.auth.token.not-found', 'Token not found'),
    ('error.auth.token.refresh-invalid', 'Invalid or expired refresh token'),
    ('error.auth.token.refresh-required', 'Refresh token is required'),
    ('error.auth.token.refresh-failed', 'Token refresh failed'),

    -- Error Messages - Auth Login
    ('error.auth.login.throttled', 'Too many login attempts. Please wait {0} seconds.'),
    ('error.auth.login.failed', 'Login failed'),
    ('error.auth.login.account-locked', 'Your account is locked. Please wait until {0}.'),
    ('error.auth.login.invalid-credentials', 'Invalid username or password'),

    -- Error Messages - Auth User
    ('error.auth.user.invalid-id', 'Invalid user ID'),
    ('error.auth.user.not-found', 'User not found'),
    ('error.auth.admin.not-found', 'Admin user info not found'),

    -- Error Messages - Auth Session
    ('error.auth.session.not-found', 'Session not found'),
    ('error.auth.session.id-required', 'Session ID is required'),
    ('error.auth.session.use-logout-endpoint', 'Use the logout endpoint to terminate the current session'),
    ('error.auth.session.revoke-failed', 'Session revocation failed'),

    -- Error Messages - Auth Logout
    ('error.auth.logout.failed', 'Logout failed'),
    ('error.auth.logout.all-failed', 'Logout all sessions failed'),

    -- Error Messages - Auth Unlock
    ('error.auth.unlock.failed', 'Failed to unlock account'),

    -- Success Messages - Auth
    ('success.auth.logout', 'Logged out successfully'),
    ('success.auth.logout-all', 'All sessions terminated'),
    ('success.auth.session-revoked', 'Session terminated'),
    ('success.auth.unlocked', 'Account unlocked'),

    -- Success Messages - Presentation
    ('success.presentation.cache-invalidated', 'Presentation cache invalidated'),

    -- Error Messages - Permission
    ('error.permission.not-found', 'Permission not found'),
    ('error.permission.grant.failed', 'Failed to grant permission'),
    ('error.permission.deny.failed', 'Failed to deny permission'),
    ('error.permission.remove.failed', 'Failed to remove permission'),
    ('error.permission.deleted', 'Permission has been deleted'),
    ('error.permission.create.code-required', 'Permission code is required'),
    ('error.permission.create.code-exists', 'Permission code already exists'),
    ('error.permission.create.code-deleted', 'Permission code is deleted. Use restore'),
    ('error.permission.update.is-deleted', 'Deleted permission cannot be updated'),
    ('error.permission.delete.already-deleted', 'Permission is already deleted'),
    ('error.permission.restore.not-deleted', 'Permission is not deleted'),
    ('error.permission.create.failed', 'Failed to create permission'),
    ('error.permission.update.failed', 'Failed to update permission'),
    ('error.permission.delete.failed', 'Failed to delete permission'),
    ('error.permission.restore.failed', 'Failed to restore permission'),

    -- Error Messages - Role
    ('error.role.not-found', 'Role not found'),
    ('error.role.create.code-exists', 'Role code already exists'),
    ('error.role.create.code-deleted', 'Role code is deleted. Use restore'),
    ('error.role.deleted', 'Cannot operate on deleted role'),
    ('error.role.delete.already-deleted', 'Role is already deleted'),
    ('error.role.restore.not-deleted', 'Role is not deleted'),
    ('error.role.system-protected', 'System role cannot be modified'),
    ('error.role.list.failed', 'Failed to get role list'),
    ('error.role.get.failed', 'Failed to get role'),
    ('error.role.create.failed', 'Failed to create role'),
    ('error.role.update.failed', 'Failed to update role'),
    ('error.role.delete.failed', 'Failed to delete role'),
    ('error.role.restore.failed', 'Failed to restore role'),
    ('error.role.assign.failed', 'Failed to assign role'),
    ('error.role.remove.failed', 'Failed to remove role'),
    ('error.role.bulk-assign.failed', 'Bulk permission assignment failed'),
    ('error.role.assign-permission.failed', 'Failed to assign permission to role'),
    ('error.role.remove-permission.failed', 'Failed to remove permission from role'),
    ('error.role.assign-tenant.failed', 'Failed to assign tenant role'),
    ('error.role.remove-tenant.failed', 'Failed to remove tenant role'),
    ('error.role.user-not-found', 'User not found'),
    ('error.role.permission-not-found', 'Permission not found'),
    ('error.role.permission-deleted', 'Cannot assign deleted permission'),
    ('error.role.operation-failed', 'Role operation failed'),
    ('error.role.tenant-mismatch', 'Tenant mismatch'),

    -- Error Messages - User
    ('error.user.not-found', 'User not found'),
    ('error.user.create.email-exists', 'This email address is already registered'),
    ('error.user.create.username-exists', 'This username is already in use in this company'),
    ('error.user.update.is-deleted', 'Deleted user cannot be updated'),
    ('error.user.update.email-exists', 'This email address is registered to another user'),
    ('error.user.update.username-exists', 'This username is in use by another user in this company'),
    ('error.user.delete.already-deleted', 'User is already deleted'),
    ('error.user.reset-password.is-deleted', 'Cannot reset password for deleted user'),
    ('error.user.reset-password.self-not-allowed', 'Use change-password to change your own password'),
    ('error.user.restore.not-deleted', 'User is not deleted'),
    ('error.user.account-inactive', 'Account is not active'),
    ('error.user.account-locked', 'Account is locked'),
    ('error.user.change-password.current-password-invalid', 'Current password is incorrect'),
    ('error.user.change-password.same-as-current', 'New password cannot be the same as current password'),
    ('error.user.change-password.recently-used', 'This password has been used recently'),

    -- Error Messages - Company
    ('error.company.not-found', 'Company not found or inactive'),

    -- Error Messages - Menu Group
    ('error.menu-group.not-found', 'Menu group not found'),
    ('error.menu-group.code-exists', 'Menu group code already exists'),
    ('error.menu-group.delete.already-deleted', 'Menu group is already deleted'),
    ('error.menu-group.restore.not-deleted', 'Menu group is not deleted'),

    -- Error Messages - Localization
    ('error.localization.language-code-invalid', 'Invalid language code: {0}'),
    ('error.localization.language-name-invalid', 'Invalid language name'),
    ('error.localization.key.not-found', 'Localization key not found'),
    ('error.localization.key.invalid', 'Invalid localization key'),
    ('error.localization.key.exists', 'Localization key already exists'),
    ('error.localization.domain-invalid', 'Invalid domain'),
    ('error.localization.translation.not-found', 'Translation not found'),

    -- Error Messages - Language
    ('error.language.not-found', 'Language not found'),
    ('error.language.create.code-exists', 'This language code already exists'),
    ('error.language.code-invalid', 'Invalid language code. Must be 2 characters'),
    ('error.language.name-invalid', 'Invalid language name. Must be at least 2 characters'),
    ('error.language.delete.has-translations', 'Cannot delete language. It has existing translations'),

    -- Error Messages - Currency
    ('error.currency.not-found', 'Currency not found'),
    ('error.currency.create.code-exists', 'This currency code already exists'),
    ('error.currency.code-invalid', 'Invalid currency code. Must be 3 characters'),
    ('error.currency.name-invalid', 'Invalid currency name. Must be at least 2 characters'),
    ('error.currency.delete.in-use', 'Cannot delete currency. It is in use by tenants'),
    ('error.currency.delete.is-base-currency', 'Cannot delete currency. It is used as base currency by tenants'),

    -- Error Messages - SQL
    ('error.sql.function-name-invalid', 'Invalid function name: {0}'),
    ('error.sql.identifier-too-long', 'Identifier ''{0}'' is too long: {1} characters (max {2})'),
    ('error.sql.command-not-allowed', 'SQL command not allowed. Allowed prefixes: {0}'),
    ('error.sql.stacked-query', 'Multiple SQL commands (stacked queries) are not allowed'),
    ('error.sql.system-table-access', 'Access to system tables is not allowed'),

    -- Error Messages - Company CRUD
    ('error.company.create.code-exists', 'Company code already exists'),
    ('error.company.create.name-exists', 'Company name already exists'),
    ('error.company.update.code-exists', 'Company code is used by another company'),
    ('error.company.update.name-exists', 'Company name is used by another company'),
    ('error.company.delete.already-deleted', 'Company is already deleted'),
    ('error.country.not-found', 'Country code not found'),
    ('error.pagination.invalid', 'Invalid page or page size'),

    -- Error Messages - Access Control
    ('error.access.superadmin-required', 'SuperAdmin permission is required for this operation'),
    ('error.access.platform-admin-required', 'Platform Admin (SuperAdmin/Admin) permission is required for this operation'),

    -- Error Messages - Provider Type
    ('error.provider-type.not-found', 'Provider type not found'),
    ('error.provider-type.id-required', 'Provider type ID is required'),
    ('error.provider-type.code-invalid', 'Invalid provider type code. Must be at least 2 characters'),
    ('error.provider-type.name-invalid', 'Invalid provider type name. Must be at least 2 characters'),
    ('error.provider-type.code-exists', 'Provider type code already exists'),
    ('error.provider-type.has-providers', 'Cannot delete provider type. It has linked providers'),

    -- Error Messages - Provider
    ('error.provider.not-found', 'Provider not found'),
    ('error.provider.id-required', 'Provider ID is required'),
    ('error.provider.type-required', 'Provider type is required'),
    ('error.provider.code-invalid', 'Invalid provider code. Must be at least 2 characters'),
    ('error.provider.name-invalid', 'Invalid provider name. Must be at least 2 characters'),
    ('error.provider.code-exists', 'Provider code already exists'),
    ('error.provider.has-games', 'Cannot delete provider. It has linked game records'),
    ('error.provider.has-payment-methods', 'Cannot delete provider. It has linked payment method records'),

    -- Error Messages - Provider Setting
    ('error.provider-setting.not-found', 'Provider setting not found'),
    ('error.provider-setting.provider-required', 'Provider ID is required'),
    ('error.provider-setting.key-required', 'Setting key is required'),
    ('error.provider-setting.key-invalid', 'Invalid setting key. Must be at least 2 characters'),
    ('error.provider-setting.value-required', 'Setting value is required'),

    -- Error Messages - Payment Method
    ('error.payment-method.not-found', 'Payment method not found'),
    ('error.payment-method.id-required', 'Payment method ID is required'),
    ('error.payment-method.provider-required', 'Provider ID is required'),
    ('error.payment-method.code-invalid', 'Invalid payment method code. Must be at least 2 characters'),
    ('error.payment-method.name-invalid', 'Invalid payment method name. Must be at least 2 characters'),
    ('error.payment-method.type-invalid', 'Invalid payment type. Must be one of: CARD, EWALLET, BANK, CRYPTO, MOBILE, VOUCHER'),
    ('error.payment-method.code-exists', 'Payment method code already exists for this provider'),
    ('error.payment-method.in-use', 'Cannot delete payment method. It is in use by tenants'),

    -- Error Messages - Jurisdiction
    ('error.jurisdiction.not-found', 'Jurisdiction not found'),
    ('error.jurisdiction.id-required', 'Jurisdiction ID is required'),
    ('error.jurisdiction.code-invalid', 'Invalid jurisdiction code. Must be at least 2 characters'),
    ('error.jurisdiction.name-invalid', 'Invalid jurisdiction name. Must be at least 2 characters'),
    ('error.jurisdiction.country-code-invalid', 'Invalid country code. Must be 2-character ISO code'),
    ('error.jurisdiction.authority-type-invalid', 'Invalid authority type. Must be one of: national, regional, offshore'),
    ('error.jurisdiction.code-exists', 'Jurisdiction code already exists'),
    ('error.jurisdiction.has-kyc-policy', 'Cannot delete jurisdiction. It has linked KYC policy'),
    ('error.jurisdiction.has-document-requirements', 'Cannot delete jurisdiction. It has linked document requirements'),
    ('error.jurisdiction.has-level-requirements', 'Cannot delete jurisdiction. It has linked level requirements'),
    ('error.jurisdiction.has-gaming-policy', 'Cannot delete jurisdiction. It has linked responsible gaming policy'),
    ('error.jurisdiction.in-use-by-tenants', 'Cannot delete jurisdiction. It is in use by tenants'),

    -- Error Messages - KYC Policy
    ('error.kyc-policy.not-found', 'KYC policy not found'),
    ('error.kyc-policy.id-required', 'KYC policy ID is required'),
    ('error.kyc-policy.jurisdiction-required', 'Jurisdiction ID is required'),
    ('error.kyc-policy.already-exists-for-jurisdiction', 'KYC policy already exists for this jurisdiction'),
    ('error.kyc-policy.verification-timing-invalid', 'Invalid verification timing'),
    ('error.kyc-policy.min-age-invalid', 'Minimum age cannot be less than 18'),

    -- Error Messages - KYC Document Requirement
    ('error.kyc-document-requirement.not-found', 'Document requirement not found'),
    ('error.kyc-document-requirement.id-required', 'Document requirement ID is required'),
    ('error.kyc-document-requirement.jurisdiction-required', 'Jurisdiction ID is required'),
    ('error.kyc-document-requirement.document-type-invalid', 'Invalid document type'),
    ('error.kyc-document-requirement.required-for-invalid', 'Invalid required-for type. Must be one of: all, deposit, withdrawal, edd'),
    ('error.kyc-document-requirement.verification-method-invalid', 'Invalid verification method. Must be one of: manual, automated, hybrid'),
    ('error.kyc-document-requirement.already-exists', 'Document requirement already exists for this jurisdiction and document type'),

    -- Error Messages - KYC Level Requirement
    ('error.kyc-level-requirement.not-found', 'Level requirement not found'),
    ('error.kyc-level-requirement.id-required', 'Level requirement ID is required'),
    ('error.kyc-level-requirement.jurisdiction-required', 'Jurisdiction ID is required'),
    ('error.kyc-level-requirement.level-invalid', 'Invalid KYC level. Must be one of: basic, standard, enhanced'),
    ('error.kyc-level-requirement.level-order-invalid', 'Invalid level order. Must be 0 or greater'),
    ('error.kyc-level-requirement.deadline-action-invalid', 'Invalid deadline action'),
    ('error.kyc-level-requirement.already-exists', 'Level requirement already exists for this jurisdiction and KYC level'),

    -- Error Messages - Responsible Gaming Policy
    ('error.responsible-gaming-policy.not-found', 'Responsible gaming policy not found'),
    ('error.responsible-gaming-policy.id-required', 'Responsible gaming policy ID is required'),
    ('error.responsible-gaming-policy.jurisdiction-required', 'Jurisdiction ID is required'),
    ('error.responsible-gaming-policy.already-exists-for-jurisdiction', 'Responsible gaming policy already exists for this jurisdiction'),

    -- Error Messages - Theme
    ('error.theme.not-found', 'Theme not found'),
    ('error.theme.id-required', 'Theme ID is required'),
    ('error.theme.code-invalid', 'Invalid theme code. Must be at least 2 characters'),
    ('error.theme.name-invalid', 'Invalid theme name. Must be at least 2 characters'),
    ('error.theme.code-exists', 'Theme code already exists'),

    -- Error Messages - Widget
    ('error.widget.not-found', 'Widget not found'),
    ('error.widget.id-required', 'Widget ID is required'),
    ('error.widget.code-invalid', 'Invalid widget code. Must be at least 2 characters'),
    ('error.widget.name-invalid', 'Invalid widget name. Must be at least 2 characters'),
    ('error.widget.category-invalid', 'Invalid widget category. Must be one of: CONTENT, GAME, ACCOUNT, NAVIGATION'),
    ('error.widget.component-name-invalid', 'Invalid component name. Must be at least 2 characters'),
    ('error.widget.code-exists', 'Widget code already exists'),

    -- Error Messages - UI Position
    ('error.ui-position.not-found', 'UI position not found'),
    ('error.ui-position.id-required', 'UI position ID is required'),
    ('error.ui-position.code-invalid', 'Invalid position code. Must be at least 2 characters'),
    ('error.ui-position.name-invalid', 'Invalid position name. Must be at least 2 characters'),
    ('error.ui-position.code-exists', 'UI position code already exists'),

    -- Error Messages - Navigation Template
    ('error.navigation-template.not-found', 'Navigation template not found'),
    ('error.navigation-template.id-required', 'Navigation template ID is required'),
    ('error.navigation-template.code-invalid', 'Invalid template code. Must be at least 2 characters'),
    ('error.navigation-template.name-invalid', 'Invalid template name. Must be at least 2 characters'),
    ('error.navigation-template.code-exists', 'Navigation template code already exists'),
    ('error.navigation-template.has-items', 'Cannot delete navigation template. It has linked items'),

    -- Error Messages - Navigation Template Item
    ('error.navigation-template-item.not-found', 'Template item not found'),
    ('error.navigation-template-item.id-required', 'Template item ID is required'),
    ('error.navigation-template-item.template-required', 'Template ID is required'),
    ('error.navigation-template-item.menu-location-invalid', 'Invalid menu location. Must be at least 2 characters'),
    ('error.navigation-template-item.target-type-invalid', 'Invalid target type. Must be one of: INTERNAL, EXTERNAL, ACTION'),
    ('error.navigation-template-item.parent-not-found', 'Parent item not found'),
    ('error.navigation-template-item.self-parent', 'An item cannot be its own parent'),
    ('error.navigation-template-item.has-children', 'Cannot delete item. It has child items')
) AS v(key, text) ON k.localization_key = v.key
ON CONFLICT DO NOTHING;
