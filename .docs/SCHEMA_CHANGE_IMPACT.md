# Şema Değişikliği Etki Analizi

Beş mimari planın (GAME, FINANCE, PROVISIONING, SHADOW_MODE, bounded context migration) tablo değişikliklerinin mevcut fonksiyonlara etkisi.

---

## Özet

| Metrik | Değer |
|--------|-------|
| Yeni tablo sayısı | 5 (+shadow_testers) |
| Taşınan tablo sayısı | 2 (Core -> Game DB, Core -> Finance DB) |
| Modify edilen tablo sayısı | 12 (+3 shadow mode) |
| Etkilenen mevcut fonksiyon sayısı | 13 |
| TAŞINACAK fonksiyon (Core -> Finance DB) | **6** |
| GÜNCELLENECEK fonksiyon | **6** |
| OPSİYONEL güncelleme | **1** |
| Kırılma (breaking change) | **0** |
| Fonksiyonu olmayan (güvenli) tablolar | 11 (+3 shadow mode) |

**Kırılma yok çünkü:** Tüm yeni kolonlar nullable (DEFAULT var), tüm fonksiyonlar explicit kolon listesi kullanıyor (SELECT * yok), tip değişiklikleri genişletme yönünde (CHAR(3) -> VARCHAR(20)), taşıma işlemleri koordineli (önce yeni DB'de oluştur, sonra Core'dan kaldır).

---

## Bounded Context Migration (Büyük Resim)

İki domain DB (Game, Finance) kendi catalog tablolarının sahibi olur. Core DB'den taşıma:

```
ÖNCE:
  Core DB: catalog.games (47 kolon) + catalog.payment_methods (31 kolon) + tüm CRUD fonksiyonları
  Game DB: BOŞ
  Finance DB: BOŞ

SONRA:
  Game DB:    catalog.game_providers + catalog.games + catalog.game_currency_limits + 8 fonksiyon
  Finance DB: catalog.payment_providers + catalog.payment_methods + catalog.payment_method_currency_limits + 8 fonksiyon
  Core DB:    core.tenant_games (denorm) + core.tenant_payment_methods (denorm) + tenant yönetim fonksiyonları
```

**Etki özeti:**
- 6 mevcut `payment_method_*` CRUD fonksiyonu Core'dan Finance DB'ye TAŞINIR
- `catalog.games` için mevcut Core fonksiyonu yok (game CRUD henüz yazılmamış)
- `provider_delete` fonksiyonu güncellenir (cross-DB kontrol)
- Core DB'de constraint/index temizliği yapılır

---

## Yeni Tablolar (4)

