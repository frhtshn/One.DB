# Game Yönetim Sistemi - Tam Mimari Plan

## Context

Game gateway entegrasyonundan tenant sitesine kadar tam oyun yaşam döngüsü. **Game DB, game catalog'un sahibidir** (bounded context). Feedback servisi Game DB'ye yazar, Core DB yalnızca tenant mapping tutar.

Mevcut tablolar: `catalog.game_providers`, `catalog.games`, `catalog.game_currency_limits` (Game DB), `core.tenant_games` (Core DB), `game.game_settings`, `game.game_limits` (Tenant DB) SQL dosya olarak var ancak hiçbir fonksiyon yazılmamış. Eksikler: crypto desteği, per-currency limit tablosu fonksiyonları, provider yönetim fonksiyonları.

**Senaryo Özeti:**
1. Gateway feedback servisi -> Game DB: `catalog.games` + currency limitleri doldurur (sürekli background)
2. BO'dan tenant'a provider açılır -> Backend Game DB'den oyunları alır -> Core'da tenant_games seed edilir
3. Backend sync grain -> Tenant DB'ye game_settings/game_limits senkronize edilir
4. Tenant oyunları BO'dan düzenleyebilir (game_settings)
5. Core'da oyun kapanırsa -> tenant'ta da kapanır
6. Provider kapanırsa -> oyunlar gösterilmez (state değişmez)

