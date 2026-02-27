# Core Functions & Triggers

Core katmanındaki tüm stored procedure, function ve trigger'ları içerir.

**Veritabanları:** `core`, `core_audit`, `core_log`, `core_report`
**Toplam:** 369 fonksiyon, 3 trigger

---

## Core Database (326 fonksiyon, 3 trigger)

### Catalog Schema (115)

#### Reference (17)

| Fonksiyon | Açıklama |
|-----------|----------|
| `country_list` | Country list |
| `currency_create` | Currency create |
| `currency_delete` | Currency delete |
| `currency_get` | Currency get |
| `currency_list` | Currency list |
| `currency_update` | Currency update |
| `cryptocurrency_delete` | Soft delete. Checks tenant usage first |
| `cryptocurrency_get` | Get by symbol. P0404 if not found |
| `cryptocurrency_list` | List all including inactive (admin) |
| `cryptocurrency_update` | Update name, icon, active status, sort order |
| `cryptocurrency_upsert` | Coinlayer /list sync. Insert or update. Returns INT |
| `language_create` | Language create |
| `language_delete` | Language delete |
| `language_get` | Language get |
| `language_list` | Language list |
| `language_update` | Language update |
| `timezone_list` | Timezone list |

#### Compliance (32)

| Fonksiyon | Açıklama |
|-----------|----------|
| `data_retention_policy_create` | Create data retention policy. Returns new ID |
| `data_retention_policy_delete` | Soft delete (is_active = false) |
| `data_retention_policy_get` | Get with jurisdiction info |
| `data_retention_policy_list` | List with filters |
| `data_retention_policy_lookup` | Lightweight lookup for dropdowns |
| `data_retention_policy_update` | Update (COALESCE pattern) |
| `jurisdiction_create` | Jurisdiction create |
| `jurisdiction_delete` | Jurisdiction delete |
| `jurisdiction_get` | Jurisdiction get |
| `jurisdiction_list` | Jurisdiction list |
| `jurisdiction_lookup` | Jurisdiction lookup |
| `jurisdiction_update` | Jurisdiction update |
| `kyc_document_requirement_create` | KYC document requirement create |
| `kyc_document_requirement_delete` | KYC document requirement delete |
| `kyc_document_requirement_get` | KYC document requirement get |
| `kyc_document_requirement_list` | KYC document requirement list |
| `kyc_document_requirement_update` | KYC document requirement update |
| `kyc_level_requirement_create` | KYC level requirement create |
| `kyc_level_requirement_delete` | KYC level requirement delete |
| `kyc_level_requirement_get` | KYC level requirement get |
| `kyc_level_requirement_list` | KYC level requirement list |
| `kyc_level_requirement_update` | KYC level requirement update |
| `kyc_policy_create` | KYC policy create |
| `kyc_policy_delete` | KYC policy delete |
| `kyc_policy_get` | KYC policy get |
| `kyc_policy_list` | KYC policy list |
| `kyc_policy_update` | KYC policy update |
| `responsible_gaming_policy_create` | RG policy create |
| `responsible_gaming_policy_delete` | RG policy delete |
| `responsible_gaming_policy_get` | RG policy get |
| `responsible_gaming_policy_list` | RG policy list |
| `responsible_gaming_policy_update` | RG policy update |

#### Localization (12)

| Fonksiyon | Açıklama |
|-----------|----------|
| `localization_category_list` | Category list by domain |
| `localization_domain_list` | Domain list |
| `localization_export` | Export all translations for a language |
| `localization_import` | Import translations (JSONB) for a language |
| `localization_key_create` | Create localization key |
| `localization_key_delete` | Delete localization key |
| `localization_key_get` | Get localization key |
| `localization_key_list` | Paginated list with domain/category/search filters |
| `localization_key_update` | Update localization key |
| `localization_messages_get` | Get all messages for a language |
| `localization_value_delete` | Delete translation value |
| `localization_value_upsert` | Upsert translation value |

#### Provider & Payment (22)

