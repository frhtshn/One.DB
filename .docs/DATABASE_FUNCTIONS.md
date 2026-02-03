# Database Functions & Triggers

This document lists all stored procedures, functions, and triggers defined in the project, categorized by database and schema.

## Core Database

### Catalog Schema

- **`country_list()`**: Returns list of countries for comboboxes (Value: country_code, Label: country_name).
- **`transaction_type_list()`**: Returns transaction type list for dropdowns. No auth required - public catalog data.
- **`operation_type_list()`**: Returns operation type list for dropdowns. No auth required - public catalog data.
- **`currency_create(p_code, p_name, p_symbol, p_numeric_code)`**: Creates a new currency.
- **`currency_delete(p_code)`**: Soft deletes a currency by setting is_active to false (checks for usage first).
- **`currency_get(p_code)`**: Gets details of a specific currency by code.
- **`currency_list()`**: Lists all currencies including inactive ones (for admin usage).
- **`currency_update(p_code, p_name, p_symbol, p_numeric_code, p_is_active)`**: Updates currency details (name, symbol, numeric code, active status).
- **`language_create(p_code, p_name)`**: Creates a new language.
- **`language_delete(p_code)`**: Soft deletes a language by setting is_active to false (checks for translations first).
- **`language_get(p_code)`**: Gets details of a specific language by code.
- **`language_list()`**: Lists all languages including inactive ones (for admin usage).
- **`language_update(p_code, p_name, p_is_active)`**: Updates language details (name, active status).
- **`localization_category_list(p_domain)`**: Lists distinct localization categories.
- **`localization_domain_list()`**: Lists distinct localization domains.
- **`localization_export(p_lang)`**: Exports translations for a specific language as JSON.
- **`localization_import(p_lang, p_translations)`**: Imports translations from JSON for a specific language.
- **`localization_key_create(p_key, p_domain, p_category, p_description)`**: Creates a new localization key.
- **`localization_key_delete(p_id)`**: Deletes a localization key and its values.
- **`localization_key_get(p_key)`**: Gets a localization key details and all its translations.
- **`localization_key_list(p_page, p_page_size, p_domain, p_category, p_search)`**: Lists localization keys with pagination and filtering.
- **`localization_key_update(p_id, p_domain, p_category, p_description)`**: Updates a localization key.
- **`localization_messages_get(p_lang)`**: Retrieves all localization messages for a specific language (for bulk loading).
- **`localization_value_delete(p_key_id, p_lang)`**: Deletes a localization value (reset to default).
- **`localization_value_upsert(p_key_id, p_lang, p_text)`**: Upserts a localization value.
- **`timezone_list()`**: Returns list of timezones.

#### Provider Functions (SuperAdmin Only)

- **`provider_type_lookup(p_caller_id)`**: Returns provider type list for dropdowns. SuperAdmin only.
- **`provider_lookup(p_caller_id, p_type_id)`**: Returns provider list for dropdowns. Optional type_id filter. SuperAdmin only.
- **`provider_type_list(p_caller_id)`**: Lists all provider types.
- **`provider_type_get(p_caller_id, p_id)`**: Gets provider type details by ID.
- **`provider_type_create(p_caller_id, p_code, p_name, p_description)`**: Creates a new provider type.
- **`provider_type_update(p_caller_id, p_id, p_code, p_name, p_description, p_status)`**: Updates a provider type.
- **`provider_type_delete(p_caller_id, p_id)`**: Soft deletes a provider type (checks for usage first).
- **`provider_list(p_caller_id, p_type_id)`**: Lists providers, optionally filtered by type.
- **`provider_get(p_caller_id, p_id)`**: Gets provider details by ID.
- **`provider_create(p_caller_id, p_type_id, p_code, p_name, p_logo_url, p_description)`**: Creates a new provider.
- **`provider_update(p_caller_id, p_id, p_type_id, p_code, p_name, p_logo_url, p_description, p_status)`**: Updates a provider.
- **`provider_delete(p_caller_id, p_id)`**: Soft deletes a provider (checks for usage first).
- **`provider_setting_list(p_caller_id, p_provider_id)`**: Lists settings for a provider.
- **`provider_setting_get(p_caller_id, p_provider_id, p_key)`**: Gets a specific provider setting.
- **`provider_setting_upsert(p_caller_id, p_provider_id, p_key, p_value, p_is_encrypted)`**: Upserts a provider setting.
- **`provider_setting_delete(p_caller_id, p_provider_id, p_key)`**: Deletes a provider setting.

