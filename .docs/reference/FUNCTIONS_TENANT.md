# Tenant Functions & Triggers

Tenant katmanındaki tüm stored procedure, function ve trigger'ları içerir.

**Veritabanları:** `tenant`, `tenant_log`, `tenant_report`, `tenant_audit`, `tenant_affiliate`
**Toplam:** 205 fonksiyon

---

## Tenant Database (175 fonksiyon)

> **Note:** Tenant database functions do NOT perform IDOR (access control) checks.
> Authorization is handled in Core DB via `user_assert_access_tenant(caller_id, tenant_id)` before calling tenant functions.
> This follows the cross-database security pattern: **Core DB (auth) → Tenant DB (business logic)**.

### Auth Schema (19)

#### Shadow Test (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `shadow_tester_add` | Shadow test kullanıcısı ekle (idempotent) → VOID |
| `shadow_tester_remove` | Shadow test kullanıcısını kaldır → VOID |
| `shadow_tester_list` | Tüm shadow tester'ları listele (username dahil) → JSONB |
| `shadow_tester_get` | player_id bazlı shadow tester detayı → JSONB |

#### Player Category CRUD (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_category_create` | Yeni oyuncu kategorisi oluştur. Kod UPPER(TRIM) ile normalize edilir → BIGINT |
| `player_category_update` | Oyuncu kategorisini güncelle. Partial update (COALESCE) → VOID |
| `player_category_get` | Kategori detayı + playerCount → JSONB |
| `player_category_list` | Kategorileri listele. Opsiyonel is_active filtresi, level sıralı → JSONB |
| `player_category_delete` | Soft delete (is_active = false) → VOID |

#### Player Group CRUD (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_group_create` | Yeni oyuncu grubu oluştur. Kod UPPER(TRIM) ile normalize edilir → BIGINT |
| `player_group_update` | Oyuncu grubunu güncelle. Partial update (COALESCE) → VOID |
| `player_group_get` | Grup detayı + playerCount → JSONB |
| `player_group_list` | Grupları listele. Opsiyonel is_active filtresi, level sıralı → JSONB |
| `player_group_delete` | Soft delete (is_active = false) → VOID |

#### Player Classification (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_classification_assign` | Oyuncuya kategori/grup ata. Kategori tek (upsert), grup çoklu (idempotent) → VOID |
| `player_classification_remove` | Oyuncudan kategori/grup kaldır → VOID |
| `player_classification_list` | Oyuncunun kategori + gruplarını getir → JSONB |
| `player_classification_bulk_assign` | Toplu kategori/grup atama → INT |

#### Player Segmentation (1)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_get_segmentation` | Bonus eligibility için oyuncu segmentasyon verisi. Tek giriş noktası → JSONB |

### Finance Schema (17)

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

#### Ücret Hesaplama (1)

| Fonksiyon | Açıklama |
|-----------|----------|
| `calculate_fee` | Ödeme yöntemi ücreti hesapla. Formül: MAX(min, MIN(max, amount * percent + fixed)) → JSONB |

### Game Schema (12)

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

#### Game Sessions (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `game_session_create` | Yeni oyun oturumu oluştur. Token üret, oyuncu durum kontrolü → JSONB |
| `game_session_validate` | Session token doğrula. Expire kontrolü, last_activity güncelle → JSONB |
| `game_session_end` | Oyun oturumunu kapat. İdempotent (zaten kapalı ise sessizce true) → BOOL |

### Transaction Schema (17)

#### Payment Sessions (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `payment_session_create` | Ödeme oturumu oluştur. UUID token üret, TTL expiry → JSONB |
| `payment_session_get` | Token ile oturum getir. Expire kontrolü, otomatik status güncelleme → JSONB |
| `payment_session_update` | Oturum güncelle. COALESCE ile kısmi güncelleme, completed_at otomatik → VOID |

#### Workflow Operations (9)

