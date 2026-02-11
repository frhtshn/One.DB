# Tenant Functions & Triggers

Tenant katmanındaki tüm stored procedure, function ve trigger'ları içerir.

**Veritabanları:** `tenant`, `tenant_log`, `tenant_report`, `tenant_audit`, `tenant_affiliate`
**Toplam:** 45 fonksiyon

---

## Tenant Database (21 fonksiyon)

> **Note:** Tenant database functions do NOT perform IDOR (access control) checks.
> Authorization is handled in Core DB via `user_assert_access_tenant(caller_id, tenant_id)` before calling tenant functions.
> This follows the cross-database security pattern: **Core DB (auth) → Tenant DB (business logic)**.

### Finance Schema (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `crypto_rates_bulk_upsert` | Bulk upsert crypto rates from CryptoGrain. History + latest in single transaction. Returns inserted_count, upserted_count |
| `crypto_rates_latest_list` | Latest crypto rates for a base currency with 24h/7d change. Used on Redis cache miss |
| `currency_rates_bulk_upsert` | Bulk upsert currency rates from CurrencyGrain. History + latest in single transaction. Returns inserted_count, upserted_count |

### Wallet Schema

> Functions will be documented here as they are implemented.

### Content Schema

> Functions will be documented here as they are implemented.

### Bonus Schema

> Functions will be documented here as they are implemented.

### Messaging Schema (14)

#### Admin Campaign (6)

| Fonksiyon | Açıklama |
|-----------|----------|
| `admin_campaign_create` | Create campaign with translations and segments. Returns INT |
| `admin_campaign_update` | Update draft/scheduled campaign. Returns BOOL |
| `admin_campaign_publish` | Publish draft → scheduled/processing. Backend pushes to RabbitMQ. Returns BOOL |
| `admin_campaign_cancel` | Cancel draft/scheduled. Processing cannot be cancelled. Returns BOOL |
| `admin_campaign_get` | Get campaign with translations and segments. Returns JSONB |
| `admin_campaign_list` | Paginated list with channel/status/search filters. Returns JSONB |

#### Admin Template (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `admin_template_create` | Create template with multilingual translations. Returns INT |
| `admin_template_update` | Update template with translations. Returns BOOL |
| `admin_template_get` | Get template with translations. Returns JSONB |
| `admin_template_list` | Paginated list with channel/status/search filters. Returns JSONB |

#### Admin Player Message (1)

| Fonksiyon | Açıklama |
|-----------|----------|
| `admin_player_message_send` | Send message to player inbox. Used by system services and BO users. Returns BIGINT |

#### Player Message (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_message_list` | Inbox messages with read/unread filter. Returns JSONB (total + unread counts) |
| `player_message_read` | Mark message as read. Owning player only. Returns BOOL |
| `player_message_delete` | Soft delete from inbox. Owning player only. Data preserved for audit. Returns BOOL |

### Maintenance Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `create_partitions` | Monthly partitions for transactions + player_messages. Idempotent |
| `drop_expired_partitions` | Drop expired. Transactions: indefinite, player_messages: 180d |
| `partition_info` | Partition status report (count, size, oldest/newest) |
| `run_maintenance` | Main cron job: create + drop |

---

## Tenant Log Database (4 fonksiyon)

### Maintenance Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `create_partitions` | Daily partitions. Look-ahead: today + N days. Idempotent |
| `drop_expired_partitions` | Drop partitions older than retention period. Safety-first |
| `partition_info` | Partition status report |
| `run_maintenance` | Main cron job: create + drop |

---

## Tenant Report Database (4 fonksiyon)

### Maintenance Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `create_partitions` | Monthly partitions for report tables. Idempotent |
| `drop_expired_partitions` | Drop expired. Default: ~100 years (business data) |
| `partition_info` | Partition status report |
| `run_maintenance` | Main cron job: create + drop |

---

## Tenant Audit Database (12 fonksiyon)

### Player Audit Schema (8)

#### Login Attempts (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `login_attempt_create` | Record login attempt with full GeoIP data. Returns BIGINT |
| `login_attempt_list` | List login attempts for a player. Returns JSONB array |
| `login_attempt_failed_list` | Failed attempts within time window for brute-force detection. Returns JSONB |

#### Login Sessions (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `login_session_create` | Create player session with full GeoIP data. Returns BIGINT |
| `login_session_update_activity` | Update last activity timestamp |
| `login_session_end` | End player session. Returns BOOL |
| `login_session_list` | List sessions with optional active-only filter. Returns JSONB array |
| `login_session_end_all` | End all active sessions (optional exclude one). Returns INT (count) |

### Maintenance Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `create_partitions` | Hybrid: daily for login_attempts, monthly for login_sessions. Idempotent |
| `drop_expired_partitions` | Drop expired. Daily: 365d, Monthly: 5 years |
| `partition_info` | Partition status report |
| `run_maintenance` | Main cron job: hybrid daily+monthly strategies |

---

## Tenant Affiliate Database (4 fonksiyon)

### Maintenance Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `create_partitions` | Monthly partitions for tracking tables. Idempotent |
| `drop_expired_partitions` | Drop expired. Default: indefinite (business data) |
| `partition_info` | Partition status report |
| `run_maintenance` | Main cron job: create + drop |
