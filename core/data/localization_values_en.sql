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
    ('validation.field.invalid-value', 'Invalid value'),
    ('validation.field.only-one-allowed', 'Only one value is allowed'),
    ('validation.format.email-invalid', '{0} is not a valid email address'),
    ('validation.format.url-invalid', '{0} is not a valid URL'),
    ('validation.format.invalid', '{0} has invalid format'),
    ('validation.format.timezone-invalid', '{0} is not a valid timezone'),
    ('validation.format.target-type-invalid', 'Invalid target type'),
    ('validation.format.environment-invalid', 'Invalid environment value'),
    ('validation.range.greater-than-zero', '{0} must be greater than zero'),
    ('validation.range.between', '{0} must be between {1} and {2}'),
    ('validation.range.min', '{0} must be at least {1}'),
    ('validation.range.cooling-off-invalid', 'Cooling off minimum cannot be greater than maximum'),
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
    ('validation.password.mismatch', 'Passwords do not match'),
    ('validation.kyc.level-invalid', 'Invalid KYC level'),
    ('validation.kyc.deadline-action-invalid', 'Invalid deadline action value'),

    -- Error Messages - Logs
    ('error.logs.errornotfound', 'Error log not found'),
    ('error.deadletter.notfound', 'Dead letter not found'),
    ('error.deadletter.bulklimitexceeded', 'Bulk operation limit exceeded (max 500 items)'),
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
    ('error.tenant.mismatch', 'Cannot modify permissions for a different tenant'),
    ('error.tenant.scope-missing', 'Tenant scope parameter not found'),
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
    ('error.auth.token.refresh-in-progress', 'Refresh operation already in progress'),

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

    -- Error Messages - Auth 2FA
    ('error.auth.2fa.invalid-code', 'Invalid verification code'),
    ('error.auth.2fa.token-expired', '2FA token expired, please login again'),
    ('error.auth.2fa.max-attempts', 'Too many failed attempts, please login again'),
    ('error.auth.2fa.already-enabled', '2FA is already enabled'),
    ('error.auth.2fa.not-enabled', '2FA is not enabled'),
    ('error.auth.2fa.setup-expired', '2FA setup session expired'),

    -- Success Messages - Auth
    ('success.auth.logout', 'Logged out successfully'),
    ('success.auth.logout-all', 'All sessions terminated'),
    ('success.auth.session-revoked', 'Session terminated'),
    ('success.auth.unlocked', 'Account unlocked'),
    ('success.auth.password-changed', 'Password changed successfully'),

    -- Success Messages - Presentation
    ('success.presentation.cache-invalidated', 'Presentation cache invalidated'),

    -- Error Messages - Permission
    ('error.permission.escalation', 'Permission escalation attempt blocked'),
    ('error.permission.not-found', 'Permission not found'),
    ('error.permission.grant.failed', 'Failed to grant permission'),
    ('error.permission.deny.failed', 'Failed to deny permission'),
    ('error.permission.remove.failed', 'Failed to remove permission'),
    ('error.permission.inactive', 'Cannot operate on inactive permission'),
    ('error.permission.create.code-required', 'Permission code is required'),
    ('error.permission.create.code-exists', 'Permission code already exists'),
    ('error.permission.create.code-deleted', 'Permission code is deleted. Use restore'),
    ('error.permission.update.is-deleted', 'Deleted permission cannot be updated'),
    ('error.permission.restore.not-deleted', 'Permission is not deleted'),
    ('error.permission.create.failed', 'Failed to create permission'),
    ('error.permission.update.failed', 'Failed to update permission'),
    ('error.permission.delete.failed', 'Failed to delete permission'),
    ('error.permission.restore.failed', 'Failed to restore permission'),

    -- Error Messages - Role
    ('error.role.not-found', 'Role not found'),
    ('error.role.create.code-exists', 'Role code already exists'),
    ('error.role.create.code-deleted', 'Role code is deleted. Use restore'),
    ('error.role.inactive', 'Cannot operate on inactive role'),
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

    -- Error Messages - Password Policy
    ('error.password-policy.invalid-expiry-days', 'Invalid password expiry days value'),
    ('error.password-policy.invalid-history-count', 'Password history count must be between 0 and 10'),

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
    ('error.navigation-template-item.has-children', 'Cannot delete item. It has child items'),

    -- Tenant Navigation Errors
    ('error.tenant-navigation.not-found', 'Navigation item not found'),
    ('error.tenant-navigation.already-initialized', 'Tenant navigation already initialized'),
    ('error.tenant-navigation.is-locked', 'Cannot delete locked item'),
    ('error.tenant-navigation.has-children', 'Cannot delete item. It has child items'),
    ('error.tenant-navigation.parent-not-found', 'Parent item not found'),
    ('error.tenant-navigation.self-parent', 'An item cannot be its own parent'),
    ('error.tenant-navigation.readonly-field-update', 'Cannot update readonly field'),
    ('error.tenant-navigation.invalid-item-ids', 'Invalid item ID list'),

    -- Tenant Theme Errors
    ('error.tenant-theme.not-found', 'Tenant theme configuration not found'),
    ('error.tenant-theme.no-active-theme', 'No active theme found'),

    -- Tenant Layout Errors
    ('error.tenant-layout.not-found', 'Layout not found'),
    ('error.tenant-layout.no-filter', 'At least one filter parameter is required'),

    -- Error Messages - Messaging
    ('error.messaging.sender-id-required', 'Sender ID is required'),
    ('error.messaging.recipient-id-required', 'Recipient ID is required'),
    ('error.messaging.subject-required', 'Message subject is required'),
    ('error.messaging.body-required', 'Message body is required'),
    ('error.messaging.user-id-required', 'User ID is required'),
    ('error.messaging.invalid-parameters', 'Invalid parameters'),
    ('error.messaging.draft-id-required', 'Draft ID is required'),
    ('error.messaging.draft-not-found', 'Draft not found or deleted'),
    ('error.messaging.draft-not-found-or-published', 'Draft not found or already published'),
    ('error.messaging.draft-already-published', 'Draft has already been published'),
    ('error.messaging.draft-not-published', 'Draft is not published, cannot recall'),
    ('error.messaging.cannot-send-to-self', 'Cannot send a message to yourself'),
    ('error.messaging.recipient-not-found', 'Recipient not found or inactive'),
    ('error.messaging.no-recipients', 'No recipients matched the specified filters'),
    ('error.messaging.not-draft-owner', 'You are not the owner of this draft'),
    ('error.messaging.draft-not-editable', 'Draft is not in editable status'),
    ('error.messaging.draft-not-scheduled', 'Draft is not in scheduled status'),
    ('error.messaging.too-many-recipients', 'Too many recipients (maximum 10000)'),
    ('error.messaging.draft-already-cancelled', 'Draft has already been cancelled'),
    ('validation.messaging.at-least-one-field', 'At least one field must be provided'),
    ('validation.messaging.invalid-priority', 'Priority must be normal, important, or urgent'),
    ('validation.messaging.invalid-message-type', 'Invalid message type'),
    ('error.field.unauthorized-modification', 'You do not have permission to modify this field'),

    -- Access Control (new)
    ('error.access.permission-denied', 'Permission denied for this operation'),
    ('error.access.user-scope-denied', 'Operation not allowed outside user scope'),

    -- Role (new)
    ('error.role.global-only', 'This role can only be used in global scope'),
    ('error.role.hierarchy-violation', 'Role hierarchy violation'),
    ('error.role.insufficient-level', 'Insufficient role level'),
    ('error.role.target-level-violation', 'Target role level violation'),
    ('error.role.tenant-required', 'Tenant ID is required'),

    -- User (new)
    ('error.user.concurrent-modification', 'User was modified by another process'),
    ('error.user.delete.self-not-allowed', 'You cannot delete your own account'),
    ('error.user.unlock.is-deleted', 'Cannot unlock deleted user'),
    ('error.user.unlock.self-not-allowed', 'You cannot unlock your own account'),

    -- Department
    ('error.department.not-found', 'Department not found'),

    -- Tenant (new)
    ('error.tenant.id-required', 'Tenant ID is required'),
    ('error.tenant-provider.not-found', 'Tenant provider record not found'),
    ('error.tenant-game.not-found', 'Tenant game record not found'),
    ('error.tenant-payment-method.not-found', 'Tenant payment method record not found'),

    -- Provider (new)
    ('error.provider.invalid-rollout-status', 'Invalid rollout status'),
    ('error.provider.not-game-type', 'Provider is not a game type provider'),
    ('error.provider.not-payment-type', 'Provider is not a payment type provider'),

    -- Game (Game DB)
    ('error.game.not-found', 'Game not found'),
    ('error.game.id-required', 'Game ID is required'),
    ('error.game.catalog-data-required', 'Catalog data is required'),
    ('error.game.currency-code-required', 'Currency code is required'),
    ('error.game.limits-data-required', 'Limits data is required'),
    ('error.game.limits-invalid-format', 'Invalid limits data format'),
    ('error.game.player-required', 'Player ID is required'),
    ('error.game.session-not-found', 'Game session not found'),
    ('error.game.session-expired', 'Game session has expired'),

    -- Wallet (Game Gateway)
    ('error.wallet.player-not-found', 'Player not found'),
    ('error.wallet.player-frozen', 'Player account is frozen or inactive'),
    ('error.wallet.wallet-not-found', 'Wallet not found for given currency'),
    ('error.wallet.insufficient-balance', 'Insufficient balance'),
    ('error.wallet.amount-required', 'Amount is required and must be positive'),
    ('error.wallet.idempotency-key-required', 'Idempotency key is required'),

    -- Payment Method (Finance DB — new)
    ('error.payment-method.data-required', 'Payment method data is required'),
    ('error.payment-method.currency-code-required', 'Currency code is required'),
    ('error.payment-method.limits-data-required', 'Limits data is required'),
    ('error.payment-method.limits-invalid-format', 'Invalid limits data format'),

    -- Player (Tenant DB)
    ('error.player.id-required', 'Player ID is required'),
    ('error.player-limit.invalid-type', 'Invalid limit type'),

    -- Financial Limit
    ('error.financial-limit.currency-code-required', 'Currency code is required'),
    ('error.financial-limit.invalid-type', 'Invalid financial limit type'),

    -- Transaction / Operation Type Sync
    ('error.transaction-type.data-required', 'Transaction type data is required'),
    ('error.transaction-type.invalid-format', 'Transaction type data must be a JSON array'),
    ('error.operation-type.data-required', 'Operation type data is required'),
    ('error.operation-type.invalid-format', 'Operation type data must be a JSON array'),

    -- Shadow Mode
    ('error.shadow-tester.player-id-required', 'Player ID is required'),
    ('error.shadow-tester.not-found', 'Shadow tester not found'),

    -- Player Segmentation (Player Category & Group)
    ('error.player-category.code-required', 'Category code is required'),
    ('error.player-category.name-required', 'Category name is required'),
    ('error.player-category.code-exists', 'Category code already exists'),
    ('error.player-category.not-found', 'Player category not found'),
    ('error.player-category.already-inactive', 'Player category is already inactive'),

    ('error.player-group.code-required', 'Group code is required'),
    ('error.player-group.name-required', 'Group name is required'),
    ('error.player-group.code-exists', 'Group code already exists'),
    ('error.player-group.not-found', 'Player group not found'),
    ('error.player-group.already-inactive', 'Player group is already inactive'),

    -- Player Classification
    ('error.player-classification.player-not-found', 'Player not found'),
    ('error.player-classification.group-not-found', 'Group not found or inactive'),
    ('error.player-classification.category-not-found', 'Category not found or inactive'),
    ('error.player-classification.no-assignment', 'At least one group or category is required'),
    ('error.player-classification.no-players', 'Player list is empty'),

    -- Jurisdiction (new)
    ('error.jurisdiction.has-retention-policies', 'Cannot delete jurisdiction. It has linked data retention policies'),

    -- Data Retention Policy
    ('error.data-retention-policy.not-found', 'Data retention policy not found'),
    ('error.data-retention-policy.id-required', 'Policy ID is required'),
    ('error.data-retention-policy.jurisdiction-required', 'Jurisdiction ID is required'),
    ('error.data-retention-policy.data-category-invalid', 'Invalid data category'),
    ('error.data-retention-policy.retention-days-invalid', 'Invalid retention period'),
    ('error.data-retention-policy.already-exists', 'Policy already exists for this jurisdiction and category'),

    -- Cryptocurrency
    ('error.cryptocurrency.not-found', 'Cryptocurrency not found'),
    ('error.cryptocurrency.symbol-required', 'Cryptocurrency symbol is required'),
    ('error.cryptocurrency.name-invalid', 'Invalid cryptocurrency name'),
    ('error.cryptocurrency.delete.in-use', 'Cannot delete cryptocurrency. It is in use'),

    -- Currency Rates
    ('error.currency-rates.base-currency-required', 'Base currency is required'),
    ('error.currency-rates.provider-required', 'Rate provider is required'),
    ('error.currency-rates.rates-empty', 'Rate data cannot be empty'),
    ('error.currency-rates.timestamp-required', 'Timestamp is required'),

    -- Crypto Rates
    ('error.crypto-rates.base-currency-required', 'Base currency is required'),
    ('error.crypto-rates.provider-required', 'Rate provider is required'),
    ('error.crypto-rates.rates-empty', 'Rate data cannot be empty'),
    ('error.crypto-rates.timestamp-required', 'Timestamp is required'),

    -- Messaging — Tenant (campaign, template, inbox)
    ('error.messaging.player-id-required', 'Player ID is required'),
    ('error.messaging.message-not-found', 'Message not found'),
    ('error.messaging.invalid-message-type', 'Invalid message type'),
    ('error.messaging.invalid-channel-type', 'Invalid channel type'),
    ('error.messaging.template-not-found', 'Message template not found'),
    ('error.messaging.template-code-required', 'Template code is required'),
    ('error.messaging.template-code-exists', 'Template code already exists'),
    ('error.messaging.template-name-required', 'Template name is required'),
    ('error.messaging.invalid-template-status', 'Invalid template status'),
    ('error.messaging.campaign-not-found', 'Messaging campaign not found'),
    ('error.messaging.campaign-name-required', 'Campaign name is required'),
    ('error.messaging.campaign-not-editable', 'Campaign cannot be edited'),
    ('error.messaging.campaign-not-publishable', 'Campaign cannot be published'),
    ('error.messaging.campaign-not-cancellable', 'Campaign cannot be cancelled'),

    -- Bonus Engine — Bonus Types
    ('error.bonus-type.not-found', 'Bonus type not found'),
    ('error.bonus-type.id-required', 'Bonus type ID is required'),
    ('error.bonus-type.code-required', 'Bonus type code is required'),
    ('error.bonus-type.code-exists', 'Bonus type code already exists'),
    ('error.bonus-type.name-required', 'Bonus type name is required'),
    ('error.bonus-type.category-required', 'Bonus category is required'),
    ('error.bonus-type.value-type-required', 'Value type is required'),

    -- Bonus Engine — Bonus Rules
    ('error.bonus-rule.not-found', 'Bonus rule not found'),
    ('error.bonus-rule.not-found-or-inactive', 'Bonus rule not found or inactive'),
    ('error.bonus-rule.id-required', 'Bonus rule ID is required'),
    ('error.bonus-rule.code-required', 'Bonus rule code is required'),
    ('error.bonus-rule.code-exists', 'Bonus rule code already exists'),
    ('error.bonus-rule.name-required', 'Bonus rule name is required'),
    ('error.bonus-rule.trigger-config-required', 'Trigger configuration is required'),
    ('error.bonus-rule.reward-config-required', 'Reward configuration is required'),
    ('error.bonus-rule.invalid-evaluation-type', 'Invalid evaluation type'),

    -- Bonus Engine — Bonus Awards
    ('error.bonus-award.not-found', 'Bonus award not found'),
    ('error.bonus-award.id-required', 'Bonus award ID is required'),
    ('error.bonus-award.player-required', 'Player ID is required'),
    ('error.bonus-award.rule-required', 'Bonus rule ID is required'),
    ('error.bonus-award.currency-required', 'Currency is required'),
    ('error.bonus-award.wallet-not-found', 'Bonus wallet not found'),
    ('error.bonus-award.cannot-cancel', 'Bonus award cannot be cancelled'),
    ('error.bonus-award.not-completable', 'Bonus award cannot be completed'),
    ('error.bonus-award.wagering-not-complete', 'Wagering requirement not met'),
    ('error.bonus-award.amount-required', 'Bonus amount is required'),

    -- Bonus Request (Manual bonus request system)
    ('error.bonus-request.not-found', 'Bonus request not found'),
    ('error.bonus-request.invalid-status', 'Invalid request status for this operation'),
    ('error.bonus-request.player-required', 'Player ID is required'),
    ('error.bonus-request.invalid-source', 'Invalid request source. Must be player or operator'),
    ('error.bonus-request.type-required', 'Bonus type is required'),
    ('error.bonus-request.description-required', 'Description is required'),
    ('error.bonus-request.amount-required', 'Amount is required for operator requests'),
    ('error.bonus-request.currency-required', 'Currency is required for operator requests'),
    ('error.bonus-request.hold-reason-required', 'Hold reason is required'),
    ('error.bonus-request.review-note-required', 'Review note is required for rejection'),
    ('error.bonus-request.rollback-reason-required', 'Rollback reason is required'),
    ('error.bonus-request.rollback-not-allowed', 'Rollback is not allowed from this status'),
    ('error.bonus-request.type-not-requestable', 'This bonus type is not available for requests'),
    ('error.bonus-request.player-not-eligible', 'Player is not eligible for this bonus type'),
    ('error.bonus-request.pending-exists', 'A pending request already exists for this bonus type'),
    ('error.bonus-request.cooldown-after-approved', 'Cooldown period after approved request has not elapsed'),
    ('error.bonus-request.cooldown-after-rejected', 'Cooldown period after rejected request has not elapsed'),
    ('error.bonus-request.not-owner', 'You are not the owner of this request'),

    -- Bonus Request Settings
    ('error.bonus-request-settings.not-found', 'Bonus request setting not found'),
    ('error.bonus-request-settings.display-name-required', 'Display name is required'),
    ('error.bonus-request-settings.invalid-display-name', 'Invalid display name JSON format'),
    ('error.bonus-request-settings.invalid-rules-content', 'Invalid rules content JSON format'),
    ('error.bonus-request-settings.invalid-eligible-groups', 'Invalid eligible groups JSON format'),
    ('error.bonus-request-settings.invalid-eligible-categories', 'Invalid eligible categories JSON format'),
    ('error.bonus-request-settings.invalid-usage-criteria', 'Invalid usage criteria JSON format'),

    -- Bonus Mapping (Provider bonus tracking)
    ('error.bonus-mapping.award-required', 'Bonus award ID is required'),
    ('error.bonus-mapping.provider-required', 'Provider code is required'),
    ('error.bonus-mapping.data-required', 'Bonus mapping data is required'),
    ('error.bonus-mapping.not-found', 'Provider bonus mapping not found'),
    ('error.bonus-mapping.invalid-status', 'Invalid bonus mapping status'),

    -- Reconciliation (Provider reconciliation)
    ('error.reconciliation.provider-required', 'Provider code is required for reconciliation'),
    ('error.reconciliation.date-required', 'Report date is required'),

    -- Bonus Engine — Campaigns
    ('error.campaign.not-found', 'Campaign not found'),
    ('error.campaign.id-required', 'Campaign ID is required'),
    ('error.campaign.code-required', 'Campaign code is required'),
    ('error.campaign.code-exists', 'Campaign code already exists'),
    ('error.campaign.name-required', 'Campaign name is required'),
    ('error.campaign.type-required', 'Campaign type is required'),
    ('error.campaign.dates-required', 'Campaign dates are required'),
    ('error.campaign.end-before-start', 'End date cannot be before start date'),
    ('error.campaign.invalid-status', 'Invalid campaign status'),
    ('error.campaign.invalid-award-strategy', 'Invalid award strategy'),

    -- Bonus Engine — Promo Codes
    ('error.promo.not-found', 'Promo code not found'),
    ('error.promo.id-required', 'Promo ID is required'),
    ('error.promo.code-required', 'Promo code is required'),
    ('error.promo.code-id-required', 'Promo code ID is required'),
    ('error.promo.code-exists', 'Promo code already exists'),
    ('error.promo.name-required', 'Promo name is required'),
    ('error.promo.invalid-status', 'Invalid promo status'),
    ('error.promo.player-required', 'Player ID is required'),

    -- Finance Gateway — Payment Sessions
    ('error.finance.session-player-required', 'Player ID is required for payment session'),
    ('error.finance.session-type-required', 'Session type is required'),
    ('error.finance.session-amount-required', 'Amount is required for payment session'),
    ('error.finance.session-not-found', 'Payment session not found'),
    ('error.finance.session-expired', 'Payment session has expired'),

    -- Finance Gateway — Deposit
    ('error.deposit.player-required', 'Player ID is required'),
    ('error.deposit.invalid-amount', 'Deposit amount must be greater than zero'),
    ('error.deposit.idempotency-required', 'Idempotency key is required'),
    ('error.deposit.player-not-active', 'Player account is not active'),
    ('error.deposit.wallet-not-found', 'Player wallet not found'),
    ('error.deposit-confirm.transaction-not-found', 'Pending deposit transaction not found'),
    ('error.deposit-confirm.player-mismatch', 'Player ID does not match the deposit transaction'),
    ('error.deposit-fail.already-confirmed', 'Cannot fail an already confirmed deposit'),

    -- Finance Gateway — Withdrawal
    ('error.withdrawal.insufficient-balance', 'Insufficient balance for withdrawal'),
    ('error.withdrawal.active-wagering-incomplete', 'Active bonus wagering requirement is not complete'),
    ('error.withdrawal-cancel.already-confirmed', 'Cannot cancel an already confirmed withdrawal'),
    ('error.withdrawal-fail.already-confirmed', 'Cannot fail an already confirmed withdrawal'),

    -- Finance Gateway — Workflow
    ('error.workflow.invalid-type', 'Invalid workflow type'),
    ('error.workflow.already-pending', 'Active workflow already exists for this transaction'),
    ('error.workflow.not-found', 'Workflow not found'),
    ('error.workflow.not-pending', 'Workflow is not in pending status'),
    ('error.workflow.not-in-review', 'Workflow is not in review status'),

    -- Finance Gateway — Account Adjustment
    ('error.adjustment.not-found', 'Adjustment not found'),
    ('error.adjustment.not-pending', 'Adjustment is not in pending status'),
    ('error.adjustment.invalid-direction', 'Direction must be CREDIT or DEBIT'),
    ('error.adjustment.invalid-wallet-type', 'Wallet type must be REAL or BONUS'),
    ('error.adjustment.invalid-type', 'Invalid adjustment type'),
    ('error.adjustment.provider-required', 'Provider ID is required for game correction'),
    ('error.adjustment.insufficient-balance', 'Insufficient balance for debit adjustment'),

    -- Finance Gateway — Fee Calculation
    ('error.calculate-fee.invalid-direction', 'Invalid direction for fee calculation'),
    ('error.calculate-fee.method-not-found', 'Payment method limits not found'),

    -- Support — Ticket System
    ('error.support.player-required', 'Player ID is required'),
    ('error.support.subject-required', 'Ticket subject is required'),
    ('error.support.description-required', 'Ticket description is required'),
    ('error.support.invalid-channel', 'Invalid communication channel'),
    ('error.support.invalid-priority', 'Invalid priority level'),
    ('error.support.invalid-created-by-type', 'Invalid creator type'),
    ('error.support.ticket-not-found', 'Ticket not found'),
    ('error.support.ticket-invalid-status', 'Invalid ticket status for this operation'),
    ('error.support.ticket-not-owner', 'This ticket does not belong to this player'),
    ('error.support.ticket-already-assigned', 'Ticket is already assigned to this agent'),
    ('error.support.ticket-closed', 'Cannot perform operation on closed ticket'),
    ('error.support.resolve-note-required', 'Resolution note is required'),
    ('error.support.max-open-tickets-reached', 'Maximum open tickets limit reached'),
    ('error.support.ticket-cooldown-active', 'Ticket creation cooldown period has not elapsed'),

    -- Support — Player Note
    ('error.support.note-not-found', 'Note not found'),
    ('error.support.note-already-deleted', 'Note is already deleted'),
    ('error.support.note-content-required', 'Note content is required'),
    ('error.support.invalid-note-type', 'Invalid note type'),

    -- Support — Representative
    ('error.support.representative-reason-required', 'Representative change reason is required'),
    ('error.support.representative-already-assigned', 'Same representative is already assigned'),

    -- Support — Welcome Call
    ('error.support.welcome-task-not-found', 'Welcome call task not found'),
    ('error.support.welcome-task-not-in-progress', 'Task is not in a valid status'),
    ('error.support.welcome-task-not-assignable', 'Task is not in an assignable status'),
    ('error.support.invalid-call-result', 'Invalid call result'),
    ('error.support.invalid-reschedule-result', 'Invalid reschedule result'),
    ('error.support.assigned-to-required', 'Assigned-to user ID is required'),

    -- Support — Category
    ('error.support.category-not-found', 'Ticket category not found'),
    ('error.support.parent-category-not-found', 'Parent category not found'),
    ('error.support.category-has-children', 'Cannot delete category with active children'),
    ('error.support.category-code-exists', 'Category code already exists'),
    ('error.support.category-code-required', 'Category code is required'),
    ('error.support.category-name-required', 'Category name is required'),
    ('error.support.invalid-category-name-format', 'Invalid category name JSON format'),
    ('error.support.invalid-category-description-format', 'Invalid category description JSON format'),

    -- Support — Tag
    ('error.support.tag-not-found', 'Tag not found'),
    ('error.support.tag-name-exists', 'Tag name already exists'),
    ('error.support.tag-name-required', 'Tag name is required'),
    ('error.support.invalid-tag-color', 'Invalid color code (HEX format expected)'),

    -- Support — Canned Response
    ('error.support.canned-response-not-found', 'Canned response not found'),

    -- Support — General
    ('error.support.no-fields-to-update', 'At least one field to update is required'),

    -- Player Registration
    ('error.player-register.username-required', 'Username is required'),
    ('error.player-register.email-required', 'Email is required'),
    ('error.player-register.password-required', 'Password is required'),
    ('error.player-register.token-required', 'Verification token is required'),
    ('error.player-register.username-exists', 'Username already exists'),
    ('error.player-register.email-exists', 'Email is already registered'),

    -- Player Email Verification
    ('error.player-verify.token-required', 'Verification token is required'),
    ('error.player-verify.token-not-found', 'Verification token not found'),
    ('error.player-verify.token-expired', 'Verification token has expired'),
    ('error.player-verify.already-verified', 'Email is already verified'),
    ('error.player-verify.player-required', 'Player ID is required'),
    ('error.player-verify.player-not-found', 'Player not found'),

    -- Player Authentication
    ('error.player-auth.email-required', 'Email is required'),
    ('error.player-auth.invalid-credentials', 'Invalid credentials'),
    ('error.player-auth.account-locked', 'Account is locked'),
    ('error.player-auth.account-suspended', 'Account is suspended'),
    ('error.player-auth.account-closed', 'Account is closed'),
    ('error.player-auth.player-required', 'Player ID is required'),
    ('error.player-auth.player-not-found', 'Player not found'),

    -- Player Password
    ('error.player-password.player-required', 'Player ID is required'),
    ('error.player-password.password-required', 'Password is required'),
    ('error.player-password.player-not-found', 'Player not found'),
    ('error.player-password.account-inactive', 'Account is not active'),
    ('error.player-password.token-required', 'Reset token is required'),
    ('error.player-password.token-not-found', 'Reset token not found'),
    ('error.player-password.token-expired', 'Reset token has expired'),

    -- Player Profile
    ('error.player-profile.player-required', 'Player ID is required'),
    ('error.player-profile.player-not-found', 'Player not found'),
    ('error.player-profile.already-exists', 'Profile already exists'),
    ('error.player-profile.not-found', 'Profile not found'),

    -- Player Identity
    ('error.player-identity.player-required', 'Player ID is required'),
    ('error.player-identity.identity-required', 'Identity number is required'),
    ('error.player-identity.player-not-found', 'Player not found'),

    -- Player BO Management
    ('error.player.player-required', 'Player ID is required'),
    ('error.player.not-found', 'Player not found'),
    ('error.player.invalid-status', 'Invalid player status'),
    ('error.player.status-unchanged', 'Status is already the same'),

    -- Wallet
    ('error.wallet.player-required', 'Player ID is required'),
    ('error.wallet.currency-required', 'Currency code is required'),
    ('error.wallet.player-not-active', 'Player account is not active'),

    -- KYC Case
    ('error.kyc-case.player-required', 'Player ID is required'),
    ('error.kyc-case.player-not-found', 'Player not found'),
    ('error.kyc-case.case-required', 'Case ID is required'),
    ('error.kyc-case.not-found', 'KYC case not found'),
    ('error.kyc-case.status-required', 'Status is required'),
    ('error.kyc-case.status-unchanged', 'Status is already the same'),
    ('error.kyc-case.reviewer-required', 'Reviewer ID is required'),

    -- KYC Document
    ('error.kyc-document.player-required', 'Player ID is required'),
    ('error.kyc-document.player-not-found', 'Player not found'),
    ('error.kyc-document.document-required', 'Document ID is required'),
    ('error.kyc-document.not-found', 'Document not found'),
    ('error.kyc-document.type-required', 'Document type is required'),
    ('error.kyc-document.storage-type-required', 'Storage type is required'),
    ('error.kyc-document.hash-required', 'File hash is required'),
    ('error.kyc-document.status-required', 'Status is required'),
    ('error.kyc-document.case-not-found', 'KYC case not found'),

    -- KYC Restriction
    ('error.kyc-restriction.player-required', 'Player ID is required'),
    ('error.kyc-restriction.player-not-found', 'Player not found'),
    ('error.kyc-restriction.restriction-required', 'Restriction ID is required'),
    ('error.kyc-restriction.type-required', 'Restriction type is required'),
    ('error.kyc-restriction.not-found', 'Restriction not found'),
    ('error.kyc-restriction.not-active', 'Restriction is not active'),
    ('error.kyc-restriction.cannot-revoke', 'Restriction cannot be revoked'),
    ('error.kyc-restriction.min-duration-not-met', 'Minimum duration has not been met'),

    -- KYC Limit
    ('error.kyc-limit.player-required', 'Player ID is required'),
    ('error.kyc-limit.player-not-found', 'Player not found'),
    ('error.kyc-limit.limit-required', 'Limit ID is required'),
    ('error.kyc-limit.type-required', 'Limit type is required'),
    ('error.kyc-limit.value-required', 'Limit value is required'),
    ('error.kyc-limit.not-found', 'Limit not found'),
    ('error.kyc-limit.not-active', 'Limit is not active'),

    -- KYC AML
    ('error.kyc-aml.player-required', 'Player ID is required'),
    ('error.kyc-aml.player-not-found', 'Player not found'),
    ('error.kyc-aml.flag-required', 'AML flag ID is required'),
    ('error.kyc-aml.flag-type-required', 'Flag type is required'),
    ('error.kyc-aml.severity-required', 'Severity is required'),
    ('error.kyc-aml.description-required', 'Description is required'),
    ('error.kyc-aml.not-found', 'AML flag not found'),
    ('error.kyc-aml.status-required', 'Status is required'),
    ('error.kyc-aml.status-unchanged', 'Status is already the same'),
    ('error.kyc-aml.assignee-required', 'Assignee ID is required'),
    ('error.kyc-aml.decision-required', 'Decision is required'),
    ('error.kyc-aml.decision-by-required', 'Decision maker ID is required'),

    -- KYC Jurisdiction
    ('error.kyc-jurisdiction.player-required', 'Player ID is required'),
    ('error.kyc-jurisdiction.player-not-found', 'Player not found'),
    ('error.kyc-jurisdiction.country-required', 'Country code is required'),
    ('error.kyc-jurisdiction.already-exists', 'Jurisdiction record already exists'),
    ('error.kyc-jurisdiction.not-found', 'Jurisdiction record not found'),

    -- KYC Screening
    ('error.kyc-screening.player-required', 'Player ID is required'),
    ('error.kyc-screening.screening-required', 'Screening ID is required'),
    ('error.kyc-screening.type-required', 'Screening type is required'),
    ('error.kyc-screening.provider-required', 'Provider code is required'),
    ('error.kyc-screening.status-required', 'Result status is required'),
    ('error.kyc-screening.decision-required', 'Review decision is required'),
    ('error.kyc-screening.reviewer-required', 'Reviewer ID is required'),
    ('error.kyc-screening.not-found', 'Screening result not found'),

    -- KYC Risk
    ('error.kyc-risk.player-required', 'Player ID is required'),
    ('error.kyc-risk.type-required', 'Assessment type is required'),
    ('error.kyc-risk.level-required', 'Risk level is required'),

    -- KYC Provider Log
    ('error.kyc-provider-log.player-required', 'Player ID is required'),
    ('error.kyc-provider-log.case-required', 'Case ID is required'),
    ('error.kyc-provider-log.provider-required', 'Provider code is required'),

    -- Tenant Backoffice — Content Management (CMS)
    ('error.content.id-required', 'Content ID is required'),
    ('error.content.not-found', 'Content not found'),
    ('error.content.slug-required', 'Slug is required'),
    ('error.content.translations-required', 'At least one translation is required'),
    ('error.content.user-id-required', 'User ID is required'),
    ('error.content.category-code-required', 'Category code is required'),
    ('error.content.category-id-required', 'Category ID is required'),
    ('error.content.category-not-found', 'Category not found'),
    ('error.content.category-has-active-types', 'Cannot delete category with active content types'),
    ('error.content.type-code-required', 'Content type code is required'),
    ('error.content.type-id-required', 'Content type ID is required'),
    ('error.content.type-not-found', 'Content type not found'),
    ('error.content.type-has-active-contents', 'Cannot delete type with active contents'),

    -- Tenant Backoffice — FAQ
    ('error.faq.user-id-required', 'User ID is required'),
    ('error.faq.category-code-required', 'FAQ category code is required'),
    ('error.faq.category-id-required', 'FAQ category ID is required'),
    ('error.faq.category-not-found', 'FAQ category not found'),
    ('error.faq.category-has-active-items', 'Cannot delete FAQ category with active items'),
    ('error.faq.item-id-required', 'FAQ item ID is required'),
    ('error.faq.item-not-found', 'FAQ item not found'),

    -- Tenant Backoffice — Layout
    ('error.layout.id-required', 'Layout ID is required'),
    ('error.layout.not-found', 'Layout not found'),
    ('error.layout.name-required', 'Layout name is required'),
    ('error.layout.structure-required', 'Layout structure is required'),

    -- Tenant Backoffice — Message Preferences
    ('error.messaging.preference.invalid-channel-type', 'Invalid preference channel type'),
    ('error.messaging.preference.opted-in-required', 'Opted-in status is required'),

    -- Tenant Backoffice — Navigation
    ('error.navigation.id-required', 'Navigation item ID is required'),
    ('error.navigation.item-not-found', 'Navigation item not found'),
    ('error.navigation.item-locked', 'Locked navigation item cannot be deleted'),
    ('error.navigation.has-children', 'Cannot delete navigation item with children'),
    ('error.navigation.parent-not-found', 'Parent navigation item not found'),
    ('error.navigation.location-required', 'Menu location is required'),
    ('error.navigation.label-required', 'Label or translation key is required'),
    ('error.navigation.item-ids-required', 'Item ID list is required'),

    -- Tenant Backoffice — Popup
    ('error.popup.id-required', 'Popup ID is required'),
    ('error.popup.not-found', 'Popup not found'),
    ('error.popup.user-id-required', 'User ID is required'),
    ('error.popup.type-code-required', 'Popup type code is required'),
    ('error.popup.type-id-required', 'Popup type ID is required'),
    ('error.popup.type-not-found', 'Popup type not found'),

    -- Tenant Backoffice — Promotion
    ('error.promotion.id-required', 'Promotion ID is required'),
    ('error.promotion.not-found', 'Promotion not found'),
    ('error.promotion.code-required', 'Promotion code is required'),
    ('error.promotion.user-id-required', 'User ID is required'),
    ('error.promotion.type-code-required', 'Promotion type code is required'),
    ('error.promotion.type-id-required', 'Promotion type ID is required'),
    ('error.promotion.type-not-found', 'Promotion type not found'),

    -- Tenant Backoffice — Slide/Banner
    ('error.slide.id-required', 'Slide ID is required'),
    ('error.slide.not-found', 'Slide not found'),
    ('error.slide.user-id-required', 'User ID is required'),
    ('error.slide.placement-id-required', 'Placement ID is required'),
    ('error.slide.placement-code-required', 'Placement code is required'),
    ('error.slide.placement-name-required', 'Placement name is required'),
    ('error.slide.placement-not-found', 'Placement not found'),
    ('error.slide.slide-ids-required', 'Slide ID list is required'),
    ('error.slide.category-code-required', 'Slide category code is required'),
    ('error.slide.category-not-found', 'Slide category not found'),

    -- Tenant Backoffice — Theme (additional)
    ('error.theme.theme-id-required', 'Theme reference ID is required'),

    -- Tenant Backoffice — Trust Logos
    ('error.trust-logo.code-required', 'Logo code is required'),
    ('error.trust-logo.type-required', 'Logo type is required'),
    ('error.trust-logo.name-required', 'Logo name is required'),
    ('error.trust-logo.logo-url-required', 'Logo URL is required'),
    ('error.trust-logo.items-required', 'Logo list is required'),
    ('error.trust-logo.id-required', 'Logo ID is required'),
    ('error.trust-logo.not-found', 'Logo not found'),

    -- Tenant Backoffice — Operator Licenses
    ('error.operator-license.jurisdiction-required', 'Jurisdiction is required'),
    ('error.operator-license.license-number-required', 'License number is required'),
    ('error.operator-license.expiry-before-issued', 'Expiry date cannot be before issued date'),
    ('error.operator-license.id-required', 'License ID is required'),
    ('error.operator-license.not-found', 'License not found'),

    -- Tenant Backoffice — SEO Redirects
    ('error.seo-redirect.from-slug-required', 'Source URL is required'),
    ('error.seo-redirect.to-url-required', 'Target URL is required'),
    ('error.seo-redirect.invalid-redirect-type', 'Invalid redirect type (must be 301 or 302)'),
    ('error.seo-redirect.circular-redirect', 'Circular redirect detected'),
    ('error.seo-redirect.items-required', 'Redirect list is required'),
    ('error.seo-redirect.id-required', 'Redirect ID is required'),
    ('error.seo-redirect.not-found', 'Redirect not found'),

    -- Tenant Backoffice — Content SEO Meta
    ('error.content-seo-meta.content-id-required', 'Content ID is required'),
    ('error.content-seo-meta.language-required', 'Language code is required'),
    ('error.content-seo-meta.invalid-twitter-card', 'Invalid Twitter card type'),
    ('error.content-seo-meta.translation-not-found', 'Content translation not found'),

    -- Tenant Backoffice — Social Links
    ('error.social-link.platform-required', 'Platform name is required'),
    ('error.social-link.url-required', 'URL is required'),
    ('error.social-link.items-required', 'Link list is required'),
    ('error.social-link.id-required', 'Link ID is required'),
    ('error.social-link.not-found', 'Social link not found'),

    -- Tenant Backoffice — Site Settings
    ('error.site-settings.field-name-required', 'Field name is required'),
    ('error.site-settings.value-required', 'Field value is required'),
    ('error.site-settings.invalid-field', 'Invalid field name'),
    ('error.site-settings.not-found', 'Site settings not found'),

    -- Tenant Backoffice — Announcement Bars
    ('error.announcement-bar.code-required', 'Announcement bar code is required'),
    ('error.announcement-bar.invalid-audience', 'Invalid target audience'),
    ('error.announcement-bar.ends-before-starts', 'End date cannot be before start date'),
    ('error.announcement-bar.id-required', 'Announcement bar ID is required'),
    ('error.announcement-bar.not-found', 'Announcement bar not found'),
    ('error.announcement-bar-translation.bar-id-required', 'Announcement bar ID is required'),
    ('error.announcement-bar-translation.language-required', 'Language code is required'),
    ('error.announcement-bar-translation.text-required', 'Announcement text is required'),

    -- Tenant Backoffice — Lobby Sections
    ('error.lobby-section.code-required', 'Section code is required'),
    ('error.lobby-section.max-items-invalid', 'Maximum items count is invalid'),
    ('error.lobby-section.id-required', 'Section ID is required'),
    ('error.lobby-section.not-found', 'Lobby section not found'),
    ('error.lobby-section-translation.section-id-required', 'Section ID is required'),
    ('error.lobby-section-translation.language-required', 'Language code is required'),
    ('error.lobby-section-translation.title-required', 'Title is required'),
    ('error.lobby-section-game.section-id-required', 'Section ID is required'),
    ('error.lobby-section-game.game-id-required', 'Game ID is required'),
    ('error.lobby-section-game.section-not-found', 'Lobby section not found'),
    ('error.lobby-section-game.section-not-manual', 'Section is not of manual curation type'),
    ('error.lobby-section-game.not-found', 'Section-game assignment not found'),

    -- Tenant Backoffice — Game Labels
    ('error.game-label.game-id-required', 'Game ID is required'),
    ('error.game-label.label-type-required', 'Label type is required'),
    ('error.game-label.expires-in-past', 'Expiry date cannot be in the past'),
    ('error.game-label.id-required', 'Label ID is required'),
    ('error.game-label.not-found', 'Game label not found')
) AS v(key, text) ON k.localization_key = v.key
ON CONFLICT DO NOTHING;