| Fonksiyon | Açıklama |
|-----------|----------|
| `workflow_create` | Onay akışı başlat. Tip: WITHDRAWAL, ADJUSTMENT, HIGH_VALUE, SUSPICIOUS, KYC_REQUIRED → BIGINT |
| `workflow_assign` | BO kullanıcısına ata. PENDING → IN_REVIEW, `assigned_to_id` güncelle → VOID |
| `workflow_approve` | Onayla. IN_REVIEW → APPROVED → VOID |
| `workflow_reject` | Reddet. IN_REVIEW → REJECTED, red sebebi kaydedilir → VOID |
| `workflow_cancel` | İptal et. PENDING → CANCELLED (oyuncu iptali) → VOID |
| `workflow_escalate` | Üst seviyeye yükselt. IN_REVIEW kalır, `assigned_to_id` değişir → VOID |
| `workflow_add_note` | Workflow'a not ekle. Durumu değiştirmez, audit trail → VOID |
| `workflow_list` | Filtrelemeli + sayfalı liste (status, assigned_to, workflow_type filtresi) → JSONB |
| `workflow_get` | Detay + action geçmişi + transaction bilgisi → JSONB |

#### Account Adjustment (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `adjustment_create` | Hesap düzeltme talebi oluştur. PENDING kayıt, workflow beklenir → BIGINT |
| `adjustment_apply` | Workflow onayı sonrası wallet'a uygula. CREDIT veya DEBIT → JSONB |
| `adjustment_cancel` | Workflow reddi sonrası iptal et. Wallet değişmez → VOID |
| `adjustment_get` | Düzeltme detayı + workflow durumu → JSONB |
| `adjustment_list` | Filtrelemeli + sayfalı liste (status, player, adjustment_type) → JSONB |

### Wallet Schema (22)

#### Balance & Info (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_info_get` | Oyuncu bilgisi getir (Hub88 /user/info). STABLE → JSONB |
| `player_balance_get` | REAL + BONUS cüzdan bakiyesi. STABLE → JSONB |
| `player_balance_per_game_get` | PP getBalancePerGame. Oyun bazlı bakiye (aynı bakiye) → JSONB |

#### Wallet Operations (7)

| Fonksiyon | Açıklama |
|-----------|----------|
| `bet_process` | Bahis işlemi. FOR UPDATE kilit, bakiye kontrolü, debit → JSONB |
| `win_process` | Kazanç işlemi. Credit, amount=0 geçerli (kayıp round) → JSONB |
| `rollback_process` | Bahis iadesi / kazanç geri alma. PP+Hub88 spec: bulunamazsa başarılı → JSONB |
| `jackpot_win_process` | Jackpot kazancı. win_process wrapper (tx_type=70) → JSONB |
| `bonus_win_process` | Bonus kazancı. win_process wrapper (tx_type=72) → JSONB |
| `promo_win_process` | Promosyon kazancı. win_process wrapper (tx_type=71) → JSONB |
| `adjustment_process` | Bakiye düzeltme. Pozitif=credit, negatif=debit (tx_type=26) → JSONB |

#### Deposit Operations (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `deposit_initiate` | Para yatırma başlat. PENDING tx oluştur, bakiye DEĞİŞMEZ → JSONB |
| `deposit_confirm` | Para yatırma onayla. FOR UPDATE kilit, bakiye ARTAR. İdempotent → JSONB |
| `deposit_fail` | Para yatırma başarısız işaretle. Bakiye değişmez → BOOLEAN |
| `deposit_manual_process` | Manuel para yatırma. Tek adım credit (tx_type=81) → JSONB |

#### Withdrawal Operations (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `withdrawal_initiate` | Para çekme başlat. FOR UPDATE kilit, bakiye HEMEN düşer, çevrim kontrolü → JSONB |
| `withdrawal_confirm` | Para çekme onayla. confirmed_at güncelle, bakiye değişmez → BOOLEAN |
| `withdrawal_cancel` | Para çekme iptal. Reversal tx ile bakiye geri eklenir → JSONB |
| `withdrawal_fail` | Para çekme başarısız (PSP red). Reversal tx ile bakiye geri eklenir → JSONB |
| `withdrawal_manual_process` | Manuel para çekme. Tek adım debit (tx_type=86) → JSONB |

### Bonus Schema (30)

#### Bonus Award (6)

| Fonksiyon | Açıklama |
|-----------|----------|
| `bonus_award_create` | Oyuncuya bonus ver. BONUS wallet credit + transaction kaydı. Worker veya bonus_request_approve tarafından çağrılır. `p_bonus_request_id` opsiyonel |
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

#### Provider Bonus Mapping (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `provider_bonus_mapping_create` | Provider tarafı bonus eşleştirmesi oluştur (free spin/free bet). Provider bonus ID ve request ID ile → BIGINT |
| `provider_bonus_mapping_get` | Provider code + provider bonus ID ile eşleştirme getir. STABLE, bulunamazsa NULL → JSONB |
| `provider_bonus_mapping_update_status` | Provider bonus eşleştirme durumunu güncelle (active/completed/cancelled/expired) → VOID |

