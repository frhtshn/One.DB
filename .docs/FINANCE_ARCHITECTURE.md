# Finance Gateway Yönetim Sistemi - Tam Mimari Plan

## Context

Finance gateway entegrasyonundan tenant sitesine kadar tam ödeme yöntemi yaşam döngüsü. **Finance DB, payment catalog'un sahibidir** (bounded context). Gateway feedback servisi Finance DB'ye yazar, Core DB yalnızca tenant mapping tutar.

Mevcut tablolar: `catalog.payment_providers`, `catalog.payment_methods`, `catalog.payment_method_currency_limits` (Finance DB), `core.tenant_payment_methods` (Core DB), `finance.payment_method_settings`, `finance.payment_method_limits`, `finance.payment_player_limits` (Tenant DB). Catalog CRUD fonksiyonları (6 adet) Finance DB'ye taşınacak. Tenant mapping ve tenant DB fonksiyonları yazılmamış. Eksikler: per-currency limit tablosu fonksiyonları, crypto desteği (CHAR(3) → VARCHAR(20)), tenant provider yönetim fonksiyonları.

**Senaryo Özeti:**
1. Finance gateway feedback servisi → Finance DB: `catalog.payment_methods` + currency limitleri doldurur (sürekli background)
2. BO'dan tenant'a provider açılır → Backend Finance DB'den metotları alır → Core'da tenant_payment_methods seed edilir
3. Backend sync grain → Tenant DB'ye payment_method_settings/limits senkronize edilir
4. Metotlar tenant sitesinde anında aktifleşir
5. Tenant metotları BO'dan düzenleyebilir (isim, görsel, sıralama, limitler)
6. Core'da metot kapanırsa → tenant'ta da kapanır (soft delete)
7. Provider kapanırsa → metotlar gösterilmez (state değişmez)

