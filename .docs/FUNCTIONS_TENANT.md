# Tenant Functions & Triggers

Tenant katmanındaki tüm stored procedure, function ve trigger'ları içerir.

**Veritabanları:** `tenant`, `tenant_log`, `tenant_report`, `tenant_audit`, `tenant_affiliate`

---

## Tenant Database

> **Note:** Tenant database functions do NOT perform IDOR (access control) checks.
> Authorization is handled in Core DB via `user_assert_access_tenant(caller_id, tenant_id)` before calling tenant functions.
> This follows the cross-database security pattern: **Core DB (auth) → Tenant DB (business logic)**.

### Finance Schema

- **`crypto_rates_bulk_upsert(p_provider VARCHAR(30), p_base_currency VARCHAR(10), p_rates TEXT, p_rate_timestamp TIMESTAMPTZ, p_fetched_at TIMESTAMPTZ DEFAULT now())`**: Bulk upsert crypto rates from CryptoGrain. Inserts history into `crypto_rates` (ON CONFLICT DO NOTHING) and upserts latest into `crypto_rates_latest` in a single transaction. Returns `inserted_count` and `upserted_count`. JSON format: `[{"symbol":"BTC","rate":97432.50,"change_24h":1200,"change_pct_24h":1.25,...}]`.
- **`crypto_rates_latest_list(p_base_currency VARCHAR(10))`**: Lists latest crypto rates for a given base currency with 24h/7d change data. Used by CryptoRateGrain on Redis cache miss.
- **`currency_rates_bulk_upsert(p_provider VARCHAR(30), p_provider_base_currency CHAR(3), p_rates JSONB, p_rate_timestamp TIMESTAMP, p_fetched_at TIMESTAMP DEFAULT now())`**: Bulk upsert currency rates from CurrencyGrain. Inserts history into `currency_rates` and upserts latest into `currency_rates_latest` in a single transaction. Returns `inserted_count` and `upserted_count`. JSONB format: `[{"currency":"USD","rate":1.036},...]`.

### Wallet Schema

> Functions will be documented here as they are implemented.

### Content Schema

> Functions will be documented here as they are implemented.

### Bonus Schema

> Functions will be documented here as they are implemented.

### Messaging Schema

#### Admin Campaign Functions
- **`admin_campaign_create(p_name VARCHAR(200), p_channel_type VARCHAR(10), p_template_id INTEGER DEFAULT NULL, p_scheduled_at TIMESTAMP DEFAULT NULL, p_translations JSONB DEFAULT NULL, p_segments JSONB DEFAULT NULL, p_created_by INTEGER DEFAULT NULL)`**: Create a new message campaign with translations and targeting segments in a single transaction. Returns INTEGER.
- **`admin_campaign_update(p_campaign_id INTEGER, p_name VARCHAR(200) DEFAULT NULL, p_channel_type VARCHAR(10) DEFAULT NULL, p_template_id INTEGER DEFAULT NULL, p_scheduled_at TIMESTAMP DEFAULT NULL, p_translations JSONB DEFAULT NULL, p_segments JSONB DEFAULT NULL, p_updated_by INTEGER DEFAULT NULL)`**: Update a draft/scheduled campaign with new details, translations, and segments. Returns BOOLEAN.
- **`admin_campaign_publish(p_campaign_id INTEGER, p_published_by INTEGER DEFAULT NULL)`**: Publish a draft campaign - sets to scheduled if future date, processing if immediate. Backend pushes to RabbitMQ after this call. Returns BOOLEAN.
- **`admin_campaign_cancel(p_campaign_id INTEGER, p_cancelled_by INTEGER DEFAULT NULL)`**: Cancel a draft or scheduled campaign. Processing campaigns cannot be cancelled. Returns BOOLEAN.
- **`admin_campaign_get(p_campaign_id INTEGER)`**: Get campaign details with translations and segments as a single JSON response. Returns JSONB.
- **`admin_campaign_list(p_channel_type VARCHAR(10) DEFAULT NULL, p_status VARCHAR(20) DEFAULT NULL, p_search VARCHAR(200) DEFAULT NULL, p_offset INTEGER DEFAULT 0, p_limit INTEGER DEFAULT 20)`**: List campaigns with channel, status, and search filters. Returns paginated results with total count. Returns JSONB.

#### Admin Template Functions
- **`admin_template_create(p_code VARCHAR(50), p_name VARCHAR(200), p_channel_type VARCHAR(10), p_description TEXT DEFAULT NULL, p_translations JSONB DEFAULT NULL, p_created_by INTEGER DEFAULT NULL)`**: Create a new message template with multilingual translations in a single transaction. Returns INTEGER.
- **`admin_template_update(p_template_id INTEGER, p_name VARCHAR(200) DEFAULT NULL, p_description TEXT DEFAULT NULL, p_status VARCHAR(20) DEFAULT NULL, p_translations JSONB DEFAULT NULL, p_updated_by INTEGER DEFAULT NULL)`**: Update a message template with new details and translations. Returns BOOLEAN.
- **`admin_template_get(p_template_id INTEGER)`**: Get template details with translations as a single JSON response. Returns JSONB.
- **`admin_template_list(p_channel_type VARCHAR(10) DEFAULT NULL, p_status VARCHAR(20) DEFAULT NULL, p_search VARCHAR(200) DEFAULT NULL, p_offset INTEGER DEFAULT 0, p_limit INTEGER DEFAULT 20)`**: List message templates with channel, status, and search filters. Returns paginated results with total count. Returns JSONB.