#### Bonus Request Settings (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `bonus_request_setting_upsert` | Bonus talep ayarı oluştur/güncelle. JSONB parse (display_name, rules_content, eligible_groups/categories). ON CONFLICT upsert → BIGINT |
| `bonus_request_setting_list` | Aktif bonus talep ayarları listesi. display_order sıralı → JSONB |
| `bonus_request_setting_get` | bonus_type_code ile tekil ayar getir → JSONB |
| `player_requestable_bonus_types` | FE-facing: oyuncu için talep edilebilir bonus tipleri. Eligibility + cooldown filtresi, lokalize display_name/rules_content → JSONB |

#### Bonus Request BO (10)

| Fonksiyon | Açıklama |
|-----------|----------|
| `bonus_request_create` | Bonus talebi oluştur (player/operator source). Operatör: amount+currency zorunlu → BIGINT |
| `bonus_request_get` | Talep detay + actions array → JSONB |
| `bonus_request_list` | Sayfalı liste (status, source, player, assignee, type, priority filtreleri) → JSONB |
| `bonus_request_assign` | pending\|assigned → assigned. Operatöre ata → VOID |
| `bonus_request_start_review` | pending\|assigned\|on_hold → in_progress. İnceleme başlat/devam et → VOID |
| `bonus_request_hold` | in_progress → on_hold. hold_reason zorunlu → VOID |
| `bonus_request_approve` | in_progress → completed (atomik). bonus_award_create() çağrılır. Award ID döner → BIGINT |
| `bonus_request_reject` | assigned\|in_progress → rejected. review_note zorunlu → VOID |
| `bonus_request_cancel` | pending\|assigned → cancelled → VOID |
| `bonus_request_rollback` | completed\|rejected → in_progress. Completed: bonus_award_cancel() çağrılır → VOID |

#### Bonus Request Player (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_bonus_request_create` | Oyuncu bonus talebi. Eligibility (grup/kategori, OR mantığı) + cooldown + pending limit kontrolü → BIGINT |
| `player_bonus_request_list` | Oyuncu talep listesi. Güvenli alanlar, completed ise wagering bilgisi → JSONB |
| `player_bonus_request_cancel` | Oyuncu kendi pending talebini iptal. Sahiplik kontrolü → VOID |

#### Bonus Request Maintenance (2)

| Fonksiyon | Açıklama |
|-----------|----------|
| `bonus_request_expire` | Süresi dolmuş pending/assigned talepleri expire et. SKIP LOCKED batch → INT |
| `bonus_request_cleanup` | cancelled/expired talepleri retention sonrası sil. completed/rejected asla silinmez → INT |

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

### Support Schema (43)

> **Detaylı rehber:** [CALL_CENTER_GUIDE.md](../guides/CALL_CENTER_GUIDE.md)

#### Ticket BO (11)

| Fonksiyon | Açıklama |
|-----------|----------|
| `ticket_create` | Ticket oluştur (BO adına, anti-abuse yok). channel, priority, category_id → BIGINT |
| `ticket_get` | Tekil ticket detay + actions + tags → JSONB |
| `ticket_list` | Filtreli + sayfalı listeleme (status, channel, priority, assigned_to, player_id) → JSONB |
| `ticket_update` | Priority ve/veya category güncelle. Aksiyon logu kaydedilir → VOID |
| `ticket_assign` | Temsilciye ata / devret. Yeniden atamada REASSIGNED logu → VOID |
| `ticket_add_note` | İç not ekle (is_internal=true) → BIGINT |
| `ticket_reply_player` | Oyuncuya yanıt gönder → BIGINT |
| `ticket_resolve` | Çöz. resolution_note zorunlu → VOID |
| `ticket_close` | Kapat (final durum) → VOID |
| `ticket_reopen` | Tekrar aç (resolved → reopened) → VOID |
| `ticket_cancel` | İptal et (final durum) → VOID |

#### Ticket Oyuncu (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_ticket_create` | Oyuncu ticket oluştur. Anti-abuse: max_open + cooldown kontrolü → BIGINT |
| `player_ticket_list` | Kendi ticketlarını listele (internal notlar gizli) → JSONB |
| `player_ticket_get` | Ticket detay (is_internal=true gizlenir) → JSONB |
| `player_ticket_reply` | Oyuncu yanıt. pending_player → in_progress → BIGINT |

