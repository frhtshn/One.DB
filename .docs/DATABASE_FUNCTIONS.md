# NUCLEO – VERİTABANI FONKSİYON REFERANSI

Bu doküman, projede yer alan tüm veritabanlarındaki (`core`, `tenant`, vb.) saklı yordamların (Stored Procedures) ve trigger'ların **tam listesidir**.

---

## 1. Core Veritabanı

Merkezi yönetim, güvenlik ve backoffice UI fonksiyonları.

### 1.1 Presentation Şeması (`core/functions/presentation/`)

Backoffice UI yapısını yöneten fonksiyonlar.

#### Genel Yapı (`.../structure/`, `.../pages/`)

- **`presentation.get_structure()`**:
    - Tüm menü, sayfa ve yetki ağacını JSON olarak döner (Cache: MD5 hash).
- **`presentation.build_page_json(p_page_id BIGINT)`**:
    - Tek bir sayfanın (tablar ve contextler dahil) JSON yapısını oluşturur.

#### Menu Group Yönetimi (`.../menu_groups/`)

- **`presentation.menu_group_create(p_code TEXT, p_title TEXT, p_order INT, p_permission TEXT, p_is_active BOOLEAN)`**:
    - Creates a new menu group with unique code validation
- **`presentation.menu_group_update(p_menu_group_id BIGINT, p_title TEXT, p_order INT, p_permission TEXT, p_is_active BOOLEAN)`**:
    - Updates menu group with partial update support. NULL values keep existing data.
- **`presentation.menu_group_delete(p_menu_group_id BIGINT)`**:
    - Soft deletes a menu group by setting is_active to FALSE
- **`presentation.menu_group_get(p_menu_group_id BIGINT)`**:
    - Returns single menu group details by ID
- **`presentation.menu_group_list()`**:
    - Returns all menu groups ordered by order_index. Includes menu count per group.

#### Menu Yönetimi (`.../menus/`)

- **`presentation.menu_create(p_menu_group_id BIGINT, p_code TEXT, p_title_localization_key TEXT, p_order_index INT, p_required_permission TEXT, p_created_by BIGINT, p_description TEXT, p_icon TEXT, p_is_system BOOLEAN, p_is_active BOOLEAN)`**:
    - Creates a new menu with unique code validation
- **`presentation.menu_update(p_menu_id BIGINT, p_menu_group_id BIGINT, p_title_localization_key TEXT, p_icon TEXT, p_order_index INT, p_required_permission TEXT, p_is_active BOOLEAN)`**:
    - Updates menu with partial update support. NULL values keep existing data.
- **`presentation.menu_delete(p_menu_id BIGINT)`**:
    - Soft deletes a menu by setting is_active to FALSE and updating deleted_at.
- **`presentation.menu_get(p_menu_id BIGINT)`**:
    - Returns details of a menu including group, submenus, pages, and audit info
- **`presentation.menu_list(p_menu_group_id BIGINT)`**:
    - Lists menus for a given group, returns items and totalCount

#### Submenu Yönetimi (`.../submenus/`)

- **`presentation.submenu_create(p_menu_id BIGINT, p_code TEXT, p_title_localization_key TEXT, p_route TEXT, p_order_index INT, p_required_permission TEXT)`**:
    - Creates a new submenu with unique code validation for the given menu.
- **`presentation.submenu_update(p_submenu_id BIGINT, p_menu_id BIGINT, p_title_localization_key TEXT, p_route TEXT, p_order_index INT, p_required_permission TEXT, p_is_active BOOLEAN)`**:
    - Updates submenu with partial update support. NULL values keep existing data.
- **`presentation.submenu_delete(p_submenu_id BIGINT)`**:
    - Soft deletes a submenu by setting is_active to FALSE and updating updated_at.
- **`presentation.submenu_list(p_menu_id BIGINT)`**:
    - Lists submenus for a given menu, returns items and totalCount.

#### Page Yönetimi (`.../pages/`)

- **`presentation.page_create(p_menu_id BIGINT, p_submenu_id BIGINT, p_code TEXT, p_route TEXT, p_title_localization_key TEXT, p_required_permission TEXT, p_is_active BOOLEAN)`**:
    - Creates a new page with unique code validation and parent menu/submenu check.