#### Payment Method Functions (SuperAdmin Only)

- **`payment_method_lookup(p_caller_id, p_provider_id)`**: Returns payment method list for dropdowns. Optional provider_id filter. SuperAdmin only.
- **`payment_method_list(p_caller_id)`**: Lists all payment methods.
- **`payment_method_get(p_caller_id, p_id)`**: Gets payment method details by ID.
- **`payment_method_create(p_caller_id, p_code, p_name, p_type, p_icon, p_description)`**: Creates a new payment method.
- **`payment_method_update(p_caller_id, p_id, p_code, p_name, p_type, p_icon, p_description, p_status)`**: Updates a payment method.
- **`payment_method_delete(p_caller_id, p_id)`**: Soft deletes a payment method (checks for usage first).

#### Compliance Functions (Platform Admin: SuperAdmin + Admin)

- **`jurisdiction_lookup(p_caller_id)`**: Returns jurisdiction list for dropdowns. Platform Admin (SuperAdmin + Admin) only.
- **`jurisdiction_list(p_caller_id)`**: Lists all jurisdictions (regulatory authorities).
- **`jurisdiction_get(p_caller_id, p_id)`**: Gets jurisdiction details by ID.
- **`jurisdiction_create(p_caller_id, p_code, p_name, p_country_code, p_regulatory_body, p_license_url, p_description)`**: Creates a new jurisdiction.
- **`jurisdiction_update(p_caller_id, p_id, p_code, p_name, p_country_code, p_regulatory_body, p_license_url, p_description, p_status)`**: Updates a jurisdiction.
- **`jurisdiction_delete(p_caller_id, p_id)`**: Soft deletes a jurisdiction (checks for usage first).
- **`kyc_policy_list(p_caller_id, p_jurisdiction_id)`**: Lists KYC policies, optionally filtered by jurisdiction.
- **`kyc_policy_get(p_caller_id, p_id)`**: Gets KYC policy details by ID.
- **`kyc_policy_create(p_caller_id, p_jurisdiction_id, p_verification_timeout_days, p_document_retention_days, p_re_verification_interval_days, p_max_verification_attempts, p_allow_manual_override, p_require_liveness_check, p_require_address_proof, p_min_age)`**: Creates a new KYC policy.
- **`kyc_policy_update(p_caller_id, p_id, ...)`**: Updates a KYC policy.
- **`kyc_policy_delete(p_caller_id, p_id)`**: Deletes a KYC policy.
- **`kyc_document_requirement_list(p_caller_id, p_jurisdiction_id)`**: Lists KYC document requirements.
- **`kyc_document_requirement_get(p_caller_id, p_id)`**: Gets KYC document requirement details.
- **`kyc_document_requirement_create(p_caller_id, p_jurisdiction_id, p_document_type, p_is_mandatory, p_verification_method, p_max_age_days, p_notes)`**: Creates a KYC document requirement.
- **`kyc_document_requirement_update(p_caller_id, p_id, ...)`**: Updates a KYC document requirement.
- **`kyc_document_requirement_delete(p_caller_id, p_id)`**: Deletes a KYC document requirement.
- **`kyc_level_requirement_list(p_caller_id, p_jurisdiction_id)`**: Lists KYC level requirements.
- **`kyc_level_requirement_get(p_caller_id, p_id)`**: Gets KYC level requirement details.
- **`kyc_level_requirement_create(p_caller_id, p_jurisdiction_id, p_kyc_level, p_required_documents, p_max_deposit_daily, p_max_deposit_monthly, p_max_withdrawal_daily, p_notes)`**: Creates a KYC level requirement.
- **`kyc_level_requirement_update(p_caller_id, p_id, ...)`**: Updates a KYC level requirement.
- **`kyc_level_requirement_delete(p_caller_id, p_id)`**: Deletes a KYC level requirement.
- **`responsible_gaming_policy_list(p_caller_id, p_jurisdiction_id)`**: Lists responsible gaming policies.
- **`responsible_gaming_policy_get(p_caller_id, p_id)`**: Gets responsible gaming policy details.
- **`responsible_gaming_policy_create(p_caller_id, p_jurisdiction_id, p_min_cooling_off_hours, p_max_cooling_off_days, p_min_self_exclusion_months, p_max_self_exclusion_months, p_allow_permanent_exclusion, p_require_deposit_limits, p_require_loss_limits, p_require_session_limits, p_reality_check_interval_minutes, p_notes)`**: Creates a responsible gaming policy.
- **`responsible_gaming_policy_update(p_caller_id, p_id, ...)`**: Updates a responsible gaming policy.
- **`responsible_gaming_policy_delete(p_caller_id, p_id)`**: Deletes a responsible gaming policy.