| Fonksiyon | Açıklama |
|-----------|----------|
| `provider_type_create` | Provider type create |
| `provider_type_delete` | Provider type delete |
| `provider_type_get` | Provider type get |
| `provider_type_list` | Provider type list |
| `provider_type_lookup` | Provider type lookup |
| `provider_type_update` | Provider type update |
| `provider_create` | Provider create |
| `provider_delete` | Provider delete |
| `provider_get` | Provider get |
| `provider_list` | Provider list |
| `provider_lookup` | Provider lookup |
| `provider_update` | Provider update |
| `provider_setting_delete` | Provider setting delete |
| `provider_setting_get` | Provider setting get |
| `provider_setting_list` | Provider setting list |
| `provider_setting_upsert` | Provider setting upsert |
| `payment_method_create` | Payment method create |
| `payment_method_delete` | Payment method delete |
| `payment_method_get` | Payment method get |
| `payment_method_list` | Payment method list |
| `payment_method_lookup` | Payment method lookup |
| `payment_method_update` | Payment method update |

#### UIKit (27)

| Fonksiyon | Açıklama |
|-----------|----------|
| `theme_create` | Theme create |
| `theme_delete` | Theme delete |
| `theme_get` | Theme get |
| `theme_list` | Theme list |
| `theme_lookup` | Theme lookup |
| `theme_update` | Theme update |
| `widget_create` | Widget create |
| `widget_delete` | Widget delete |
| `widget_get` | Widget get |
| `widget_list` | Widget list |
| `widget_update` | Widget update |
| `navigation_template_create` | Navigation template create |
| `navigation_template_delete` | Navigation template delete |
| `navigation_template_get` | Navigation template get |
| `navigation_template_list` | Navigation template list |
| `navigation_template_lookup` | Navigation template lookup for dropdowns |
| `navigation_template_update` | Navigation template update |
| `navigation_template_item_create` | Navigation template item create |
| `navigation_template_item_delete` | Navigation template item delete |
| `navigation_template_item_get` | Navigation template item get |
| `navigation_template_item_list` | Navigation template item list |
| `navigation_template_item_update` | Navigation template item update |
| `ui_position_create` | UI position create |
| `ui_position_delete` | UI position delete |
| `ui_position_get` | UI position get |
| `ui_position_list` | UI position list |
| `ui_position_update` | UI position update |

#### GeoIP (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `ip_geo_cache_upsert` | Upsert IP geo cache with full ip-api.com fields. Configurable TTL |
| `ip_geo_cache_get` | Returns JSONB if cache hit and not expired, NULL otherwise |
| `ip_geo_cache_cleanup` | Deletes expired entries. Returns deleted count (INT) |

#### Types (2)

| Fonksiyon | Açıklama |
|-----------|----------|
| `operation_type_list` | Operation type list |
| `transaction_type_list` | Transaction type list |

---

### Core Schema (70)

#### Company (6)

| Fonksiyon | Açıklama |
|-----------|----------|
| `company_create` | Company create |
| `company_delete` | Company delete |
| `company_get` | Company get |
| `company_list` | Paginated list with search |
| `company_lookup` | Company lookup |
| `company_update` | Company update |

#### Department (6)

| Fonksiyon | Açıklama |
|-----------|----------|
| `department_create` | Create department. Code uppercase, unique per company. JSONB name. IDOR |
| `department_delete` | Soft delete. Fails if active children exist. IDOR |
| `department_get` | Get with parent name (multi-language JSONB). IDOR |
| `department_list` | List. Search across all JSONB language values. IDOR |
| `department_lookup` | Active departments for dropdowns. Optional lang resolve. IDOR |
| `department_update` | Update (COALESCE). JSONB name/description. IDOR |

#### Platform Settings (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `platform_setting_create` | Create platform service configuration |
| `platform_setting_delete` | Soft delete (is_active = false) |
| `platform_setting_get` | Get by ID |
| `platform_setting_list` | List with category/environment/active filters |
| `platform_setting_update` | Update configuration |

#### Tenant Management (19)