- **`presentation.page_update(p_page_id BIGINT, p_menu_id BIGINT, p_submenu_id BIGINT, p_route TEXT, p_title_localization_key TEXT, p_required_permission TEXT, p_is_active BOOLEAN)`**:
    - Updates page with partial update support. NULL values keep existing data.
- **`presentation.page_delete(p_page_id BIGINT)`**:
    - Soft deletes a page by setting is_active to FALSE and updating updated_at.
- **`presentation.page_get(p_page_id BIGINT)`**:
    - Returns details of a page including tabs and contexts.
- **`presentation.page_list(p_menu_id BIGINT, p_submenu_id BIGINT)`**:
    - Lists pages for a given menu or submenu, returns items and totalCount.

#### Tab Yönetimi (`.../tabs/`)

- **`presentation.tab_create(p_page_id BIGINT, p_code TEXT, p_title_localization_key TEXT, p_order_index INT, p_required_permission TEXT, p_is_active BOOLEAN)`**:
    - Creates a new tab with unique code validation for the given page.
- **`presentation.tab_update(p_tab_id BIGINT, p_title_localization_key TEXT, p_order_index INT, p_required_permission TEXT, p_is_active BOOLEAN)`**:
    - Updates tab with partial update support. NULL values keep existing data.
- **`presentation.tab_delete(p_tab_id BIGINT)`**:
    - Soft deletes a tab by setting is_active to FALSE and updating updated_at.
- **`presentation.tab_list(p_page_id BIGINT)`**:
    - Lists tabs for a given page, returns items and totalCount.

#### Context Yönetimi (`.../contexts/`)

- **`presentation.context_create(p_page_id BIGINT, p_code VARCHAR, p_type VARCHAR, p_label VARCHAR, p_permission_edit VARCHAR, p_permission_readonly VARCHAR, p_permission_mask VARCHAR)`**:
    - Creates a new context. Returns TABLE(id BIGINT).
- **`presentation.context_update(p_id BIGINT, p_page_id BIGINT, p_code VARCHAR, p_type VARCHAR, p_label VARCHAR, p_permission_edit VARCHAR, p_permission_readonly VARCHAR, p_permission_mask VARCHAR, p_is_active BOOLEAN)`**:
    - Updates a context. Partial update supported. Returns VOID.
- **`presentation.context_delete(p_id BIGINT)`**:
    - Deletes a context (hard delete). Returns VOID.
- **`presentation.context_list(p_page_id BIGINT)`**:
    - Lists contexts for a given page, returns items and totalCount.

### 1.2 Security Şeması (`core/functions/security/`)

#### Auth & Oturum (`.../auth/`, `.../session/`)

- **`security.user_authenticate(p_email VARCHAR(255))`**:
    - Authenticates user via email. Returns structured user data, roles, and permissions.
- **`security.session_save(p_session_id VARCHAR(50), p_user_id BIGINT, p_refresh_token_id VARCHAR(100), p_ip_address VARCHAR(50), p_user_agent VARCHAR(500), p_device_name VARCHAR(100), p_expires_at TIMESTAMPTZ)`**:
    - Saves a new session or updates existing one
- **`security.session_revoke(p_session_id VARCHAR(50), p_reason VARCHAR(200))`**:
    - Revokes a specific session
- **`security.session_revoke_all(p_user_id BIGINT, p_reason VARCHAR(200), p_except_session_id VARCHAR(50))`**:
    - Revokes all sessions for a user (optionally keeping current one)
- **`security.session_list(p_user_id BIGINT)`**:
    - Lists active sessions for a user
- **`security.session_cleanup_expired(p_batch_size INT, p_revoked_retention_days INT)`**:
    - Cleans up expired and old revoked sessions securely using batches.

#### Kullanıcı Yönetimi (`.../users/`)

- **`security.user_create(p_email TEXT, p_username TEXT, p_password TEXT, p_first_name TEXT, p_last_name TEXT, p_company_id BIGINT, p_language CHAR(2), p_created_by BIGINT)`**:
    - Creates a new user with email/username uniqueness validation