#### UIKit Functions (SuperAdmin Only)

- **`theme_lookup(p_caller_id)`**: Returns theme list for dropdowns. SuperAdmin only.
- **`theme_list(p_caller_id)`**: Lists all themes.
- **`theme_get(p_caller_id, p_id)`**: Gets theme details by ID including variables.
- **`theme_create(p_caller_id, p_code, p_name, p_description, p_base_theme, p_variables, p_is_default)`**: Creates a new theme.
- **`theme_update(p_caller_id, p_id, p_code, p_name, p_description, p_base_theme, p_variables, p_is_default, p_status)`**: Updates a theme.
- **`theme_delete(p_caller_id, p_id)`**: Soft deletes a theme (checks for usage first).
- **`widget_list(p_caller_id, p_category)`**: Lists widgets, optionally filtered by category.
- **`widget_get(p_caller_id, p_id)`**: Gets widget details by ID.
- **`widget_create(p_caller_id, p_code, p_name, p_category, p_description, p_default_config, p_schema)`**: Creates a new widget.
- **`widget_update(p_caller_id, p_id, p_code, p_name, p_category, p_description, p_default_config, p_schema, p_status)`**: Updates a widget.
- **`widget_delete(p_caller_id, p_id)`**: Soft deletes a widget (checks for usage first).
- **`ui_position_list(p_caller_id)`**: Lists all UI positions.
- **`ui_position_get(p_caller_id, p_id)`**: Gets UI position details by ID.
- **`ui_position_create(p_caller_id, p_code, p_name, p_page_type, p_description, p_max_widgets)`**: Creates a new UI position.
- **`ui_position_update(p_caller_id, p_id, p_code, p_name, p_page_type, p_description, p_max_widgets, p_status)`**: Updates a UI position.
- **`ui_position_delete(p_caller_id, p_id)`**: Soft deletes a UI position (checks for usage first).
- **`navigation_template_list(p_caller_id)`**: Lists all navigation templates.
- **`navigation_template_get(p_caller_id, p_id)`**: Gets navigation template details by ID.
- **`navigation_template_create(p_caller_id, p_code, p_name, p_description, p_platform, p_is_default)`**: Creates a new navigation template.
- **`navigation_template_update(p_caller_id, p_id, p_code, p_name, p_description, p_platform, p_is_default, p_status)`**: Updates a navigation template.
- **`navigation_template_delete(p_caller_id, p_id)`**: Soft deletes a navigation template (checks for items first).
- **`navigation_template_item_list(p_caller_id, p_template_id)`**: Lists items for a navigation template.
- **`navigation_template_item_get(p_caller_id, p_id)`**: Gets navigation template item details.
- **`navigation_template_item_create(p_caller_id, p_template_id, p_menu_location, p_translation_key, p_default_label, p_icon, p_target_type, p_target_url, p_target_action, p_parent_id, p_display_order, p_is_locked, p_is_mandatory)`**: Creates a navigation template item.
- **`navigation_template_item_update(p_caller_id, p_id, ...)`**: Updates a navigation template item.
- **`navigation_template_item_delete(p_caller_id, p_id)`**: Deletes a navigation template item (checks for children first).

### Core Schema