#### Admin Player Message Functions
- **`admin_player_message_send(p_player_id BIGINT, p_subject VARCHAR(500), p_body TEXT, p_message_type VARCHAR(30) DEFAULT 'system', p_campaign_id INTEGER DEFAULT NULL, p_created_by INTEGER DEFAULT NULL)`**: Send a single message to a player inbox. Used by system services (automated notifications) and BO users (manual direct messages). Returns BIGINT.

#### Player Message Functions
- **`player_message_list(p_player_id BIGINT, p_is_read BOOLEAN DEFAULT NULL, p_offset INTEGER DEFAULT 0, p_limit INTEGER DEFAULT 20)`**: List player inbox messages with read/unread filter. Returns paginated results with total and unread counts. Returns JSONB.
- **`player_message_read(p_player_id BIGINT, p_message_id BIGINT)`**: Mark a player message as read. Only the owning player can mark their messages. Returns BOOLEAN.
- **`player_message_delete(p_player_id BIGINT, p_message_id BIGINT)`**: Soft delete a player message from inbox. Only the owning player can delete their messages. Data is preserved for audit. Returns BOOLEAN.

### Maintenance Schema

> Each partitioned database has identical maintenance functions under `maintenance` schema.

- **`create_partitions(p_months_ahead INT DEFAULT 3)`**: Creates monthly partitions for tenant tables (transactions, player_messages). Look-ahead: current month + N months. Idempotent.
- **`drop_expired_partitions(p_retention_days INT DEFAULT NULL)`**: Drops monthly partitions older than per-table retention period. Transactions: indefinite, player_messages: 180 days. Never drops current month.
- **`partition_info()`**: Reports partition status for all partitioned tables. Shows count, size, oldest/newest partitions.
- **`run_maintenance(p_months_ahead INT DEFAULT 3, p_retention_days INT DEFAULT NULL)`**: Main maintenance function for cron jobs. Creates future monthly partitions and drops expired ones.

---

## Tenant Log Database

### Maintenance Schema

- **`create_partitions(p_days_ahead INT DEFAULT 7)`**: Creates daily partitions for tenant_log tables. Look-ahead: today + N days. Idempotent.
- **`drop_expired_partitions(p_retention_days INT DEFAULT NULL)`**: Drops daily partitions older than retention period. Never drops current day partition. Safety-first design.
- **`partition_info()`**: Reports partition status for all partitioned tables in tenant_log. Shows count, size, oldest/newest partitions.
- **`run_maintenance(p_days_ahead INT DEFAULT 7, p_retention_days INT DEFAULT NULL)`**: Main maintenance function for cron jobs. Creates future partitions and drops expired ones in a single call.

---

## Tenant Report Database

### Maintenance Schema

- **`create_partitions(p_months_ahead INT DEFAULT 3)`**: Creates monthly partitions for tenant_report tables. Look-ahead: current month + N months. Idempotent.
- **`drop_expired_partitions(p_retention_days INT DEFAULT NULL)`**: Drops monthly partitions older than retention period. Default ~100 years (business data). Never drops current month.
- **`partition_info()`**: Reports partition status for all partitioned tables in tenant_report. Shows count, size, oldest/newest partitions.
- **`run_maintenance(p_months_ahead INT DEFAULT 3, p_retention_days INT DEFAULT NULL)`**: Main maintenance function for cron jobs. Creates future monthly partitions and drops expired ones in a single call.

---

## Tenant Audit Database

### Player Audit Schema

#### Login Attempts
- **`login_attempt_create(p_player_id BIGINT, p_identifier VARCHAR(300), p_ip_address INET, p_user_agent VARCHAR(500), p_is_successful BOOLEAN, p_country VARCHAR(100) DEFAULT NULL, p_country_code CHAR(2) DEFAULT NULL, p_continent VARCHAR(100) DEFAULT NULL, p_continent_code CHAR(2) DEFAULT NULL, p_region VARCHAR(100) DEFAULT NULL, p_region_name VARCHAR(200) DEFAULT NULL, p_city VARCHAR(200) DEFAULT NULL, p_district VARCHAR(200) DEFAULT NULL, p_zip VARCHAR(20) DEFAULT NULL, p_lat DECIMAL(9,6) DEFAULT NULL, p_lon DECIMAL(9,6) DEFAULT NULL, p_timezone VARCHAR(100) DEFAULT NULL, p_utc_offset INTEGER DEFAULT NULL, p_currency VARCHAR(10) DEFAULT NULL, p_isp VARCHAR(300) DEFAULT NULL, p_org VARCHAR(300) DEFAULT NULL, p_as_number VARCHAR(200) DEFAULT NULL, p_as_name VARCHAR(300) DEFAULT NULL, p_reverse_dns VARCHAR(300) DEFAULT NULL, p_is_mobile BOOLEAN DEFAULT FALSE, p_is_proxy BOOLEAN DEFAULT FALSE, p_is_hosting BOOLEAN DEFAULT FALSE, p_failure_reason VARCHAR(50) DEFAULT NULL)`**: Records a player login attempt with full GeoIP data. Returns BIGINT.
- **`login_attempt_list(p_player_id BIGINT, p_limit INT DEFAULT 50)`**: Lists login attempts for a player. Returns JSONB array.
- **`login_attempt_failed_list(p_player_id BIGINT, p_hours INT DEFAULT 1)`**: Returns failed attempts within time window for brute-force detection. Returns JSONB with failedCount and attempts.