#### Player Notes (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_note_create` | Not oluştur (general/warning/vip/compliance tipi) → BIGINT |
| `player_note_update` | İçerik, tip, pin durumu güncelle (COALESCE) → VOID |
| `player_note_delete` | Soft delete (is_active = false) → VOID |
| `player_note_list` | Sayfalı liste. Pinned önce, sonra created_at DESC → JSONB |

#### Agent Settings (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `agent_setting_upsert` | Agent profili oluştur/güncelle. ON CONFLICT upsert → BIGINT |
| `agent_setting_get` | Tekil agent ayarı → JSONB |
| `agent_setting_list` | Agent listesi + mevcut açık ticket sayısı (workload) → JSONB |

#### Canned Responses (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `canned_response_create` | Hazır yanıt oluştur → BIGINT |
| `canned_response_update` | Güncelle (COALESCE) → VOID |
| `canned_response_delete` | Soft delete → VOID |
| `canned_response_list` | Kategoriye göre filtreli + ILIKE arama → JSONB |

#### Representative (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_representative_assign` | Temsilci ata/değiştir. Zorunlu neden, immutable tarihçe → VOID |
| `player_representative_get` | Mevcut temsilci bilgisi → JSONB |
| `player_representative_history_list` | Atama değişiklik tarihçesi → JSONB |

#### Welcome Call (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `welcome_call_task_list` | Görev kuyruğu (pending → created_at, rescheduled → next_attempt_at) → JSONB |
| `welcome_call_task_assign` | Görevi al (pending/rescheduled → assigned) → VOID |
| `welcome_call_task_complete` | Tamamla (answered/declined → completed, wrong_number → failed) → VOID |
| `welcome_call_task_reschedule` | Tekrar planla (no_answer/busy/voicemail). Max aşılınca → failed → VOID |

#### Ticket Category (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `ticket_category_create` | Hiyerarşik kategori oluştur. JSONB çoklu dil desteği → BIGINT |
| `ticket_category_update` | Kategori güncelle (name, description, display_order) → VOID |
| `ticket_category_delete` | Soft delete. Alt kategorisi varsa hata → VOID |
| `ticket_category_list` | Hiyerarşik ağaç yapısında listele. Dil parametresi → JSONB |

#### Ticket Tag (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `ticket_tag_create` | Etiket oluştur (ad + HEX renk) → BIGINT |
| `ticket_tag_update` | Ad ve/veya renk güncelle → VOID |
| `ticket_tag_list` | Tüm aktif etiketler + ticket kullanım sayısı → JSONB |

#### Dashboard (2)

| Fonksiyon | Açıklama |
|-----------|----------|
| `ticket_queue_list` | Atanmamış ticketlar (open/reopened). priority DESC, created_at ASC → JSONB |
| `ticket_dashboard_stats` | Status/priority/channel dağılımı + hoşgeldin arama özeti → JSONB |

#### Support Maintenance (1)

| Fonksiyon | Açıklama |
|-----------|----------|
| `welcome_call_task_cleanup` | Tamamlanan/başarısız görevleri sil (180 gün, batch, SKIP LOCKED) → INT |

### Maintenance Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `create_partitions` | Monthly partitions for transactions + player_messages. Idempotent |
| `drop_expired_partitions` | Drop expired. Transactions: indefinite, player_messages: 180d |
| `partition_info` | Partition status report (count, size, oldest/newest) |
| `run_maintenance` | Main cron job: create + drop |

---

## Tenant Log Database (10 fonksiyon)

### Game Log Schema (6)

#### Round (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `round_upsert` | Round kaydı oluştur/güncelle. Kümülatif bet/win. round_closed flag ile otomatik kapatma → BIGINT |
| `round_close` | PP endRound callback. Round'u kapat, duration hesapla. İdempotent → VOID |
| `round_cancel` | Round iptal/refund. Durum: cancelled veya refunded. İdempotent → VOID |

#### Reconciliation (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `reconciliation_report_create` | Günlük reconciliation raporu oluştur/güncelle. game_rounds tablosundan aggregate hesaplar → BIGINT |
| `reconciliation_mismatch_upsert` | Round bazlı mismatch kaydı oluştur/güncelle → BIGINT |
| `reconciliation_report_list` | Raporları filtrele ve listele. Mismatch sayısı dahil, pagination destekli. STABLE → JSONB |

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
