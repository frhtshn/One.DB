# Uygulama Sıralaması

Dört mimari planın (GAME, FINANCE, PROVISIONING, bounded context migration) bağımlılık ve risk analizi bazlı uygulama sırası.

Referans dokümanlar:
- [GAME_ARCHITECTURE.md](GAME_ARCHITECTURE.md) + [GAME_ISSUE.md](GAME_ISSUE.md)
- [FINANCE_ARCHITECTURE.md](FINANCE_ARCHITECTURE.md) + [FINANCE_ISSUE.md](FINANCE_ISSUE.md)
- [PROVISIONING_ARCHITECTURE.md](PROVISIONING_ARCHITECTURE.md)
- [SHADOW_MODE_ARCHITECTURE.md](SHADOW_MODE_ARCHITECTURE.md) + [SHADOW_MODE_ISSUE.md](SHADOW_MODE_ISSUE.md)
- [SCHEMA_CHANGE_IMPACT.md](SCHEMA_CHANGE_IMPACT.md)

---

## Özet

```
Faz 0  ->  Bounded Context Altyapı + Tablo Değişiklikleri  — temel, hepsinden önce
Faz 1  ->  Mevcut fonksiyon güncellemeleri (7 fn)          — production uyumu
Faz 2  ->  Game (28 fn, shadow mode dahil)                  — en basit, pattern kurar
Faz 3  ->  Finance (28 fn, shadow mode dahil)               — Game pattern'ini takip eder
Faz 4  ->  Provisioning (14 fn)                             — harici bağımlılık, en son
```

Faz 0 + 1 birlikte yapılabilir (aynı deploy cycle).
Faz 2 ve 3 bağımsız ama Game önce yapılarak pattern oturur.
Faz 4 tamamen bağımsız, ProductionManager hazır olduğunda başlar.

---

## Faz 0: Bounded Context Altyapı + Tablo Değişiklikleri

**Neden ilk:** Zero-downtime, 0 kırılma. Domain DB'ler kendi catalog tablolarına sahip olur. Mevcut kod Faz 0 boyunca çalışmaya devam eder (Core'daki eski tablolar henüz kaldırılmadı).

### 0A. Game DB Altyapı (YENİ)

| Dosya | İşlem | Kaynak |
|-------|-------|--------|
| `game/tables/catalog/game_providers.sql` | **YENİ TABLO** — Core provider'ların GAME alt kümesi (aynı ID'ler) | GAME (1A) |
| `game/tables/catalog/games.sql` | **Core'dan TAŞINDI** + `supported_cryptocurrencies` eklendi | GAME (1B) |
| `game/tables/catalog/game_currency_limits.sql` | **YENİ TABLO** — per-game, per-currency limitler | GAME (1C) |
| `game/constraints/catalog.sql` | **YENİ** — FK + UQ (game_providers, games, game_currency_limits) | GAME (1G-a) |
| `game/indexes/catalog.sql` | **YENİ** — Core'daki game indexleri buraya taşındı | GAME (1G-a) |

### 0B. Finance DB Altyapı (YENİ)

| Dosya | İşlem | Kaynak |
|-------|-------|--------|
| `finance/tables/catalog/payment_providers.sql` | **YENİ TABLO** — Core provider'ların PAYMENT alt kümesi (aynı ID'ler) | FINANCE (1A) |
| `finance/tables/catalog/payment_methods.sql` | **Core'dan TAŞINDI** + `supported_cryptocurrencies` eklendi | FINANCE (1C) |
| `finance/tables/catalog/payment_method_currency_limits.sql` | **YENİ TABLO** — per-method, per-currency limitler + fee | FINANCE (1B) |
| `finance/constraints/catalog.sql` | **YENİ** — FK + UQ (payment_providers, payment_methods, payment_method_currency_limits) | FINANCE (1I-a) |
| `finance/indexes/catalog.sql` | **YENİ** — Core'daki payment_methods indexleri buraya taşındı | FINANCE (1I-a) |

