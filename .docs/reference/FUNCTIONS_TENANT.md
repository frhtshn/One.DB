# Tenant Functions & Triggers

Tenant katmanındaki tüm stored procedure, function ve trigger'ları içerir.

**Veritabanları:** `tenant`, `tenant_log`, `tenant_report`, `tenant_audit`, `tenant_affiliate`
**Toplam:** 76 fonksiyon

---

## Tenant Database (52 fonksiyon)

> **Note:** Tenant database functions do NOT perform IDOR (access control) checks.
> Authorization is handled in Core DB via `user_assert_access_tenant(caller_id, tenant_id)` before calling tenant functions.
> This follows the cross-database security pattern: **Core DB (auth) → Tenant DB (business logic)**.

### Auth Schema (2)

| Fonksiyon | Açıklama |
|-----------|----------|
| `shadow_tester_add` | Shadow test kullanıcısı ekle. Provider entegrasyon testi için |
| `shadow_tester_remove` | Shadow test kullanıcısını kaldır |

### Finance Schema (16)

#### Döviz Kurları (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `crypto_rates_bulk_upsert` | Bulk upsert crypto rates from CryptoGrain. History + latest in single transaction |
| `crypto_rates_latest_list` | Latest crypto rates for a base currency with 24h/7d change |
| `currency_rates_bulk_upsert` | Bulk upsert currency rates from CurrencyGrain. History + latest in single transaction |
| `currency_rates_latest_list` | Latest fiat currency rates with change tracking |

#### Ödeme Yöntemi Ayarları (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `payment_method_settings_sync` | Ödeme yöntemi ayarlarını Core DB'den senkronize et |
| `payment_method_settings_remove` | Ödeme yöntemi ayarlarını kaldır |
| `payment_method_settings_get` | ID ile ödeme yöntemi ayarı getir |
| `payment_method_settings_update` | Ödeme yöntemi ayarını güncelle |
| `payment_method_settings_list` | Ödeme yöntemi ayarları listesi |

#### Ödeme Limitleri (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `payment_method_limits_sync` | Ödeme yöntemi limitlerini Core DB'den senkronize et |
| `payment_method_limit_upsert` | Ödeme yöntemi limiti oluştur/güncelle |
| `payment_method_limit_list` | Ödeme yöntemi limitleri listesi |
| `payment_provider_rollout_sync` | Ödeme sağlayıcı rollout durumunu senkronize et |

#### Oyuncu Limitleri (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `payment_player_limit_set` | Oyuncu bazlı ödeme limiti ata |
| `payment_player_limit_get` | Oyuncu ödeme limitini getir |
| `payment_player_limit_list` | Oyuncu ödeme limitleri listesi |

### Game Schema (9)

#### Oyun Ayarları (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `game_settings_sync` | Oyun ayarlarını Core DB'den senkronize et |
| `game_settings_remove` | Oyun ayarlarını kaldır |
| `game_settings_get` | ID ile oyun ayarı getir |
| `game_settings_update` | Oyun ayarını güncelle |
| `game_settings_list` | Oyun ayarları listesi |

#### Oyun Limitleri (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `game_limits_sync` | Oyun limitlerini Core DB'den senkronize et |
| `game_limit_upsert` | Oyun limiti oluştur/güncelle |
| `game_limit_list` | Oyun limitleri listesi |
| `game_provider_rollout_sync` | Oyun sağlayıcı rollout durumunu senkronize et |

### Bonus Schema (8)

#### Bonus Award (6)

| Fonksiyon | Açıklama |
|-----------|----------|
| `bonus_award_create` | Oyuncuya bonus ver. BONUS wallet credit + transaction kaydı. Worker tarafından çağrılır |
| `bonus_award_get` | ID ile bonus award detayı getir |
| `bonus_award_list` | Oyuncu bonus award listesi (durum filtreleme) |
| `bonus_award_cancel` | Aktif bonusu iptal et. Kalan bakiye BONUS wallet'tan düşülür |
| `bonus_award_complete` | Çevrimi tamamlanan bonusu REAL wallet'a aktar. max_withdrawal_amount limiti uygulanır |
| `bonus_award_expire` | Batch expire: süresi dolmuş bonusları expire et. SKIP LOCKED ile concurrent worker güvenliği |

#### Promo Redemption (2)

| Fonksiyon | Açıklama |
|-----------|----------|
| `promo_redeem` | Promosyon kodu kullan. Kullanım limiti ve süre kontrolü |
| `promo_redemption_list` | Promosyon kullanım geçmişi listesi |

### Content Schema

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