- **`company_lookup(p_caller_id)`**: Returns company list for dropdowns with IDOR protection. Platform Admin sees all, others see only their own company.
- **`company_create(p_company_code, p_company_name, p_country_code, p_timezone)`**: Creates a new company record for management UI.
- **`company_delete(p_id)`**: Soft deletes a company record for management UI.
- **`company_get(p_id)`**: Returns details of a company by id for management UI.
- **`company_list(p_page, p_page_size, p_search)`**: Returns a paginated list of companies for management UI. Searchable by name or code.
- **`company_update(p_id, p_company_code, p_company_name, p_status, p_country_code, p_timezone)`**: Updates company information for management UI.
- **`tenant_lookup(p_caller_id, p_company_id)`**: Returns tenant list for dropdowns with IDOR protection. Platform Admin sees all, CompanyAdmin sees own company tenants, others see only allowed tenants.
- **`tenant_create(p_caller_id, p_company_id, p_tenant_code, p_tenant_name, ...)`**: Creates a new tenant. Checks caller permissions.
- **`tenant_delete(p_caller_id, p_id)`**: Soft deletes a tenant. Checks caller permissions.
- **`tenant_get(p_caller_id, p_id)`**: Returns detailed tenant information. Checks caller permissions.
- **`tenant_list(p_caller_id, p_page, p_page_size, p_company_id, p_search, p_status)`**: Lists tenants with permission check (Caller ID). Non-platform users are restricted to their company.
- **`tenant_update(p_caller_id, p_id, ...)`**: Updates tenant information with partial update support. Checks caller permissions.
- **`tenant_currency_list(p_tenant_id)`**: Lists enabled currencies for a tenant.
- **`tenant_currency_upsert(p_tenant_id, p_currencies)`**: Upserts tenant currencies (enable/disable).
- **`tenant_language_list(p_tenant_id)`**: Lists enabled languages for a tenant.
- **`tenant_language_upsert(p_tenant_id, p_languages)`**: Upserts tenant languages (enable/disable).
- **`tenant_setting_delete(p_tenant_id, p_key)`**: Deletes a tenant setting.
- **`tenant_setting_get(p_tenant_id, p_key)`**: Gets a tenant setting value.
- **`tenant_setting_list(p_tenant_id)`**: Lists all settings for a tenant.
- **`tenant_setting_upsert(p_tenant_id, p_category, p_key, p_value, p_type, p_description)`**: Upserts a tenant setting.
- **`update_updated_at_column()`**: Generic trigger function to auto-update updated_at timestamp.

### Presentation Schema

- **`context_create(...)`**: Creates a new context.
- **`context_delete(p_id)`**: Deletes a context (hard delete).
- **`context_list(p_page_id)`**: Lists contexts for a given page.
- **`context_update(...)`**: Updates a context. Partial update supported.
- **`menu_create(...)`**: Creates a new menu with unique code validation.
- **`menu_delete(p_menu_id)`**: Soft deletes a menu.
- **`menu_get(p_menu_id)`**: Returns details of a menu including group, submenus, pages, and audit info.
- **`menu_list(p_menu_group_id)`**: Lists menus for a given group.
- **`menu_update(...)`**: Updates menu with partial update support.
- **`menu_group_create(...)`**: Creates a new menu group with unique code validation.
- **`menu_group_delete(p_menu_group_id)`**: Soft deletes a menu group.
- **`menu_group_get(p_menu_group_id)`**: Returns single menu group details by ID.
- **`menu_group_list()`**: Returns all menu groups ordered by order_index.
- **`menu_group_update(...)`**: Updates menu group with partial update support.
- **`page_create(...)`**: Creates a new page.
- **`build_page_json(p_page_id)`**: Builds JSON object for a page (including tabs and contexts). Helper function for get_structure.

### Security Schema

