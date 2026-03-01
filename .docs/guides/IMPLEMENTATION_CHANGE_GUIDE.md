# Faz 0-9 Uygulama Değişiklik Rehberi

IMPLEMENTATION_ORDER.md'deki 10 fazın (Player Segmentation, Game Gateway, Finance Gateway, Manuel Bonus Request, Call Center) tüm tablo, fonksiyon, permission ve seed değişikliklerinin backend entegrasyon rehberi.

> **Son güncelleme:** 2026-02-19. Tüm fazlar tamamlandı.
> **Referans:** [../../.planning/IMPLEMENTATION_ORDER.md](../../.planning/IMPLEMENTATION_ORDER.md)

---

## Uygulama Durumu

| Faz | Kapsam | Durum | Fonksiyon | Tablo | Not |
|-----|--------|-------|-----------|-------|-----|
| **0** | Player Segmentation | ✅ | 17 | 0 (modify 2) | Category/Group CRUD + Classification + Shadow Tester |
| **1** | Bonus Eligibility | ✅ | 1 | 0 | Player requestable bonus types |
| **2** | Game Gateway Core | ✅ | 16 | 1 | 3 session + 10 wallet + 3 round (client_log) |
| **3** | Game Gateway Extended | ✅ | 6 | 3 | 3 bonus mapping + 3 reconciliation |
| **4** | Finance Gateway Core | ✅ | 12 | 1 | 3 payment session + 4 deposit + 5 withdrawal |
| **5** | Finance Gateway Extended | ✅ | 19 | 3 | 9 workflow + 5 adjustment + 1 fee + 4 finance_log maintenance |
| **6** | Manuel Bonus Request | ✅ | 19 | 3 | 4 ayar + 10 BO + 2 maintenance + 3 oyuncu |
| **7** | Call Center: Foundation | ✅ | 15 | 13 | 11 client + 1 log + 1 report tablo, 11 BO + 4 oyuncu ticket |
| **8** | Call Center: Standard | ✅ | 18 | 0 | 4 note + 3 agent + 4 canned + 3 representative + 4 welcome call |
| **9** | Call Center: Integration | ✅ | 10 | 0 | 4 category + 3 tag + 2 dashboard + 1 maintenance |
| | **TOPLAM** | ✅ | **133** | **24 yeni + 3 modify** | |

---

## Özet

| Metrik | Değer |
|--------|-------|
| Yeni tablo | 24 (19 client + 2 client_log + 1 client_report + 2 finance_log) |
| Modify edilen tablo | 3 (bonus_awards, transaction_workflows + player_categories/groups yeni) |
| Yeni fonksiyon | 133 |
| Yeni permission | 24 (107 → 131) |
| Yeni transaction type | 11 (72 → 83) |
| Yeni error key | ~145 (3 dosya: keys + en + tr) |
| Yeni constraint dosyası | 3 (bonus_requests, support, finance_log) |
| Yeni index dosyası | 3 (bonus_requests, support, finance_log) |
| Etkilenen deploy script | 4 (client, client_log, client_report, finance_log) |

**Kırılma (breaking change): 0** — Tüm yeni kolonlar nullable/DEFAULT'lu, mevcut fonksiyonlar etkilenmez.

---

## 1. Yeni Tablolar

### 1.1 Client DB — Game Schema

| Tablo | Faz | Açıklama | Önemli Kolonlar |
|-------|-----|----------|-----------------|
| `game.game_sessions` | 2 | Oyun oturum takibi, provider token → player çözümleme | `session_token` UNIQUE, `player_id` FK, `provider_code`, `mode` (real/demo/fun), `status` (active/expired/closed), `metadata` JSONB, `expires_at` |

**Backend etkisi:** `GameSessionService` — Session token tabanlı provider callback çözümleme. Token üretimi ve süre yönetimi DB'de.

### 1.2 Client DB — Bonus Schema

| Tablo | Faz | Açıklama | Önemli Kolonlar |
|-------|-----|----------|-----------------|
| `bonus.provider_bonus_mappings` | 3 | Provider tarafı bonus takibi (free spin, freebet) | `bonus_award_id` FK, `provider_code`, `provider_bonus_type`, `provider_bonus_id`, `status`, `provider_data` JSONB |
| `bonus.bonus_request_settings` | 6 | Talep edilebilir bonus tipi ayarları | `bonus_type_code` (cross-DB), `display_name` JSONB, `rules_content` JSONB (HTML), `eligible_groups/categories` JSONB, `cooldown_*_days`, `default_usage_criteria` JSONB |
| `bonus.bonus_requests` | 6 | Oyuncu/operatör bonus talepleri | `player_id` FK, `request_source` (player/operator), `status` (10 durumlu), `priority`, `assigned_to_id`, `approved_amount`, `bonus_award_id`, `expires_at` |
| `bonus.bonus_request_actions` | 6 | Talep aksiyon geçmişi (immutable) | `request_id` FK, `action` (14 tip), `performed_by_type` (PLAYER/BO_USER/SYSTEM), `action_data` JSONB |

**Backend etkisi:**
- `ProviderBonusMappingService` — PP/Hub88 free spin callback'lerinde mapping oluşturma/güncelleme.
- `BonusRequestService` — 10 durumlu state machine. `bonus_request_approve` atomik olarak `bonus_awards` kaydı oluşturur.
- `BonusRequestSettingService` — Client admin panelinde bonus tipi yapılandırması. JSONB çoklu dil desteği.

### 1.3 Client DB — Transaction Schema