| Fonksiyon | Açıklama |
|-----------|----------|
| `tenant_create` | Tenant create with currency/language arrays |
| `tenant_delete` | Tenant delete |
| `tenant_get` | Tenant get |
| `tenant_list` | Paginated list with company/search/status filters |
| `tenant_lookup` | Tenant lookup |
| `tenant_update` | Tenant update with currency/language sync |
| `tenant_currency_list` | List tenant currencies. IDOR |
| `tenant_currency_mapping_list` | All active tenant-currency mappings (CurrencyRateSyncGrain, no auth) |
| `tenant_currency_upsert` | Assign/update tenant currency. IDOR |
| `tenant_cryptocurrency_list` | List tenant cryptocurrencies. Returns JSONB. IDOR |
| `tenant_cryptocurrency_mapping_list` | All active tenant-crypto mappings (CryptoRateSyncGrain, no auth) |
| `tenant_cryptocurrency_upsert` | Assign/update tenant cryptocurrency. IDOR |
| `tenant_language_list` | List tenant languages. IDOR |
| `tenant_language_upsert` | Assign/update tenant language. IDOR |
| `tenant_setting_delete` | Delete tenant setting. IDOR |
| `tenant_setting_get` | Get tenant setting. IDOR |
| `tenant_setting_list` | List tenant settings with optional category filter. IDOR |
| `tenant_setting_upsert` | Upsert tenant setting. IDOR |
| `tenant_get_verification_timing` | Returns KYC verification timing for tenant primary jurisdiction |

#### User-Department (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `user_department_assign` | Assign user to department. Idempotent. Primary flag support. IDOR |
| `user_department_list` | List user departments. Primary first. JSONB names. IDOR |
| `user_department_remove` | Remove user from department (hard delete on junction). IDOR |

#### Infrastructure (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `infrastructure_server_list` | Sunucu envanteri listesi (filtreleme, pagination) |
| `infrastructure_server_get` | ID ile sunucu detayı getir |
| `infrastructure_server_create` | Yeni sunucu kaydı oluştur |
| `infrastructure_server_update` | Sunucu bilgilerini güncelle |

#### Provisioning (10)

| Fonksiyon | Açıklama |
|-----------|----------|
| `tenant_config_auto_populate` | Tenant oluşturulunca varsayılan ayarları otomatik doldur |
| `tenant_secrets_generate` | Tenant için API key ve secret oluştur |
| `tenant_provision_start` | Provisioning başlat: 7 adımlı log, outbox event. IDOR |
| `tenant_provision_step_update` | Provisioning adımını güncelle (başarılı/başarısız) |
| `tenant_provision_complete` | Tüm adımlar tamam → provisioning='active'. Outbox event |
| `tenant_provision_fail` | Provisioning hata durumu. Hata detayı kaydedilir |
| `tenant_provision_status` | Mevcut provisioning durumu ve adım detayları |
| `tenant_provision_history_list` | Provisioning/decommission geçmişi listesi. IDOR |
| `tenant_decommission_start` | Decommission başlat: 4 adımlı süreç, outbox event. IDOR |
| `tenant_decommission_complete` | Decommission tamamla: sunucu kaydı temizle, outbox event |

#### Tenant Servers (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `tenant_server_list` | Tenant'a atanmış sunucu listesi |
| `tenant_server_assign` | Tenant'a sunucu ata |
| `tenant_server_update` | Tenant sunucu atamasını güncelle |

#### Tenant Providers (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `tenant_provider_list` | Tenant'a bağlı provider listesi |
| `tenant_provider_enable` | Tenant için provider'ı etkinleştir |
| `tenant_provider_disable` | Tenant için provider'ı devre dışı bırak |
| `tenant_provider_set_rollout` | Provider rollout yüzdesi ayarla (0-100) |

#### Tenant Games (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `tenant_game_list` | Tenant'ın aktif oyun listesi |
| `tenant_game_upsert` | Tenant oyun ataması oluştur/güncelle |
| `tenant_game_remove` | Tenant oyun atamasını kaldır |
| `tenant_game_refresh` | Game DB'den tenant oyun listesini yeniden senkronize et |

