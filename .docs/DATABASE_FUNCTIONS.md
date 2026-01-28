# Veritabanı Fonksiyon ve Trigger Dokümantasyonu

Bu doküman, projede yer alan stored procedure ve trigger tanımlarını içerir.

## Core Veritabanı

### Catalog Şeması

- **`country_list`**: Returns list of countries for comboboxes (Value: country_code, Label: country_name).
- **`currency_list`**: Returns list of active currencies for comboboxes (Value: currency_code, Label: currency_name).
- **`language_create`**: Creates a new language
- **`language_delete`**: Soft deletes a language by setting is_active to false (checks for translations first)
- **`language_get`**: Gets details of a specific language by code
- **`language_list`**: Lists all languages including inactive ones (for admin usage)
- **`language_list_active`**: Lists all active languages (for public API usage)
- **`language_update`**: Updates language details (name, active status)
- **`localization_category_list`**: Lists distinct localization categories.
- **`localization_domain_list`**: Lists distinct localization domains.
- **`localization_export`**: Exports translations for a specific language as JSON.
- **`localization_import`**: Imports translations from JSON for a specific language.
- **`localization_key_create`**: Creates a new localization key.
- **`localization_key_delete`**: Deletes a localization key and its values.
- **`localization_key_get`**: Gets a localization key details and all its translations.
- **`localization_key_list`**: Lists localization keys with pagination and filtering.
- **`localization_key_update`**: Updates a localization key.
- **`localization_messages_get`**: Retrieves all localization messages for a specific language (for bulk loading)
- **`localization_value_delete`**: Deletes a specific localization value.
- **`localization_value_upsert`**: Inserts or updates a localization value (translation).
- **`timezone_list`**: Returns list of active timezones from catalog table.

### Core Şeması

- **`company_create`**: Creates a new company record for management UI.
- **`company_delete`**: Soft deletes a company record for management UI.
- **`company_get`**: Returns details of a company by id for management UI.
- **`company_list`**: Returns a paginated list of companies for management UI. Searchable by name or code.
- **`company_update`**: Updates company information for management UI.
- **`tenant_create`**: No description info.
- **`tenant_currency_list`**: Lists all assigned currencies for a tenant.
- **`tenant_currency_upsert`**: Assigns or updates a currency for a tenant.
- **`tenant_delete`**: Soft deletes a tenant by setting status to 0.
- **`tenant_get`**: Returns detailed tenant information including supported configuration.
- **`tenant_list`**: Lists tenants with pagination, filter, and configuration details.
- **`tenant_setting_delete`**: Deletes a tenant configuration setting.
- **`tenant_setting_get`**: Returns a specific tenant setting as JSON object. Returns NULL if not found.
- **`tenant_setting_list`**: Lists all configuration settings for a tenant, optionally filtered by category.
- **`tenant_setting_upsert`**: Inserts or updates a tenant configuration setting.
- **`tenant_update`**: No description info.
- **`update_updated_at_column`**: Generic trigger function to auto-update updated_at timestamp.

### Presentation Şeması

