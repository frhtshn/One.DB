# Finance Yönetim Sistemi - Tam Uygulama

Gateway entegrasyonundan tenant sitesine kadar tam ödeme yöntemi yaşam döngüsü.
Mimari detaylar: [FINANCE_ARCHITECTURE.md](FINANCE_ARCHITECTURE.md)

## Senaryo

1. Gateway feedback servisi -> Finance DB: `catalog.payment_methods` + currency limitleri doldurur (sürekli background)
2. BO'dan tenant'a provider açılır -> Backend Finance DB'den metotları alır -> Core'da tenant_payment_methods seed edilir
3. Backend sync grain -> Tenant DB'ye payment_method_settings/limits senkronize edilir
4. Metotlar tenant sitesinde anında aktif olur
5. Tenant metotları BO'dan düzenleyebilir (`payment_method_settings`)
6. Core'da metot kapanırsa -> tenant'ta da kapanır
7. Provider kapanırsa -> metotlar gösterilmez (state değişmez)

## Mimari Kararlar

- **Finance DB catalog owner**: Ödeme kataloğu Finance DB'de yaşır. Core DB'de catalog.payment_methods YOKTUR
- **catalog.payment_providers**: Finance DB'de hafif provider referansı, Core ile aynı ID'ler
- **core.tenant_payment_methods denormalize**: payment_method_name, payment_method_code, provider_code, payment_type, icon_url
- **tenant_payment_provider_enable refactored**: Backend Finance DB'den metot listesi alır, p_method_data TEXT olarak Core'a geçirir
- **Mevcut catalog CRUD taşınır**: 6 fonksiyon (create/update/delete/get/list/lookup) Core'dan Finance DB'ye
- Provider disable -> metot state değişmez, sorgu seviyesinde filtrelenir
- Fiat/Crypto tek tablo + `currency_type` (ayrı tablo değil)
- Hard DELETE yok, tüm tablolarda soft delete
- Cursor-based pagination (OFFSET yok)
- Fonksiyon parametreleri TEXT->JSONB, tablolar fully-typed
- Outbox pattern ile event-driven sync
- Limit hiyerarşisi: provider default (catalog) -> platform ceiling (core) -> tenant site (finance) -> player bireysel (finance)

---

## Adım 1: Tablo Değişiklikleri

### Finance DB (Catalog Owner)

- [ ] **1A.** `catalog.payment_providers` -- YENİ tablo (Finance DB)
  - `finance/tables/catalog/payment_providers.sql`
  - Core catalog.providers'ın PAYMENT alt kümesinin hafif kopyası
  - Aynı ID'ler kullanılır (BIGINT PK, SERIAL değil)
  - Backend `payment_provider_sync` ile senkronize eder

- [ ] **1B.** `catalog.payment_methods` -- Core'dan Finance DB'ye TAŞINDI
  - `finance/tables/catalog/payment_methods.sql`
  - ADD `supported_cryptocurrencies VARCHAR(20)[] DEFAULT '{}'`
  - FK: `provider_id` -> `catalog.payment_providers(id)` (Finance DB içi)
  - Tüm kolonlar typed kalır (~31 kolon)

- [ ] **1C.** `catalog.payment_method_currency_limits` -- YENİ tablo (Finance DB)
  - `finance/tables/catalog/payment_method_currency_limits.sql`
  - Per-method, per-currency limit + fee bilgileri (feedback servisinden)
  - `UNIQUE(payment_method_id, currency_code)`, `currency_type` (1=Fiat, 2=Crypto)
  - `DECIMAL(18,8)` (crypto hassasiyeti)
  - `is_active` soft delete

### Core DB (Tenant Mapping)

- [ ] **1D.** `core.tenant_payment_methods` -- MODIFY (Core DB)
  - `core/tables/core/integration/tenant_payment_methods.sql`
  - FK `payment_method_id -> catalog.payment_methods` **KALDIRILDI** (cross-DB, backend doğrular)
  - ADD denormalize alanlar: `payment_method_name`, `payment_method_code`, `provider_code`, `payment_type`, `icon_url`
  - BO listesi cross-DB JOIN yapmadan gösterilir

- [ ] **1E.** `core.tenant_provider_limits` -- MODIFY (Core DB)
  - `core/tables/core/integration/tenant_provider_limits.sql`
  - `decimal(18,2)` -> `decimal(18,8)` (tüm limit alanları, crypto hassasiyeti)
  - Yapı değişikliği yok, sadece hassasiyet

### Tenant DB (Runtime)

- [ ] **1F.** `finance.payment_method_limits` -- MODIFY (Tenant DB)
  - `tenant/tables/finance/payment_method_limits.sql`
  - `currency_code` CHAR(3) -> VARCHAR(20) (crypto desteği)
  - ADD `currency_type SMALLINT NOT NULL DEFAULT 1`
  - ADD `is_active BOOLEAN NOT NULL DEFAULT true`