### 0C. Core DB Temizlik

| Dosya | İşlem | Kaynak |
|-------|-------|--------|
| `core/tables/catalog/game/games.sql` | **SİL** (Game DB'ye taşındı) | GAME |
| `core/tables/catalog/payment/payment_methods.sql` | **SİL** (Finance DB'ye taşındı) | FINANCE |
| `core/tables/core/integration/tenant_games.sql` | **MODIFY** — +5 denormalize alan, FK kaldırıldı | GAME (1D) |
| `core/tables/core/integration/tenant_payment_methods.sql` | **MODIFY** — +5 denormalize alan, FK kaldırıldı | FINANCE (1D) |
| `core/tables/core/integration/tenant_provider_limits.sql` | **MODIFY** — decimal(18,2) -> decimal(18,8) | FINANCE (1E) |
| `core/constraints/catalog.sql` | **MODIFY** — games FK/UQ + payment_methods FK/UQ KALDIRILDI | GAME+FINANCE |
| `core/constraints/core.sql` | **MODIFY** — cross-DB FK'lar KALDIRILDI (tenant_games->games, tenant_payment_methods->payment_methods) | GAME+FINANCE |
| `core/indexes/catalog.sql` | **MODIFY** — 10 game index + 8 payment_methods index KALDIRILDI | GAME+FINANCE |

### 0D. Core DB Provisioning Kolonları

| Dosya | İşlem | Kaynak |
|-------|-------|--------|
| `core/tables/core/tenants.sql` | **MODIFY** — +7 kolon (domain, subdomain, provisioning_status, provisioning_step, provisioned_at, decommissioned_at, hosting_mode) | PROVISIONING (1A) |
| `core/tables/core/integration/tenant_providers.sql` | **MODIFY** — +`rollout_status` + CHECK constraint | SHADOW_MODE (1A) |

### 0E. Tenant DB Tablo Modify

| Dosya | İşlem | Kaynak |
|-------|-------|--------|
| `tenant/tables/game/game_limits.sql` | **MODIFY** — currency_code CHAR(3)->VARCHAR(20), +currency_type, +is_active | GAME (1E) |
| `tenant/tables/game/game_settings.sql` | **MODIFY** — +allowed_countries | GAME (1F) |
| `tenant/tables/finance/payment_method_limits.sql` | **MODIFY** — currency_code CHAR(3)->VARCHAR(20), +currency_type, +is_active | FINANCE (1F) |
| `tenant/tables/finance/payment_method_settings.sql` | **MODIFY** — +allowed_countries | FINANCE (1G) |
| `tenant/tables/finance/payment_player_limits.sql` | **MODIFY** — +currency_code, +currency_type, decimal(18,2)->(18,8), UQ güncelle | FINANCE (1H) |
| `tenant/tables/game/game_settings.sql` | **MODIFY** — +`rollout_status` | SHADOW_MODE (1C) |
| `tenant/tables/finance/payment_method_settings.sql` | **MODIFY** — +`rollout_status` | SHADOW_MODE (1D) |
| `tenant/tables/player_auth/shadow_testers.sql` | **YENİ TABLO** — Shadow mode test oyuncuları | SHADOW_MODE (1B) |

### 0F. Tenant DB Constraint/Index Güncellemeleri

| Dosya | İşlem | Kaynak |
|-------|-------|--------|
| `tenant/constraints/game.sql` | **MODIFY** — CHAR(3)->VARCHAR(20) uyumu | GAME (1G-c) |
| `tenant/indexes/game.sql` | **MODIFY** — cursor pagination: BTREE(display_order, id) | GAME (1G-c) |
| `tenant/constraints/finance.sql` | **MODIFY** — VARCHAR(20) uyumu, player_limits UQ güncelle | FINANCE (1I-c) |
| `tenant/indexes/finance.sql` | **MODIFY** — cursor pagination + currency_type indexleri | FINANCE (1I-c) |
| `tenant/constraints/auth.sql` | **MODIFY** — shadow_testers FK + UQ eklenmesi | SHADOW_MODE |
| `tenant/indexes/auth.sql` | (UNIQUE constraint otomatik index oluşturur) | SHADOW_MODE |

**Faz 0 toplam:** 5 yeni tablo + 2 taşınan tablo + 12 modify + constraint/index dosyaları = **~28 dosya**

---

## Faz 1: Mevcut Fonksiyon Güncellemeleri (7 fonksiyon)

**Neden ikinci:** Bu fonksiyonlar production'da çalışıyor. Yeni kolonları tanımalı, bounded context değişikliklerine uyum sağlamalıları lazım.

Detaylı güncelleme talimatları: [SCHEMA_CHANGE_IMPACT.md](SCHEMA_CHANGE_IMPACT.md)

### Öncelik 1 — Provisioning (zorunlu)

| # | Fonksiyon | Dosya | Güncelleme |
|---|----------|-------|-----------|
| 1 | `tenant_create` | `core/functions/core/tenants/tenant_create.sql` | +p_domain, +p_hosting_mode |
| 2 | `tenant_update` | `core/functions/core/tenants/tenant_update.sql` | +p_domain, +p_subdomain, +p_hosting_mode |
| 3 | `tenant_get` | `core/functions/core/tenants/tenant_get.sql` | +7 JSONB alan |
| 4 | `tenant_list` | `core/functions/core/tenants/tenant_list.sql` | +3 JSONB alan |
| 5 | `tenant_lookup` | `core/functions/core/tenants/tenant_lookup.sql` | +domain, +provisioning_status (opsiyonel) |

### Öncelik 2 — Cross-DB etki (zorunlu)

| # | Fonksiyon | Dosya | Güncelleme |
|---|----------|-------|-----------|
| 6 | `provider_delete` | `core/functions/catalog/providers/provider_delete.sql` | games + payment_methods EXISTS kontrolleri KALDIRILDI (cross-DB, backend'e taşınır) |

> **NOT:** 6 mevcut `payment_method_*` CRUD fonksiyonu artık burada GÜNCELLENMEZ. Faz 3'te (Finance) doğrudan Finance DB'ye taşınır.

### Öncelik 3 — Güvenlik (opsiyonel)

| # | Fonksiyon | Dosya | Güncelleme |
|---|----------|-------|-----------|
| 7 | `user_authenticate` | `core/functions/security/auth/user_authenticate.sql` | +provisioning_status filtresi |

---

## Faz 2: Game Fonksiyonları (23 fonksiyon)

**Neden üçüncü:**
- GAME_ISSUE.md zaten detaylı checklist hazır
- En basit pattern (2 seviye limit: catalog -> tenant)
- `tenant_provider_enable/disable` pattern'ini burada kurarız — Finance aynısını kullanacak
- Harici servis bağımlılığı yok (Gateway zaten mevcut)
- Finance'in "şablonu" olur

Detaylı plan: [GAME_ARCHITECTURE.md](GAME_ARCHITECTURE.md) + [GAME_ISSUE.md](GAME_ISSUE.md)

### Grup A0: Game DB — Provider Sync (1 fonksiyon)
`game/functions/catalog/`

| # | Fonksiyon | Açıklama |
|---|----------|---------|
| 0 | game_provider_sync | Core'dan GAME provider sync (TEXT->JSONB, UPSERT) |

### Grup A: Game DB — Catalog Game CRUD (7 fonksiyon)
`game/functions/catalog/`

| # | Fonksiyon | Açıklama |
|---|----------|---------|
| 1 | game_upsert | Tekil oyun upsert (feedback servisten) |
| 2 | game_bulk_upsert | Toplu oyun upsert (TEXT->JSONB) |
| 3 | game_update | BO metadata güncelleme (COALESCE) |
| 4 | game_get | Tekil oyun detay (JOIN game_providers) |
| 5 | game_list | Filtreli liste |
| 6 | game_lookup | Dropdown hafif liste |
| 7 | game_currency_limit_sync | Currency limit bulk upsert (soft delete) |

### Grup B: Core — Tenant Provider (4 fonksiyon)
`core/functions/core/tenant_providers/`

| # | Fonksiyon | Açıklama |
|---|----------|---------|
| 8 | tenant_provider_enable | Provider aç + oyunları seed et (p_game_data TEXT, +p_rollout_status) |
| 9 | tenant_provider_disable | Provider kapat (flag only, oyunlara dokunmaz) |
| 10 | tenant_provider_list | GAME provider listesi + gameCount + rolloutStatus (JSONB) |
| 10b | tenant_provider_set_rollout | Shadow/production geçişi (SHADOW_MODE YENİ) |

### Grup C: Core — Tenant Game (4 fonksiyon)
`core/functions/core/tenant_games/`

| # | Fonksiyon | Açıklama |
|---|----------|---------|
| 11 | tenant_game_upsert | Tekil oyun aç/düzenle (denorm alanlar) |
| 12 | tenant_game_list | Oyun listesi BO admin (denorm, cross-DB JOIN yok) |
| 13 | tenant_game_remove | Soft delete + disabled_reason |
| 14 | tenant_game_refresh | Yeni oyunları toplu seed et (p_game_data TEXT) |

### Grup D: Tenant — Sync (4 fonksiyon)
`tenant/functions/game/`

| # | Fonksiyon | Açıklama |
|---|----------|---------|
| 15 | game_settings_sync | Core->Tenant game data upsert (+p_rollout_status, tenant overrides korunur) |
| 16 | game_settings_remove | Soft delete |
| 17 | game_limits_sync | Core->Tenant currency limits (soft delete) |
| 17b | game_provider_rollout_sync | Provider rollout status toplu güncelle (SHADOW_MODE YENİ) |

### Grup E: Tenant — BO + Game Open (5 fonksiyon)
`tenant/functions/game/`

| # | Fonksiyon | Açıklama |
|---|----------|---------|
| 18 | game_settings_get | Tekil oyun detay (game open flow) |
| 19 | game_settings_update | Tenant customization (COALESCE) |
| 20 | game_settings_list | Lobi oyun listesi (cursor pagination, +shadow mode filtresi) |
| 21 | game_limit_upsert | Oyun limiti ekle/güncelle |
| 22 | game_limit_list | Oyun limit listesi |

### Grup F: Tenant — Shadow Tester CRUD (2 fonksiyon)
`tenant/functions/auth/`

| # | Fonksiyon | Açıklama |
|---|----------|---------|
| 23 | shadow_tester_add | Shadow tester ekle (idempotent, SHADOW_MODE YENİ) |
| 24 | shadow_tester_remove | Shadow tester çıkar (SHADOW_MODE YENİ) |

---

## Faz 3: Finance Fonksiyonları (26 fonksiyon)

**Neden dördüncü:**
- Game ile aynı mimari pattern ama 4 seviye limit (daha karmaşık)
- Game'de kurulan `tenant_provider_enable` pattern'ini takip eder
- 6 mevcut CRUD fonksiyonu Core'dan Finance DB'ye TAŞINIR (sadece provider JOIN değişir)
- Game tecrübesiyle daha hızlı yazılır

Detaylı plan: [FINANCE_ARCHITECTURE.md](FINANCE_ARCHITECTURE.md) + [FINANCE_ISSUE.md](FINANCE_ISSUE.md)

### Grup A0: Finance DB — Provider Sync (1 fonksiyon)
`finance/functions/catalog/`

| # | Fonksiyon | Açıklama |
|---|----------|---------|
| 0 | payment_provider_sync | Core'dan PAYMENT provider sync (TEXT->JSONB, UPSERT) |

### Grup A: Finance DB — Catalog Payment Method CRUD + Sync (7 fonksiyon)
`finance/functions/catalog/`

| # | Fonksiyon | Açıklama | Durum |
|---|----------|---------|-------|
| 1 | payment_method_create | Yeni metot oluştur (feedback servis) | **Core'dan TAŞINDI** + crypto |
| 2 | payment_method_update | Metot güncelle (COALESCE) | **Core'dan TAŞINDI** + crypto |
| 3 | payment_method_delete | Metot kapat (soft delete) | **Core'dan TAŞINDI** |
| 4 | payment_method_get | Tekil metot detay (JOIN payment_providers) | **Core'dan TAŞINDI** + crypto |
| 5 | payment_method_list | Filtreli liste | **Core'dan TAŞINDI** + crypto |
| 6 | payment_method_lookup | Dropdown hafif liste | **Core'dan TAŞINDI** |
| 7 | payment_method_currency_limit_sync | Currency limit bulk upsert (soft delete) | **YENİ** |

> **NOT:** #1-6 mevcut Core fonksiyonlarıdır. `catalog.providers` JOIN'ları `catalog.payment_providers` JOIN'larına dönüşür. `supported_cryptocurrencies` eklenir. Core deploy'dan kaldırılır.

### Grup B: Core — Tenant Payment Provider (3 fonksiyon)
`core/functions/core/tenant_payment_providers/`

| # | Fonksiyon | Açıklama |
|---|----------|---------|
| 8 | tenant_payment_provider_enable | Provider aç + metotları seed et (p_method_data TEXT) |
| 9 | tenant_payment_provider_disable | Provider kapat (flag only, metotlara dokunmaz) |
| 10 | tenant_payment_provider_list | PAYMENT provider listesi + methodCount (JSONB) |

### Grup C: Core — Tenant Payment Method (4 fonksiyon)
`core/functions/core/tenant_payment_methods/`

| # | Fonksiyon | Açıklama |
|---|----------|---------|
| 11 | tenant_payment_method_upsert | Tekil metot aç/düzenle (limit override, visibility) |
| 12 | tenant_payment_method_list | Metot listesi BO admin (denorm, cross-DB JOIN yok) |
| 13 | tenant_payment_method_remove | Soft delete + disabled_reason |
| 14 | tenant_payment_method_refresh | Yeni metotları toplu seed et (p_method_data TEXT) |

### Grup D: Tenant — Sync (4 fonksiyon)
`tenant/functions/finance/`

| # | Fonksiyon | Açıklama |
|---|----------|---------|
| 15 | payment_method_settings_sync | Core->Tenant method data upsert (+p_rollout_status, tenant overrides korunur) |
| 16 | payment_method_settings_remove | Soft delete |
| 17 | payment_method_limits_sync | Core->Tenant currency limits (soft delete) |
| 17b | payment_provider_rollout_sync | Provider rollout status toplu güncelle (SHADOW_MODE YENİ) |

### Grup E: Tenant — BO + Cashier (5 fonksiyon)
`tenant/functions/finance/`

| # | Fonksiyon | Açıklama |
|---|----------|---------|
| 18 | payment_method_settings_get | Tekil metot detay (cashier flow) |
| 19 | payment_method_settings_update | Tenant customization (COALESCE) |
| 20 | payment_method_settings_list | Cashier metot listesi (cursor pagination, +shadow mode filtresi) |
| 21 | payment_method_limit_upsert | Metot limiti ekle/güncelle |
| 22 | payment_method_limit_list | Metot limit listesi |

### Grup F: Tenant — Player Limitleri (3 fonksiyon)
`tenant/functions/finance/`

| # | Fonksiyon | Açıklama |
|---|----------|---------|
| 23 | payment_player_limit_set | Player limiti ekle/güncelle (self/admin/responsible_gaming) |
| 24 | payment_player_limit_get | Player metot+currency limiti (cashier limit kontrolü) |
| 25 | payment_player_limit_list | Player tüm limitleri |

---

## Faz 4: Provisioning Fonksiyonları (14 fonksiyon)

**Neden son:**
- ProductionManager gRPC servisi lazım (ayrı repo, ayrı proje)
- 11 adımlı orchestration — en karmaşık iş akışı
- Acil değil: tenant açma şu an manuel yapılabiliyor
- DB fonksiyonları hazır olsa bile ProductionManager olmadan çalışmaz

Detaylı plan: [PROVISIONING_ARCHITECTURE.md](PROVISIONING_ARCHITECTURE.md)

### Grup A: Server Yönetimi (4 fonksiyon)
`core/functions/core/tenant_servers/`

| # | Fonksiyon | Açıklama |
|---|----------|---------|
| 1 | tenant_server_create | Sunucu kaydı oluştur |
| 2 | tenant_server_update | Sunucu bilgisi güncelle |
| 3 | tenant_server_list | Sunucu listesi + kapasite |
| 4 | tenant_server_health_update | Sağlık durumu güncelle |

### Grup B: Template Yönetimi (3 fonksiyon)
`core/functions/core/tenant_templates/`

| # | Fonksiyon | Açıklama |
|---|----------|---------|
| 5 | tenant_template_register | Template kaydı |
| 6 | tenant_template_list | Template listesi |
| 7 | tenant_template_set_active | Aktif template belirle |

### Grup C: Provisioning Orchestration (4 fonksiyon)
`core/functions/core/provisioning/`

| # | Fonksiyon | Açıklama |
|---|----------|---------|
| 8 | tenant_provision_start | Provisioning başlat |
| 9 | tenant_provision_update_step | Adım ilerlet |
| 10 | tenant_provision_complete | Başarılı tamamla |
| 11 | tenant_provision_fail | Hata kaydet |

### Grup D: Decommission (3 fonksiyon)
`core/functions/core/provisioning/`

| # | Fonksiyon | Açıklama |
|---|----------|---------|
| 12 | tenant_decommission_start | Kapatma başlat |
| 13 | tenant_decommission_complete | Kapatma tamamla |
| 14 | tenant_provision_history_list | Provisioning geçmişi |

---

## Bağımlılık Grafiği

```
Faz 0 (Bounded Context Altyapı + Tablo Değişiklikleri + Shadow Mode tabloları)
  |
  +---> Faz 1 (Mevcut fn güncelleme: 7)
  |       |
  |       +---> Faz 2 (Game: 26 fn + shadow mode rollout/tester)
  |       |       |
  |       |       +---> Faz 3 (Finance: 27 fn + shadow mode rollout)  <-- Game pattern'ini kullanır
  |       |
  |       +---> Faz 4 (Provisioning: 14 fn)       <-- Bağımsız, ProductionManager gerekli
  |
  +---> (Mevcut kod çalışmaya devam eder)
```

**Toplam:** ~28 dosya (Faz 0) + 7 mevcut fn güncelleme + 70 yeni fonksiyon = **~105 iş kalemi**

### Fonksiyon Dağılımı

| Faz | Game DB | Finance DB | Core DB | Tenant DB | Toplam |
|-----|---------|-----------|---------|-----------|--------|
| 0 | 5 dosya | 5 dosya | 9 dosya | 9 dosya | ~28 dosya |
| 1 | — | — | 7 fn | — | 7 fn |
| 2 | 8 fn | — | 8 fn (+set_rollout) | 10 fn (+rollout_sync, +2 tester CRUD) | 26 fn |
| 3 | — | 8 fn | 7 fn | 12 fn (+rollout_sync) | 27 fn |
| 4 | — | — | 14 fn | — | 14 fn |
| **Toplam** | **8 fn** | **8 fn** | **36 fn** | **22 fn** | **74 fn** |

> Shadow mode etkisi: +1 Core fn, +2 rollout_sync fn, +2 tester CRUD fn, +6 modifikasyon. Detay: [SHADOW_MODE_ARCHITECTURE.md](SHADOW_MODE_ARCHITECTURE.md)