- **`build_page_json`**: Builds JSON object for a page (including tabs and contexts). Helper function for get_structure.
- **`context_create`**: Creates a new context. Returns TABLE(id BIGINT).
- **`context_delete`**: Deletes a context (hard delete). Returns VOID.
- **`context_list`**: Lists contexts for a given page, returns items and totalCount.
- **`context_update`**: Updates a context. Partial update supported. Returns VOID.
- **`get_structure`**: Returns entire presentation structure as nested JSON. Uses MD5 version hash for cache invalidation.
- **`menu_create`**: Creates a new menu with unique code validation
- **`menu_delete`**: Soft deletes a menu by setting is_active to FALSE and updating deleted_at.
- **`menu_get`**: Returns details of a menu including group, submenus, pages, and audit info
- **`menu_group_create`**: Creates a new menu group with unique code validation
- **`menu_group_delete`**: Soft deletes a menu group by setting is_active to FALSE
- **`menu_group_get`**: Returns single menu group details by ID
- **`menu_group_list`**: Returns all menu groups ordered by order_index. Includes menu count per group.
- **`menu_group_update`**: Updates menu group with partial update support. NULL values keep existing data.
- **`menu_list`**: Lists menus for a given group, returns items and totalCount
- **`menu_update`**: Updates menu with partial update support. NULL values keep existing data.
- **`page_create`**: Creates a new page with unique code validation and parent menu/submenu check.
- **`page_delete`**: Soft deletes a page by setting is_active to FALSE and updating updated_at.
- **`page_get`**: Returns details of a page including tabs and contexts.
- **`page_list`**: Lists pages for a given menu or submenu, returns items and totalCount.
- **`page_update`**: Updates page with partial update support. NULL values keep existing data.
- **`submenu_create`**: Creates a new submenu with unique code validation for the given menu.
- **`submenu_delete`**: Soft deletes a submenu by setting is_active to FALSE and updating updated_at.
- **`submenu_list`**: Lists submenus for a given menu, returns items and totalCount.
- **`submenu_update`**: Updates submenu with partial update support. NULL values keep existing data.
- **`tab_create`**: Creates a new tab with unique code validation for the given page.
- **`tab_delete`**: Soft deletes a tab by setting is_active to FALSE and updating updated_at.
- **`tab_list`**: Lists tabs for a given page, returns items and totalCount.
- **`tab_update`**: Updates tab with partial update support. NULL values keep existing data.

### Security Şeması

- **`is_system_role`**: Checks if a role code is a protected system role (e.g. superadmin).
- **`permission_category_list`**: Lists active permission categories and count. Returns direct JSON array.
- **`permission_check`**: Checks if a user has a specific permission (Global or Tenant-level)
- **`permission_cleanup_expired`**: Cleans up expired permission overrides. Should be run as a scheduled job.
- **`permission_create`**: Creates a new permission. Returns ID. Code is normalized to lowercase.
- **`permission_delete`**: Soft deletes a permission and removes role associations. Returns affected role count.
- **`permission_exists`**: Checks if a permission code exists and is active
- **`permission_get`**: Get permission details by code, including role count.
- **`permission_list`**: Paginated permissions list. Returns items + totalCount.
- **`permission_update`**: Updates permission details. Code is immutable.
- **`role_create`**: Creates a new role. Protects system roles.
- **`role_delete`**: Soft deletes a role. System roles cannot be deleted. Returns affected user count.
- **`role_get`**: Get role details by code, including permissions.
- **`role_list`**: Paginated role list with user/permission counts. Returns items + totalCount.
- **`role_permission_assign`**: Assigns a permission to a role. Idempotent. Returns already_assigned status.
- **`role_permission_bulk_assign`**: Bulk assigns permissions to a role. Returns assigned count and invalid codes.
- **`role_permission_list`**: Lists permissions for a role.
- **`role_permission_remove`**: Removes a permission from a role. Returns removal status.
- **`role_update`**: Updates role details. System roles cannot be updated.
- **`session_cleanup_expired`**: Cleans up expired and old revoked sessions securely using batches to avoid table locks.
- **`session_list`**: Lists active sessions for a user
- **`session_revoke`**: Revokes a specific session
- **`session_revoke_all`**: Revokes all sessions for a user (optionally keeping current one)
- **`session_save`**: Saves a new session or updates existing one
- **`user_authenticate`**: Authenticates user via email. Returns structured user data, roles, and permissions based on role type (Platform vs Company/Tenant).
- **`user_check_email_exists`**: Checks if email exists. Use excludeUserId for update scenarios.
- **`user_check_username_exists`**: Checks if username exists in company. Use excludeUserId for update scenarios.
- **`user_create`**: Creates a new user with email/username uniqueness validation
- **`user_delete`**: Soft deletes a user by setting status to -1
- **`user_get`**: Returns user details including company info, global roles, tenant roles, and allowed tenants
- **`user_list`**: Returns paginated user list with filters (search, status, company) and sorting
- **`user_login_failed_increment`**: Increments failed login count, locks account if threshold exceeded
- **`user_login_failed_reset`**: Resets failed login count after successful login
- **`user_permission_list`**: Hybrid Permission: Returns user roles and user-level override permissions. Formula: (Role + Granted) - Denied
- **`user_permission_override_list`**: Lists active permission overrides for a user
- **`user_permission_remove`**: Removes a permission override rule from a user. Does not affect role-based permissions.
- **`user_permission_set`**: Grants or Denies a specific permission to a user. Creates or updates an override.
- **`user_reset_password`**: Resets user password (admin action). Password should be hashed before calling.
- **`user_role_assign`**: Assigns a global role to a user. Idempotent.
- **`user_role_list`**: Lists usage roles (global and tenant-specific).
- **`user_role_remove`**: Removes a global role from a user.
- **`user_tenant_role_assign`**: Assigns a tenant-specific role to a user. Idempotent.
- **`user_tenant_role_list`**: Lists tenant-specific roles for a user. Returns direct JSON array.
- **`user_tenant_role_remove`**: Removes a tenant-specific role from a user.
- **`user_unlock`**: Unlocks a locked user account (Admin action)
- **`user_update`**: Updates user with partial update support. NULL values keep existing data. Validates email/username uniqueness.