#### Tenant Payment Methods (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `tenant_payment_method_list` | Tenant ödeme yöntemleri listesi |
| `tenant_payment_method_upsert` | Tenant ödeme yöntemi ataması oluştur/güncelle |
| `tenant_payment_method_remove` | Tenant ödeme yöntemi atamasını kaldır |
| `tenant_payment_method_refresh` | Finance DB'den tenant ödeme yöntemlerini yeniden senkronize et |

#### Tenant Payment Providers (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `tenant_payment_provider_list` | Tenant ödeme sağlayıcıları listesi |
| `tenant_payment_provider_enable` | Tenant için ödeme sağlayıcıyı etkinleştir |
| `tenant_payment_provider_disable` | Tenant için ödeme sağlayıcıyı devre dışı bırak |

---

### Outbox Schema (9)

| Fonksiyon | Açıklama |
|-----------|----------|
| `outbox_create` | Create single outbox message |
| `outbox_create_batch` | Create batch outbox messages (JSON array) |
| `outbox_get_pending` | Get pending messages for processing |
| `outbox_mark_completed` | Mark single message completed |
| `outbox_mark_completed_batch` | Mark batch completed |
| `outbox_mark_failed` | Mark single message failed with error |
| `outbox_mark_failed_batch` | Mark batch failed with error |
| `outbox_cleanup` | Cleanup old messages (retention days) |
| `outbox_stats` | Outbox statistics |

---

### Presentation Schema (47)

#### Backoffice UI (29)

| Fonksiyon | Açıklama |
|-----------|----------|
| `build_page_json` | Build complete page JSON structure |
| `context_create` | Create page context |
| `context_delete` | Delete page context |
| `context_list` | List page contexts |
| `context_update` | Update page context |
| `menu_group_create` | Menu group create |
| `menu_group_delete` | Menu group delete |
| `menu_group_get` | Menu group get |
| `menu_group_list` | Menu group list |
| `menu_group_update` | Menu group update |
| `menu_create` | Menu create |
| `menu_delete` | Menu delete |
| `menu_get` | Menu get |
| `menu_list` | Menu list by group |
| `menu_structure` | Complete menu structure (groups → menus → submenus → pages) |
| `menu_update` | Menu update |
| `submenu_create` | Submenu create |
| `submenu_delete` | Submenu delete |
| `submenu_list` | Submenu list |
| `submenu_update` | Submenu update |
| `page_create` | Page create |
| `page_delete` | Page delete |
| `page_get` | Page get |
| `page_list` | Page list |
| `page_update` | Page update |
| `tab_create` | Tab create |
| `tab_delete` | Tab delete |
| `tab_list` | Tab list |
| `tab_update` | Tab update |

#### Theme Engine (15)

| Fonksiyon | Açıklama |
|-----------|----------|
| `tenant_layout_delete` | Delete tenant layout. IDOR |
| `tenant_layout_get` | Get by ID, page_id, or layout_name. IDOR |
| `tenant_layout_list` | List all tenant layouts. IDOR |
| `tenant_layout_upsert` | Create or update layout. Unique layout_name per tenant. IDOR |
| `tenant_navigation_create` | Create custom navigation item (is_locked=FALSE). IDOR |
| `tenant_navigation_delete` | Delete navigation item. Locked items protected. IDOR |
| `tenant_navigation_get` | Get single navigation item. IDOR |
| `tenant_navigation_init_from_template` | Initialize from catalog template. Copies parent-child tree. IDOR |
| `tenant_navigation_list` | List items by menu_location. IDOR |
| `tenant_navigation_reorder` | Reorder items within menu_location. IDOR |
| `tenant_navigation_update` | Update item. Readonly items: visibility fields only. IDOR |
| `tenant_theme_activate` | Activate theme, deactivate others. IDOR |
| `tenant_theme_get` | Get merged config (default + override). NULL = active theme. IDOR |
| `tenant_theme_list` | List themes with tenant config status. IDOR |
| `tenant_theme_upsert` | Create or update theme configuration. IDOR |