#### Login Sessions
- **`login_session_create(p_session_token UUID, p_player_id BIGINT, p_ip_address INET, p_user_agent VARCHAR(500) DEFAULT NULL, p_device_fingerprint VARCHAR(64) DEFAULT NULL, p_country VARCHAR(100) DEFAULT NULL, p_country_code CHAR(2) DEFAULT NULL, p_continent VARCHAR(100) DEFAULT NULL, p_continent_code CHAR(2) DEFAULT NULL, p_region VARCHAR(100) DEFAULT NULL, p_region_name VARCHAR(200) DEFAULT NULL, p_city VARCHAR(200) DEFAULT NULL, p_district VARCHAR(200) DEFAULT NULL, p_zip VARCHAR(20) DEFAULT NULL, p_lat DECIMAL(9,6) DEFAULT NULL, p_lon DECIMAL(9,6) DEFAULT NULL, p_timezone VARCHAR(100) DEFAULT NULL, p_utc_offset INTEGER DEFAULT NULL, p_currency VARCHAR(10) DEFAULT NULL, p_isp VARCHAR(300) DEFAULT NULL, p_org VARCHAR(300) DEFAULT NULL, p_as_number VARCHAR(200) DEFAULT NULL, p_as_name VARCHAR(300) DEFAULT NULL, p_reverse_dns VARCHAR(300) DEFAULT NULL, p_is_mobile BOOLEAN DEFAULT FALSE, p_is_proxy BOOLEAN DEFAULT FALSE, p_is_hosting BOOLEAN DEFAULT FALSE)`**: Creates a player login session with full GeoIP data. Returns BIGINT.
- **`login_session_update_activity(p_session_token UUID)`**: Updates last activity timestamp for active session. Returns VOID.
- **`login_session_end(p_session_token UUID, p_logout_type VARCHAR(20) DEFAULT 'MANUAL')`**: Ends a player session. Returns BOOLEAN.
- **`login_session_list(p_player_id BIGINT, p_active_only BOOLEAN DEFAULT FALSE, p_limit INT DEFAULT 50)`**: Lists player sessions with optional active-only filter. Returns JSONB array.
- **`login_session_end_all(p_player_id BIGINT, p_logout_type VARCHAR(20) DEFAULT 'FORCED', p_exclude_token UUID DEFAULT NULL)`**: Ends all active sessions, optionally excluding one. Returns INT (count).

### Maintenance Schema

- **`create_partitions(p_look_ahead_days INT DEFAULT 7, p_look_ahead_months INT DEFAULT 3)`**: Creates partitions for tenant_audit tables. Hybrid: daily for login_attempts, monthly for login_sessions. Idempotent.
- **`drop_expired_partitions(p_daily_retention_days INT DEFAULT 365, p_monthly_retention_days INT DEFAULT 1825)`**: Drops expired partitions. Daily tables: 365 days. Monthly tables: 5 years. Never drops active partitions.
- **`partition_info()`**: Reports partition status for all partitioned tables in tenant_audit player_audit schema. Shows count, size, oldest/newest partitions.
- **`run_maintenance(p_daily_retention_days INT DEFAULT 365, p_monthly_retention_days INT DEFAULT 1825, p_look_ahead_days INT DEFAULT 7, p_look_ahead_months INT DEFAULT 3)`**: Main maintenance function for cron jobs. Supports hybrid daily+monthly partition strategies.

---

## Tenant Affiliate Database

### Maintenance Schema

- **`create_partitions(p_months_ahead INT DEFAULT 3)`**: Creates monthly partitions for tenant_affiliate tracking tables. Look-ahead: current month + N months. Idempotent.
- **`drop_expired_partitions(p_retention_days INT DEFAULT NULL)`**: Drops monthly partitions older than retention period. Default: indefinite (business data). Never drops current month.
- **`partition_info()`**: Reports partition status for all partitioned tables in tenant_affiliate. Shows count, size, oldest/newest partitions.
- **`run_maintenance(p_months_ahead INT DEFAULT 3, p_retention_days INT DEFAULT NULL)`**: Main maintenance function for cron jobs. Creates future monthly partitions and drops expired ones.