**Kararlar:**
- **Finance DB catalog owner**: Ödeme kataloğu Finance DB'de yaşar. Core DB'de catalog.payment_methods YOKTUR.
- **catalog.payment_providers**: Finance DB'de hafif provider referans tablosu. Core'daki catalog.providers ile aynı ID'ler kullanılır (cross-DB tutarlılık). Backend tarafından `payment_provider_sync` ile senkronize edilir.
- **core.tenant_payment_methods denormalize alanlar**: `payment_method_name`, `payment_method_code`, `provider_code`, `payment_type`, `icon_url` — BO listesi cross-DB JOIN yapmadan gösterilir. Backend seed/sync sırasında doldurur.
- **tenant_payment_provider_enable refactored**: Backend Finance DB'den metot listesini alır, `p_method_data TEXT` (JSONB) olarak Core fonksiyonuna geçirir. Core fonksiyon catalog.payment_methods sorgusu YAPMAZ.
- **Mevcut catalog CRUD taşınır**: 6 mevcut fonksiyon (payment_method_create/update/delete/get/list/lookup) Core'dan Finance DB'ye taşınır. Aynı imzaları korur, sadece `catalog.providers` JOIN'ları `catalog.payment_providers` JOIN'larına dönüşür.
- Provider spesifik ayarlar (API key, endpoint, merchant_id) gateway katmanında tutulacak. DB'ye ek tablo eklenmeyecek.
- Payment limitleri için fiat/crypto tek tablo + `currency_type` (ayrı tablo değil). Game mimarisiyle tutarlı.
- **Provider disable stratejisi**: Provider kapatıldığında metotların `is_enabled` değeri DEĞİŞMEZ. Sorgu seviyesinde provider durumu filtrelenir. Böylece provider tekrar açıldığında metot state'leri korunur ve tenant'ın manuel kapattığı metotlar yanlışlıkla açılmaz.
- **Bulk sync**: Gateway feedback servisi toplu currency limit yazar. `payment_method_currency_limit_sync` JSONB array kabul eder, tek transaction.
- **Hard DELETE yok**: Tüm tablolarda soft delete. Artık desteklenmeyen limitler `is_active=false` olur.
- **Cursor pagination**: Cashier liste fonksiyonlarında OFFSET yerine cursor-based pagination (display_order, id).
- **Sync fonksiyonları TEXT→JSONB**: `payment_method_settings_sync` çok parametre yerine `p_catalog_data TEXT` kabul eder, fonksiyon içinde JSONB'ye cast edilir, typed kolonlara extract edilerek yazılır.
- **TEXT→JSONB fonksiyon parametreleri**: Array/bulk veriler fonksiyonlara **TEXT** olarak gelir, fonksiyon içinde `v_json := p_param::JSONB` ile cast edilir. Dapper (C#) TEXT gönderir.
- **Typed tablo yapısı**: `catalog.payment_methods` (~31 kolon) ve `finance.payment_method_settings` (~30 kolon) tüm alanları typed kolon olarak tutar.
- **Sync tetikleme**: Outbox pattern ile event-driven (mevcut altyapı). Polling yok.
- **Limit hiyerarşisi**: Provider default (catalog) → Platform-to-tenant ceiling (core.tenant_provider_limits) → Tenant site limiti (finance.payment_method_limits) → Player bireysel limit (finance.payment_player_limits). Her seviye üst seviyeyi aşamaz.
- **Tenant provider fonksiyonları**: Game ve Finance provider'lar için ayrı fonksiyonlar. `core.tenant_providers` paylaşımlı tablo, ancak seeding mantığı farklı olduğu için ayrı fonksiyonlar daha temiz.

---

## Mevcut Durum

| Tablo | DB | Durum | Sorun |
|---|---|---|---|
| `catalog.payment_providers` | **Finance** | Dosyada | YENİ — Core'dan sync gerekli |
| `catalog.payment_methods` | **Finance** | Dosyada | Core'dan taşındı, `supported_cryptocurrencies` eklendi |
| `catalog.payment_method_currency_limits` | **Finance** | Dosyada | YENİ |
| `catalog.providers` | Core | **DEPLOYED** | OK (tüm provider tipleri, shared) |
| `catalog.provider_types` | Core | **DEPLOYED** | OK (GAME, PAYMENT, SMS, KYC) |
| `catalog.provider_settings` | Core | **DEPLOYED** | OK (global key-value), per-tenant config yok (gateway'de) |
| `core.tenant_providers` | Core | **DEPLOYED** | OK, formal UQ constraint eklendi (Game mimarisiyle paylaşımlı) |
| `core.tenant_payment_methods` | Core | Dosyada güncellendi | Denormalize alanlar eklendi, FK→catalog.payment_methods kaldırıldı (cross-DB) |
| `core.tenant_provider_limits` | Core | **DEPLOYED** | `decimal(18,2)` crypto hassasiyeti yetersiz, currency_code yok |
| `finance.payment_method_settings` | Tenant | **DEPLOYED** | `allowed_countries` eksik |
| `finance.payment_method_limits` | Tenant | **DEPLOYED** | `currency_code CHAR(3)` crypto desteklemez, `currency_type` yok, `is_active` yok |
| `finance.payment_player_limits` | Tenant | **DEPLOYED** | `currency_code` yok, `decimal(18,2)` crypto yetersiz |

**Mevcut Fonksiyonlar:**
- Catalog CRUD: `payment_method_create/update/delete/get/list/lookup` (6 fonksiyon) → **Finance DB'ye taşınacak** ✅
- Provider CRUD: `provider_create/update/delete/get/list/lookup` (6 fonksiyon) → Core'da kalır (shared) ✅
- Tenant currency mapping: `tenant_currency_upsert/list/mapping_list` (3 fonksiyon) ✅
- Tenant crypto mapping: `tenant_cryptocurrency_upsert/list/mapping_list` (3 fonksiyon) ✅
- Tenant finance rates: `currency_rates_bulk_upsert/latest_list`, `crypto_rates_bulk_upsert/latest_list` (4 fonksiyon) ✅
- **Tenant payment method yönetimi: YOK** ❌
- **Tenant provider (PAYMENT) yönetimi: YOK** ❌
- **Tenant DB sync fonksiyonları: YOK** ❌

**Kritik**: `catalog.provider_types` ile `providers.provider_type_id` üzerinden PAYMENT provider filtrelemesi yapılabilir.

---

## Katmanlı Mimari

```
KATMAN 1: CATALOG (Finance DB) - Provider API verisi, Finance Gateway domain
  catalog.payment_providers           -- Payment-type provider referansı (Core sync)
  catalog.payment_methods             -- Master ödeme yöntemi listesi (~31 kolon)
  catalog.payment_method_currency_limits -- Per-method, per-currency limitler (provider'dan)

KATMAN 2: TENANT MAPPING (Core DB) - BO yönetimi
  catalog.providers                   -- Tüm provider tipleri (shared: GAME, PAYMENT, SMS, KYC)
  core.tenant_providers               -- Provider enable/disable per tenant (GAME + PAYMENT paylaşımlı)
  core.tenant_payment_methods         -- Method enable/disable + limit overrides + sync_status + denormalize alanlar
  core.tenant_provider_limits         -- Platform-to-tenant limit ceiling (admin tarafından)
  (IDOR korumalı, sync_status takibi)

KATMAN 3: TENANT (Tenant DB) - Runtime denormalize kopya
  finance.payment_method_settings     -- Denormalize metot verisi + tenant özelleştirmeleri
  finance.payment_method_limits       -- Per-method, per-currency limitler (catalog seed + tenant override)
  finance.payment_player_limits       -- Player bireysel limitler (self/admin/responsible_gaming)
  (Auth-agnostic, cross-DB auth pattern)
```

**Cross-DB İletişim:**
```
Finance DB ←→ Core DB ←→ Tenant DB
       Backend orchestrator (ayrı connection'lar)
```

**Limit Hiyerarşisi:**
```
catalog.payment_method_currency_limits   → Provider varsayılanı (ceiling)
  ↓ (platform admin override)
core.tenant_provider_limits              → Platform-to-tenant ceiling
  ↓ (tenant admin override, ≤ üst limit)
finance.payment_method_limits            → Tenant site limiti (cashier'da gösterilen)
  ↓ (player self-limit veya admin-imposed)
finance.payment_player_limits            → Player bireysel limit (en kısıtlayıcı)
```

---

## ADIM 1: Tablo Değişiklikleri

### 1A. YENİ TABLO: `catalog.payment_providers` (Finance DB)

Core DB'deki `catalog.providers` tablosunun PAYMENT tipli alt kümesinin hafif kopyası. Aynı ID'ler kullanılır.

Dosya: `finance/tables/catalog/payment_providers.sql`

```
catalog.payment_providers
  id              BIGINT PK               -- Core catalog.providers.id ile aynı (SERIAL değil)
  provider_code   VARCHAR(50) NOT NULL UQ  -- PAYTR, MPAY, PAPARA
  provider_name   VARCHAR(255) NOT NULL    -- PayTR, mPay, Papara
  is_active       BOOLEAN NOT NULL DEFAULT true
  created_at      TIMESTAMP DEFAULT now()
  updated_at      TIMESTAMP DEFAULT now()
```

### 1B. YENİ TABLO: `catalog.payment_method_currency_limits` (Finance DB)

Provider API'den gelen per-method, per-currency limit ve fee bilgileri.
Gateway feedback servisi bu tabloyu doldurur. `catalog.payment_methods`'deki min_deposit/max_deposit referans olarak kalır.

Dosya: `finance/tables/catalog/payment_method_currency_limits.sql`

```
catalog.payment_method_currency_limits
  id                      BIGSERIAL PK
  payment_method_id       BIGINT NOT NULL           -- FK: catalog.payment_methods(id) ON DELETE CASCADE
  currency_code           VARCHAR(20) NOT NULL       -- TRY, USD, BTC, ETH, DOGE
  currency_type           SMALLINT NOT NULL DEFAULT 1  -- 1=Fiat, 2=Crypto

  -- Para Yatırma Limitleri
  min_deposit             DECIMAL(18,8) NOT NULL
  max_deposit             DECIMAL(18,8) NOT NULL
  daily_deposit_limit     DECIMAL(18,8)
  monthly_deposit_limit   DECIMAL(18,8)

  -- Para Çekme Limitleri
  min_withdrawal          DECIMAL(18,8) NOT NULL
  max_withdrawal          DECIMAL(18,8) NOT NULL
  daily_withdrawal_limit  DECIMAL(18,8)
  monthly_withdrawal_limit DECIMAL(18,8)

  -- Ücret Yapısı (Para Yatırma)
  deposit_fee_percent     DECIMAL(5,4) DEFAULT 0
  deposit_fee_fixed       DECIMAL(18,8) DEFAULT 0

  -- Ücret Yapısı (Para Çekme)
  withdrawal_fee_percent  DECIMAL(5,4) DEFAULT 0
  withdrawal_fee_fixed    DECIMAL(18,8) DEFAULT 0

  is_active               BOOLEAN NOT NULL DEFAULT true  -- Soft delete
  created_at              TIMESTAMP DEFAULT now()
  updated_at              TIMESTAMP DEFAULT now()
  UNIQUE(payment_method_id, currency_code)
```

### 1C. MODIFY: `catalog.payment_methods` (Finance DB)

Dosya: `finance/tables/catalog/payment_methods.sql` (Core'dan taşındı)
- ADD `supported_cryptocurrencies VARCHAR(20)[] DEFAULT '{}'` (supported_currencies sonrası)
- FK: `provider_id` → `catalog.payment_providers(id)` (Finance DB içi, Core'a değil)
- Mevcut `supported_currencies CHAR(3)[]`, `min_deposit/max_deposit` vb. olduğu gibi kalır (referans)
- Tüm kolonlar typed kalır (~31 kolon).

### 1D. MODIFY: `core.tenant_payment_methods` (Core DB)

Dosya: `core/tables/core/integration/tenant_payment_methods.sql`
- FK `payment_method_id → catalog.payment_methods` **KALDIRILDI** (cross-DB, backend doğrular)
- ADD denormalize alanlar (cross-DB JOIN yerine):
  - `payment_method_name VARCHAR(255)` — BO listesinde gösterilir
  - `payment_method_code VARCHAR(100)` — BO filtreleme/arama
  - `provider_code VARCHAR(50)` — BO provider filtresi
  - `payment_type VARCHAR(50)` — BO tip filtresi
  - `icon_url VARCHAR(500)` — BO listesinde ikon

### 1E. MODIFY: `finance.payment_method_limits` (Tenant DB)

Dosya: `tenant/tables/finance/payment_method_limits.sql`
- `currency_code` CHAR(3) → VARCHAR(20) (crypto desteği: BTC, ETH, DOGE)
- ADD `currency_type SMALLINT NOT NULL DEFAULT 1` (1=Fiat, 2=Crypto)
- ADD `is_active BOOLEAN NOT NULL DEFAULT true` (soft delete: provider artık desteklemiyorsa false)

> **Neden ayrı tablo değil?** Core'da fiat/crypto ayrı tablo (tenant_currencies / tenant_cryptocurrencies) ama payment limitleri için yapı aynı. Tek tablo + currency_type daha pragmatik. Game mimarisiyle tutarlı.

### 1F. MODIFY: `finance.payment_method_settings` (Tenant DB)

Dosya: `tenant/tables/finance/payment_method_settings.sql`
- ADD `allowed_countries CHAR(2)[] DEFAULT '{}'` (blocked_countries sonrası)

### 1G. MODIFY: `finance.payment_player_limits` (Tenant DB)

Dosya: `tenant/tables/finance/payment_player_limits.sql`
- ADD `currency_code VARCHAR(20) NOT NULL DEFAULT 'TRY'` (payment_method_code sonrası)
- ADD `currency_type SMALLINT NOT NULL DEFAULT 1` (1=Fiat, 2=Crypto)
- `decimal(18,2)` → `decimal(18,8)` (tüm limit alanları, crypto hassasiyeti)
- UNIQUE constraint: `(player_id, payment_method_id)` → `(player_id, payment_method_id, currency_code)`

> **Neden per-currency?** Fiat ve crypto ölçekleri çok farklı. 100 TRY limit ile 0.001 BTC limit aynı tabloda ama farklı currency_code ile tutulmalı.

### 1H. MODIFY: `core.tenant_provider_limits` (Core DB)

Dosya: `core/tables/core/integration/tenant_provider_limits.sql`
- `decimal(18,2)` → `decimal(18,8)` (tüm limit alanları, crypto hassasiyeti)
- Yapı olarak değişiklik yok. Currency-agnostic kalır (platform admin genel tavan belirler).

> **tenant_provider_limits vs tenant_payment_methods.override_* örtüşmesi:**
> `core.tenant_provider_limits` = Platform admin'in tenant'a koyduğu tavan (Nucleo → Tenant)
> `core.tenant_payment_methods.override_*` = Tenant admin'in kendi sitesi için ayarladığı limitler (Tenant → Site)
> İki farklı yetki seviyesi, örtüşme yok.

### 1I. Constraint ve Index Güncellemeleri

**Finance DB** (`finance/constraints/catalog.sql`):
- `uq_payment_providers_code` UNIQUE(provider_code)
- `fk_payment_methods_provider` FK → catalog.payment_providers(id)
- `uq_payment_methods_provider_code` UNIQUE(provider_id, payment_method_code)
- `fk_pm_currency_limits_method` FK → catalog.payment_methods(id) ON DELETE CASCADE
- `uq_pm_currency_limits` UNIQUE(payment_method_id, currency_code)

**Finance DB** (`finance/indexes/catalog.sql`):
- `idx_payment_providers_code` UNIQUE BTREE(provider_code)
- `idx_payment_providers_active` BTREE(is_active) WHERE is_active = true
- Tüm mevcut payment_methods index'leri (Core'dan taşındı)
- `idx_pm_currency_limits_method` BTREE(payment_method_id)
- `idx_pm_currency_limits_currency_type` BTREE(currency_type)
- `idx_pm_currency_limits_active` BTREE(payment_method_id) WHERE is_active = true

**Core DB** (`core/constraints/catalog.sql`):
- `fk_payment_methods_provider`, `uq_payment_methods_provider_code` **KALDIRILDI** (Finance DB'ye taşındı)

**Core DB** (`core/constraints/core.sql`):
- `fk_tenant_payment_methods_method` **KALDIRILDI** (cross-DB, FK yok)
- NOT: `uq_tenant_providers` UNIQUE(tenant_id, provider_id) zaten ekli (Game mimarisiyle paylaşımlı)

**Core DB** (`core/indexes/catalog.sql`):
- Tüm `idx_payment_methods_*` index'leri **KALDIRILDI** (Finance DB'ye taşındı)

**Tenant** (`tenant/constraints/finance.sql`):
- payment_method_limits: CHAR(3) → VARCHAR(20) uyumu
- payment_player_limits: UNIQUE constraint güncelle → (player_id, payment_method_id, currency_code)

**Tenant** (`tenant/indexes/finance.sql`):
- `idx_payment_method_settings_cursor` BTREE(display_order, id) — cursor pagination için
- payment_method_limits: currency_type index
- payment_player_limits: currency_code index

---

## ADIM 2: Fonksiyonlar (26 fonksiyon)

### Grup A0: Finance DB - Provider Sync (1)

Klasör: `finance/functions/catalog/`
Pattern: SECURITY DEFINER (platform seviyesi, IDOR yok)

| # | Dosya | Açıklama | Return |
|---|-------|----------|--------|
| 0 | `payment_provider_sync.sql` | Backend: Core'dan payment provider'ları sync et (JSONB array) | INTEGER (upsert sayısı) |

**payment_provider_sync detay:**
```
Params: p_providers TEXT   -- TEXT → JSONB cast
  v_providers := p_providers::JSONB;

  p_providers format: [
    {"id":5,"provider_code":"PAYTR","provider_name":"PayTR","is_active":true},
    {"id":6,"provider_code":"MPAY","provider_name":"mPay","is_active":true},
    {"id":7,"provider_code":"PAPARA","provider_name":"Papara","is_active":true},
    ...
  ]

Loop: JSONB array → her eleman için:
  - id, provider_code, provider_name, is_active extract
  - UPSERT: id bazlı → UPDATE or INSERT
  - Normalize: UPPER(provider_code)
Return: upsert edilen provider sayısı

Kullanım: Backend, Core DB'den PAYMENT tipli provider'ları alıp bu fonksiyona geçirir.
Tetikleme: Provider create/update/delete sırasında veya periyodik sync.
```

---

### Grup A: Finance DB - Catalog Payment Method CRUD + Sync (7)

Klasör: `finance/functions/catalog/`
Pattern: SECURITY DEFINER (platform seviyesi, IDOR yok)

| # | Dosya | Açıklama | Return |
|---|-------|----------|--------|
| 1 | `payment_method_create.sql` | **TAŞINDI** — Yeni metot oluştur (feedback servis) | BIGINT (method id) |
| 2 | `payment_method_update.sql` | **TAŞINDI** — Metot güncelle (COALESCE pattern) | VOID |
| 3 | `payment_method_delete.sql` | **TAŞINDI** — Metot kapat (soft delete: is_active=false) | VOID |
| 4 | `payment_method_get.sql` | **TAŞINDI** — Tekil metot detay (JOIN payment_providers) | TABLE/JSONB |
| 5 | `payment_method_list.sql` | **TAŞINDI** — Filtreli liste | TABLE/JSONB |
| 6 | `payment_method_lookup.sql` | **TAŞINDI** — Dropdown hafif liste | TABLE |
| 7 | `payment_method_currency_limit_sync.sql` | **YENİ** — Per-method currency limit bulk upsert (soft delete) | VOID |

> **NOT**: #1-6 mevcut Core fonksiyonlarıdır. Finance DB'ye taşınırken `catalog.providers` JOIN'ları `catalog.payment_providers` JOIN'larına dönüşür. İmza ve davranış aynı kalır.

**payment_method_currency_limit_sync detay:**
```
Params: p_payment_method_id BIGINT, p_limits TEXT   -- TEXT → JSONB cast
  v_limits := p_limits::JSONB;
  p_limits format: [
    {"cc":"TRY","ct":1,"min_dep":10,"max_dep":50000,"min_wd":50,"max_wd":25000,
     "daily_dep":100000,"daily_wd":50000,"monthly_dep":500000,"monthly_wd":250000,
     "dep_fee_pct":0,"dep_fee_fix":0,"wd_fee_pct":0.01,"wd_fee_fix":2.50},
    {"cc":"BTC","ct":2,"min_dep":0.0001,"max_dep":1.0,"min_wd":0.001,"max_wd":0.5,
     "daily_dep":2.0,"daily_wd":1.0,"monthly_dep":10.0,"monthly_wd":5.0,
     "dep_fee_pct":0,"dep_fee_fix":0,"wd_fee_pct":0.005,"wd_fee_fix":0},
    ...
  ]

Validasyon: payment_method_id EXISTS (catalog.payment_methods)
Loop: JSONB array → her eleman extract → typed kolonlara INSERT ON CONFLICT (payment_method_id, currency_code) DO UPDATE
Artık desteklenmeyen limitler: p_limits'te olmayan currency'ler → is_active=false (HARD DELETE YOK)
Tekrar desteklenirse: is_active=true + değerler güncellenir
```

---

### Grup B: Core - Tenant Payment Provider Yönetimi (3)

Klasör: `core/functions/core/tenant_payment_providers/`
Pattern: IDOR korumalı (`user_assert_access_company`)

| # | Dosya | Açıklama | Return |
|---|-------|----------|--------|
| 8 | `tenant_payment_provider_enable.sql` | Provider aç + backend'den gelen metotları seed et | INTEGER (eklenen metot) |
| 9 | `tenant_payment_provider_disable.sql` | Provider kapat (sadece flag, metotlara dokunmaz) | VOID |
| 10 | `tenant_payment_provider_list.sql` | Tenant PAYMENT provider listesi | JSONB |

> **Neden Game provider fonksiyonlarından ayrı?** `core.tenant_providers` paylaşımlı tablo ama seeding mantığı tamamen farklı. Game: tenant_games. Finance: tenant_payment_methods. Ayrı fonksiyonlar daha temiz.

**tenant_payment_provider_enable detay (refactored — cross-DB orchestration):**
```
Params: p_caller_id, p_tenant_id, p_provider_id, p_method_data TEXT DEFAULT NULL, p_mode DEFAULT 'real'
  -- p_method_data: Backend'in Finance DB'den aldığı metot listesi (JSONB array)
  -- Format: [{"payment_method_id":1,"payment_method_name":"mPay Kredi Kartı",
  --           "payment_method_code":"mpay_credit_card","provider_code":"MPAY",
  --           "payment_type":"CARD","icon_url":"..."},...]

1. SELECT company_id FROM core.tenants WHERE id = p_tenant_id
   -> NOT FOUND: RAISE 'error.tenant.not-found'
2. PERFORM security.user_assert_access_company(p_caller_id, v_company_id)
3. Validate: provider EXISTS + provider_type_id -> provider_type_code = 'PAYMENT'
   -> NOT FOUND: RAISE 'error.provider.not-found'
   -> NOT PAYMENT: RAISE 'error.provider.not-payment-type'
4. UPSERT core.tenant_providers (is_enabled=true, mode=p_mode)
   ON CONFLICT (tenant_id, provider_id) DO UPDATE SET is_enabled=true, mode=p_mode
5. IF p_method_data IS NOT NULL THEN
     v_methods := p_method_data::JSONB;
     FOR elem IN SELECT * FROM jsonb_array_elements(v_methods) LOOP
       INSERT INTO core.tenant_payment_methods (tenant_id, payment_method_id,
                                                 payment_method_name, payment_method_code,
                                                 provider_code, payment_type, icon_url,
                                                 sync_status, created_by)
       VALUES (p_tenant_id, (elem->>'payment_method_id')::BIGINT,
               elem->>'payment_method_name', elem->>'payment_method_code',
               elem->>'provider_code', elem->>'payment_type', elem->>'icon_url',
               'pending', p_caller_id)
       ON CONFLICT (tenant_id, payment_method_id) DO NOTHING;
     END LOOP;
   END IF;
6. GET DIAGNOSTICS v_count = ROW_COUNT
7. RETURN v_count

NOT: Mevcut metotların is_enabled durumuna DOKUNULMAZ.
Provider daha önce kapatılıp tekrar açılıyorsa, metot state'leri korunur.
Sadece yeni metotlar seed edilir (ON CONFLICT DO NOTHING).

BACKEND ORCHESTRATION:
  1. Backend → Finance DB: payment_method_list(provider_id=X, is_active=true)
  2. Backend → method_data JSONB oluşturur (method_id + denorm alanlar)
  3. Backend → Core DB: tenant_payment_provider_enable(caller, tenant, provider, method_data)
```

**tenant_payment_provider_disable detay:**
```
Params: p_caller_id, p_tenant_id, p_provider_id

1. Tenant + IDOR check
2. UPDATE core.tenant_providers SET is_enabled=false, updated_at=now()
   WHERE tenant_id = p_tenant_id AND provider_id = p_provider_id
3. RETURN (void)

NOT: Metotlara (core.tenant_payment_methods) DOKUNULMAZ.
Provider durumu sorgu seviyesinde filtrelenir.
Tenant'ın metot bazlı enable/disable kararları korunur.
Provider tekrar açıldığında ayrıca güncelleme gerekmez.
```

**tenant_payment_provider_list detay:**
```
Params: p_caller_id, p_tenant_id

IDOR + JSONB return:
  JOIN catalog.providers p, catalog.provider_types pt
  Fields: id, providerId, providerCode, providerName, providerType,
          mode, isEnabled, methodCount (subquery from tenant_payment_methods), createdAt, updatedAt
  WHERE pt.provider_type_code = 'PAYMENT' -- sadece payment provider'lar
  ORDER BY p.provider_name
```

---

### Grup C: Core - Tenant Payment Method Yönetimi (4)

Klasör: `core/functions/core/tenant_payment_methods/`
Tümü: IDOR korumalı

| # | Dosya | Açıklama | Return |
|---|-------|----------|--------|
| 11 | `tenant_payment_method_upsert.sql` | Tekil metot aç/düzenle (limit override, visibility) | VOID |
| 12 | `tenant_payment_method_list.sql` | Metot listesi (denormalize alanlardan, cross-DB JOIN yok) | JSONB |
| 13 | `tenant_payment_method_remove.sql` | Metot kapat (soft: is_enabled=false + reason) | VOID |
| 14 | `tenant_payment_method_refresh.sql` | Backend'den gelen yeni metotları toplu seed | INTEGER |

**tenant_payment_method_upsert validasyonlar:**
```
Params: p_caller_id, p_tenant_id, p_payment_method_id,
        p_is_enabled, p_is_visible, p_is_featured, p_display_order,
        p_custom_name, p_custom_icon_url, p_custom_description,
        p_allow_deposit, p_allow_withdrawal,
        p_override_min_deposit, p_override_max_deposit,
        p_override_min_withdrawal, p_override_max_withdrawal,
        p_override_daily_deposit_limit, p_override_daily_withdrawal_limit,
        p_override_deposit_fee_percent, p_override_deposit_fee_fixed,
        p_override_withdrawal_fee_percent, p_override_withdrawal_fee_fixed,
        p_override_kyc_level,
        p_allowed_platforms, p_blocked_countries, p_allowed_countries,
        p_available_from, p_available_until

1. Tenant exists -> company_id -> IDOR
2. payment_method_id EXISTS in core.tenant_payment_methods (kaydı Core'da olmalı)
3. UPSERT: (tenant_id, payment_method_id) -> UPDATE or INSERT
4. sync_status = 'pending'

NOT: catalog.payment_methods validasyonu YAPILMAZ (cross-DB). Backend geçerli payment_method_id geçirir.
```

**tenant_payment_method_list detay:**
```
Params: p_caller_id, p_tenant_id,
        p_provider_code?, p_payment_type?, p_is_enabled?, p_search?, p_limit?, p_offset?

IDOR + denormalize alanlardan JSONB return:
  SELECT FROM core.tenant_payment_methods tpm
  -- NOT: catalog.payment_methods JOIN YOK (cross-DB). Denormalize alanlar kullanılır.

JSONB fields:
  id, paymentMethodId, paymentMethodName, paymentMethodCode, providerCode, paymentType, iconUrl,
  isEnabled, isVisible, isFeatured, displayOrder,
  customName, customIconUrl, customDescription,
  allowDeposit, allowWithdrawal,
  overrideMinDeposit, overrideMaxDeposit, overrideMinWithdrawal, overrideMaxWithdrawal,
  overrideDailyDepositLimit, overrideDailyWithdrawalLimit,
  allowedPlatforms, blockedCountries, allowedCountries,
  availableFrom, availableUntil,
  syncStatus, lastSyncedAt, createdAt, updatedAt

NOT: Provider durumuna göre FİLTRE YOK. BO admin tüm metotları görür.
Provider durumu tenant_payment_provider_list'ten ayrıca sorgulanır.
```

**tenant_payment_method_refresh (refactored — cross-DB orchestration):**
```
Params: p_caller_id, p_tenant_id, p_provider_id, p_method_data TEXT
  -- p_method_data: Backend'in Finance DB'den aldığı yeni metot listesi (JSONB array)
  -- Aynı format: [{"payment_method_id":1,"payment_method_name":"...",
  --                "payment_method_code":"...","provider_code":"...",
  --                "payment_type":"...","icon_url":"..."},...]

IDOR + Provider type=PAYMENT check
Loop: JSONB array → INSERT INTO core.tenant_payment_methods (denorm alanlar ile)
ON CONFLICT (tenant_id, payment_method_id) DO NOTHING
RETURN inserted count

BACKEND ORCHESTRATION:
  1. Backend → Finance DB: payment_method_list(provider_id=X, is_active=true)
  2. Backend → Core DB: tenant_payment_method_refresh(caller, tenant, provider, method_data)
```

---

### Grup D: Tenant - Sync (3)

Klasör: `tenant/functions/finance/`
Tümü: Auth-agnostic (backend çağırır, auth core'da yapılmış)

| # | Dosya | Açıklama | Return |
|---|-------|----------|--------|
| 15 | `payment_method_settings_sync.sql` | Core→Tenant: method data upsert (TEXT→JSONB, tenant overrides korunur) | VOID |
| 16 | `payment_method_settings_remove.sql` | Metot devre dışı bırak (soft delete: is_enabled=false) | VOID |
| 17 | `payment_method_limits_sync.sql` | Core→Tenant: currency limits seed/update (soft delete) | VOID |

> ~~`payment_method_settings_disable_by_provider`~~: Kaldırıldı. Provider durumu sorgu seviyesinde filtrelenir, metot state'leri değişmez.

**payment_method_settings_sync detay:**
```
Params: p_payment_method_id BIGINT, p_catalog_data TEXT, p_tenant_overrides TEXT DEFAULT NULL
  -- TEXT → JSONB cast (fonksiyon içi)
  v_catalog := p_catalog_data::JSONB;
  v_overrides := COALESCE(p_tenant_overrides, '{}')::JSONB;

p_catalog_data format: {
  "provider_id": 5, "external_method_id": "mpay_cc",
  "payment_method_code": "mpay_credit_card",
  "payment_method_name": "mPay Kredi Kartı", "provider_code": "mpay",
  "payment_type": "CARD", "payment_subtype": "CREDIT", "channel": "ONLINE",
  "icon_url": "...", "logo_url": "...",
  "supports_deposit": true, "supports_withdrawal": false, "supports_refund": false,
  "features": ["INSTANT","3DS"], "supports_recurring": false, "supports_tokenization": true,
  "requires_kyc_level": 1, "requires_3ds": true, "requires_verification": false,
  "is_mobile": true, "is_desktop": true,
  "deposit_processing_time": "INSTANT", "withdrawal_processing_time": null,
  "supported_currencies": ["TRY","USD","EUR"],
  "supported_cryptocurrencies": ["BTC","ETH"]
}

p_tenant_overrides format (sadece INSERT'te kullanılır): {
  "display_order": 0, "is_visible": true, "is_enabled": true, "is_featured": false,
  "allow_deposit": true, "allow_withdrawal": false,
  "blocked_countries": [], "allowed_countries": [],
  "custom_name": null, "custom_icon_url": null
}

Fonksiyon içi: JSONB'den extract → typed kolonlara yazar
Upsert: payment_method_id unique → UPDATE / INSERT
  INSERT → v_catalog'dan extract edilen tüm catalog alanları + v_overrides'dan tenant alanları
  UPDATE → SADECE catalog alanları güncellenir
           Tenant override alanları (custom_name, display_order, is_featured vb.) DOKUNULMAZ
core_synced_at = NOW()

BACKEND ORCHESTRATION:
  1. Backend → Finance DB: payment_method_get(method_id) → catalog data
  2. Backend → Core DB: tenant_payment_methods → tenant overrides
  3. Backend → Tenant DB: payment_method_settings_sync(method_id, catalog_data, overrides)
```

**payment_method_settings_remove detay:**
```
Params: p_payment_method_id BIGINT

Soft delete:
  UPDATE finance.payment_method_settings
  SET is_enabled = false, updated_at = now()
  WHERE payment_method_id = p_payment_method_id

NOT: Fiziksel DELETE yok. payment_method_limits kayıtları da korunur.
```

**payment_method_limits_sync detay:**
```
Params: p_payment_method_id BIGINT, p_limits TEXT   -- TEXT → JSONB cast
  v_limits := p_limits::JSONB;
  p_limits format: [
    {"currency_code":"TRY","currency_type":1,"min_deposit":10,"max_deposit":50000,
     "min_withdrawal":50,"max_withdrawal":25000,
     "daily_deposit_limit":100000,"daily_withdrawal_limit":50000,
     "monthly_deposit_limit":500000,"monthly_withdrawal_limit":250000,
     "deposit_fee_percent":0,"deposit_fee_fixed":0,
     "withdrawal_fee_percent":0.01,"withdrawal_fee_fixed":2.50,
     "deposit_fee_min":null,"deposit_fee_max":null,
     "withdrawal_fee_min":null,"withdrawal_fee_max":null},
    ...
  ]

Validasyon: payment_method_id EXISTS in finance.payment_method_settings
Loop: JSONB array → her eleman extract → typed kolonlara INSERT ON CONFLICT (payment_method_id, currency_code) DO UPDATE
Artık desteklenmeyen limitler → is_active=false (HARD DELETE YOK)
Tekrar desteklenirse: is_active=true + değerler güncellenir
```

---

### Grup E: Tenant - BO Yönetim + Cashier (5)

Klasör: `tenant/functions/finance/`
Tümü: Auth-agnostic (cross-DB auth pattern)

| # | Dosya | Açıklama | Return |
|---|-------|----------|--------|
| 18 | `payment_method_settings_get.sql` | Tekil metot detay (cashier flow için) | JSONB |
| 19 | `payment_method_settings_update.sql` | Tenant customization güncelle | VOID |
| 20 | `payment_method_settings_list.sql` | Metot listesi (cashier + BO, cursor pagination, provider filtreli) | JSONB |
| 21 | `payment_method_limit_upsert.sql` | Metot limiti ekle/güncelle | VOID |
| 22 | `payment_method_limit_list.sql` | Metot limit listesi | JSONB |

**payment_method_settings_get detay:**
```
Params: p_payment_method_id BIGINT

Return JSONB: {
  paymentMethodId, providerId, providerCode, externalMethodId,
  paymentMethodCode, paymentMethodName,
  paymentType, paymentSubtype, channel,
  iconUrl, logoUrl, customIconUrl,
  allowDeposit, allowWithdrawal, supportsRefund,
  features, supportsRecurring, supportsTokenization,
  requiresKycLevel, requires3ds, requiresVerification,
  isMobile, isDesktop,
  isEnabled, isVisible, isFeatured,
  displayOrder, customName, customDescription,
  allowedPlatforms, blockedCountries, allowedCountries,
  availableFrom, availableUntil,
  depositProcessingTime, withdrawalProcessingTime,
  popularityScore, usageCount, coreSyncedAt
}

Validasyon: payment_method_id EXISTS → NOT FOUND: RAISE 'error.payment-method.not-found'

Kullanım: Cashier flow
  1. Player para yatırma/çekme seçer → Backend tenant DB'den payment_method_settings_get çağırır
  2. provider_id + external_method_id alır
  3. Gateway'e gRPC ile PaymentRequest gönderir
  4. Gateway, provider API'den işlem başlatır
  5. Player ödeme akışına yönlendirilir
```

**payment_method_settings_update detay:**
```
Params: p_payment_method_id + tüm tenant-editable alanlar DEFAULT NULL
Editable: custom_name, custom_icon_url, custom_description,
          display_order, is_visible, is_featured,
          allow_deposit, allow_withdrawal,
          allowed_platforms, blocked_countries, allowed_countries,
          available_from, available_until,
          deposit_processing_time, withdrawal_processing_time
COALESCE pattern: NULL = mevcut değeri koru
Validasyon: payment_method_id EXISTS in payment_method_settings
updated_at = now()
```

**payment_method_settings_list detay:**
```
Params: p_provider_ids BIGINT[] DEFAULT NULL,
        p_payment_type?, p_allow_deposit?, p_allow_withdrawal?,
        p_is_enabled?, p_is_visible?, p_search?,
        p_limit INT DEFAULT 50,
        p_cursor_order INT DEFAULT NULL,
        p_cursor_id BIGINT DEFAULT NULL

Filtreleme:
  - p_provider_ids NOT NULL ise: WHERE provider_id = ANY(p_provider_ids)
  - p_provider_ids NULL ise: tüm metotlar (BO admin görünümü)
  - p_payment_type: CARD, EWALLET, BANK, CRYPTO, MOBILE, VOUCHER
  - p_allow_deposit / p_allow_withdrawal: İşlem yönü filtresi
Search: ILIKE on payment_method_name, payment_method_code, custom_name

Cursor pagination:
  - İlk sayfa: p_cursor_order ve p_cursor_id NULL
  - Sonraki sayfalar: WHERE (display_order, id) > (p_cursor_order, p_cursor_id)
  - OFFSET yok → büyük kataloglarda sabit performans
ORDER BY: display_order ASC, id ASC
LIMIT: p_limit

JSONB array return + metadata: {items: [...], nextCursorOrder: N, nextCursorId: N, hasMore: bool}

KULLANIM:
  Cashier: p_provider_ids = [aktif provider ID'leri] + p_is_enabled = true + p_allow_deposit = true
  BO:      p_provider_ids = NULL (tüm metotları gösterir, disabled provider metotları da)
```

**payment_method_limit_upsert detay:**
```
Params: p_payment_method_id, p_currency_code, p_currency_type,
        p_min_deposit, p_max_deposit, p_min_withdrawal, p_max_withdrawal,
        p_daily_deposit_limit?, p_weekly_deposit_limit?, p_monthly_deposit_limit?,
        p_daily_withdrawal_limit?, p_weekly_withdrawal_limit?, p_monthly_withdrawal_limit?,
        p_deposit_fee_percent?, p_deposit_fee_fixed?, p_deposit_fee_min?, p_deposit_fee_max?,
        p_withdrawal_fee_percent?, p_withdrawal_fee_fixed?, p_withdrawal_fee_min?, p_withdrawal_fee_max?
Validasyon: payment_method_id EXISTS in payment_method_settings
UPSERT: (payment_method_id, currency_code) -> UPDATE or INSERT
```

**payment_method_limit_list detay:**
```
Params: p_payment_method_id
JSONB return: [{
  currencyCode, currencyType,
  minDeposit, maxDeposit, minWithdrawal, maxWithdrawal,
  dailyDepositLimit, weeklyDepositLimit, monthlyDepositLimit,
  dailyWithdrawalLimit, weeklyWithdrawalLimit, monthlyWithdrawalLimit,
  depositFeePercent, depositFeeFixed, depositFeeMin, depositFeeMax,
  withdrawalFeePercent, withdrawalFeeFixed, withdrawalFeeMin, withdrawalFeeMax,
  isActive
}]
WHERE is_active = true
ORDER BY: currency_type, currency_code
```

---

### Grup F: Tenant - Player Limitleri (3)

Klasör: `tenant/functions/finance/`
Tümü: Auth-agnostic

| # | Dosya | Açıklama | Return |
|---|-------|----------|--------|
| 23 | `payment_player_limit_set.sql` | Player limiti ekle/güncelle | VOID |
| 24 | `payment_player_limit_get.sql` | Player'ın belirli metot + currency limiti | JSONB |
| 25 | `payment_player_limit_list.sql` | Player'ın tüm limitleri | JSONB |

**payment_player_limit_set detay:**
```
Params: p_player_id, p_payment_method_id, p_currency_code, p_currency_type,
        p_limit_type VARCHAR(50),  -- 'self_imposed', 'responsible_gaming', 'admin_imposed'
        p_min_deposit?, p_max_deposit?, p_min_withdrawal?, p_max_withdrawal?,
        p_daily_deposit_limit?, p_daily_withdrawal_limit?,
        p_monthly_deposit_limit?, p_monthly_withdrawal_limit?

Validasyon:
  - player_id NOT NULL
  - payment_method_id EXISTS in payment_method_settings
  - p_limit_type IN ('self_imposed', 'responsible_gaming', 'admin_imposed')
  - Limit değerleri <= site limitleri (finance.payment_method_limits) kontrolü

UPSERT: (player_id, payment_method_id, currency_code) -> UPDATE or INSERT

NOT: self_imposed limitler player tarafından artırılamaz (cooling period).
     admin_imposed limitler sadece admin tarafından değiştirilebilir.
     Bu business logic backend'de uygulanır, fonksiyon sadece kayıt yapar.
```

**payment_player_limit_get detay:**
```
Params: p_player_id, p_payment_method_id, p_currency_code

JSONB return: {
  playerId, paymentMethodId, paymentMethodCode, currencyCode, currencyType,
  limitType, minDeposit, maxDeposit, minWithdrawal, maxWithdrawal,
  dailyDepositLimit, dailyWithdrawalLimit,
  monthlyDepositLimit, monthlyWithdrawalLimit,
  createdAt, updatedAt
}

Kullanım: Cashier'da player işlem yapmadan önce limit kontrolü.
```

**payment_player_limit_list detay:**
```
Params: p_player_id, p_payment_method_id? DEFAULT NULL

p_payment_method_id NULL → tüm metotlar için limitler
p_payment_method_id NOT NULL → sadece o metot için limitler

JSONB array return: [{...}, ...]
ORDER BY: payment_method_code, currency_code
```

---

## ADIM 3: Akış Diyagramları

### Akış 1: Provider API → Catalog (Background, sürekli)
```
Gateway Finance Feedback Service (sürekli çalışır)
  -> Finance DB: catalog.payment_method_create/update (taşınan fonksiyonlar)  -- metot CRUD
  -> Finance DB: catalog.payment_method_currency_limit_sync(method_id, limits_json)  -- per-currency limitleri
  -> Yeni metotlar eklenir, kapanan metotlar is_active=false
  -> Artık desteklenmeyen currency limitleri is_active=false (hard delete yok)

NOT: payment_method_create tekil oluşturma için.
payment_method_update tekil güncelleme için.
payment_method_currency_limit_sync toplu limit sync için.
```

### Akış 2: Tenant'a Provider Açma (BO action)
```
BO User -> Core: tenant_payment_provider_enable(caller, tenant, provider, method_data)
  1. IDOR check
  2. Provider type=PAYMENT kontrolü (catalog.providers Core'da)
  3. core.tenant_providers UPSERT (is_enabled=true)

  Backend orchestration (cross-DB):
  4. Backend -> Finance DB: payment_method_list(provider_id=X, is_active=true)
  5. Backend -> method_data JSONB oluşturur (method_id + denorm alanlar)
  6. Backend -> Core DB: tenant_payment_provider_enable(..., method_data)

  Core fonksiyon devam:
  7. p_method_data JSONB array → core.tenant_payment_methods toplu INSERT (denorm alanlar ile)
  8. Tüm yeni kayıtlar sync_status='pending'
  9. Outbox event: 'tenant_payment_methods_pending' (tenant_id, provider_id)
  -> Return: eklenen metot sayısı

Backend Sync Grain (event-driven, outbox pattern):
  10. Event consume → core.tenant_payment_methods WHERE sync_status='pending' batch al
  11. Her metot için:
      a. Finance DB: payment_method_get(method_id) → catalog data
      b. Tenant DB: payment_method_settings_sync(method_id, catalog_data_json, overrides_json)
      c. Finance DB: payment_method_currency_limits → Tenant DB: payment_method_limits_sync(method_id, limits_json)
  12. Core DB: sync_status='synced', last_synced_at=now()
```

### Akış 3: Provider Yeni Metot Ekledikten Sonra (periyodik)
```
Feedback Service -> Finance DB: catalog.payment_method_create(new method) -> catalog'a eklendi

Backend periyodik job (veya admin trigger):
  -> Finance DB: payment_method_list(provider_id=X) → yeni metotları tespit
  -> Core DB: tenant_payment_method_refresh(caller, tenant, provider, method_data)
  -> Catalog'daki yeni metotları tenant_payment_methods'e ekle (denorm alanlar ile)
  -> sync_status='pending' -> Sync Grain çalışır
```

### Akış 4: Core'da Metot Kapanması (background)
```
Feedback Service -> Finance DB: catalog.payment_method_update(is_active=false)

Backend Sync:
  -> Core DB: core.tenant_payment_methods WHERE payment_method_id = kapanan metot
  -> SET is_enabled=false, disabled_reason='method_disabled_by_provider'
  -> sync_status='pending'
  -> Tenant DB: payment_method_settings_remove(payment_method_id)
```

### Akış 5: Tenant'tan Provider Kapatma (BO action)
```
BO -> Core: tenant_payment_provider_disable(caller, tenant, provider)
  1. IDOR check
  2. core.tenant_providers SET is_enabled=false
  3. BİTTİ. Metotlara dokunulmaz.

Etki:
  - tenant_payment_method_list (Core, BO): Tüm metotlar görünür, provider durumu ayrıca sorgulanır
  - payment_method_settings_list (Tenant, Cashier): p_provider_ids parametresinde bu provider olmaz → metotlar gösterilmez
  - Tenant DB'ye sync GEREKMEZ

Provider tekrar açıldığında:
  - tenant_payment_provider_enable: is_enabled=true → metotlar tekrar listelenir
  - Tüm metot state'leri (is_enabled, is_visible, display_order vb.) KORUNUR
  - Tenant'ın manuel kapattığı metotlar kapalı kalır ✓
```

### Akış 6: Tenant Metot Düzenleme (BO, sadece tenant DB)
```
BO -> Tenant DB: payment_method_settings_update(method_id, custom_name, display_order, ...)
  -> Doğrudan tenant DB'de güncellenir
  -> Core'a geri sync YOK (tenant-local customization)

BO -> Tenant DB: payment_method_limit_upsert(method_id, currency_code, min_deposit, max_deposit, ...)
  -> Tenant override olarak kaydedilir
  -> Limit hiyerarşisi: provider default ≥ tenant site limiti ≥ player limiti
```

### Akış 7: Cashier Flow (Player para yatırma/çekme)
```
Player cashier'da ödeme yöntemi seçer
  1. Frontend -> Backend: payment_method_id ile işlem başlat
  2. Backend -> Tenant DB: payment_method_settings_get(payment_method_id)
     -> provider_id, external_method_id, payment_type, is_enabled, allow_deposit/withdrawal
     -> NOT FOUND veya is_enabled=false: hata dön
  3. Backend -> Core DB: tenant_providers check (provider is_enabled?)
     -> Provider kapalı: hata dön
  4. Backend -> Tenant DB: payment_method_limit_list(payment_method_id)
     -> Player'ın currency'sine ait limit bilgileri
  5. Backend -> Tenant DB: payment_player_limit_get(player_id, method_id, currency)
     -> Player bireysel limit varsa, en kısıtlayıcı olanı uygula
  6. Backend -> Limit kontrolü: tutar >= min AND tutar <= max AND günlük toplam <= daily_limit
  7. Backend -> Gateway Cluster (gRPC): PaymentRequest {
       tenantId, playerId, providerId, externalMethodId,
       amount, currency, paymentType, platform
     }
  8. Gateway -> Provider API: İşlem başlat (PayTR, mPay, Papara vb.)
  9. Gateway -> Backend: redirectUrl veya transactionId
  10. Backend -> Frontend: redirect to payment page
  11. Player ödeme yapar, provider callback'ler başlar
```

---

## ADIM 4: Deploy Güncellemeleri

### deploy_finance.sql (Finance DB - MAJOR güncelleme):
```sql
-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS catalog;
COMMENT ON SCHEMA catalog IS 'Payment catalog and provider reference data';

CREATE SCHEMA IF NOT EXISTS finance;
COMMENT ON SCHEMA finance IS 'Finance gateway integration';

-- CATALOG TABLES
\i finance/tables/catalog/payment_providers.sql
\i finance/tables/catalog/payment_methods.sql
\i finance/tables/catalog/payment_method_currency_limits.sql

-- FUNCTIONS - Catalog Provider Sync
\i finance/functions/catalog/payment_provider_sync.sql

-- FUNCTIONS - Catalog Payment Method CRUD (Core'dan taşındı)
\i finance/functions/catalog/payment_method_create.sql
\i finance/functions/catalog/payment_method_update.sql
\i finance/functions/catalog/payment_method_delete.sql
\i finance/functions/catalog/payment_method_get.sql
\i finance/functions/catalog/payment_method_list.sql
\i finance/functions/catalog/payment_method_lookup.sql

-- FUNCTIONS - Catalog Currency Limit Sync
\i finance/functions/catalog/payment_method_currency_limit_sync.sql

-- CONSTRAINTS
\i finance/constraints/catalog.sql

-- INDEXES
\i finance/indexes/catalog.sql
```

### deploy_core.sql değişiklikleri:
```sql
-- KALDIRILDI: \i core/tables/catalog/payment/payment_methods.sql
-- Payment methods tablosu Finance DB'ye taşındı

-- KALDIRILDI: 6 mevcut payment method CRUD fonksiyonu
-- payment_method_create/update/delete/get/list/lookup Finance DB'ye taşındı

-- EKLENECEK FUNCTIONS - Tenant Payment Providers (~tenant_currencies sonrası)
\i core/functions/core/tenant_payment_providers/tenant_payment_provider_enable.sql
\i core/functions/core/tenant_payment_providers/tenant_payment_provider_disable.sql
\i core/functions/core/tenant_payment_providers/tenant_payment_provider_list.sql

-- EKLENECEK FUNCTIONS - Tenant Payment Methods
\i core/functions/core/tenant_payment_methods/tenant_payment_method_upsert.sql
\i core/functions/core/tenant_payment_methods/tenant_payment_method_list.sql
\i core/functions/core/tenant_payment_methods/tenant_payment_method_remove.sql
\i core/functions/core/tenant_payment_methods/tenant_payment_method_refresh.sql
```

### deploy_tenant.sql eklemeleri:
```sql
-- FUNCTIONS - Finance Sync
\i tenant/functions/finance/payment_method_settings_sync.sql
\i tenant/functions/finance/payment_method_settings_remove.sql
\i tenant/functions/finance/payment_method_limits_sync.sql

-- FUNCTIONS - Finance BO + Cashier
\i tenant/functions/finance/payment_method_settings_get.sql
\i tenant/functions/finance/payment_method_settings_update.sql
\i tenant/functions/finance/payment_method_settings_list.sql
\i tenant/functions/finance/payment_method_limit_upsert.sql
\i tenant/functions/finance/payment_method_limit_list.sql

-- FUNCTIONS - Player Limits
\i tenant/functions/finance/payment_player_limit_set.sql
\i tenant/functions/finance/payment_player_limit_get.sql
\i tenant/functions/finance/payment_player_limit_list.sql
```

---

## Uygulama Sırası

1. Finance DB tablo dosyaları (payment_providers, payment_methods taşı, payment_method_currency_limits)
2. Finance DB constraints + indexes
3. Core DB temizlik (payment_methods.sql kaldır, tenant_payment_methods modify, constraints/indexes güncelle)
4. Finance DB catalog fonksiyonları (Grup A0 + A: 8 — 1 yeni + 6 taşınan + 1 yeni)
5. Core tenant_payment_provider fonksiyonları (Grup B: 3)
6. Core tenant_payment_method fonksiyonları (Grup C: 4)
7. Tenant DB tablo modify (payment_method_limits, payment_method_settings, payment_player_limits)
8. Tenant sync fonksiyonları (Grup D: 3)
9. Tenant BO + Cashier fonksiyonları (Grup E: 5)
10. Tenant player limit fonksiyonları (Grup F: 3)
11. Deploy dosyaları güncelle
12. Doküman: FUNCTIONS_CORE.md, FUNCTIONS_TENANT.md

## Doğrulama

- Her fonksiyonun DROP + CREATE syntax kontrolü
- Deploy script sırasının tutarlılığı
- MCP ile tenant DB'de ALTER sonrası kolon kontrolü
- Fonksiyon imza/return type doğrulama
- Limit hiyerarşisi test: provider ceiling >= tenant limit >= player limit
- Cross-DB orchestration akışlarının backend seviyesinde test edilmesi