- **`security.user_update(p_user_id BIGINT, p_first_name TEXT, p_last_name TEXT, p_email TEXT, p_username TEXT, p_status SMALLINT, p_language CHAR(2), p_two_factor_enabled BOOLEAN, p_updated_by BIGINT)`**:
    - Updates user with partial update support. Validates email/username uniqueness.
- **`security.user_delete(p_user_id BIGINT, p_deleted_by BIGINT)`**:
    - Soft deletes a user by setting status to -1
- **`security.user_get(p_user_id BIGINT)`**:
    - Returns user details including company info, global roles, tenant roles, and allowed tenants
- **`security.user_list(p_page INT, p_page_size INT, p_search TEXT, p_status SMALLINT, p_company_id BIGINT, p_sort_by TEXT, p_sort_order TEXT)`**:
    - Returns paginated user list with filters (search, status, company) and sorting
- **`security.user_check_email_exists(p_email TEXT, p_exclude_user_id BIGINT)`**:
    - Checks if email exists. Use excludeUserId for update scenarios.
- **`security.user_check_username_exists(p_username TEXT, p_company_id BIGINT, p_exclude_user_id BIGINT)`**:
    - Checks if username exists in company. Use excludeUserId for update scenarios.
- **`security.user_reset_password(p_user_id BIGINT, p_new_password TEXT, p_reset_by BIGINT)`**:
    - Resets user password (admin action). Password should be hashed before calling.
- **`security.user_unlock(p_user_id BIGINT, p_unlocked_by BIGINT)`**:
    - Unlocks a locked user account (Admin action)
- **`security.user_login_failed_increment(p_user_id BIGINT, p_lock_threshold INT, p_lock_duration_minutes INT)`**:
    - Increments failed login count, locks account if threshold exceeded
- **`security.user_login_failed_reset(p_user_id BIGINT)`**:
    - Resets failed login count after successful login

#### Rol Yönetimi (`.../roles/`)

- **`security.role_create(p_code VARCHAR, p_name VARCHAR, p_description VARCHAR, p_created_by BIGINT)`**:
    - Creates a new role. Protects system roles.
- **`security.role_update(p_id BIGINT, p_name VARCHAR, p_description VARCHAR, p_updated_by BIGINT, p_status SMALLINT)`**:
    - Updates role details. System roles cannot be updated.
- **`security.role_delete(p_id BIGINT, p_deleted_by BIGINT)`**:
    - Soft deletes a role. System roles cannot be deleted. Returns affected user count.
- **`security.role_get(p_code VARCHAR)`**:
    - Get role details by code, including permissions.
- **`security.role_list(p_page INT, p_page_size INT, p_search VARCHAR, p_status SMALLINT)`**:
    - Paginated role list with user/permission counts. Returns items + totalCount.
- **`security.is_system_role(p_role_code VARCHAR)`**:
    - Checks if a role code is a protected system role.
- **`security.role_permission_assign(p_role_id BIGINT, p_permission_code VARCHAR)`**:
    - Assigns a permission to a role. Idempotent.
- **`security.role_permission_bulk_assign(p_role_id BIGINT, p_permission_codes VARCHAR[], p_replace_existing BOOLEAN)`**:
    - Bulk assigns permissions to a role.
- **`security.role_permission_remove(p_role_id BIGINT, p_permission_code VARCHAR)`**:
    - Removes a permission from a role.
- **`security.role_permission_list(p_role_id BIGINT)`**:
    - Lists permissions for a role.
- **`security.user_role_assign(p_user_id BIGINT, p_role_code VARCHAR, p_assigned_by BIGINT)`**:
    - Assigns a global role to a user. Idempotent.
- **`security.user_role_remove(p_user_id BIGINT, p_role_code VARCHAR)`**:
    - Removes a global role from a user.
- **`security.user_role_list(p_user_id BIGINT)`**:
    - Lists usage roles (global and tenant-specific).
- **`security.user_tenant_role_assign(p_user_id BIGINT, p_tenant_id BIGINT, p_role_code VARCHAR, p_assigned_by BIGINT)`**:
    - Assigns a tenant-specific role to a user.