- [ ] **1G.** `finance.payment_method_settings` -- MODIFY (Tenant DB)
  - `tenant/tables/finance/payment_method_settings.sql`
  - ADD `allowed_countries CHAR(2)[] DEFAULT '{}'`
  - ADD `rollout_status VARCHAR(20) NOT NULL DEFAULT 'production'` (SHADOW_MODE)

- [ ] **1H.** `finance.payment_player_limits` -- MODIFY (Tenant DB)
  - `tenant/tables/finance/payment_player_limits.sql`
  - ADD `currency_code VARCHAR(20) NOT NULL DEFAULT 'TRY'`
  - ADD `currency_type SMALLINT NOT NULL DEFAULT 1`
  - `decimal(18,2)` -> `decimal(18,8)` (tüm limit alanları)
  - UNIQUE constraint: `(player_id, payment_method_id)` -> `(player_id, payment_method_id, currency_code)`

### Constraint ve Index Güncellemeleri

- [ ] **1I-a.** Finance DB constraints + indexes
  - [ ] `finance/constraints/catalog.sql` -- FK + UQ (payment_providers, payment_methods, payment_method_currency_limits)
  - [ ] `finance/indexes/catalog.sql` -- payment_providers, payment_methods (Core'dan taşındı), payment_method_currency_limits indexleri

- [ ] **1I-b.** Core DB constraint/index temizliği
  - [ ] `core/constraints/catalog.sql` -- payment_methods FK/UQ KALDIRILDI (Finance DB'ye taşındı)
  - [ ] `core/constraints/core.sql` -- tenant_payment_methods->payment_methods FK KALDIRILDI (cross-DB)
  - [ ] `core/indexes/catalog.sql` -- Tüm idx_payment_methods_* KALDIRILDI (Finance DB'ye taşındı)

- [ ] **1I-c.** Tenant DB constraint/index güncellemeleri
  - [ ] `tenant/constraints/finance.sql` -- CHAR(3) -> VARCHAR(20) uyumu, player_limits UQ güncelle
  - [ ] `tenant/indexes/finance.sql` -- `idx_payment_method_settings_cursor` BTREE(display_order, id), currency_type indexleri

---

## Adım 2: Finance DB -- Catalog Fonksiyonları (Grup A0 + A: 8)

Klasör: `finance/functions/catalog/`
Pattern: SECURITY DEFINER, IDOR yok

- [ ] **#0** `payment_provider_sync.sql` -- Provider sync (Core->Finance DB)
  - `p_providers TEXT` -> JSONB cast, UPSERT per element
  - Backend Core'dan PAYMENT tipli provider'ları alıp geçirir
  - Return: INTEGER (upsert sayısı)

- [ ] **#1** `payment_method_create.sql` -- **TAŞINDI** Yeni metot oluştur
  - Feedback servis: tekil metot kaydı
  - `catalog.providers` JOIN -> `catalog.payment_providers` JOIN'a dönüşür
  - Return: BIGINT (method id)

- [ ] **#2** `payment_method_update.sql` -- **TAŞINDI** Metot güncelle
  - COALESCE pattern (NULL = değiştirme)
  - Soft delete: `p_is_active := FALSE`
  - Return: VOID

- [ ] **#3** `payment_method_delete.sql` -- **TAŞINDI** Metot kapat
  - Soft delete: `is_active=false`
  - Return: VOID

- [ ] **#4** `payment_method_get.sql` -- **TAŞINDI** Tekil metot detay
  - JOIN payment_providers
  - Return: TABLE/JSONB

- [ ] **#5** `payment_method_list.sql` -- **TAŞINDI** Filtreli liste
  - Filter: provider, type, status, search ILIKE
  - Return: TABLE/JSONB

- [ ] **#6** `payment_method_lookup.sql` -- **TAŞINDI** Dropdown hafif liste
  - id, code, name, provider, type
  - Return: TABLE

- [ ] **#7** `payment_method_currency_limit_sync.sql` -- YENİ, currency limit bulk upsert
  - `p_payment_method_id BIGINT, p_limits TEXT` -> JSONB cast
  - Artık desteklenmeyen -> `is_active=false` (hard delete yok)
  - Return: VOID

---

## Adım 3: Core -- Tenant Payment Provider Fonksiyonları (Grup B: 3)

Klasör: `core/functions/core/tenant_payment_providers/`
Pattern: IDOR korumalı (`user_assert_access_company`)

- [ ] **#8** `tenant_payment_provider_enable.sql` -- Provider aç + metotları seed et
  - `p_method_data TEXT` -- Backend Finance DB'den aldığı metot listesi (JSONB array)
  - core.tenant_providers UPSERT + core.tenant_payment_methods toplu INSERT (denorm alanlar ile)
  - catalog.payment_methods sorgusu YAPMAZ (cross-DB orchestration)
  - Mevcut metotlara DOKUNMAZ (ON CONFLICT DO NOTHING)
  - Return: INTEGER (eklenen metot sayısı)

- [ ] **#9** `tenant_payment_provider_disable.sql` -- Provider kapat
  - Sadece flag: `is_enabled=false`
  - Metotlara DOKUNMAZ (sorgu seviyesinde filtrelenir)
  - Return: VOID

- [ ] **#10** `tenant_payment_provider_list.sql` -- Provider listesi
  - Sadece PAYMENT provider'lar (provider_type_code = 'PAYMENT')
  - methodCount subquery
  - Return: JSONB

---

## Adım 4: Core -- Tenant Payment Method Fonksiyonları (Grup C: 4)

Klasör: `core/functions/core/tenant_payment_methods/`
Pattern: IDOR korumalı

- [ ] **#11** `tenant_payment_method_upsert.sql` -- Tekil metot aç/düzenle
  - Customization alanları (display_order, custom_name, override limitleri vb.)
  - catalog.payment_methods validasyonu YAPILMAZ (cross-DB, backend doğrular)
  - sync_status = 'pending'
  - Return: VOID

- [ ] **#12** `tenant_payment_method_list.sql` -- Metot listesi (BO admin)
  - Denormalize alanlardan sorgu, catalog.payment_methods JOIN YOK
  - Provider filtresi: provider_code üzerinden
  - `providerIsEnabled` bilgi amaçlı döner
  - Return: JSONB

- [ ] **#13** `tenant_payment_method_remove.sql` -- Metot kapat
  - Soft delete: `is_enabled=false` + `disabled_reason`
  - Return: VOID

- [ ] **#14** `tenant_payment_method_refresh.sql` -- Yeni metotları toplu seed et
  - `p_method_data TEXT` -- Backend Finance DB'den aldığı metot listesi
  - Provider'ın yeni metotlarını tenant_payment_methods'e ekle (denorm alanlar ile)
  - ON CONFLICT DO NOTHING
  - Return: INTEGER

---

## Adım 5: Tenant -- Sync Fonksiyonları (Grup D: 3)

Klasör: `tenant/functions/finance/`
Pattern: Auth-agnostic (backend çağırır)

- [ ] **#15** `payment_method_settings_sync.sql` -- Core->Tenant method data upsert
  - `p_catalog_data TEXT` -> JSONB cast -> typed kolonlara extract
  - `p_rollout_status VARCHAR(20) DEFAULT 'production'` -- Provider rollout status miras alınır (SHADOW_MODE)
  - INSERT: catalog + tenant override (default değerler)
  - UPDATE: SADECE catalog alanları -- tenant override'lara DOKUNMAZ
  - Return: VOID

- [ ] **#16** `payment_method_settings_remove.sql` -- Metot devre dışı bırak
  - Soft delete: `is_enabled=false`
  - Fiziksel DELETE yok, payment_method_limits korunur
  - Return: VOID

- [ ] **#17** `payment_method_limits_sync.sql` -- Core->Tenant currency limits
  - `p_limits TEXT` -> JSONB cast
  - Artık desteklenmeyen -> `is_active=false` (hard delete yok)
  - Return: VOID

- [ ] **#17b** `payment_provider_rollout_sync.sql` -- Provider rollout status toplu güncelle (SHADOW_MODE YENİ)
  - `p_provider_id BIGINT, p_rollout_status VARCHAR(20)`
  - UPDATE finance.payment_method_settings SET rollout_status WHERE provider_id
  - Return: INTEGER (güncellenen satır)

---

## Adım 6: Tenant -- BO Yönetim + Cashier (Grup E: 5)

Klasör: `tenant/functions/finance/`
Pattern: Auth-agnostic

- [ ] **#18** `payment_method_settings_get.sql` -- Tekil metot detay (cashier flow)
  - Cashier flow: provider_id + external_method_id -> Gateway gRPC
  - Return: JSONB

- [ ] **#19** `payment_method_settings_update.sql` -- Tenant customization
  - COALESCE pattern (NULL = değiştirme)
  - Editable: custom_name, display_order, is_visible, is_featured, blocked_countries, vb.
  - Return: VOID

- [ ] **#20** `payment_method_settings_list.sql` -- Cashier metot listesi
  - `p_provider_ids BIGINT[]` -- cashier filtresi (backend core'dan alır)
  - `p_player_id BIGINT DEFAULT NULL` -- NULL=anonymous, NOT NULL=logged in (SHADOW_MODE)
  - Shadow mode filtresi: production herkes görür, shadow sadece auth.shadow_testers (SHADOW_MODE)
  - Cursor pagination: (display_order, id)
  - Search: ILIKE on payment_method_name, payment_method_code, custom_name
  - Return: JSONB `{items, nextCursorOrder, nextCursorId, hasMore}`

- [ ] **#21** `payment_method_limit_upsert.sql` -- Metot limiti ekle/güncelle
  - UPSERT: (payment_method_id, currency_code)
  - Return: VOID

- [ ] **#22** `payment_method_limit_list.sql` -- Metot limit listesi
  - WHERE `is_active=true`
  - Return: JSONB

---

## Adım 7: Tenant -- Player Limitleri (Grup F: 3)

Klasör: `tenant/functions/finance/`
Pattern: Auth-agnostic

- [ ] **#23** `payment_player_limit_set.sql` -- Player limiti ekle/güncelle
  - UPSERT: (player_id, payment_method_id, currency_code)
  - `p_limit_type`: self_imposed, responsible_gaming, admin_imposed
  - Limit <= site limiti kontrolü
  - Return: VOID

- [ ] **#24** `payment_player_limit_get.sql` -- Player metot+currency limiti
  - Cashier'da işlem öncesi limit kontrolü
  - Return: JSONB

- [ ] **#25** `payment_player_limit_list.sql` -- Player tüm limitleri
  - p_payment_method_id NULL -> tüm metotlar
  - Return: JSONB

---

## Adım 8: Deploy Dosyaları

### deploy_finance.sql (MAJOR güncelleme)
- [ ] `catalog` schema + tablolar (payment_providers, payment_methods, payment_method_currency_limits)
- [ ] Fonksiyonlar: Provider Sync (1: Grup A0)
- [ ] Fonksiyonlar: Catalog CRUD (6: #1-#6, Core'dan taşındı)
- [ ] Fonksiyonlar: Currency Limit Sync (1: #7)
- [ ] Constraints: `finance/constraints/catalog.sql`
- [ ] Indexes: `finance/indexes/catalog.sql`

### deploy_core.sql değişiklikleri
- [ ] `catalog.payment_methods` satırı **KALDIRILDI** (Finance DB'ye taşındı)
- [ ] 6 mevcut payment_method CRUD fonksiyonu **KALDIRILDI** (Finance DB'ye taşındı)
- [ ] Fonksiyonlar: Tenant Payment Providers (3: Grup B)
- [ ] Fonksiyonlar: Tenant Payment Methods (4: Grup C)

### deploy_tenant.sql eklemeleri
- [ ] Fonksiyonlar: Finance Sync (4: Grup D, +rollout_sync)
- [ ] Fonksiyonlar: Finance BO + Cashier (5: Grup E)
- [ ] Fonksiyonlar: Player Limits (3: Grup F)

---

## Adım 9: Doküman Güncellemeleri

- [x] `FINANCE_ARCHITECTURE.md` -- Tam güncellendi (Finance DB catalog owner)
- [x] `FINANCE_ISSUE.md` -- Yeni dosya lokasyonları ve checklist
- [ ] `FUNCTIONS_CORE.md` güncelle
- [ ] `FUNCTIONS_TENANT.md` güncelle

---

## Uygulama Sırası

1. Finance DB tablo dosyaları (payment_providers, payment_methods taşı, payment_method_currency_limits)
2. Finance DB constraints + indexes
3. Core DB temizlik (payment_methods.sql kaldır, tenant_payment_methods modify, constraints/indexes güncelle)
4. Core DB tenant_provider_limits modify (decimal hassasiyeti)
5. Finance DB catalog fonksiyonları (Grup A0 + A: 8)
6. Core tenant_payment_provider fonksiyonları (Grup B: 3)
7. Core tenant_payment_method fonksiyonları (Grup C: 4)
8. Tenant DB tablo modify (payment_method_limits, payment_method_settings, payment_player_limits)
9. Tenant sync fonksiyonları (Grup D: 3)
10. Tenant BO + Cashier fonksiyonları (Grup E: 5)
11. Tenant player limit fonksiyonları (Grup F: 3)
12. Deploy dosyaları güncelle
13. Doküman: FUNCTIONS_CORE.md, FUNCTIONS_TENANT.md

## Doğrulama

- [ ] Her fonksiyonun DROP + CREATE syntax kontrolü
- [ ] Deploy script sırasının tutarlılığı
- [ ] MCP ile tenant DB'de ALTER sonrası kolon kontrolü
- [ ] Fonksiyon imza/return type doğrulama
- [ ] Limit hiyerarşisi test: provider ceiling >= tenant limit >= player limit
- [ ] Cross-DB orchestration akışlarının backend seviyesinde test edilmesi