#### Consumer / Frontend (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `get_active_theme` | Active theme with merged config for frontend rendering |
| `get_layout` | Active layout structure for frontend rendering |
| `get_navigation` | Visible navigation items as nested tree for frontend |

---

### Security Schema (74)

#### IDOR Protection (7)

| Fonksiyon | Açıklama |
|-----------|----------|
| `user_get_access_level` | Returns caller's access level (is_platform_admin, company_id, allowed IDs). Foundation |
| `user_can_access_tenant` | Returns BOOL. Can caller access tenant? |
| `user_can_access_company` | Returns BOOL. Can caller access company? |
| `user_can_manage_user` | Returns BOOL. Can caller manage target user? |
| `user_assert_access_tenant` | Guard clause. Raises P0403 on failure |
| `user_assert_access_company` | Guard clause. Raises P0403 on failure |
| `user_assert_manage_user` | Guard clause. Raises P0403 on failure |

#### Permission Management (16)

| Fonksiyon | Açıklama |
|-----------|----------|
| `permission_category_list` | Permission category list |
| `permission_check` | Check if user has permission (optional tenant scope) |
| `permission_cleanup_expired` | Cleanup expired permissions |
| `permission_create` | Permission create |
| `permission_delete` | Permission delete |
| `permission_exists` | Check if permission code exists |
| `permission_get` | Permission get by code |
| `permission_list` | Paginated list with category/search/status filters |
| `permission_update` | Permission update |
| `user_context_overrides_load` | Load context-scoped overrides for ProtectedFieldReadFilter |
| `user_permission_list` | List user's effective permissions (optional tenant scope) |
| `user_permission_override_list` | List user permission overrides. IDOR |
| `user_permission_override_load` | Load user permission overrides (optional tenant scope) |
| `user_permission_remove` | Remove user permission override. IDOR |
| `user_permission_set` | Set user permission override (grant/deny, optional expiry) |
| `user_permission_set_with_outbox` | Set permission + outbox message in single transaction |

#### Permission Template Management (12)

| Fonksiyon | Açıklama |
|-----------|----------|
| `permission_template_create` | Create new permission template. IDOR (company scope) |
| `permission_template_update` | Update template metadata and active status |
| `permission_template_delete` | Soft-delete template preserving audit trail |
| `permission_template_get` | Retrieve template details with items and assignments |
| `permission_template_list` | Paginated template list with filtering and search |
| `permission_template_item_set` | Bulk add or remove permissions from template |
| `permission_template_assign` | Assign template to user (expansion + snapshot model) |
| `permission_template_unassign` | Remove template assignment from user |
| `permission_template_assignment_list` | List active template assignments for user |
| `permission_template_clone` | Clone template with new code/name (metadata + items) |
| `permission_template_from_user` | Create template from user's effective permission set |
| `permission_template_cleanup_expired` | Clean up expired assignments and permission overrides |

#### Role Management (12)

| Fonksiyon | Açıklama |
|-----------|----------|
| `is_system_role` | Check if role is a system role |
| `role_create` | Role create |
| `role_delete` | Role delete |
| `role_get` | Role get by code |
| `role_list` | Paginated list with search/status filters |
| `role_update` | Role update |
| `role_permission_assign` | Assign permission to role |
| `role_permission_bulk_assign` | Bulk assign permissions (optional replace existing) |
| `role_permission_list` | List role permissions |
| `role_permission_remove` | Remove permission from role |
| `user_role_assign` | Assign role to user (optional tenant scope). IDOR |
| `user_role_list` | List user roles (optional tenant scope). IDOR |
| `user_role_remove` | Remove role from user. IDOR |

#### Session Management (8)

| Fonksiyon | Açıklama |
|-----------|----------|
| `session_save` | Save session with full GeoIP data. UPDATE-then-INSERT for partitioned table |
| `session_belongs_to_user` | Check if session belongs to user |
| `session_enforce_limit` | Atomic session limit enforcement. Revokes oldest session if limit exceeded |
| `session_update_activity` | Update last activity timestamp (on refresh token use) |
| `session_list` | List user sessions |
| `session_revoke` | Revoke single session |
| `session_revoke_all` | Revoke all sessions (optional exclude one) |
| `session_cleanup_expired` | Cleanup expired/revoked sessions. PK-based delete for partitioned table |