- **`security.user_tenant_role_remove(p_user_id BIGINT, p_tenant_id BIGINT, p_role_code VARCHAR)`**:
    - Removes a tenant-specific role from a user.
- **`security.user_tenant_role_list(p_user_id BIGINT, p_tenant_id BIGINT)`**:
    - Lists tenant-specific roles for a user.

#### Yetki Yönetimi (`.../permissions/`)

- **`security.permission_create(p_code VARCHAR(100), p_name VARCHAR(150), p_description VARCHAR(500), p_category VARCHAR(50))`**:
    - Creates a new permission. Returns ID. Code is normalized to lowercase.
- **`security.permission_update(p_id BIGINT, p_name VARCHAR(150), p_description VARCHAR(500), p_category VARCHAR(50), p_status SMALLINT)`**:
    - Updates permission details. Code is immutable.
- **`security.permission_delete(p_id BIGINT)`**:
    - Soft deletes a permission and removes role associations. Returns affected role count.
- **`security.permission_get(p_code VARCHAR(100))`**:
    - Get permission details by code, including role count.
- **`security.permission_list(p_page INT, p_page_size INT, p_category VARCHAR(50), p_search VARCHAR(100), p_status SMALLINT)`**:
    - Paginated permissions list. Returns items + totalCount.
- **`security.permission_exists(p_permission_code VARCHAR(100))`**:
    - Checks if a permission code exists and is active
- **`security.permission_check(p_user_id BIGINT, p_permission_code VARCHAR(100), p_tenant_id BIGINT)`**:
    - Checks if a user has a specific permission (Global or Tenant-level)
- **`security.permission_category_list()`**:
    - Lists active permission categories and count.
- **`security.permission_cleanup_expired()`**:
    - Cleans up expired permission overrides. Should be run as a scheduled job.
- **`security.user_permission_list(p_user_id BIGINT, p_tenant_id BIGINT)`**:
    - Hybrid Permission: Returns user roles and user-level override permissions.
- **`security.user_permission_set(p_user_id BIGINT, p_permission_code VARCHAR(100), p_is_granted BOOLEAN, p_tenant_id BIGINT, p_reason VARCHAR(500), p_assigned_by BIGINT, p_expires_at TIMESTAMPTZ)`**:
    - Grants or Denies a specific permission to a user. Creates or updates an override.
- **`security.user_permission_remove(p_user_id BIGINT, p_permission_code VARCHAR(100), p_tenant_id BIGINT)`**:
    - Removes a permission override rule from a user.
- **`security.user_permission_override_list(p_user_id BIGINT, p_tenant_id BIGINT)`**:
    - Lists active permission overrides for a user.

### 1.3 Catalog Şeması (`core/functions/catalog/`)

#### Dil Yönetimi (`.../languages/`)

- **`catalog.language_create(p_code CHAR(2), p_name VARCHAR(50))`**:
    - Creates a new language
- **`catalog.language_update(p_code CHAR(2), p_name VARCHAR(50), p_is_active BOOLEAN)`**:
    - Updates language details (name, active status)
- **`catalog.language_delete(p_code CHAR(2))`**:
    - Soft deletes a language by setting is_active to false
- **`catalog.language_get(p_code CHAR(2))`**:
    - Gets details of a specific language by code
- **`catalog.language_list()`**:
    - Lists all languages including inactive ones
- **`catalog.language_list_active()`**:
    - Lists all active languages

#### Lokalizasyon (`.../localization/`)

- **`catalog.localization_key_create(p_key VARCHAR, p_domain VARCHAR, p_category VARCHAR, p_description VARCHAR)`**:
    - Creates a new localization key.
- **`catalog.localization_key_update(p_id BIGINT, p_domain VARCHAR, p_category VARCHAR, p_description VARCHAR)`**:
    - Updates a localization key.
- **`catalog.localization_key_delete(p_id BIGINT)`**:
    - Deletes a localization key and its values.
- **`catalog.localization_key_get(p_key VARCHAR)`**:
    - Gets a localization key details and all its translations.