**Kararlar:**
- **Game DB catalog owner**: Oyun kataloğu Game DB'de yaşar. Core DB'de catalog.games YOKTUR.
- **catalog.game_providers**: Game DB'de hafif provider referans tablosu. Core'daki catalog.providers ile aynı ID'ler kullanılır (cross-DB tutarlılık). Backend tarafından `game_provider_sync` ile senkronize edilir.
- **core.tenant_games denormalize alanlar**: `game_name`, `game_code`, `provider_code`, `game_type`, `thumbnail_url` — BO listesi cross-DB JOIN yapmadan gösterilir. Backend seed/sync sırasında doldurur.
- **tenant_provider_enable refactored**: Backend Game DB'den oyun listesini alır, `p_game_data TEXT` (JSONB) olarak Core fonksiyonuna geçirir. Core fonksiyon catalog.games sorgusu YAPMAZ.
- Provider spesifik ayarlar (API key, endpoint, callback URL) gateway katmanında tutulacak. DB'ye ek tablo eklenmeyecek.
- Game limitleri için fiat/crypto tek tablo + currency_type (ayrı tablo değil).
- **Provider disable stratejisi**: Provider kapatıldığında oyunların `is_enabled` değeri DEĞİŞMEZ. Sorgu seviyesinde provider durumu filtrelenir. Böylece provider tekrar açıldığında oyun state'leri korunur ve tenant'ın manuel kapattığı oyunlar yanlışlıkla açılmaz.
- **Bulk upsert**: Feedback servisi toplu oyun yazar. `game_bulk_upsert` JSONB array kabul eder, tek transaction.
- **Hard DELETE yok**: game_limits dahil tüm tablolarda soft delete. Artık desteklenmeyen limitler `is_active=false` olur.
- **Cursor pagination**: Lobby liste fonksiyonlarında OFFSET yerine cursor-based pagination (display_order, id).
- **Sync fonksiyonları TEXT→JSONB**: `game_settings_sync` 30+ parametre yerine `p_catalog_data TEXT` kabul eder, fonksiyon içinde JSONB'ye cast edilir, typed kolonlara extract edilerek yazılır. Tablolar typed kalır, sadece fonksiyon parametreleri JSONB.
- **TEXT→JSONB fonksiyon parametreleri**: Array/bulk veriler fonksiyonlara **TEXT** olarak gelir, fonksiyon içinde `v_json := p_param::JSONB` ile cast edilir. Dapper (C#) TEXT gönderir. Mevcut pattern: `crypto_rates_bulk_upsert`, `department_create`, `user_permission_set_with_outbox`. Tablolar fully-typed kalır (JSONB kolon yok).
- **Typed tablo yapısı**: `catalog.games` (~48 kolon) ve `game.game_settings` (~44 kolon) tüm alanları typed kolon olarak tutar. Avantajlar: her provider'dan farklı model gelse de DEFAULT değerlerle tutarlı şema, FE'de net filtreleme, index dostu WHERE.
- **Sync tetikleme**: Outbox pattern ile event-driven (mevcut altyapı). Polling yok.
- **Game metadata cache**: Gateway, catalog verisine grain silo + Redis üzerinden erişir. DB'de cache tablosu yok.

---

## Mevcut Durum

| Tablo | DB | Durum | Sorun |
|---|---|---|---|
| `catalog.game_providers` | **Game** | Dosyada | YENİ — Core'dan sync gerekli |
| `catalog.games` | **Game** | Dosyada | `supported_cryptocurrencies` eklendi |
| `catalog.game_currency_limits` | **Game** | Dosyada | YENİ |
| `catalog.provider_types` | Core | **DEPLOYED** | OK (GAME, PAYMENT, SMS, KYC) |
| `catalog.providers` | Core | **DEPLOYED** | OK (tüm provider tipleri, shared) |
| `core.tenant_providers` | Core | **DEPLOYED** | OK, fonksiyon yok, formal UQ constraint eklendi |
| `core.tenant_games` | Core | Dosyada güncellendi | Denormalize alanlar eklendi, FK→catalog.games kaldırıldı (cross-DB) |
| `game.game_settings` | Tenant | **DEPLOYED** | `allowed_countries` eksik |
| `game.game_limits` | Tenant | **DEPLOYED** | `currency_code CHAR(3)` crypto desteklemez, `currency_type` yok |

**Kritik**: `catalog.provider_types` ile `providers.provider_type_id` üzerinden GAME provider filtrelemesi yapılabilir.

---

## Katmanlı Mimari

```
KATMAN 1: CATALOG (Game DB) - Provider API verisi, Game Gateway domain
  catalog.game_providers           -- Game-type provider referansı (Core sync)
  catalog.games                    -- Master oyun listesi (feedback servisinden)
  catalog.game_currency_limits     -- Per-game, per-currency limitler (feedback servisinden)

KATMAN 2: TENANT MAPPING (Core DB) - BO yönetimi
  catalog.providers                -- Tüm provider tipleri (shared: GAME, PAYMENT, SMS, KYC)
  core.tenant_providers            -- Provider enable/disable per tenant
  core.tenant_games                -- Game enable/disable per tenant + denormalize alanlar
  (IDOR korumalı, sync_status takibi)

KATMAN 3: TENANT (Tenant DB) - Runtime denormalize kopya
  game.game_settings               -- Denormalize oyun verisi + tenant özelleştirmeleri
  game.game_limits                 -- Per-game, per-currency limitler (catalog seed + tenant override)
  (Auth-agnostic, cross-DB auth pattern)
```

**Cross-DB İletişim:**
```
Game DB ←→ Core DB ←→ Tenant DB
     Backend orchestrator (ayrı connection'lar)
```

---

## ADIM 1: Tablo Değişiklikleri

### 1A. YENİ TABLO: `catalog.game_providers` (Game DB)

Core DB'deki `catalog.providers` tablosunun GAME tipli alt kümesinin hafif kopyası. Aynı ID'ler kullanılır.

Dosya: `game/tables/catalog/game_providers.sql`

```
catalog.game_providers
  id              BIGINT PK               -- Core catalog.providers.id ile aynı (SERIAL değil)
  provider_code   VARCHAR(50) NOT NULL UQ  -- PRAGMATIC, EVOLUTION, EGT
  provider_name   VARCHAR(255) NOT NULL    -- Pragmatic Play, Evolution Gaming
  is_active       BOOLEAN NOT NULL DEFAULT true
  created_at      TIMESTAMP DEFAULT now()
  updated_at      TIMESTAMP DEFAULT now()
```

### 1B. YENİ TABLO: `catalog.game_currency_limits` (Game DB)

Provider API'den gelen per-game, per-currency limit bilgileri.
Feedback servisi bu tabloyu doldurur. `catalog.games`'deki min_bet/max_bet referans olarak kalır.

Dosya: `game/tables/catalog/game_currency_limits.sql`

```
catalog.game_currency_limits
  id              BIGSERIAL PK
  game_id         BIGINT NOT NULL           -- FK: catalog.games(id) ON DELETE CASCADE
  currency_code   VARCHAR(20) NOT NULL      -- TRY, USD, BTC, ETH, DOGE
  currency_type   SMALLINT NOT NULL DEFAULT 1  -- 1=Fiat, 2=Crypto
  min_bet         DECIMAL(18,8) NOT NULL
  max_bet         DECIMAL(18,8) NOT NULL
  default_bet     DECIMAL(18,8)
  max_win         DECIMAL(18,8)
  is_active       BOOLEAN NOT NULL DEFAULT true  -- Soft delete: provider artık desteklemiyorsa false
  created_at      TIMESTAMP DEFAULT now()
  updated_at      TIMESTAMP DEFAULT now()
  UNIQUE(game_id, currency_code)
```

### 1C. MODIFY: `catalog.games` (Game DB)

Dosya: `game/tables/catalog/games.sql` (Core'dan taşındı)
- ADD `supported_cryptocurrencies VARCHAR(20)[] DEFAULT '{}'` (supported_currencies sonrası)
- FK: `provider_id` → `catalog.game_providers(id)` (Game DB içi, Core'a değil)
- Tüm kolonlar typed kalır (~48 kolon). Her provider farklı model gönderse de DEFAULT değerlerle tutarlı şema garantilenir.

### 1D. MODIFY: `core.tenant_games` (Core DB)

Dosya: `core/tables/core/integration/tenant_games.sql`
- FK `game_id → catalog.games` **KALDIRILDI** (cross-DB, backend doğrular)
- ADD denormalize alanlar (cross-DB JOIN yerine):
  - `game_name VARCHAR(255)` — BO listesinde gösterilir
  - `game_code VARCHAR(100)` — BO filtreleme/arama
  - `provider_code VARCHAR(50)` — BO provider filtresi
  - `game_type VARCHAR(50)` — BO tip filtresi
  - `thumbnail_url VARCHAR(500)` — BO listesinde ikon

### 1E. MODIFY: `game.game_limits` (Tenant DB)

Dosya: `tenant/tables/game/game_limits.sql`
- `currency_code` CHAR(3) -> VARCHAR(20) (crypto desteği)
- ADD `currency_type SMALLINT NOT NULL DEFAULT 1` (1=Fiat, 2=Crypto)
- ADD `is_active BOOLEAN NOT NULL DEFAULT true` (soft delete: provider artık desteklemiyorsa false)

> **Neden ayrı tablo değil?** Core'da fiat/crypto ayrı tablo (tenant_currencies / tenant_cryptocurrencies) ama game limitleri için yapı aynı. Tek tablo + currency_type daha pragmatik.

### 1F. MODIFY: `game.game_settings` (Tenant DB)

Dosya: `tenant/tables/game/game_settings.sql`
- ADD `allowed_countries CHAR(2)[] DEFAULT '{}'` (blocked_countries sonrası)
- core.tenant_games ile tutarlılık sağlanır
- Tüm kolonlar typed kalır (~44 kolon). Catalog alanları + tenant override alanları ayrı section olarak korunur. Sync fonksiyonu catalog alanlarını günceller, tenant override alanlarına DOKUNMAZ.

### 1G. Constraint ve Index Güncellemeleri

**Game DB** (`game/constraints/catalog.sql`):
- `uq_game_providers_code` UNIQUE(provider_code)
- `fk_games_provider` FK → catalog.game_providers(id)
- `uq_games_provider_external` UNIQUE(provider_id, external_game_id)
- `uq_games_provider_code` UNIQUE(provider_id, game_code)
- `fk_game_currency_limits_game` FK → catalog.games(id) ON DELETE CASCADE
- `uq_game_currency_limits` UNIQUE(game_id, currency_code)

**Game DB** (`game/indexes/catalog.sql`):
- `idx_game_providers_code` UNIQUE BTREE(provider_code)
- `idx_games_*` tüm game index'leri (Core'dan taşındı)
- `idx_game_currency_limits_game` BTREE(game_id)
- `idx_game_currency_limits_currency_type` BTREE(currency_type)

**Core DB** (`core/constraints/catalog.sql`):
- `fk_games_provider`, `uq_games_provider_external`, `uq_games_provider_code` **KALDIRILDI** (Game DB'ye taşındı)

**Core DB** (`core/constraints/core.sql`):
- `fk_tenant_games_game` **KALDIRILDI** (cross-DB, FK yok)
- `uq_tenant_providers` UNIQUE(tenant_id, provider_id) **EKLENDİ** (formal constraint)

**Core DB** (`core/indexes/catalog.sql`):
- Tüm `idx_games_*` index'leri **KALDIRILDI** (Game DB'ye taşındı)

**Tenant** (`tenant/constraints/game.sql` + `tenant/indexes/game.sql`):
- game_limits constraint/index: CHAR(3) -> VARCHAR(20) uyumu
- `idx_game_settings_cursor` BTREE(display_order, id) — cursor pagination için

---

## ADIM 2: Fonksiyonlar (23 fonksiyon)

### Grup A0: Game DB - Provider Sync (1)

Klasör: `game/functions/catalog/`
Pattern: SECURITY DEFINER (platform seviyesi, IDOR yok)

| # | Dosya | Açıklama | Return |
|---|-------|----------|--------|
| 0 | `game_provider_sync.sql` | Backend: Core'dan game provider'ları sync et (JSONB array) | INTEGER (upsert sayısı) |

**game_provider_sync detay:**
```
Params: p_providers TEXT   -- TEXT → JSONB cast
  v_providers := p_providers::JSONB;

  p_providers format: [
    {"id":1,"provider_code":"PRAGMATIC","provider_name":"Pragmatic Play","is_active":true},
    {"id":2,"provider_code":"EVOLUTION","provider_name":"Evolution Gaming","is_active":true},
    ...
  ]

Loop: JSONB array → her eleman için:
  - id, provider_code, provider_name, is_active extract
  - UPSERT: id bazlı → UPDATE or INSERT
  - Normalize: UPPER(provider_code)
Return: upsert edilen provider sayısı

Kullanım: Backend, Core DB'den GAME tipli provider'ları alıp bu fonksiyona geçirir.
Tetikleme: Provider create/update/delete sırasında veya periyodik sync.
```

---

### Grup A: Game DB - Catalog Game CRUD (7)

Klasör: `game/functions/catalog/`
Pattern: SECURITY DEFINER (platform seviyesi, IDOR yok)

| # | Dosya | Açıklama | Return |
|---|-------|----------|--------|
| 1 | `game_upsert.sql` | Feedback servis: tekil oyun upsert (provider_id + external_game_id) | BIGINT (game id) |
| 2 | `game_bulk_upsert.sql` | Feedback servis: toplu oyun upsert (JSONB array, tek transaction) | INTEGER (upsert sayısı) |
| 3 | `game_update.sql` | BO: metadata güncelleme (COALESCE pattern, NULL=değiştirme) | VOID |
| 4 | `game_get.sql` | Tekil oyun detay (JOIN game_providers) | TABLE |
| 5 | `game_list.sql` | Filtreli liste (provider, type, status, search ILIKE) | TABLE |
| 6 | `game_lookup.sql` | Dropdown hafif liste (id, code, name, provider, type) | TABLE |
| 7 | `game_currency_limit_sync.sql` | Feedback servis: per-game currency limit bulk upsert (soft delete) | VOID |

> **Neden `game_upsert` var, `game_create` yok?** Oyunlar provider API'lerinden gelir -- aynı `external_game_id` tekrar geldiğinde güncellenmeli. Manuel oluşturma yok.
> **Neden `game_delete` yok?** Soft delete = `game_update(p_is_active := FALSE)`. Catalog'dan fiziksel silme yok.

**game_upsert detay:**
```
Params: p_provider_id, p_external_game_id, p_game_code, p_game_name, p_game_type,
        + tüm opsiyonel (studio, rtp, volatility, features, URLs, currencies vb.)
Validasyon:
  - p_provider_id NOT NULL + EXISTS (catalog.game_providers)
  - p_external_game_id, p_game_code, p_game_name NOT NULL
  - p_game_type validasyon (SLOT, LIVE, TABLE, CRASH, SCRATCH, BINGO, VIRTUAL)
Normalize: LOWER(game_code), UPPER(game_type, volatility)
Upsert: (provider_id, external_game_id) unique -> UPDATE / INSERT
Return: game id (new or existing)
```

**game_bulk_upsert detay:**
```
Params: p_provider_id BIGINT, p_games TEXT   -- TEXT → JSONB cast
  v_games := p_games::JSONB

  p_games format: [
    {"external_game_id":"vs25x","game_code":"gates-of-olympus","game_name":"Gates of Olympus",
     "game_type":"SLOT","studio":"Pragmatic","rtp":96.50,"volatility":"HIGH",
     "thumbnail_url":"...","has_demo":true,...},
    ...
  ]

Validasyon: p_provider_id EXISTS (catalog.game_providers)
Loop: JSONB array → her eleman için:
  - Her alanı extract: (elem->>'game_code'), (elem->>'rtp')::DECIMAL, ...
  - (provider_id, external_game_id) bazlı upsert → typed kolonlara yazılır
  - Normalize: LOWER(game_code), UPPER(game_type, volatility)
Tek transaction: Tüm oyunlar atomik olarak yazılır
Return: upsert edilen oyun sayısı

Kullanım: Feedback servisi provider'dan toplu oyun çektiğinde.
game_upsert tekil güncellemeler için kalır (artımlı sync).
```

**game_currency_limit_sync detay:**
```
Params: p_game_id BIGINT, p_limits TEXT   -- TEXT → JSONB cast
  v_limits := p_limits::JSONB;
  p_limits format: [{"cc":"USD","ct":1,"min":0.10,"max":100,"def":1,"win":5000}, ...]

Validasyon: game_id EXISTS (catalog.games)
Loop: JSONB array → her eleman extract → typed kolonlara INSERT ON CONFLICT (game_id, currency_code) DO UPDATE
Artık desteklenmeyen limitler: p_limits'te olmayan currency'ler → is_active=false (HARD DELETE YOK)
Tekrar desteklenirse: is_active=true + değerler güncellenir
```

---

### Grup B: Core - Tenant Provider Yönetimi (3)

Klasör: `core/functions/core/tenant_providers/`
Pattern: IDOR korumalı (user_assert_access_company)

| # | Dosya | Açıklama | Return |
|---|-------|----------|--------|
| 8 | `tenant_provider_enable.sql` | Provider aç + backend'den gelen oyunları seed et | INTEGER (eklenen oyun) |
| 9 | `tenant_provider_disable.sql` | Provider kapat (sadece flag, oyunlara dokunmaz) | VOID |
| 10 | `tenant_provider_list.sql` | Tenant provider listesi (JSONB) | JSONB |

**tenant_provider_enable detay (refactored — cross-DB orchestration):**
```
Params: p_caller_id, p_tenant_id, p_provider_id, p_game_data TEXT DEFAULT NULL, p_mode DEFAULT 'real'
  -- p_game_data: Backend'in Game DB'den aldığı oyun listesi (JSONB array)
  -- Format: [{"game_id":1,"game_name":"Sweet Bonanza","game_code":"sweet-bonanza",
  --           "provider_code":"PRAGMATIC","game_type":"SLOT","thumbnail_url":"..."},...]

1. SELECT company_id FROM core.tenants WHERE id = p_tenant_id
   -> NOT FOUND: RAISE 'error.tenant.not-found'
2. PERFORM security.user_assert_access_company(p_caller_id, v_company_id)
3. Validate: provider EXISTS + provider_type_id -> provider_type_code = 'GAME'
   -> NOT FOUND: RAISE 'error.provider.not-found'
   -> NOT GAME: RAISE 'error.provider.not-game-type'
4. UPSERT core.tenant_providers (is_enabled=true, mode=p_mode)
   ON CONFLICT (tenant_id, provider_id) DO UPDATE SET is_enabled=true, mode=p_mode
5. IF p_game_data IS NOT NULL THEN
     v_games := p_game_data::JSONB;
     FOR elem IN SELECT * FROM jsonb_array_elements(v_games) LOOP
       INSERT INTO core.tenant_games (tenant_id, game_id, game_name, game_code,
                                      provider_code, game_type, thumbnail_url,
                                      sync_status, created_by)
       VALUES (p_tenant_id, (elem->>'game_id')::BIGINT, elem->>'game_name',
               elem->>'game_code', elem->>'provider_code', elem->>'game_type',
               elem->>'thumbnail_url', 'pending', p_caller_id)
       ON CONFLICT (tenant_id, game_id) DO NOTHING;
     END LOOP;
   END IF;
6. GET DIAGNOSTICS v_count = ROW_COUNT
7. RETURN v_count

NOT: Mevcut oyunların is_enabled durumuna DOKUNULMAZ.
Provider daha önce kapatılıp tekrar açılıyorsa, oyun state'leri korunur.
Sadece yeni oyunlar seed edilir (ON CONFLICT DO NOTHING).

BACKEND ORCHESTRATION:
  1. Backend → Game DB: game_list(provider_id=X, is_active=true)
  2. Backend → game_data JSONB oluşturur (game_id + denorm alanlar)
  3. Backend → Core DB: tenant_provider_enable(caller, tenant, provider, game_data)
```

**tenant_provider_disable detay:**
```
Params: p_caller_id, p_tenant_id, p_provider_id

1. Tenant + IDOR check
2. UPDATE core.tenant_providers SET is_enabled=false, updated_at=now()
   WHERE tenant_id = p_tenant_id AND provider_id = p_provider_id
3. RETURN (void)

NOT: Oyunlara (core.tenant_games) DOKUNULMAZ.
Provider durumu sorgu seviyesinde filtrelenir.
Tenant'ın oyun bazlı enable/disable kararları korunur.
Provider tekrar açıldığında ayrıca güncelleme gerekmez.
```

**tenant_provider_list detay:**
```
Params: p_caller_id, p_tenant_id

IDOR + JSONB return:
  JOIN catalog.providers p, catalog.provider_types pt
  Fields: id, providerId, providerCode, providerName, providerType,
          mode, isEnabled, gameCount (subquery from tenant_games), createdAt, updatedAt
  WHERE pt.provider_type_code = 'GAME' -- sadece game provider'lar
  ORDER BY p.provider_name
```

---

### Grup C: Core - Tenant Game Yönetimi (4)

Klasör: `core/functions/core/tenant_games/`
Tümü: IDOR korumalı

| # | Dosya | Açıklama | Return |
|---|-------|----------|--------|
| 11 | `tenant_game_upsert.sql` | Tekil oyun aç/düzenle (customization) | VOID |
| 12 | `tenant_game_list.sql` | Oyun listesi (denormalize alanlardan, cross-DB JOIN yok) | JSONB |
| 13 | `tenant_game_remove.sql` | Oyun kapat (soft: is_enabled=false + reason) | VOID |
| 14 | `tenant_game_refresh.sql` | Backend'den gelen yeni oyunları toplu seed | INTEGER |

**tenant_game_upsert validasyonlar:**
```
Params: p_caller_id, p_tenant_id, p_game_id,
        p_is_enabled, p_is_visible, p_is_featured, p_display_order,
        p_custom_name, p_custom_thumbnail_url, p_custom_categories, p_custom_tags,
        p_rtp_variant, p_allowed_platforms, p_blocked_countries, p_allowed_countries,
        p_available_from, p_available_until

1. Tenant exists -> company_id -> IDOR
2. game_id EXISTS in core.tenant_games (game_id Game DB'de, ama tenant_games kaydı Core'da olmalı)
3. UPSERT: (tenant_id, game_id) -> UPDATE or INSERT
4. sync_status = 'pending'

NOT: catalog.games validasyonu YAPILMAZ (cross-DB). Backend geçerli game_id geçirir.
```

**tenant_game_list detay:**
```
Params: p_caller_id, p_tenant_id,
        p_provider_code?, p_game_type?, p_is_enabled?, p_search?, p_limit?, p_offset?

IDOR + denormalize alanlardan JSONB return:
  SELECT FROM core.tenant_games tg
  -- NOT: catalog.games JOIN YOK (cross-DB). Denormalize alanlar kullanılır.

JSONB fields:
  id, gameId, gameName, gameCode, providerCode, gameType, thumbnailUrl,
  isEnabled, isVisible, isFeatured, displayOrder, customName, customThumbnailUrl,
  customCategories, customTags, rtpVariant, allowedPlatforms,
  blockedCountries, allowedCountries, availableFrom, availableUntil,
  syncStatus, lastSyncedAt, createdAt, updatedAt

NOT: Provider durumuna göre FİLTRE YOK. BO admin tüm oyunları görür.
Provider durumu tenant_provider_list'ten ayrıca sorgulanır.
```

**tenant_game_refresh (refactored — cross-DB orchestration):**
```
Params: p_caller_id, p_tenant_id, p_provider_id, p_game_data TEXT
  -- p_game_data: Backend'in Game DB'den aldığı yeni oyun listesi (JSONB array)
  -- Aynı format: [{"game_id":1,"game_name":"...","game_code":"...",
  --                "provider_code":"...","game_type":"...","thumbnail_url":"..."},...]

IDOR + Provider type=GAME check
Loop: JSONB array → INSERT INTO core.tenant_games (denorm alanlar ile)
ON CONFLICT (tenant_id, game_id) DO NOTHING
RETURN inserted count

BACKEND ORCHESTRATION:
  1. Backend → Game DB: game_list(provider_id=X, is_active=true)
  2. Backend → Core DB: tenant_game_refresh(caller, tenant, provider, game_data)
```

---

### Grup D: Tenant - Sync (3)

Klasör: `tenant/functions/game/`
Tümü: Auth-agnostic (backend çağırır, auth core'da yapılmış)

| # | Dosya | Açıklama | Return |
|---|-------|----------|--------|
| 15 | `game_settings_sync.sql` | Core->Tenant: game data upsert (TEXT→JSONB, tenant overrides korunur) | VOID |
| 16 | `game_settings_remove.sql` | Oyun devre dışı bırak (soft delete: is_enabled=false) | VOID |
| 17 | `game_limits_sync.sql` | Core->Tenant: currency limits seed/update (soft delete) | VOID |

> ~~`game_settings_disable_by_provider`~~: Kaldırıldı. Provider durumu sorgu seviyesinde filtrelenir, oyun state'leri değişmez.

**game_settings_remove detay:**
```
Params: p_game_id BIGINT

Soft delete:
  UPDATE game.game_settings
  SET is_enabled = false, updated_at = now()
  WHERE game_id = p_game_id

NOT: Fiziksel DELETE yok. game_limits kayıtları da korunur.
Kullanım: Core'da oyun catalog'dan kaldırıldığında (is_active=false)
backend bu fonksiyonu çağırarak tenant tarafında da devre dışı bırakır.
```

**game_settings_sync detay:**
```
Params: p_game_id BIGINT, p_catalog_data TEXT, p_tenant_overrides TEXT DEFAULT NULL
  -- TEXT → JSONB cast (fonksiyon içi)
  v_catalog := p_catalog_data::JSONB;
  v_overrides := COALESCE(p_tenant_overrides, '{}')::JSONB;

p_catalog_data format: {
  "provider_id": 1, "external_game_id": "vs25x", "game_code": "gates-of-olympus",
  "game_name": "Gates of Olympus", "provider_code": "pragmatic",
  "studio": "Pragmatic", "game_type": "SLOT", "game_subtype": null,
  "categories": ["slot","popular"], "tags": ["megaways"],
  "rtp": 96.50, "volatility": "HIGH", "max_multiplier": 5000, "paylines": 20,
  "thumbnail_url": "...", "background_url": "...", "logo_url": "...",
  "features": ["FREESPINS","MULTIPLIER"], "has_demo": true,
  "has_jackpot": false, "jackpot_type": null, "has_bonus_buy": true,
  "is_mobile": true, "is_desktop": true
}

p_tenant_overrides format (sadece INSERT'te kullanılır): {
  "display_order": 0, "is_visible": true, "is_enabled": true, "is_featured": false,
  "blocked_countries": [], "allowed_countries": []
}

Fonksiyon içi: JSONB'den extract → typed kolonlara yazar
  (v_catalog->>'game_name')::VARCHAR → game_name kolonu
  (v_catalog->>'rtp')::DECIMAL → rtp kolonu
  ...

Upsert: game_id unique → UPDATE / INSERT
  INSERT → v_catalog'dan extract edilen tüm catalog alanları + v_overrides'dan tenant alanları
  UPDATE → SADECE catalog alanları (provider_id, game_code, game_name, studio, ...) güncellenir
           Tenant override alanları (custom_name, display_order, is_featured vb.) DOKUNULMAZ
core_synced_at = NOW()

KRİTİK: 30+ parametre yerine 2 TEXT param. Fonksiyon JSONB'den extract edip typed kolonlara yazar.

BACKEND ORCHESTRATION:
  1. Backend → Game DB: game_get(game_id) → catalog data
  2. Backend → Core DB: tenant_games → tenant overrides
  3. Backend → Tenant DB: game_settings_sync(game_id, catalog_data, overrides)
```

**game_limits_sync detay:**
```
Params: p_game_id BIGINT, p_limits TEXT   -- TEXT → JSONB cast
  v_limits := p_limits::JSONB;
  p_limits format: [{"currency_code":"USD","currency_type":1,"min_bet":0.10,"max_bet":100,...}]

Validasyon: game_id EXISTS in game.game_settings
Loop: JSONB array → her eleman extract → typed kolonlara INSERT ON CONFLICT (game_id, currency_code) DO UPDATE
  -> Mevcut kayıt: değerler + is_active=true güncellenir
  -> Yeni kayıt: INSERT
Artık desteklenmeyen limitler: p_limits'te olmayan currency'ler → is_active=false (HARD DELETE YOK)
Tekrar desteklenirse: is_active=true + değerler güncellenir
```

---

### Grup E: Tenant - BO Yönetim + Game Open (5)

Klasör: `tenant/functions/game/`
Tümü: Auth-agnostic (cross-DB auth pattern)

| # | Dosya | Açıklama | Return |
|---|-------|----------|--------|
| 18 | `game_settings_get.sql` | Tekil oyun detay (game open flow için) | JSONB |
| 19 | `game_settings_update.sql` | Tenant customization güncelle | VOID |
| 20 | `game_settings_list.sql` | Oyun listesi (lobi + BO, cursor pagination, provider filtreli) | JSONB |
| 21 | `game_limit_upsert.sql` | Oyun limiti ekle/güncelle | VOID |
| 22 | `game_limit_list.sql` | Oyun limit listesi | JSONB |

**game_settings_get detay:**
```
Params: p_game_id BIGINT

Return JSONB: {
  gameId, providerId, providerCode, externalGameId, gameCode, gameName,
  studio, gameType, gameSubtype, categories, tags,
  rtp, rtpVariant, volatility, maxMultiplier, paylines,
  thumbnailUrl, backgroundUrl, logoUrl, customThumbnailUrl,
  features, hasDemo, hasJackpot, jackpotType, hasBonusBuy,
  isMobile, isDesktop, isEnabled, isVisible, isFeatured,
  displayOrder, customName, customCategories, customTags,
  allowedPlatforms, blockedCountries, allowedCountries,
  availableFrom, availableUntil, coreSyncedAt
}

Validasyon: game_id EXISTS → NOT FOUND: RAISE 'error.game.not-found'

Kullanım: Game open flow
  1. Player oyun açar → Backend tenant DB'den game_settings_get çağırır
  2. provider_id + external_game_id alır
  3. Gateway'e gRPC ile GameURL request gönderir
  4. Gateway, provider API'den launch URL alır
  5. Player oyuna yönlendirilir
```

**game_settings_update detay:**
```
Params: p_game_id + tüm tenant-editable alanlar DEFAULT NULL
Editable: custom_name, custom_thumbnail_url, custom_categories, custom_tags,
          display_order, is_visible, is_featured, rtp_variant,
          allowed_platforms, blocked_countries, allowed_countries,
          available_from, available_until
COALESCE pattern: NULL = mevcut değeri koru
Validasyon: game_id EXISTS in game_settings
updated_at = now()
```

**game_settings_list detay:**
```
Params: p_provider_ids BIGINT[] DEFAULT NULL,  -- Backend'den gelen aktif provider ID'leri
        p_game_type?, p_is_enabled?, p_is_visible?, p_search?,
        p_limit INT DEFAULT 50,
        p_cursor_order INT DEFAULT NULL,       -- Cursor: son görülen display_order
        p_cursor_id BIGINT DEFAULT NULL        -- Cursor: son görülen game_id

Filtreleme:
  - p_provider_ids NOT NULL ise: WHERE provider_id = ANY(p_provider_ids)
    (Backend core.tenant_providers'dan is_enabled=true olanları alıp geçirir)
  - p_provider_ids NULL ise: tüm oyunlar (BO admin görünümü)
Search: ILIKE on game_name, game_code, custom_name

Cursor pagination:
  - İlk sayfa: p_cursor_order ve p_cursor_id NULL
  - Sonraki sayfalar: WHERE (display_order, id) > (p_cursor_order, p_cursor_id)
  - OFFSET yok → büyük kataloglarda sabit performans
ORDER BY: display_order ASC, id ASC
LIMIT: p_limit

JSONB array return + metadata: {items: [...], nextCursorOrder: N, nextCursorId: N, hasMore: bool}

KULLANIM:
  Lobi: p_provider_ids = [aktif provider ID'leri] (backend core'dan alır)
  BO:   p_provider_ids = NULL (tüm oyunları gösterir, disabled provider oyunları da)
```

**game_limit_upsert detay:**
```
Params: p_game_id, p_currency_code, p_currency_type, p_min_bet, p_max_bet, p_default_bet?, p_max_win?
Validasyon: game_id EXISTS in game_settings
UPSERT: (game_id, currency_code) -> UPDATE or INSERT
```

**game_limit_list detay:**
```
Params: p_game_id
JSONB return: [{currencyCode, currencyType, minBet, maxBet, defaultBet, maxWin, isActive}]
WHERE is_active = true (varsayılan, devre dışı limitler gösterilmez)
ORDER BY: currency_type, currency_code
```

---

## ADIM 3: Akış Diyagramları

### Akış 1: Provider API -> Catalog (Background, sürekli)
```
Gateway Feedback Service (sürekli çalışır)
  -> Game DB: catalog.game_bulk_upsert(provider_id, games_json)  -- toplu, tek transaction
  -> Game DB: catalog.game_currency_limit_sync(game_id, limits_json)  -- per-game limitleri
  -> Yeni oyunlar eklenir, kapanan oyunlar is_active=false
  -> Artık desteklenmeyen currency limitleri is_active=false (hard delete yok)

NOT: game_upsert tekil güncellemeler için kalır (artımlı sync).
game_bulk_upsert ilk yükleme ve periyodik tam sync için kullanılır.
```

### Akış 2: Tenant'a Provider Açma (BO action)
```
BO User -> Core: tenant_provider_enable(caller, tenant, provider, game_data)
  1. IDOR check
  2. Provider type=GAME kontrolü (catalog.providers Core'da)
  3. core.tenant_providers UPSERT (is_enabled=true)

  Backend orchestration (cross-DB):
  4. Backend -> Game DB: game_list(provider_id=X, is_active=true)
  5. Backend -> game_data JSONB oluşturur (game_id + denorm alanlar)
  6. Backend -> Core DB: tenant_provider_enable(..., game_data)

  Core fonksiyon devam:
  7. p_game_data JSONB array → core.tenant_games toplu INSERT (denorm alanlar ile)
  8. Tüm yeni kayıtlar sync_status='pending'
  9. Outbox event: 'tenant_games_pending' (tenant_id, provider_id)
  -> Return: eklenen oyun sayısı

Backend Sync Grain (event-driven, outbox pattern):
  10. Event consume → core.tenant_games WHERE sync_status='pending' batch al
  11. Her oyun için:
      a. Game DB: game_get(game_id) → catalog data
      b. Tenant DB: game_settings_sync(game_id, catalog_data_json)
      c. Game DB: game_currency_limit_sync data → Tenant DB: game_limits_sync(game_id, limits_json)
  12. Core DB: sync_status='synced', last_synced_at=now()
```

### Akış 3: Provider Yeni Oyun Ekledikten Sonra (periyodik)
```
Feedback Service -> Game DB: catalog.game_upsert(new game) -> catalog'a eklendi

Backend periyodik job (veya admin trigger):
  -> Game DB: game_list(provider_id=X) → yeni oyunları tespit
  -> Core DB: tenant_game_refresh(caller, tenant, provider, game_data)
  -> Catalog'daki yeni oyunları tenant_games'e ekle (denorm alanlar ile)
  -> sync_status='pending' -> Sync Grain çalışır
```

### Akış 4: Core'da Oyun Kapanması (background)
```
Feedback Service -> Game DB: catalog.game_upsert(is_active=false)

Backend Sync:
  -> Core DB: core.tenant_games WHERE game_id = kapanan oyun
  -> SET is_enabled=false, disabled_reason='game_disabled_by_provider'
  -> sync_status='pending'
  -> Tenant DB: game_settings_remove(game_id)
```

### Akış 5: Tenant'tan Provider Kapatma (BO action)
```
BO -> Core: tenant_provider_disable(caller, tenant, provider)
  1. IDOR check
  2. core.tenant_providers SET is_enabled=false
  3. BİTTİ. Oyunlara dokunulmaz.

Etki:
  - tenant_game_list (Core, BO): Tüm oyunlar görünür, provider durumu ayrıca sorgulanır
  - game_settings_list (Tenant, Lobi): p_provider_ids parametresinde bu provider olmaz → oyunlar gösterilmez
  - Tenant DB'ye sync GEREKMEZ

Provider tekrar açıldığında:
  - tenant_provider_enable: is_enabled=true → oyunlar tekrar listelenir
  - Tüm oyun state'leri (is_enabled, is_visible, display_order vb.) KORUNUR
  - Tenant'ın manuel kapattığı oyunlar kapalı kalır ✓
```

### Akış 6: Tenant Oyun Düzenleme (BO, sadece tenant DB)
```
BO -> Tenant DB: game_settings_update(game_id, custom_name, display_order, ...)
  -> Doğrudan tenant DB'de güncellenir
  -> Core'a geri sync YOK (tenant-local customization)

BO -> Tenant DB: game_limit_upsert(game_id, currency_code, min_bet, max_bet, ...)
  -> Tenant override olarak kaydedilir
```

### Akış 7: Game Open (Player oyun açma)
```
Player lobide oyuna tıklar
  1. Frontend -> Backend: game_id ile oyun aç talebi
  2. Backend -> Tenant DB: game_settings_get(game_id)
     -> provider_id, external_game_id, provider_code, is_enabled, is_mobile/is_desktop
     -> NOT FOUND veya is_enabled=false: hata dön
  3. Backend -> Core DB: tenant_providers check (provider is_enabled?)
     -> Provider kapalı: hata dön
  4. Backend -> Gateway Cluster (gRPC): GameOpenRequest {
       tenantId, playerId, providerId, externalGameId, currency, platform, language
     }
  5. Gateway -> Provider API: GameURL request (PP: getCasinoGameURL)
  6. Gateway -> Backend: launch_url
  7. Backend -> Frontend: redirect to launch_url
  8. Player oyuna girer, provider callback'ler başlar (Bet, Result, ...)
```

---

## ADIM 4: Deploy Güncellemeleri

### deploy_game.sql (Game DB - MAJOR güncelleme):
```sql
-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS catalog;
COMMENT ON SCHEMA catalog IS 'Game catalog and provider reference data';

CREATE SCHEMA IF NOT EXISTS game;
COMMENT ON SCHEMA game IS 'Game gateway integration';

-- CATALOG TABLES
\i game/tables/catalog/game_providers.sql
\i game/tables/catalog/games.sql
\i game/tables/catalog/game_currency_limits.sql

-- FUNCTIONS - Catalog
\i game/functions/catalog/game_provider_sync.sql
\i game/functions/catalog/game_upsert.sql
\i game/functions/catalog/game_bulk_upsert.sql
\i game/functions/catalog/game_update.sql
\i game/functions/catalog/game_get.sql
\i game/functions/catalog/game_list.sql
\i game/functions/catalog/game_lookup.sql
\i game/functions/catalog/game_currency_limit_sync.sql

-- CONSTRAINTS
\i game/constraints/catalog.sql

-- INDEXES
\i game/indexes/catalog.sql
```

### deploy_core.sql değişiklikleri:
```sql
-- KALDIRILDI: \i core/tables/catalog/game/games.sql (satır 67)
-- Game tablosu Game DB'ye taşındı

-- EKLENECEK FUNCTIONS - Tenant Providers (~tenant_currencies sonrası)
\i core/functions/core/tenant_providers/tenant_provider_enable.sql
\i core/functions/core/tenant_providers/tenant_provider_disable.sql
\i core/functions/core/tenant_providers/tenant_provider_list.sql

-- EKLENECEK FUNCTIONS - Tenant Games
\i core/functions/core/tenant_games/tenant_game_upsert.sql
\i core/functions/core/tenant_games/tenant_game_list.sql
\i core/functions/core/tenant_games/tenant_game_remove.sql
\i core/functions/core/tenant_games/tenant_game_refresh.sql
```

### deploy_tenant.sql eklemeleri:
```sql
-- FUNCTIONS - Game Sync (~satır 194 civarı)
\i tenant/functions/game/game_settings_sync.sql
\i tenant/functions/game/game_settings_remove.sql
\i tenant/functions/game/game_limits_sync.sql

-- FUNCTIONS - Game BO + Game Open
\i tenant/functions/game/game_settings_get.sql
\i tenant/functions/game/game_settings_update.sql
\i tenant/functions/game/game_settings_list.sql
\i tenant/functions/game/game_limit_upsert.sql
\i tenant/functions/game/game_limit_list.sql
```

---

## Uygulama Sırası

1. Game DB tablo dosyaları (game_providers, games, game_currency_limits)
2. Game DB constraints + indexes
3. Core DB temizlik (games.sql kaldır, tenant_games modify, constraints/indexes güncelle)
4. Game DB catalog fonksiyonları (Grup A0 + A: 8)
5. Core tenant_provider fonksiyonları (Grup B: 3)
6. Core tenant_game fonksiyonları (Grup C: 4)
7. Tenant sync fonksiyonları (Grup D: 3)
8. Tenant BO + Game Open fonksiyonları (Grup E: 5)
9. Deploy dosyaları güncelle
10. Doküman: FUNCTIONS_CORE.md, FUNCTIONS_TENANT.md, FUNCTIONS_GATEWAY.md

## Doğrulama

- Her fonksiyonun DROP + CREATE syntax kontrolü
- Deploy script sırasının tutarlılığı
- MCP ile tenant DB'de ALTER sonrası kolon kontrolü
- Fonksiyon imza/return type doğrulama
- Cross-DB orchestration akışlarının backend seviyesinde test edilmesi