#### User Identity (11)

| Fonksiyon | Açıklama |
|-----------|----------|
| `user_authenticate` | Authenticate by email. Returns user info + requirePasswordChange + primaryDepartment |
| `user_check_email_exists` | Check email uniqueness (optional exclude user) |
| `user_check_username_exists` | Check username uniqueness per company (optional exclude user) |
| `user_create` | Create user. Optional department assignment. IDOR |
| `user_delete` | User delete. IDOR |
| `user_get` | Get user with departments array (JSONB multi-language). IDOR |
| `user_list` | Paginated list with primaryDepartment. IDOR |
| `user_login_failed_increment` | Increment failed login counter. Auto-lock at threshold |
| `user_login_failed_reset` | Reset failed login counter |
| `user_unlock` | Unlock user account. IDOR |
| `user_update` | Update user. Optional department change. IDOR |

#### Password Management (6)

| Fonksiyon | Açıklama |
|-----------|----------|
| `user_get_password_hash` | Get password hash for Argon2id verification in Grain |
| `user_password_history_list` | Last N password hashes for history validation (Argon2id) |
| `user_change_password` | User changes own password. History check + require_password_change = FALSE |
| `user_reset_password` | Admin resets password. IDOR. Sets require_password_change = TRUE |
| `company_password_policy_get` | Get company password policy. IDOR |
| `company_password_policy_upsert` | Create or update company password policy. IDOR |

#### Two-Factor Auth (2)

| Fonksiyon | Açıklama |
|-----------|----------|
| `user_2fa_get_secret` | Get 2FA secret for TOTP verification. NULL if not enabled |
| `user_2fa_set` | Enable/disable 2FA. P0404 if user not found |

---

### Messaging Schema (25)

#### Admin Functions (12)

| Fonksiyon | Açıklama |
|-----------|----------|
| `admin_message_draft_create` | Create draft with caller scope validation. Returns INT (draft_id) |
| `admin_message_draft_update` | Update draft/scheduled. Caller scope validation. Returns BOOL |
| `admin_message_draft_get` | Get draft details with read statistics. Returns JSONB |
| `admin_message_draft_list` | Paginated list with sender/status/type/search filters. Returns JSONB |
| `admin_message_draft_list_due_scheduled` | List scheduled drafts past due time. Used by ScheduledPublishService |
| `admin_message_draft_delete` | Soft delete draft. Published cannot be deleted (use recall). Returns BOOL |
| `admin_message_draft_cancel` | Cancel draft/scheduled (status → cancelled). Returns BOOL |
| `admin_message_draft_unschedule` | Revert scheduled draft back to draft status. Returns BOOL |
| `admin_message_publish` | Publish draft. Resolves recipients with AND-combined filters. Returns INT (count) |
| `admin_message_recall` | Recall published message. Soft deletes user_messages. Returns INT (count) |
| `admin_message_send` | Direct message to single user. No draft. Returns BIGINT (message_id) |
| `get_published_recipients` | Get recipient list with message IDs for published draft. Used by fan-out handler |

#### User Inbox (6)

| Fonksiyon | Açıklama |
|-----------|----------|
| `user_message_list` | Inbox messages with read/priority filters. Excludes expired. Returns JSONB |
| `user_message_get_by_ids` | Batch fetch messages by IDs. Used by GetPendingNotifications on reconnect |
| `user_message_read` | Mark message as read. Recipient only. Returns BOOL |
| `user_message_read_all` | Mark all unread messages as read. Returns INT (affected count) |
| `user_message_unread_count` | Unread message count. Excludes deleted and expired. Returns INT |
| `user_message_delete` | Soft delete from inbox. Recipient only. Returns BOOL |

#### Background Jobs (1)

| Fonksiyon | Açıklama |
|-----------|----------|
| `user_message_cleanup_expired` | Soft-delete expired messages in batches. SKIP LOCKED for concurrency |

#### Message Template (6)