- **`catalog.localization_key_list(p_page INT, p_page_size INT, p_domain VARCHAR, p_category VARCHAR, p_search VARCHAR)`**:
    - Lists localization keys with pagination and filtering.
- **`catalog.localization_value_upsert(p_key_id BIGINT, p_lang CHAR(2), p_text TEXT)`**:
    - Inserts or updates a localization value (translation).
- **`catalog.localization_value_delete(p_key_id BIGINT, p_lang CHAR(2))`**:
    - Deletes a specific localization value.
- **`catalog.localization_messages_get(p_lang CHAR(2))`**:
    - Retrieves all localization messages for a specific language
- **`catalog.localization_export(p_lang CHAR(2))`**:
    - Exports translations for a specific language as JSON.
- **`catalog.localization_import(p_lang CHAR(2), p_translations JSONB)`**:
    - Imports translations from JSON for a specific language.
- **`catalog.localization_category_list(p_domain VARCHAR)`**:
    - Lists distinct localization categories.
- **`catalog.localization_domain_list()`**:
    - Lists distinct localization domains.

---

## 2. Core Log Veritabanı

Sistem ve operasyonel logların yönetimi.

### 2.1 Backoffice Şeması (`core_log/functions/backoffice/`)

- **`backoffice.audit_create(p_event_id VARCHAR(255), p_original_event_id VARCHAR(255), p_tenant_id VARCHAR(100), p_user_id VARCHAR(255), p_action VARCHAR(100), p_entity_type VARCHAR(100), p_entity_id VARCHAR(255), p_old_value TEXT, p_new_value TEXT, p_ip_address VARCHAR(50), p_correlation_id VARCHAR(255), p_forwarded_at TIMESTAMPTZ)`**:
    - Adds an entity audit log entry.
- **`backoffice.audit_get(p_id UUID)`**:
    - Gets an entity audit log entry by ID as JSONB
- **`backoffice.audit_list(p_tenant_id VARCHAR(100), p_user_id VARCHAR(255), p_action VARCHAR(100), p_entity_type VARCHAR(100), p_entity_id VARCHAR(255), p_from_date TIMESTAMPTZ, p_to_date TIMESTAMPTZ, p_page INT, p_page_size INT)`**:
    - Retrieves paginated entity audit logs as JSONB

### 2.2 Log Şeması (`core_log/functions/logs/`)

- **`logs.core_audit_create(p_event_id VARCHAR(255), p_user_id VARCHAR(255), p_action VARCHAR(100), p_entity_type VARCHAR(100), p_entity_id VARCHAR(255), p_old_value TEXT, p_new_value TEXT, p_ip_address VARCHAR(50), p_correlation_id VARCHAR(255))`**:
    - Adds a core audit log entry. Returns UUID.
- **`logs.core_audit_list(p_user_id VARCHAR(255), p_action VARCHAR(100), p_entity_type VARCHAR(100), p_entity_id VARCHAR(255), p_from_date TIMESTAMPTZ, p_to_date TIMESTAMPTZ, p_page INT, p_page_size INT)`**:
    - Retrieves filtered core audit logs as JSONB array
- **`logs.dead_letter_create(p_event_id VARCHAR(255), p_event_type VARCHAR(255), p_tenant_id VARCHAR(100), p_payload JSONB, p_exception_message TEXT, p_exception_stack_trace TEXT, p_retry_count INT, p_status VARCHAR(50))`**:
    - Adds a dead letter message. Returns UUID.
- **`logs.dead_letter_get(p_id UUID)`**:
    - Gets dead letter details by ID
- **`logs.dead_letter_list_pending(p_limit INT)`**:
    - Retrieves pending dead letters for processing
- **`logs.dead_letter_retry(p_id UUID)`**:
    - Increments retry count and sets status to RETRYING for a message
- **`logs.dead_letter_stats()`**:
    - Calculates dead letter message statistics (counts by status, etc.)
- **`logs.dead_letter_update_status(p_id UUID, p_status VARCHAR(50), p_resolved_by VARCHAR(255), p_resolution_notes TEXT)`**:
    - Updates status and resolution details of a dead letter message