## Core Audit Veritabanı

### Backoffice Şeması

- **`auth_audit_create`**: Adds an auth audit log entry. Returns BIGINT.
- **`auth_audit_failed_logins`**: Gets failed login attempts for brute-force detection
- **`auth_audit_list_by_type`**: Retrieves auth audit logs by event type as JSONB array
- **`auth_audit_list_by_user`**: Retrieves auth audit logs for a user as JSONB array

## Core Log Veritabanı

### Backoffice Şeması

- **`audit_create`**: Adds an entity audit log entry. Returns UUID.
- **`audit_get`**: Gets an entity audit log entry by ID as JSONB
- **`audit_list`**: Retrieves paginated entity audit logs as JSONB

### Logs Şeması

- **`core_audit_create`**: Adds a core audit log entry. Returns UUID.
- **`core_audit_list`**: Retrieves filtered core audit logs as JSONB array
- **`dead_letter_create`**: Adds a dead letter message. Returns UUID.
- **`dead_letter_get`**: Gets dead letter details by ID
- **`dead_letter_list_pending`**: Retrieves pending dead letters for processing
- **`dead_letter_retry`**: Increments retry count and sets status to RETRYING for a message
- **`dead_letter_stats`**: Calculates dead letter message statistics (counts by status, etc.)
- **`dead_letter_update_status`**: Updates status and resolution details of a dead letter message
- **`error_get`**: Gets error detail by ID as JSONB
- **`error_list`**: Retrieves filtered application errors as JSONB array
- **`error_log`**: Adds an application error log entry. Returns ID.
- **`error_stats`**: Calculates error statistics (counts, top errors, etc.)

## Tenant Veritabanı

Henüz özel fonksiyon tanımlanmamıştır.

## Tenant Affiliate Veritabanı

Henüz özel fonksiyon tanımlanmamıştır.

## Tenant Audit Veritabanı

Henüz özel fonksiyon tanımlanmamıştır.

## Tenant Log Veritabanı

Henüz özel fonksiyon tanımlanmamıştır.

## Tenant Report Veritabanı

Henüz özel fonksiyon tanımlanmamıştır.

## Finance Veritabanı

Henüz özel fonksiyon tanımlanmamıştır.

## Finance Log Veritabanı

Henüz özel fonksiyon tanımlanmamıştır.

## Game Veritabanı

Henüz özel fonksiyon tanımlanmamıştır.

## Game Log Veritabanı

Henüz özel fonksiyon tanımlanmamıştır.