| Tablo | Faz | Açıklama | Önemli Kolonlar |
|-------|-----|----------|-----------------|
| `transaction.payment_sessions` | 4 | Ödeme oturum takibi (deposit/withdrawal) | `session_token` UNIQUE, `player_id` FK, `session_type` (DEPOSIT/WITHDRAWAL), `payment_method_id` FK, `amount/fee_amount/net_amount`, `status` (9 durumlu), `idempotency_key`, `provider_data` JSONB, `expires_at` |
| `transaction.transaction_adjustments` | 5 | Hesap düzeltme detayları (workflow onaylı) | `player_id` FK, `wallet_type` (REAL/BONUS), `direction` (CREDIT/DEBIT), `adjustment_type` (GAME_CORRECTION/BONUS_CORRECTION/FRAUD/MANUAL), `status` (PENDING/APPLIED/CANCELLED), `workflow_id` FK, `provider_id/game_id` (GGR için) |

**Backend etkisi:**
- `PaymentSessionService` — PSP entegrasyonu. `session_token` ile callback çözümleme. `idempotency_key` ile tekrar koruma.
- `AdjustmentService` — Workflow onayı gerektirir. `adjustment_create` → workflow → `adjustment_apply`. GAME_CORRECTION tipi GGR raporlamayı etkiler.

### 1.4 Client DB — Support Schema (Faz 7)

| Tablo | Açıklama | Önemli Kolonlar |
|-------|----------|-----------------|
| `support.ticket_categories` | Hiyerarşik ticket kategori ağacı | `parent_id` (self-ref), `code` UNIQUE, `name` JSONB (çoklu dil), `display_order` |
| `support.tickets` | Ana ticket tablosu | `player_id`, `category_id` FK, `channel` (phone/live_chat/email/social_media), `status` (8 durumlu), `priority` (0-3), `assigned_to_id`, `created_by_type` (PLAYER/BO_USER) |
| `support.ticket_actions` | Ticket aksiyon geçmişi (immutable) | `ticket_id` FK, `action` (17 tip), `performed_by_type`, `old_status/new_status`, `content` TEXT, `is_internal` BOOLEAN |
| `support.ticket_tags` | Ticket etiketleri | `name` UNIQUE (aktif), `color` VARCHAR(7) HEX |
| `support.ticket_tag_assignments` | Ticket ↔ tag M:N | `ticket_id` FK, `tag_id` FK, UNIQUE(ticket_id, tag_id) |
| `support.ticket_activity_log_outbox` | Outbox: aktivite log olayları | Transactional outbox → client_log'a aktarılır |
| `support.player_notes` | Operatör oyuncu notları (CRM) | `player_id`, `note_type` (general/warning/vip/compliance), `content`, `is_pinned`, `is_active` (soft delete) |
| `support.agent_settings` | Operatör destek ayarları | `user_id` UNIQUE, `is_available`, `max_concurrent_tickets`, `skills` JSONB |
| `support.canned_responses` | Hazır yanıt şablonları | `category_id` FK (opsiyonel), `title`, `content`, `is_active` |
| `support.player_representatives` | Oyuncu ↔ temsilci ataması | `player_id` UNIQUE (1:1), `representative_id` |
| `support.player_representative_history` | Temsilci değişiklik geçmişi (immutable) | `player_id`, `old/new_representative_id`, `change_reason` |
| `support.welcome_call_tasks` | Hoşgeldin araması görevleri | `player_id` (UNIQUE aktif), `status` (7 durumlu), `assigned_to_id`, `call_result`, `attempt_count/max_attempts`, `next_attempt_at` |

**Backend etkisi:**
- `TicketService` — 8 durumlu state machine. Ticket plugin `ticket_plugin_enabled` client ayarıyla gating yapılır. Oyuncu ticket'ları `player_ticket_*` fonksiyonlarıyla (anti-abuse dahil).
- `PlayerNoteService` — Ticket'tan bağımsız CRM notları. Soft delete.
- `AgentSettingService` — Agent availability ve kapasite yönetimi. Skills JSONB ile beceri bazlı routing.
- `RepresentativeService` — 1:1 oyuncu-temsilci ataması. Her değişiklik history'ye yazılır.
- `WelcomeCallService` — Oyuncu kayıtta otomatik task oluşturma (backend trigger). Kuyruk yönetimi.
- `CannedResponseService` — Kategori bazlı hazır yanıt şablonları.

### 1.5 Client Log DB

| Tablo | Faz | Şema | Partition | Retention | Açıklama |
|-------|-----|------|-----------|-----------|----------|
| `game_log.reconciliation_reports` | 3 | game_log | — | 30 gün | Günlük provider reconciliation raporları. `status`: pending/matched/mismatched/resolved |
| `game_log.reconciliation_mismatches` | 3 | game_log | — | 30 gün | Round bazlı mismatch kayıtları. `report_id` FK |
| `support_log.ticket_activity_logs` | 7 | support_log | **Daily** | 90 gün | Ticket bildirim logları (email/sms/push/internal) |

### 1.6 Client Report DB

| Tablo | Faz | Şema | Partition | Retention | Açıklama |
|-------|-----|------|-----------|-----------|----------|
| `support_report.ticket_daily_stats` | 7 | support_report | **Monthly** | Sınırsız | Günlük ticket istatistikleri (kategori/kanal/temsilci bazlı) |

### 1.7 Finance Log DB (Yeni DB)

| Tablo | Faz | Şema | Partition | Retention | Açıklama |
|-------|-----|------|-----------|-----------|----------|
| `finance_log.provider_api_requests` | 5 | finance_log | **Daily** | 14 gün | PSP'ye yapılan API çağrı logları (deposit/withdrawal/refund/status_check) |
| `finance_log.provider_api_callbacks` | 5 | finance_log | **Daily** | 14 gün | PSP'den gelen callback/webhook logları (signature doğrulama dahil) |

---

## 2. Değiştirilen Tablolar