- **`logs.error_log(p_error_code TEXT, p_error_message TEXT, p_exception_type TEXT, p_http_status_code INT, p_is_retryable BOOLEAN, p_tenant_id BIGINT, p_user_id TEXT, p_correlation_id TEXT, p_request_path TEXT, p_request_method TEXT, p_resource_type TEXT, p_resource_key TEXT, p_error_metadata TEXT, p_stack_trace TEXT, p_cluster_name TEXT, p_occurred_at TIMESTAMPTZ)`**:
    - Adds an application error log entry. Returns ID.
- **`logs.error_get(p_id BIGINT)`**:
    - Gets error detail by ID as JSONB
- **`logs.error_list(p_tenant_id BIGINT, p_error_code TEXT, p_from_date TIMESTAMPTZ, p_to_date TIMESTAMPTZ, p_limit INT)`**:
    - Retrieves filtered application errors as JSONB array
- **`logs.error_stats(p_tenant_id BIGINT, p_hours INT)`**:
    - Calculates error statistics (counts, top errors, etc.)

---

## 3. Core Audit Veritabanı

Kalıcı ve yasal saklama gerektiren denetim izleri.

### 3.1 Backoffice Şeması (`core_audit/functions/backoffice/`)

- **`backoffice.auth_audit_create(p_user_id BIGINT, p_company_id BIGINT, p_tenant_id BIGINT, p_event_type VARCHAR(50), p_event_data TEXT, p_ip_address VARCHAR(50), p_user_agent VARCHAR(500), p_success BOOLEAN, p_error_message VARCHAR(500))`**:
    - Adds an auth audit log entry.
- **`backoffice.auth_audit_failed_logins(p_user_id BIGINT, p_hours INT)`**:
    - Gets failed login attempts for brute-force detection
- **`backoffice.auth_audit_list_by_type(p_event_type VARCHAR(50), p_from_date TIMESTAMPTZ, p_to_date TIMESTAMPTZ, p_limit INT)`**:
    - Retrieves auth audit logs by event type
- **`backoffice.auth_audit_list_by_user(p_user_id BIGINT, p_limit INT)`**:
    - Retrieves auth audit logs for a user

---

## 4. Diğer Veritabanları

### 4.1 Core Report Veritabanı

_(Henüz özel fonksiyon tanımlanmamıştır)_

### 4.2 Game & Game Log Veritabanları

_(Henüz özel fonksiyon tanımlanmamıştır)_

### 4.3 Finance & Finance Log Veritabanları

_(Henüz özel fonksiyon tanımlanmamıştır)_

### 4.4 Bonus Veritabanı

_(Henüz özel fonksiyon tanımlanmamıştır)_

### 4.5 Tenant Veritabanı

_(Henüz özel fonksiyon tanımlanmamıştır)_

### 4.6 Tenant Affiliate Veritabanı

_(Henüz özel fonksiyon tanımlanmamıştır)_

### 4.7 Tenant Log & Audit & Report Veritabanları

_(Sadece partitioning ve otomatik temizlik triggerları mevcuttur)_

---

## 5. Triggerlar (Tüm Veritabanları)

Veri bütünlüğünü sağlamak ve audit loglarını oluşturmak için kullanılan otomatik tetikleyiciler.

### 5.1 Genel Triggerlar (`core/triggers/`)

- **`update_updated_at_column`**:
    - `core.update_updated_at_column()` fonksiyonunu çağırır.
    - Kayıt güncellendiğinde `updated_at` kolonunu otomatik olarak `NOW()` yapar.

### 5.2 Security Triggerlar (`core/triggers/security_triggers.sql`)

Aşağıdaki tablolarda yapılan değişiklikleri `core_audit` veritabanına loglar:

- `security.users`
- `security.roles`
- `security.permissions`
- `security.user_roles`
- `security.role_permissions`

### 5.3 Presentation Triggerlar (`core/triggers/presentation_triggers.sql`)

Aşağıdaki tablolarda değişiklik olduğunda `updated_at` alanını güncelleyerek cache invalidation sağlar:

- `presentation.menus`
- `presentation.pages`
- `presentation.menu_groups`
- `presentation.submenus`
- `presentation.tabs`