- **`user_authenticate(p_email)`**: Authenticates user and returns details, global/tenant roles, and permissions (merged scope).
- **`permission_category_list()`**: Lists active permission categories and count.
- **`permission_check(p_user_id, p_permission_code, p_tenant_id)`**: Checks if a user has a specific permission (supports overrides and scope).
- **`permission_cleanup_expired()`**: Cleans up expired permission overrides.
- **`permission_create(...)`**: Creates a new permission. Code is normalized to lowercase.
- **`permission_delete(p_id)`**: Soft deletes a permission and removes role associations.
- **`permission_exists(p_permission_code)`**: Checks if a permission code exists and is active.
- **`permission_get(p_code)`**: Get permission details by code, including role count.
- **`permission_list(...)`**: Paginated permissions list.
- **`permission_update(...)`**: Updates permission details. Code is immutable.
- **`user_permission_list(p_user_id, p_tenant_id)`**: Lists user's effective permissions based on roles and overrides.
- **`user_permission_override_list(p_caller_id, p_user_id, p_tenant_id)`**: Lists active permission overrides for a user.
- **`user_permission_remove(...)`**: Removes a permission override from a user.
- **`user_permission_set(...)`**: Grants or Denies a specific permission to a user (override).
- **`is_system_role(p_role_code)`**: Checks if a role code is a protected system role (e.g. superadmin).
- **`role_create(...)`**: Creates a new role. Protects system roles.
- **`role_delete(p_id, p_deleted_by)`**: Soft deletes a role. System roles cannot be deleted.
- **`role_get(p_code)`**: Get role details by code, including permissions.
- **`role_list(...)`**: Paginated role list.
- **`role_permission_list(p_role_id)`**: Lists permissions for a role.
- **`role_permission_remove(p_role_id, p_permission_code)`**: Removes a permission from a role.
- **`role_update(...)`**: Updates role details. System roles cannot be updated.
- **`user_role_assign(...)`**: Assigns a role to a user. Supports global and tenant scopes. Enforces hierarchy.
- **`user_role_list(p_caller_id, p_user_id, p_tenant_id)`**: Lists user roles. Supports filtering by tenant.
- **`user_role_remove(...)`**: Removes a role from a user.
- **`session_belongs_to_user(p_session_id, p_user_id)`**: Checks if session belongs to user.
- **`session_cleanup_expired(...)`**: Cleans up expired, old revoked, and inactive session records in batches.
- **`session_list(p_user_id)`**: Lists active sessions for a user.
- **`session_revoke(p_session_id, p_reason)`**: Revokes a specific session.
- **`session_revoke_all(p_user_id, p_reason)`**: Revokes all sessions for a user.

### Backoffice Schema (Audit)

- **`audit_create(...)`**: Adds an entity audit log entry. Returns UUID.
- **`audit_get(p_id)`**: Gets an entity audit log entry by ID as JSONB.
- **`audit_list(...)`**: Retrieves paginated entity audit logs as JSONB.
- **`auth_audit_create(...)`**: Adds an auth audit log entry. Returns BIGINT.
- **`auth_audit_failed_logins(p_user_id, p_hours)`**: Gets failed login attempts for brute-force detection.
- **`auth_audit_list_by_type(p_event_type, ...)`**: Retrieves auth audit logs by event type as JSONB array.
- **`auth_audit_list_by_user(p_user_id, p_limit)`**: Retrieves auth audit logs for a user as JSONB array.

### Logs Schema (Core Log)

- **`core_audit_create(...)`**: Adds a core audit log entry. Returns UUID.
- **`core_audit_list(...)`**: Retrieves filtered core audit logs as JSONB array.
- **`dead_letter_create(...)`**: Adds a dead letter message. Returns UUID.
- **`dead_letter_get(p_id)`**: Gets dead letter details by ID.
- **`dead_letter_list_pending(p_limit)`**: Retrieves pending dead letters for processing.
- **`dead_letter_retry(p_id)`**: Increments retry count and sets status to RETRYING for a message.
- **`dead_letter_stats()`**: Calculates dead letter message statistics (counts by status, etc.).
- **`dead_letter_update_status(p_id, p_status, ...)`**: Updates status and resolution details of a dead letter message.
- **`error_get(p_id)`**: Gets error detail by ID as JSONB.
- **`error_list(...)`**: Retrieves filtered application errors as JSONB array.
- **`error_log(...)`**: Adds an application error log entry. Returns ID.
- **`error_stats(...)`**: Calculates error statistics (counts, top errors, etc.).

## Triggers

### Core Database

All these triggers use `core.update_updated_at_column()` to automatically update the `updated_at` timestamp.

- **`presentation.trigger_menu_groups_updated_at`**
- **`presentation.trigger_menus_updated_at`**
- **`presentation.trigger_submenus_updated_at`**
- **`presentation.trigger_pages_updated_at`**
- **`presentation.trigger_tabs_updated_at`**
- **`presentation.trigger_contexts_updated_at`**
- **`security.trigger_users_updated_at`**
- **`security.trigger_roles_updated_at`**
- **`security.trigger_permissions_updated_at`**