| Tablo | DB | Faz | Değişiklik |
|-------|-----|-----|-----------|
| `bonus.bonus_awards` | Client | 6 | ADD `bonus_request_id BIGINT` — Manuel bonus talebiyle oluşturulan award'ları izlemek için |
| `transaction.transaction_workflows` | Client | 5 | `transaction_id` artık NULL olabilir (ADJUSTMENT workflow'ları için, tx apply sonrası dolar). `workflow_type`'a ADJUSTMENT eklendi |
| `auth.player_categories` | Client | 0 | YENİ tablo (`player_auth/` klasöründe). `category_code` UNIQUE, `level` INT (hiyerarşi) |
| `auth.player_groups` | Client | 0 | YENİ tablo (`player_auth/` klasöründe). `group_code` UNIQUE, `level` INT (hiyerarşi) |

> **Not:** player_categories ve player_groups tabloları `client/tables/player_auth/` klasöründe oluşturuldu. Mevcut `auth.players` tablosuna `category_id` ve `player_groups` M:N ilişkisi eklenmedi — segmentation `player_classification_*` fonksiyonlarıyla yönetilir.

---

## 3. Yeni Fonksiyonlar

### 3.1 Faz 0 — Player Segmentation (17 fonksiyon)

**Schema: auth** | **Backend Service: `PlayerSegmentationService`**

#### Category CRUD (5)

| Fonksiyon | Parametreler | Return | Açıklama |
|-----------|-------------|--------|----------|
| `player_category_create` | code, name, level, description | BIGINT | Yeni kategori oluştur (code uppercase normalize) |
| `player_category_update` | id, name, level, description, is_active | VOID | Partial update (COALESCE pattern) |
| `player_category_delete` | id | VOID | Soft delete (is_active=false) |
| `player_category_get` | id | JSONB | Detay + aktif oyuncu sayısı |
| `player_category_list` | is_active filter | JSONB | Level sıralı liste + oyuncu sayıları |

#### Group CRUD (5)

| Fonksiyon | Parametreler | Return | Açıklama |
|-----------|-------------|--------|----------|
| `player_group_create` | code, name, level, description | BIGINT | Yeni grup oluştur (code uppercase normalize) |
| `player_group_update` | id, name, level, description, is_active | VOID | Partial update |
| `player_group_delete` | id | VOID | Soft delete |
| `player_group_get` | id | JSONB | Detay + aktif oyuncu sayısı |
| `player_group_list` | is_active filter | JSONB | Level sıralı liste |

#### Classification (5)

| Fonksiyon | Parametreler | Return | Açıklama |
|-----------|-------------|--------|----------|
| `player_classification_assign` | player_id, category_id, group_id | VOID | Kategori (upsert, tekil) + Grup (additive, idempotent) |
| `player_classification_bulk_assign` | player_ids[], category_id, group_id | INT | Toplu atama, etkilenen satır sayısı döner |
| `player_classification_list` | player_id | JSONB | Oyuncunun kategori (tekil/null) + grup dizisi |
| `player_classification_remove` | player_id, category_id, group_id | VOID | Kategori NULL'a çek veya gruptan çıkar |
| `player_get_segmentation` | player_id | JSONB | Bonus eligibility değerlendirmesi için tek giriş noktası |

#### Shadow Tester (2)

| Fonksiyon | Parametreler | Return | Açıklama |
|-----------|-------------|--------|----------|
| `shadow_tester_get` | player_id | JSONB | Shadow tester detayı |
| `shadow_tester_list` | — | JSONB | Tüm shadow tester'lar (username dahil) |

**Backend entegrasyonu:**
- `PlayerSegmentationService.AssignAsync(playerId, categoryId, groupId)` — `player_classification_assign` çağırır
- `PlayerSegmentationService.GetSegmentationAsync(playerId)` — Bonus Worker'dan çağrılır, eligibility verisi döner
- Category/Group CRUD → Admin panel endpoint'leri

---

### 3.2 Faz 1 — Bonus Eligibility (1 fonksiyon)

**Schema: bonus** | **Backend Service: `BonusRequestService`**

| Fonksiyon | Parametreler | Return | Açıklama |
|-----------|-------------|--------|----------|
| `player_requestable_bonus_types` | player_id, language | JSONB | Oyuncunun talep edebileceği bonus tiplerini döner (eligibility + cooldown kontrolü) |

**Backend entegrasyonu:**
- Oyuncu bonus talep sayfasında liste olarak gösterilir
- `eligible_groups/categories` OR mantığıyla kontrol edilir (herhangi birinde olması yeterli)
- Cooldown: Son approved/rejected tarihine göre `cooldown_after_*_days` hesaplanır

---

### 3.3 Faz 2 — Game Gateway Core (16 fonksiyon)

**Schema: game** | **Backend Service: `GameSessionService`**

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `game_session_create` | JSONB | Oyun oturumu oluştur, session_token üret. Provider launch URL'e token eklenir |
| `game_session_validate` | JSONB | Token doğrula + player_id çözümle. Provider callback'lerinde kullanılır. Auto-expire |
| `game_session_end` | BOOLEAN | Oturumu kapat. Idempotent |

**Schema: wallet** | **Backend Service: `WalletService` / `GameCallbackService`**

| Fonksiyon | Return | Açıklama | İşlem Tipi |
|-----------|--------|----------|------------|
| `player_balance_get` | JSONB | REAL + BONUS bakiye | Read-only |
| `player_balance_per_game_get` | JSONB | PP getBalancePerGame endpoint'i için | Read-only |
| `player_info_get` | JSONB | Provider user info endpoint'i için | Read-only |
| `bet_process` | JSONB | Bahis: REAL cüzdan debit | `FOR UPDATE` lock, idempotent |
| `win_process` | JSONB | Kazanç: REAL cüzdan credit | 0-amount destekler (loss round) |
| `rollback_process` | JSONB | Bahis iptali: credit veya debit | Original bulunamazsa da başarılı |
| `bonus_win_process` | JSONB | Free spin kazancı (tx_type=72) | `win_process` wrapper |
| `promo_win_process` | JSONB | Promo/turnuva kazancı (tx_type=71) | `win_process` wrapper |
| `jackpot_win_process` | JSONB | Jackpot kazancı (tx_type=70) | `win_process` wrapper |
| `adjustment_process` | JSONB | Provider düzeltmesi (tx_type=26) | Pozitif=credit, negatif=debit |

**Backend entegrasyonu:**
- **PP Seamless Wallet:** `authenticate` → `game_session_validate`, `getBalance` → `player_balance_get`, `bet` → `bet_process`, `result` → `win_process`, `refund` → `rollback_process`
- **Hub88:** Aynı wallet fonksiyonları, farklı endpoint mapping
- Tüm wallet fonksiyonları `idempotency_key` ile idempotent
- `FOR UPDATE` row lock ile concurrency güvenli

**Schema: game_log (client_log)** | **Backend Service: `GameRoundService`**

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `round_upsert` | JSONB | Round oluştur/güncelle (kümülatif bet/win). UPDATE-first pattern |
| `round_close` | BOOLEAN | PP endRound callback. Idempotent |
| `round_cancel` | BOOLEAN | Round iptal/refund. Idempotent |

---

### 3.4 Faz 3 — Game Gateway Extended (6 fonksiyon)

**Schema: bonus** | **Backend Service: `ProviderBonusMappingService`**

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `provider_bonus_mapping_create` | BIGINT | Provider tarafı bonus eşleştirmesi oluştur (PP free spin vb.) |
| `provider_bonus_mapping_get` | JSONB | Provider code + bonus ID ile mapping bul |
| `provider_bonus_mapping_update_status` | VOID | Mapping durumu güncelle (active→completed/cancelled/expired) |

**Schema: game_log (client_log)** | **Backend Service: `ReconciliationService`**

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `reconciliation_report_create` | BIGINT | Günlük reconciliation raporu oluştur |
| `reconciliation_report_list` | JSONB | Raporları listele (filtreleme + pagination) |
| `reconciliation_mismatch_upsert` | VOID | Mismatch kaydı oluştur/güncelle |

---

### 3.5 Faz 4 — Finance Gateway Core (12 fonksiyon)

**Schema: wallet** | **Backend Service: `DepositService` / `WithdrawalService`**

#### Deposit (4)

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `deposit_initiate` | JSONB | PENDING transaction oluştur. Cüzdan DEĞİŞMEZ. `idempotency_key` ile idempotent |
| `deposit_confirm` | JSONB | Pending deposit'i onayla, cüzdanı creditle. Idempotent (tekrar çağrıda cached sonuç) |
| `deposit_fail` | BOOLEAN | Pending deposit'i başarısız yap. Cüzdan değişmez |
| `deposit_manual_process` | JSONB | Tek adımda manuel deposit (PSP gerektirmez) |

#### Withdrawal (5)

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `withdrawal_initiate` | JSONB | Cüzdanı HEMEN debit et (double-spend önleme). PENDING transaction. Bonus wagering kontrolü |
| `withdrawal_confirm` | BOOLEAN | Pending withdrawal'ı onayla. Cüzdan zaten debit edilmiş |
| `withdrawal_fail` | JSONB | PSP reddi: reversal transaction ile cüzdana geri yatır |
| `withdrawal_cancel` | JSONB | İptal: reversal transaction ile cüzdana geri yatır |
| `withdrawal_manual_process` | JSONB | Tek adımda manuel withdrawal |

**Schema: transaction** | **Backend Service: `PaymentSessionService`**

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `payment_session_create` | JSONB | Ödeme oturumu oluştur (deposit veya withdrawal). Token + TTL |
| `payment_session_get` | JSONB | Token ile oturum bul. Auto-expire |
| `payment_session_update` | VOID | Oturum durumu güncelle (COALESCE partial update) |

**Backend entegrasyonu:**
```
Deposit akışı:
  1. payment_session_create(DEPOSIT) → session_token
  2. PSP redirect → oyuncu ödeme yapar
  3. PSP callback → payment_session_get(token) ile player çözümle
  4. deposit_initiate(player_id, ..., idempotency_key) → PENDING tx
  5. deposit_confirm(idempotency_key) → cüzdan credit
  6. payment_session_update(token, 'completed')

Withdrawal akışı:
  1. withdrawal_initiate(player_id, ...) → cüzdan HEMEN debit, PENDING tx
  2. workflow_create(tx_id, 'WITHDRAWAL') → onay akışı (büyük tutarlar)
  3. workflow_approve → withdrawal_confirm(idempotency_key)
  4. VEYA workflow_reject → withdrawal_cancel(idempotency_key) → cüzdan geri
```

---

### 3.6 Faz 5 — Finance Gateway Extended (19 fonksiyon)

**Schema: finance** | **Backend Service: `FeeService`**

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `calculate_fee` | JSONB | Ödeme yöntemi fee hesapla: `MAX(min, MIN(max, amount * percent + fixed))` |

**Schema: transaction** | **Backend Service: `WorkflowService`**

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `workflow_create` | BIGINT | Onay akışı oluştur (WITHDRAWAL/HIGH_VALUE/SUSPICIOUS/ADJUSTMENT/KYC_REQUIRED) |
| `workflow_get` | JSONB | Workflow detayı + aksiyon geçmişi + bağlı transaction |
| `workflow_list` | JSONB | Filtreleme + pagination (status, type, assignee) |
| `workflow_assign` | VOID | BO kullanıcıya ata (PENDING/IN_REVIEW → IN_REVIEW) |
| `workflow_add_note` | VOID | Durum değiştirmeden not ekle |
| `workflow_approve` | VOID | Onayla (IN_REVIEW → APPROVED). Backend follow-up action gerektirir |
| `workflow_reject` | VOID | Reddet (IN_REVIEW → REJECTED). Zorunlu reason |
| `workflow_cancel` | VOID | İptal (PENDING → CANCELLED). IN_REVIEW iptal edilemez |
| `workflow_escalate` | VOID | Başka BO kullanıcıya eskalasyon (assigned_to değişir) |

**Schema: transaction** | **Backend Service: `AdjustmentService`**

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `adjustment_create` | BIGINT | Pending düzeltme oluştur. Cüzdan DEĞİŞMEZ. GAME_CORRECTION → provider_id zorunlu |
| `adjustment_apply` | VOID | Düzeltmeyi uygula: transaction oluştur + cüzdan güncelle (tx_type=95/96) |
| `adjustment_cancel` | VOID | Düzeltmeyi iptal et (workflow reject sonrası) |
| `adjustment_get` | JSONB | Düzeltme detayı + bağlı workflow durumu |
| `adjustment_list` | JSONB | Filtreleme + pagination |

**Backend entegrasyonu:**
```
Adjustment akışı:
  1. adjustment_create(player_id, GAME_CORRECTION, CREDIT, 100, ...) → adj_id
  2. workflow_create(NULL, 'ADJUSTMENT', ...) → workflow_id
  3. BO operatör: workflow_approve(workflow_id, user_id)
  4. Backend: adjustment_apply(adj_id, user_id) → tx oluşur, cüzdan güncellenir

Workflow approve sonrası backend sorumlulukları:
  - WITHDRAWAL → withdrawal_confirm(idempotency_key)
  - ADJUSTMENT → adjustment_apply(adj_id, approver_id)
  - HIGH_VALUE/SUSPICIOUS → withdrawal_confirm(idempotency_key)
  - KYC_REQUIRED → KYC sürecini başlat
```

**Schema: finance_log (maintenance)** — 4 fonksiyon: `create_partitions`, `drop_expired_partitions`, `partition_info`, `run_maintenance`

---

### 3.7 Faz 6 — Manuel Bonus Request (19 fonksiyon)

**Schema: bonus** | **Backend Service: `BonusRequestService`**

#### Settings (3)

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `bonus_request_setting_upsert` | VOID | Bonus tipi ayarı oluştur/güncelle (JSONB: display_name, rules_content, eligible_groups/categories, usage_criteria) |
| `bonus_request_setting_get` | JSONB | Tek bonus tipi ayarını getir |
| `bonus_request_setting_list` | JSONB | Tüm aktif ayarları listele |

#### BO Operations (10)

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `bonus_request_create` | BIGINT | BO operatör bonus talebi oluştur (amount+currency zorunlu) |
| `bonus_request_get` | JSONB | Talep detayı + tam aksiyon geçmişi |
| `bonus_request_list` | JSONB | Filtreleme + pagination (status, source, player, assignee, type, priority) |
| `bonus_request_assign` | VOID | Operatöre ata (pending/assigned → assigned) |
| `bonus_request_start_review` | VOID | İncelemeye al (in_progress). REVIEW_STARTED/RESUMED aksiyon |
| `bonus_request_hold` | VOID | Beklemeye al (on_hold). Zorunlu reason |
| `bonus_request_approve` | BIGINT | Onayla + atomik bonus_award oluştur. `bonus_award_id` döner |
| `bonus_request_reject` | VOID | Reddet. Zorunlu review_note |
| `bonus_request_cancel` | VOID | İptal (pending/assigned). Oyuncu veya BO |
| `bonus_request_rollback` | VOID | Geri al (completed→in_progress). Award iptal + cüzdan geri |

#### Player Operations (3)

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `player_bonus_request_create` | BIGINT | Oyuncu talebi: eligibility + cooldown + pending limit kontrolü |
| `player_bonus_request_cancel` | VOID | Oyuncu kendi pending talebini iptal eder |
| `player_bonus_request_list` | JSONB | Oyuncu kendi taleplerini listeler (BO alanları gizli) |

#### Maintenance (2)

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `bonus_request_expire` | INT | Süresi dolmuş talepleri expire et (batch) |
| `bonus_request_cleanup` | INT | Eski completed/cancelled/rejected kayıtları temizle |

**Backend entegrasyonu:**
- **State machine (10 durum):** pending → assigned → in_progress → approved → completed (veya on_hold, rejected, cancelled, expired, failed)
- `bonus_request_approve` atomik: award oluşturur, cüzdanı güncellemez (Bonus Worker yapar)
- `bonus_request_rollback` atomik: award'ı iptal eder + cüzdan bakiyesini geri alır
- Player tarafı: `player_bonus_request_create` tüm eligibility kontrollerini yapar (grup/kategori/cooldown/pending limit)

---

### 3.8 Faz 7-9 — Call Center (43 fonksiyon)

**Schema: support** | **Detaylı dokümantasyon:** [CALL_CENTER_GUIDE.md](CALL_CENTER_GUIDE.md)

#### Ticket BO (11) — `TicketService`

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `ticket_create` | BIGINT | BO kullanıcı ticket oluşturur (anti-abuse yok) |
| `ticket_get` | JSONB | Tam detay + kategori + tag'ler + aksiyon geçmişi (internal notlar dahil) |
| `ticket_list` | JSONB | Filtreleme: status, channel, priority, category, assignee, player, tarih aralığı, text search |
| `ticket_update` | VOID | Priority ve/veya category güncelle |
| `ticket_assign` | VOID | Agent'a ata/yeniden ata |
| `ticket_add_note` | BIGINT | Internal veya external not ekle |
| `ticket_resolve` | VOID | Çözüldü olarak işaretle |
| `ticket_close` | VOID | Kapat (resolved → closed) |
| `ticket_reopen` | VOID | Yeniden aç (resolved/closed → reopened) |
| `ticket_cancel` | VOID | İptal et (herhangi durum → cancelled, closed hariç) |
| `ticket_reply_player` | BIGINT | Oyuncuya yanıt gönder |

#### Ticket Player (4) — `PlayerTicketService`

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `player_ticket_create` | BIGINT | Oyuncu ticket oluşturur (anti-abuse: max açık ticket + cooldown, backend client_settings'ten geçer) |
| `player_ticket_get` | JSONB | Oyuncu kendi ticket'ı (internal notlar filtrelenir) |
| `player_ticket_list` | JSONB | Oyuncu kendi ticket listesi + okunmamış göstergesi |
| `player_ticket_reply` | BIGINT | Oyuncu yanıtı |

#### Ticket Config (7) — `TicketConfigService`

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `ticket_category_create` | BIGINT | Hiyerarşik kategori oluştur (JSONB çoklu dil name) |
| `ticket_category_update` | VOID | Kategori güncelle (partial) |
| `ticket_category_delete` | VOID | Soft delete (aktif alt kategori varsa hata) |
| `ticket_category_list` | JSONB | Hiyerarşik ağaç (recursive CTE, dil parametreli) |
| `ticket_tag_create` | BIGINT | Etiket oluştur (HEX renk doğrulama) |
| `ticket_tag_update` | VOID | Etiket güncelle (name ve/veya color) |
| `ticket_tag_list` | JSONB | Aktif etiketler + kullanım sayısı |

#### Player Notes (4) — `PlayerNoteService`

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `player_note_create` | BIGINT | CRM notu oluştur (general/warning/vip/compliance) |
| `player_note_update` | VOID | Not güncelle (partial) |
| `player_note_list` | JSONB | Oyuncu notları (pinned önce, tip filtresi) |
| `player_note_delete` | VOID | Soft delete |

#### Agent Settings (3) — `AgentSettingService`

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `agent_setting_upsert` | VOID | Agent ayarı oluştur/güncelle (upsert on user_id) |
| `agent_setting_get` | JSONB | Agent ayarını getir (NULL yoksa) |
| `agent_setting_list` | JSONB | Tüm agent'lar + mevcut ticket yükü. Availability filtresi |

#### Canned Responses (4) — `CannedResponseService`

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `canned_response_create` | BIGINT | Hazır yanıt oluştur (opsiyonel kategori bağlantısı) |
| `canned_response_update` | VOID | Güncelle (partial) |
| `canned_response_delete` | VOID | Soft delete |
| `canned_response_list` | JSONB | Filtreleme: kategori + text search + pagination |

#### Representative (3) — `RepresentativeService`

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `player_representative_assign` | VOID | Temsilci ata/değiştir (history'ye yazılır, zorunlu reason) |
| `player_representative_get` | JSONB | Mevcut temsilci ataması |
| `player_representative_history_list` | JSONB | Atama geçmişi (en yeni önce) |

#### Welcome Call (4) — `WelcomeCallService`

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `welcome_call_task_assign` | VOID | Pending/rescheduled task'ı agent'a ata |
| `welcome_call_task_complete` | VOID | Aramayı tamamla (answered/declined→completed, wrong_number→failed) |
| `welcome_call_task_list` | JSONB | Kuyruk: pending (tarih sıralı), rescheduled (next_attempt sıralı) |
| `welcome_call_task_reschedule` | VOID | Yeni zamana ertele |

#### Dashboard (2) — `SupportDashboardService`

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `ticket_queue_list` | JSONB | Atanmamış ticket'lar (open/reopened), priority DESC sıralı |
| `ticket_dashboard_stats` | JSONB | İstatistikler: byStatus, byPriority, byChannel, welcomeCalls, unassignedCount, avgResolutionMinutes |

#### Maintenance (1)

| Fonksiyon | Return | Açıklama |
|-----------|--------|----------|
| `welcome_call_task_cleanup` | INT | Completed/failed task'ları temizle (retention + batch + SKIP LOCKED) |

---

## 4. Permission Değişiklikleri (107 → 131)

### 4.1 Yeni Permission'lar (24)

#### CLIENT.SEGMENTATION (3) — Faz 0

| Permission Code | Açıklama |
|----------------|----------|
| `client.player-category.manage` | Oyuncu VIP kategorileri CRUD |
| `client.player-group.manage` | Oyuncu davranış grupları CRUD |
| `client.player-classification.manage` | Oyuncu kategori/grup ataması |

#### CLIENT.BONUS-REQUEST (6) — Faz 6

| Permission Code | Açıklama |
|----------------|----------|
| `client.bonus-request.list` | Bonus taleplerini listele |
| `client.bonus-request.view` | Bonus talep detayı ve aksiyon geçmişi |
| `client.bonus-request.create` | Manuel bonus talebi oluştur |
| `client.bonus-request.review` | Bonus talebini onayla/reddet |
| `client.bonus-request.assign` | Bonus talebini operatöre ata |
| `client.bonus-request-settings.manage` | Talep edilebilir bonus tipi yapılandırması |

#### CLIENT.SUPPORT (15) — Faz 9

| Permission Code | Açıklama |
|----------------|----------|
| `client.support-ticket.list` | Ticket listesi |
| `client.support-ticket.view` | Ticket detayı |
| `client.support-ticket.create` | Ticket oluştur |
| `client.support-ticket.assign` | Ticket'ı agent'a ata |
| `client.support-ticket.manage` | Ticket yönetimi (resolve/close/reopen/cancel) |
| `client.support-player-note.list` | Oyuncu notları listesi |
| `client.support-player-note.manage` | Oyuncu notu CRUD |
| `client.support-representative.view` | Temsilci atamalarını görüntüle |
| `client.support-representative.manage` | Temsilci ata/değiştir |
| `client.support-agent.manage` | Agent ayarları yönetimi |
| `client.support-category.manage` | Ticket kategorileri CRUD |
| `client.support-tag.manage` | Ticket etiketleri CRUD |
| `client.support-canned-response.manage` | Hazır yanıt CRUD |
| `client.support-dashboard.view` | Dashboard istatistikleri |
| `client.support-welcome-call.manage` | Hoşgeldin araması yönetimi |

### 4.2 Rol Dağılımı

| Rol | Eski | Yeni | Eklenen | Segmentation | Bonus Request | Support |
|-----|------|------|---------|-------------|---------------|---------|
| **admin** | 66 | 90 | +24 | 3 | 6 | 15 |
| **companyadmin** | 31 | 52 | +21 | — | 6 | 15 |
| **clientadmin** | 25 | 49 | +24 | 3 | 6 | 15 |
| **moderator** | 15 | 30 | +15 | 1 (classification) | 4 (list/view/create/assign) | 10 (config hariç) |
| **operator** | 13 | 23 | +10 | — | 3 (list/view/create) | 7 (assign/manage/config hariç) |
| **editor** | 14 | 14 | — | — | — | — |

**Backend etkisi:** `[Authorize(Permission = "client.support-ticket.list")]` gibi attribute'lar eklenmelidir. Mevcut `user_assert_access_client` IDOR kontrolü değişmedi.

---

## 5. Transaction Type Değişiklikleri (72 → 83)

### 5.1 Yeni Transaction Type'lar (11)

| ID | Code | Açıklama | Kategori |
|----|------|----------|----------|
| 80 | `deposit.provider` | PSP deposit | Finance |
| 81 | `deposit.manual` | Manuel deposit | Finance |
| 82 | `deposit.crypto` | Kripto deposit | Finance |
| 85 | `withdrawal.provider` | PSP withdrawal | Finance |
| 86 | `withdrawal.manual` | Manuel withdrawal | Finance |
| 87 | `withdrawal.crypto` | Kripto withdrawal | Finance |
| 90 | `deposit.chargeback` | Deposit chargeback | Finance |
| 91 | `withdrawal.reversal` | Withdrawal reversal (fail/cancel sonrası) | Finance |
| 95 | `adjustment.credit` | Hesap düzeltme credit | Adjustment |
| 96 | `adjustment.debit` | Hesap düzeltme debit | Adjustment |

> Tümü `is_audit_relevant = true`.

**Backend etkisi:** `TransactionTypeEnum` veya sabit dosyaya eklenmeli. Wallet fonksiyonları ilgili type ID'yi otomatik kullanır.

---

## 6. Localization Değişiklikleri (~145 error key)

### 6.1 Domain Bazlı Dağılım

| Domain | Adet | Faz |
|--------|------|-----|
| `error.player-category` | 5 | 0 |
| `error.player-group` | 5 | 0 |
| `error.player-classification` | 4 | 0 |
| `error.shadow-tester` | 1 | 0 |
| `error.game` | 3 | 2 |
| `error.wallet` | 6 | 2 |
| `error.bonus-mapping` | 5 | 3 |
| `error.reconciliation` | 2 | 3 |
| `error.deposit` | 8 | 4 |
| `error.withdrawal` | 4 | 4 |
| `error.finance` | 5 | 4 |
| `error.calculate-fee` | 2 | 5 |
| `error.workflow` | 5 | 5 |
| `error.adjustment` | 7 | 5 |
| `error.bonus-request` | 17 | 6 |
| `error.bonus-request-settings` | 7 | 6 |
| `error.support` | 47 | 7-9 |
| **TOPLAM** | **~145** | |

### 6.2 Dosyalar

| Dosya | İçerik |
|-------|--------|
| `core/data/localization_keys.sql` | Key tanımları (domain, category, description — Türkçe) |
| `core/data/localization_values_en.sql` | İngilizce çeviriler |
| `core/data/localization_values_tr.sql` | Türkçe çeviriler (doğru Unicode: ş, ç, ğ, ı, ö, ü) |

**Backend etkisi:** Fonksiyonlar `RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.domain.key'` formatında hata fırlatır. Backend bu key'i localization tablosundan çeviriye dönüştürmelidir.

---

## 7. Constraint ve Index Değişiklikleri

### 7.1 Yeni Constraint Dosyaları

| Dosya | DB | İçerik |
|-------|-----|--------|
| `client/constraints/bonus_requests.sql` | Client | FK: request_actions→requests, awards→requests, requests→players |
| `client/constraints/support.sql` | Client | FK: ticket_actions→tickets, tag_assignments→tickets/tags, canned→categories, categories→self |
| `finance_log/constraints/finance_log.sql` | Finance Log | CHECK: status, api_method, response_time, http_status |

### 7.2 Güncellenen Constraint Dosyaları

| Dosya | Değişiklik |
|-------|-----------|
| `client/constraints/bonus.sql` | +FK: provider_bonus_mappings→bonus_awards |
| `client/constraints/game.sql` | +FK: game_sessions→players, CHECK: status, mode |
| `client/constraints/transaction.sql` | +FK: payment_sessions→players, payment_sessions→payment_method_settings, tx_adjustments→players, tx_adjustments→workflows. +CHECK: session_type, status, wallet_type, direction, adjustment_type |

### 7.3 Yeni Index Dosyaları

| Dosya | DB | İçerik |
|-------|-----|--------|
| `client/indexes/bonus_requests.sql` | Client | requests: player_id, status, assigned_to, expires_at. actions: request_id. settings: bonus_type_code |
| `client/indexes/support.sql` | Client | tickets: player_id, assigned_to, category, status, channel, priority, queue composite. actions: ticket_id. notes: player_id. agents: user_id. representatives: representative_id. welcome_calls: status, assigned_to, player_id |
| `finance_log/indexes/finance_log.sql` | Finance Log | requests: client, provider, player, session_token, error/slow filters. callbacks: client, provider, processing_status, session_token |

---

## 8. Deploy Script Değişiklikleri

### 8.1 Etkilenen Script'ler

| Script | Eklenen |
|--------|---------|
| `deploy_client.sql` | +19 tablo, +133 fonksiyon (7 maintenance), +3 constraint, +3 index dosyası |
| `deploy_client_log.sql` | +3 tablo, +6 fonksiyon (game_log), +1 constraint, +1 index |
| `deploy_client_report.sql` | +1 tablo (ticket_daily_stats) |
| `deploy_finance_log.sql` | +2 tablo, +4 maintenance fonksiyon, +1 constraint, +1 index |

### 8.2 Sıralama

Tüm deploy script'ler standart sırayı takip eder:
```
TABLES → VIEWS → FUNCTIONS → CONSTRAINTS → INDEXES → MAINTENANCE
```

---

## 9. Cross-DB İletişim Rehberi

### 9.1 Auth Pattern (Tüm Fazlar)

```
Tüm client fonksiyonları auth-agnostic:
  1. Frontend → Backend API (JWT token)
  2. Backend → Core DB: user_assert_access_client(caller_id, client_id)
  3. Backend → Client DB: iş fonksiyonu (player_id, parametreler)
```

### 9.2 Game Gateway (Faz 2-3)

```
Provider callback akışı:
  1. PP/Hub88 → Backend (session_token veya player_id)
  2. Backend → Client DB: game_session_validate(token) → player_id
  3. Backend → Client DB: bet_process / win_process / rollback_process
  4. Backend → Client Log DB: round_upsert / round_close
  5. Backend → Game Log DB: provider_api_request_log (game_log DB)
```

### 9.3 Finance Gateway (Faz 4-5)

```
PSP callback akışı:
  1. PSP → Backend (session_token)
  2. Backend → Client DB: payment_session_get(token) → player_id
  3. Backend → Client DB: deposit_confirm / withdrawal_confirm
  4. Backend → Finance Log DB: provider_api_callback_log
```

### 9.4 Bonus Request (Faz 6)

```
Approve akışı:
  1. BO → Backend: bonus_request_approve(request_id, ...)
  2. Backend → Client DB: bonus_request_approve → bonus_award oluşturur
  3. Backend → Bonus DB: bonus_award bilgisini Bonus Worker'a ilet
  4. Bonus Worker → Client DB: bonus_award durumunu güncelle (ayrı süreç)
```

### 9.5 Call Center (Faz 7-9)

```
Ticket plugin gating:
  1. Backend → Core DB: client_setting_get('ticket_plugin_enabled')
  2. Eğer enabled → Client DB: ticket_* fonksiyonları
  3. Eğer disabled → 403 Forbidden

Standard servisler (plugin gerektirmez):
  - player_note_*, agent_setting_*, representative_*, welcome_call_*
```

---

## 10. Backend Checklist

Backend entegrasyonu için yapılması gerekenler:

### Entity/Model Oluşturma
- [ ] `GameSession` entity (game.game_sessions)
- [ ] `PaymentSession` entity (transaction.payment_sessions)
- [ ] `TransactionAdjustment` entity (transaction.transaction_adjustments)
- [ ] `ProviderBonusMapping` entity (bonus.provider_bonus_mappings)
- [ ] `BonusRequest`, `BonusRequestAction`, `BonusRequestSetting` entity'leri
- [ ] `Ticket`, `TicketAction`, `TicketCategory`, `TicketTag` entity'leri
- [ ] `PlayerNote`, `AgentSetting`, `CannedResponse` entity'leri
- [ ] `PlayerRepresentative`, `WelcomeCallTask` entity'leri
- [ ] `PlayerCategory`, `PlayerGroup` entity'leri
- [ ] `ReconciliationReport`, `ReconciliationMismatch` entity'leri

### Service Layer
- [ ] `GameSessionService` — Token-based session management
- [ ] `GameCallbackService` (veya `WalletService`) — PP/Hub88 callback handler
- [ ] `PaymentSessionService` — PSP session management
- [ ] `DepositService` — Initiate/Confirm/Fail/Manual
- [ ] `WithdrawalService` — Initiate/Confirm/Fail/Cancel/Manual
- [ ] `WorkflowService` — Approval workflow management
- [ ] `AdjustmentService` — Account adjustments with workflow
- [ ] `FeeService` — Payment method fee calculation
- [ ] `BonusRequestService` — 10-state machine bonus requests
- [ ] `BonusRequestSettingService` — Requestable bonus configuration
- [ ] `PlayerSegmentationService` — Category/Group/Classification CRUD
- [ ] `TicketService` — 8-state machine ticket management
- [ ] `PlayerNoteService`, `AgentSettingService`, `CannedResponseService`
- [ ] `RepresentativeService`, `WelcomeCallService`
- [ ] `ReconciliationService` — Provider data reconciliation
- [ ] `ProviderBonusMappingService` — Free spin/freebet tracking

### Permission Tanımları
- [ ] 24 yeni permission → Authorization attribute'ları
- [ ] Rol-permission mapping → Role seeding

### Transaction Type Enum
- [ ] 11 yeni transaction type → `TransactionTypeEnum` veya sabit dosya

### Localization
- [ ] Error key → mesaj çevirisi middleware/interceptor

### Client Settings
- [ ] `ticket_plugin_enabled` — Call center plugin gating
- [ ] `max_open_tickets_per_player` — Anti-abuse
- [ ] `ticket_creation_cooldown_minutes` — Anti-abuse

---

## Referans

| Doküman | İçerik |
|---------|--------|
| [IMPLEMENTATION_ORDER.md](../../.planning/IMPLEMENTATION_ORDER.md) | 10 faz detaylı iş kalemleri |
| [CALL_CENTER_GUIDE.md](CALL_CENTER_GUIDE.md) | Call center entegrasyon rehberi |
| [GAME_GATEWAY_GUIDE.md](GAME_GATEWAY_GUIDE.md) | Game gateway entegrasyon rehberi |
| [FINANCE_GATEWAY_GUIDE.md](FINANCE_GATEWAY_GUIDE.md) | Finance gateway entegrasyon rehberi |
| [BONUS_ENGINE_GUIDE.md](BONUS_ENGINE_GUIDE.md) | Bonus engine entegrasyon rehberi |
| [SHADOW_MODE_GUIDE.md](SHADOW_MODE_GUIDE.md) | Shadow mode rollout rehberi |
| [FUNCTIONS_CLIENT.md](../reference/FUNCTIONS_CLIENT.md) | Tüm client fonksiyon referansı (205 fonksiyon) |
| [DATABASE_ARCHITECTURE.md](../reference/DATABASE_ARCHITECTURE.md) | Veritabanı mimari dokümanı |