| Tablo | DB | Açıklama | Kaynak |
|-------|-----|----------|--------|
| `catalog.game_providers` | Game | Core provider'ların GAME alt kümesinin hafif kopyası | GAME_ARCHITECTURE.md (1A) |
| `catalog.game_currency_limits` | Game | Per-game, per-currency limitler | GAME_ARCHITECTURE.md (1C) |
| `catalog.payment_providers` | Finance | Core provider'ların PAYMENT alt kümesinin hafif kopyası | FINANCE_ARCHITECTURE.md (1A) |
| `catalog.payment_method_currency_limits` | Finance | Per-method, per-currency limitler + fee | FINANCE_ARCHITECTURE.md (1C) |
| `auth.shadow_testers` | Tenant | Shadow mode test oyuncuları (her tenant'ta ayrı) | SHADOW_MODE_ARCHITECTURE.md (1B) |

---

## Taşınan Tablolar (2)

| Tablo | Nereden | Nereye | Ek Değişiklik | Kaynak |
|-------|---------|--------|---------------|--------|
| `catalog.games` | Core DB | **Game DB** | ADD `supported_cryptocurrencies VARCHAR(20)[]`, FK provider -> `catalog.game_providers` | GAME_ARCHITECTURE.md (1B) |
| `catalog.payment_methods` | Core DB | **Finance DB** | ADD `supported_cryptocurrencies VARCHAR(20)[]`, FK provider -> `catalog.payment_providers` | FINANCE_ARCHITECTURE.md (1C) |

---

## Fonksiyon Yok — Güvenli Tablolar

Bu tablolarda henüz fonksiyon yazılmamış, değişiklik güvenli:

| Tablo | DB | Değişiklik |
|-------|-----|-----------|
| `core.tenant_games` | Core | ADD denormalize alanlar (game_name, game_code, provider_code, game_type, thumbnail_url), FK kaldırıldı |
| `core.tenant_payment_methods` | Core | ADD denormalize alanlar (payment_method_name, payment_method_code, provider_code, payment_type, icon_url), FK kaldırıldı |
| `core.tenant_provider_limits` | Core | decimal(18,2) -> decimal(18,8) tüm limit alanları |
| `game.game_settings` | Tenant | ADD `allowed_countries CHAR(2)[]` |
| `game.game_limits` | Tenant | `currency_code` CHAR(3) -> VARCHAR(20), ADD `currency_type`, `is_active` |
| `finance.payment_method_settings` | Tenant | ADD `allowed_countries CHAR(2)[]` |
| `finance.payment_method_limits` | Tenant | `currency_code` CHAR(3) -> VARCHAR(20), ADD `currency_type`, `is_active` |
| `finance.payment_player_limits` | Tenant | ADD `currency_code`, `currency_type`, decimal(18,2) -> (18,8), UQ güncelle |
| `core.tenant_providers` | Core | ADD `rollout_status VARCHAR(20) DEFAULT 'production'` + CHECK constraint |
| `game.game_settings` | Tenant | ADD `rollout_status VARCHAR(20) DEFAULT 'production'` (denormalize) |
| `finance.payment_method_settings` | Tenant | ADD `rollout_status VARCHAR(20) DEFAULT 'production'` (denormalize) |

> Shadow mode tablo değişiklikleri: Tüm yeni kolonlar `DEFAULT 'production'` ile eklendiğinden mevcut veri etkilenmez, kırılma yok. Detay: [SHADOW_MODE_ARCHITECTURE.md](SHADOW_MODE_ARCHITECTURE.md)

---

## TAŞINACAK Fonksiyonlar: Core -> Finance DB (6)

Bu fonksiyonlar `catalog.payment_methods` tablosuyla birlikte Finance DB'ye taşınır. Mevcut imzaları korunur, sadece `catalog.providers` JOIN'ları `catalog.payment_providers` JOIN'larına dönüşür.

### 1. `payment_method_create` — Finance DB'ye taşı + crypto ekle

**Mevcut dosya:** `core/functions/catalog/payment/payment_method_create.sql`
**Yeni dosya:** `finance/functions/catalog/payment_method_create.sql`
**Mevcut durum:** 36 kolon INSERT, `catalog.providers` JOIN ile provider kontrolü.
**Kırılır mı:** Hayır (koordineli taşıma)
**Değişiklikler:**
- `catalog.providers` -> `catalog.payment_providers` JOIN
- ADD parametre: `p_supported_cryptocurrencies VARCHAR(20)[] DEFAULT '{}'`
- INSERT kolon listesine `supported_cryptocurrencies` ekle
- DROP Core'dan, CREATE Finance DB'de

**Backend etkisi:** `PaymentMethodService.CreateAsync()` — Finance DB connection'a yönlendirilir.

---

### 2. `payment_method_update` — Finance DB'ye taşı + crypto ekle

**Mevcut dosya:** `core/functions/catalog/payment/payment_method_update.sql`
**Yeni dosya:** `finance/functions/catalog/payment_method_update.sql`
**Mevcut durum:** COALESCE pattern, `catalog.payment_methods` UPDATE.
**Kırılır mı:** Hayır
**Değişiklikler:**
- `catalog.providers` referansları -> `catalog.payment_providers`
- ADD parametre: `p_supported_cryptocurrencies VARCHAR(20)[] DEFAULT NULL`
- UPDATE SET'e `supported_cryptocurrencies = COALESCE(...)` ekle
- DROP Core'dan, CREATE Finance DB'de

**Backend etkisi:** `PaymentMethodService.UpdateAsync()` — Finance DB connection.

---

### 3. `payment_method_delete` — Finance DB'ye taşı

**Mevcut dosya:** `core/functions/catalog/payment/payment_method_delete.sql`
**Yeni dosya:** `finance/functions/catalog/payment_method_delete.sql`
**Mevcut durum:** Soft delete (is_active=false). Yorum satırında tenant kullanım kontrolü.
**Kırılır mı:** Hayır
**Değişiklikler:**
- Tablo referansı aynı (`catalog.payment_methods`, artık Finance DB'de)
- Tenant kullanım kontrolü: cross-DB olacağı için backend'de yapılmalı
- DROP Core'dan, CREATE Finance DB'de

**Backend etkisi:** `PaymentMethodService.DeleteAsync()` — Finance DB connection.

---

### 4. `payment_method_get` — Finance DB'ye taşı + crypto ekle

**Mevcut dosya:** `core/functions/catalog/payment/payment_method_get.sql`
**Yeni dosya:** `finance/functions/catalog/payment_method_get.sql`
**Mevcut durum:** TABLE return ~37 kolon, `catalog.providers` JOIN.
**Kırılır mı:** Hayır
**Değişiklikler:**
- `JOIN catalog.providers p` -> `JOIN catalog.payment_providers p`
- Return TABLE'a `supported_cryptocurrencies VARCHAR(20)[]` ekle
- SELECT listesine `pm.supported_cryptocurrencies` ekle
- DROP Core'dan, CREATE Finance DB'de (return type değiştiği için zorunlu)

**Backend etkisi:** `PaymentMethodDetailDto` — +supportedCryptocurrencies, Finance DB connection.

---

### 5. `payment_method_list` — Finance DB'ye taşı + crypto ekle

**Mevcut dosya:** `core/functions/catalog/payment/payment_method_list.sql`
**Yeni dosya:** `finance/functions/catalog/payment_method_list.sql`
**Mevcut durum:** TABLE return ~25 kolon, `catalog.providers` JOIN.
**Kırılır mı:** Hayır
**Değişiklikler:**
- `JOIN catalog.providers p` -> `JOIN catalog.payment_providers p`
- Return TABLE'a `supported_cryptocurrencies VARCHAR(20)[]` ekle
- DROP Core'dan, CREATE Finance DB'de

**Backend etkisi:** `PaymentMethodListDto` — +supportedCryptocurrencies, Finance DB connection.

---

### 6. `payment_method_lookup` — Finance DB'ye taşı

**Mevcut dosya:** `core/functions/catalog/payment/payment_method_lookup.sql`
**Yeni dosya:** `finance/functions/catalog/payment_method_lookup.sql`
**Mevcut durum:** TABLE return (id, code, name, provider, type). `catalog.providers` JOIN.
**Kırılır mı:** Hayır
**Değişiklikler:**
- `JOIN catalog.providers p` -> `JOIN catalog.payment_providers p`
- DROP Core'dan, CREATE Finance DB'de

**Backend etkisi:** `PaymentMethodLookupDto` — Finance DB connection.

---

## GÜNCELLENECEK Fonksiyonlar (6)

### TABLO: `core.tenants` — Provisioning Alanları

**Eklenen kolonlar:** `domain`, `subdomain`, `provisioning_status`, `provisioning_step`, `provisioned_at`, `decommissioned_at`, `hosting_mode`

#### 7. `tenant_create` — Yeni parametreler ekle

**Dosya:** `core/functions/core/tenants/tenant_create.sql`
**Mevcut durum:** 11 kolon INSERT eder. Yeni alanları bilmiyor.
**Kırılır mı:** Hayır (yeni kolonlar nullable/DEFAULT'lu)
**Güncelleme:**
- ADD parametre: `p_domain VARCHAR(255) DEFAULT NULL`
- ADD parametre: `p_hosting_mode VARCHAR(20) DEFAULT 'shared'`
- INSERT listesine `domain`, `hosting_mode` ekle
- `provisioning_status` otomatik 'draft' olacak (tablo DEFAULT'u)
- DROP eski imza, CREATE yeni imza

**Backend etkisi:** `TenantService.CreateAsync()` — yeni parametreler opsiyonel, mevcut çağrılar çalışmaya devam eder.

---

#### 8. `tenant_update` — Yeni alanları güncelleyebilmeli

**Dosya:** `core/functions/core/tenants/tenant_update.sql`
**Mevcut durum:** COALESCE pattern ile partial update. Yeni alanları güncelleyemiyor.
**Kırılır mı:** Hayır
**Güncelleme:**
- ADD parametre: `p_domain VARCHAR(255) DEFAULT NULL`
- ADD parametre: `p_subdomain VARCHAR(255) DEFAULT NULL`
- ADD parametre: `p_hosting_mode VARCHAR(20) DEFAULT NULL`
- UPDATE SET'e COALESCE satırları ekle:
  ```sql
  domain = COALESCE(p_domain, domain),
  subdomain = COALESCE(p_subdomain, subdomain),
  hosting_mode = COALESCE(p_hosting_mode, hosting_mode),
  ```
- `provisioning_status` bu fonksiyondan GÜNCELLENMEMELİ (ProductionManager yönetir)
- DROP eski imza, CREATE yeni imza

**Backend etkisi:** `TenantService.UpdateAsync()` — yeni parametreler opsiyonel.

---

#### 9. `tenant_get` — Response'a yeni alanlar ekle

**Dosya:** `core/functions/core/tenants/tenant_get.sql`
**Mevcut durum:** JSONB return, belirli alanları seçer. Yeni alanlar response'ta yok.
**Kırılır mı:** Hayır (mevcut response aynı kalır)
**Güncelleme:**
- JSONB build'e yeni alanlar ekle:
  ```sql
  'domain', t.domain,
  'subdomain', t.subdomain,
  'provisioningStatus', t.provisioning_status,
  'provisioningStep', t.provisioning_step,
  'provisionedAt', t.provisioned_at,
  'decommissionedAt', t.decommissioned_at,
  'hostingMode', t.hosting_mode
  ```

**Backend etkisi:** `TenantDto` — yeni alanlar eklenmeli. Mevcut alanlar değişmiyor, frontend backward-compatible.

---

#### 10. `tenant_list` — Liste response'una durum bilgisi ekle

**Dosya:** `core/functions/core/tenants/tenant_list.sql`
**Mevcut durum:** JSONB array return, belirli alanlarla. Provisioning durumu görünmüyor.
**Kırılır mı:** Hayır
**Güncelleme:**
- JSONB build'e yeni alanlar ekle:
  ```sql
  'domain', t.domain,
  'provisioningStatus', t.provisioning_status,
  'hostingMode', t.hosting_mode
  ```
- Opsiyonel: `p_provisioning_status` filtre parametresi eklenebilir

**Backend etkisi:** `TenantListDto` — yeni alanlar eklenmeli. BO UI'da provisioning durumu badge olarak gösterilebilir.

---

#### 11. `tenant_lookup` — Domain bilgisi ekle (opsiyonel)

**Dosya:** `core/functions/core/tenants/tenant_lookup.sql`
**Mevcut durum:** TABLE return (id, code, name, company_id, company_name, status). Dropdown için kullanılıyor.
**Kırılır mı:** Hayır
**Güncelleme (opsiyonel):**
- Return TABLE'a `domain VARCHAR(255)` ekle
- Return TABLE'a `provisioning_status VARCHAR(20)` ekle
- SELECT'e `t.domain`, `t.provisioning_status` ekle

**Backend etkisi:** `TenantLookupDto` — yeni alanlar. Mevcut dropdown'lar çalışmaya devam eder.

---

### TABLO: `catalog.games` + `catalog.payment_methods` — Cross-DB Etki

#### 12. `provider_delete` — Cross-DB kontroller güncellenmeli

**Dosya:** `core/functions/catalog/providers/provider_delete.sql`
**Mevcut durum:** Hem `catalog.games` hem `catalog.payment_methods` üzerinde EXISTS kontrolü yapıyor. Her iki tablo da Core'dan taşınacak.
**Kırılır mı:** EVET — tablo artık Core DB'de olmayacak, sorgu hata verecek.
**Güncelleme:**
- `catalog.games` kontrolü **KALDIRILDI** (tablo Game DB'ye taşındı)
- `catalog.payment_methods` kontrolü **KALDIRILDI** (tablo Finance DB'ye taşındı)
- Her iki kontrol artık **backend seviyesinde** yapılmalı:
  ```
  Backend orchestration:
  1. Backend -> Game DB: catalog.games WHERE provider_id = X EXISTS?
  2. Backend -> Finance DB: catalog.payment_methods WHERE provider_id = X EXISTS?
  3. Herhangi biri varsa -> hata dön, silme yapma
  4. Yoksa -> Core DB: provider_delete(p_id)
  ```
- Fonksiyon içindeki iki EXISTS bloğu kaldırılır
- DROP eski imza, CREATE yeni imza

**Backend etkisi:** `ProviderService.DeleteAsync()` — silme öncesi Game DB ve Finance DB'ye kontrol sorgusu eklenmeli. **KIRILMA RİSKİ**: Bu fonksiyon koordineli deploy gerektirir.

---

## OPSİYONEL Güncelleme (1)

#### 13. `user_authenticate` — Provisioning durumu filtrelemesi

**Dosya:** `core/functions/security/auth/user_authenticate.sql`
**Mevcut durum:** accessible_tenants subquery'sinde `core.tenants` JOIN ediyor. Tüm tenant'ları döner.
**Kırılır mı:** Hayır
**Güncelleme (opsiyonel):**
- accessible_tenants subquery'sine filtre ekle:
  ```sql
  AND t.provisioning_status = 'active'
  ```
  Böylece henüz provision edilmemiş tenant'lara erişim engellenir.

**Backend etkisi:** Yok — sadece SQL seviyesinde filtre.

---

## Core DB Constraint/Index Temizliği

### Constraints Kaldırılacak

**`core/constraints/catalog.sql`** — Game DB'ye taşındı:
- `fk_games_provider` (games -> providers)
- `uq_games_provider_external` (provider_id, external_game_id)
- `uq_games_provider_code` (provider_id, game_code)

**`core/constraints/catalog.sql`** — Finance DB'ye taşındı:
- `fk_payment_methods_provider` (payment_methods -> providers)
- `uq_payment_methods_provider_code` (provider_id, payment_method_code)

**`core/constraints/core.sql`** — Cross-DB FK'lar kaldırıldı:
- `fk_tenant_games_game` (tenant_games -> catalog.games) — tablo başka DB'de
- `fk_tenant_payment_methods_payment_method` (tenant_payment_methods -> catalog.payment_methods) — tablo başka DB'de

### Indexes Kaldırılacak

**`core/indexes/catalog.sql`** — Game indexleri (Game DB'ye taşındı):
- `idx_games_provider_id`
- `idx_games_game_type`
- `idx_games_is_active`
- `idx_games_categories` (GIN)
- `idx_games_tags` (GIN)
- `idx_games_features` (GIN)
- `idx_games_popularity`
- `idx_games_release_date`
- `idx_games_rtp`
- `idx_games_has_jackpot`

**`core/indexes/catalog.sql`** — Payment method indexleri (Finance DB'ye taşındı):
- `idx_payment_methods_provider_id`
- `idx_payment_methods_payment_type`
- `idx_payment_methods_is_active`
- `idx_payment_methods_deposit`
- `idx_payment_methods_withdrawal`
- `idx_payment_methods_currencies` (GIN)
- `idx_payment_methods_features` (GIN)
- `idx_payment_methods_popularity`

### Deploy Script Değişiklikleri

**`deploy_core.sql`** kaldırılacaklar:
- `\i core/tables/catalog/game/games.sql` — Game DB'ye taşındı
- `\i core/tables/catalog/payment/payment_methods.sql` — Finance DB'ye taşındı
- 6 adet `payment_method_*` fonksiyon satırı — Finance DB'ye taşındı

---

## Etkilenmeyen Fonksiyonlar (Referans var ama güncelleme gereksiz)

Bu fonksiyonlar `core.tenants` tablosuna referans veriyor ancak sadece `tenant_id` ile JOIN/EXISTS yapıyor, kolon değişikliklerinden **etkilenmez**:

| Fonksiyon | Neden etkilenmez |
|-----------|------------------|
| `tenant_delete` | Sadece `status = 0` yapar |
| `tenant_currency_upsert/list/mapping_list` | Sadece `tenant_id` ile JOIN |
| `tenant_cryptocurrency_upsert/list/mapping_list` | Sadece `tenant_id` ile JOIN |
| `tenant_language_upsert/list` | Sadece `tenant_id` ile JOIN |
| `tenant_setting_upsert/get/list/delete` | Sadece `tenant_id` ile WHERE |
| `user_get_access_level` | Sadece `company_id` okur |
| `user_role_assign/list` | Sadece tenant EXISTS check |
| `user_permission_set/remove/list` | Sadece tenant check |
| `user_get` | Allowed tenants subquery |
| `admin_message_publish` | Sadece tenant EXISTS check |
| `currency_delete` | Sadece tenant_currencies check |
| Tüm `presentation/*` fonksiyonları (13 adet) | Sadece `tenant_id` ile IDOR check |

---

## Uygulama Sırası

### Faz 1: Yeni DB Altyapıları (Game DB + Finance DB)
```
1. Game DB: catalog schema + game_providers + games (taşı) + game_currency_limits
2. Game DB: constraints + indexes (catalog.sql)
3. Finance DB: catalog schema + payment_providers + payment_methods (taşı) + payment_method_currency_limits
4. Finance DB: constraints + indexes (catalog.sql)
-> Mevcut Core DB kodu hala ÇALIŞIYOR (eski tablolar henüz kaldırılmadı)
```

### Faz 2: Core DB Temizlik + Fonksiyon Taşımaları
```
Öncelik 1 — Tablo temizlik:
  1. core/tables/catalog/game/games.sql KALDIRILDI
  2. core/tables/catalog/payment/payment_methods.sql KALDIRILDI
  3. core/tables/core/integration/tenant_games.sql MODIFY (denorm alanlar)
  4. core/tables/core/integration/tenant_payment_methods.sql MODIFY (denorm alanlar)
  5. core/tables/core/integration/tenant_provider_limits.sql MODIFY (decimal hassasiyeti)

Öncelik 2 — Constraint/index temizlik:
  6. core/constraints/catalog.sql: games + payment_methods FK/UQ kaldır
  7. core/constraints/core.sql: cross-DB FK'lar kaldır
  8. core/indexes/catalog.sql: games + payment_methods indexleri kaldır

Öncelik 3 — Fonksiyon taşıma (Core'dan sil):
  9. 6 adet payment_method_* fonksiyonu Core deploy'dan kaldır
  10. provider_delete güncelle (cross-DB kontrolleri kaldır)
```

### Faz 3: Provisioning + Tenant Tablo Güncellemeleri
```
Öncelik 1 — core.tenants provisioning:
  1. ALTER TABLE core.tenants ADD COLUMN domain/subdomain/provisioning_*/hosting_mode
  2. tenant_create/update/get/list/lookup fonksiyonlarını güncelle

Öncelik 2 — Tenant DB tablo modify:
  3. game.game_settings: +allowed_countries
  4. game.game_limits: currency_code genişlet, +currency_type, +is_active
  5. finance.payment_method_settings: +allowed_countries
  6. finance.payment_method_limits: currency_code genişlet, +currency_type, +is_active
  7. finance.payment_player_limits: +currency_code, +currency_type, decimal genişlet

Öncelik 3 — Güvenlik (opsiyonel):
  8. user_authenticate: provisioning_status filtresi
```

### Faz 4: Backend Güncellemeleri
```
Öncelik 1 — Connection yönlendirme:
  - PaymentMethodService: Core DB connection -> Finance DB connection
  - Yeni GameCatalogService: Game DB connection (yeni servis)

Öncelik 2 — DTO Güncellemeleri:
  - TenantDto: +domain, subdomain, provisioningStatus, provisioningStep, provisionedAt, hostingMode
  - TenantListDto: +domain, provisioningStatus, hostingMode
  - PaymentMethodDetailDto: +supportedCryptocurrencies
  - PaymentMethodListDto: +supportedCryptocurrencies

Öncelik 3 — Cross-DB Orchestration:
  - ProviderService.DeleteAsync: Game DB + Finance DB kontrol eklenmeli
  - TenantPaymentProviderService: Finance DB'den metot listesi al -> Core'a seed et
  - TenantGameProviderService: Game DB'den oyun listesi al -> Core'a seed et

Öncelik 4 — API Endpoint Güncellemeleri:
  - POST /api/tenants -> +domain, hostingMode
  - PUT /api/tenants/{id} -> +domain, subdomain, hostingMode
  - GET /api/tenants -> +provisioningStatus
  - POST /api/catalog/payment-methods -> supportedCryptocurrencies (Finance DB)
  - PUT /api/catalog/payment-methods/{id} -> supportedCryptocurrencies (Finance DB)
```

---

## Referans: Tüm Tablo Değişiklikleri

### Yeni Tablolar
| Tablo | DB | Kaynak |
|-------|-----|--------|
| `catalog.game_providers` | Game | GAME_ARCHITECTURE.md (1A) |
| `catalog.game_currency_limits` | Game | GAME_ARCHITECTURE.md (1C) |
| `catalog.payment_providers` | Finance | FINANCE_ARCHITECTURE.md (1A) |
| `catalog.payment_method_currency_limits` | Finance | FINANCE_ARCHITECTURE.md (1B) |
| `auth.shadow_testers` | Tenant | SHADOW_MODE_ARCHITECTURE.md (1B) |

### Taşınan Tablolar
| Tablo | Core -> | Kaynak |
|-------|---------|--------|
| `catalog.games` | Game DB | GAME_ARCHITECTURE.md (1B) |
| `catalog.payment_methods` | Finance DB | FINANCE_ARCHITECTURE.md (1C) |

### Modify Edilen Tablolar
| Tablo | DB | Kaynak |
|-------|-----|--------|
| `core.tenants` | Core | PROVISIONING_ARCHITECTURE.md (1A) |
| `core.tenant_games` | Core | GAME_ARCHITECTURE.md (1D) |
| `core.tenant_payment_methods` | Core | FINANCE_ARCHITECTURE.md (1D) |
| `core.tenant_provider_limits` | Core | FINANCE_ARCHITECTURE.md (1H) |
| `game.game_settings` | Tenant | GAME_ARCHITECTURE.md (1F) |
| `game.game_limits` | Tenant | GAME_ARCHITECTURE.md (1E) |
| `finance.payment_method_settings` | Tenant | FINANCE_ARCHITECTURE.md (1F) |
| `finance.payment_method_limits` | Tenant | FINANCE_ARCHITECTURE.md (1E) |
| `finance.payment_player_limits` | Tenant | FINANCE_ARCHITECTURE.md (1G) |
| `core.tenant_providers` | Core | SHADOW_MODE_ARCHITECTURE.md (1A) |
| `game.game_settings` | Tenant | SHADOW_MODE_ARCHITECTURE.md (1C) |
| `finance.payment_method_settings` | Tenant | SHADOW_MODE_ARCHITECTURE.md (1D) |