| Fonksiyon | Açıklama |
|-----------|----------|
| `admin_message_template_create` | Create platform message template with multilingual translations. Validates channel-specific requirements → INT |
| `admin_message_template_update` | Update template metadata and translations. Channel type immutable → BOOL |
| `admin_message_template_get` | Get template details with all translations. Returns JSONB |
| `admin_message_template_list` | Paginated list with channel/category/status/search filters. Returns JSONB |
| `admin_message_template_delete` | Soft delete template. System templates cannot be deleted → VOID |
| `message_template_get_by_code` | Get active template by code and language. Backend internal use. Returns JSONB |

---

### Maintenance Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `create_partitions` | Monthly partitions for user_messages + user_sessions. Idempotent |
| `drop_expired_partitions` | Drop expired partitions. user_messages: 180d, user_sessions: 90d |
| `partition_info` | Partition status report (count, size, oldest/newest) |
| `run_maintenance` | Main cron job: create + drop in single call |

---

### Triggers (3)

| Trigger | Açıklama |
|---------|----------|
| `trigger_menu_groups_updated_at` | Auto-update updated_at on menu_groups |
| `trigger_users_updated_at` | Auto-update updated_at on users |
| `update_updated_at_column` | Generic trigger function for updated_at = NOW() |

---

## Core Audit Database (8 fonksiyon)

### Backoffice Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `auth_audit_create` | Create auth audit entry with full GeoIP data |
| `auth_audit_failed_logins` | Failed logins within time window |
| `auth_audit_list_by_type` | List by event type with date range filter |
| `auth_audit_list_by_user` | List by user ID |

### Maintenance Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `create_partitions` | Daily partitions. Look-ahead: today + N days. Idempotent |
| `drop_expired_partitions` | Drop partitions older than 90 days. Never drops current day |
| `partition_info` | Partition status report |
| `run_maintenance` | Main cron job: create + drop |

---

## Core Log Database (25 fonksiyon)

### Backoffice Schema (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `audit_create` | Create entity audit log (forwarded from tenants) |
| `audit_get` | Get entity audit log by ID |
| `audit_list` | Paginated entity audit logs with filters |

### Logs Schema (18)

| Fonksiyon | Açıklama |
|-----------|----------|
| `core_audit_create` | Create core audit log |
| `core_audit_list` | Core audit logs with filtering |
| `dead_letter_archive` | Archive resolved, failed, ignored messages before date |
| `dead_letter_bulk_ignore` | Bulk mark messages as ignored with reason |
| `dead_letter_bulk_resolve` | Bulk mark messages as resolved with notes |
| `dead_letter_bulk_retry` | Bulk reset messages to pending for retry |
| `dead_letter_create` | Create dead letter entry |
| `dead_letter_get` | Get dead letter by ID |
| `dead_letter_get_for_auto_retry` | Claim pending messages eligible for automatic retry |
| `dead_letter_list` | Paginated filtered list with search and sorting |
| `dead_letter_purge` | Permanently delete archived messages before date |
| `dead_letter_schedule_retry` | Schedule single message retry at specified time |
| `dead_letter_stats_detailed` | Comprehensive statistics by multiple dimensions |
| `dead_letter_update_status` | Update dead letter status with resolution notes |
| `error_get` | Get error by ID |
| `error_list` | Recent errors with filtering |
| `error_log` | Log error with full context (request, metadata, stack trace) |
| `error_stats` | Error statistics by time window |

### Maintenance Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `create_partitions` | Daily partitions. Look-ahead: today + N days. Idempotent |
| `drop_expired_partitions` | Drop partitions older than retention period. Safety-first |
| `partition_info` | Partition status report |
| `run_maintenance` | Main cron job: create + drop |

---

## Core Report Database (4 fonksiyon)

### Maintenance Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `create_partitions` | Monthly partitions for all report tables. Idempotent |
| `drop_expired_partitions` | Drop expired partitions. Default: indefinite (business data) |
| `partition_info` | Partition status report (performance, finance, billing schemas) |
| `run_maintenance` | Main cron job: create + drop |
