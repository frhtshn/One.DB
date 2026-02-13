# Game Yönetim Sistemi - Tam Uygulama

Gateway entegrasyonundan tenant sitesine kadar tam oyun yaşam döngüsü.
Mimari detaylar: [GAME_ARCHITECTURE.md](GAME_ARCHITECTURE.md)

## Senaryo

1. Gateway feedback servisi -> Game DB: `catalog.games` + currency limitleri doldurur (sürekli background)
2. BO'dan tenant'a provider açılır -> Backend Game DB'den oyunları alır -> Core'da tenant_games seed edilir
3. Backend sync grain -> Tenant DB'ye game_settings/game_limits senkronize edilir
4. Oyunlar tenant sitesinde anında aktif olur
5. Tenant oyunları BO'dan düzenleyebilir (`game_settings`)
6. Core'da oyun kapanırsa -> tenant'ta da kapanır
7. Provider kapanırsa -> oyunlar gösterilmez (state değişmez)

## Mimari Kararlar

- **Game DB catalog owner**: Oyun kataloğu Game DB'de yaşır. Core DB'de catalog.games YOKTUR
- **catalog.game_providers**: Game DB'de hafif provider referansı, Core ile aynı ID'ler
- **core.tenant_games denormalize**: game_name, game_code, provider_code, game_type, thumbnail_url
- **tenant_provider_enable refactored**: Backend Game DB'den oyun listesi alır, p_game_data TEXT olarak Core'a geçirir
- Provider disable -> oyun state değişmez, sorgu seviyesinde filtrelenir
- Fiat/Crypto tek tablo + `currency_type` (ayrı tablo değil)
- Hard DELETE yok, tüm tablolarda soft delete
- Cursor-based pagination (OFFSET yok)
- Fonksiyon parametreleri TEXT->JSONB, tablolar fully-typed
- Outbox pattern ile event-driven sync
- Gateway metadata cache: grain silo + Redis (DB'de cache yok)

---

## Adım 1: Tablo Değişiklikleri

### Game DB (Catalog Owner)

- [ ] **1A.** `catalog.game_providers` -- YENİ tablo (Game DB)
  - `game/tables/catalog/game_providers.sql`
  - Core catalog.providers'ın GAME alt kümesinin hafif kopyası
  - Aynı ID'ler kullanılır (BIGINT PK, SERIAL değil)
  - Backend `game_provider_sync` ile senkronize eder

- [ ] **1B.** `catalog.games` -- Core'dan Game DB'ye TAŞINDI
  - `game/tables/catalog/games.sql`
  - ADD `supported_cryptocurrencies VARCHAR(20)[] DEFAULT '{}'`
  - FK: `provider_id` -> `catalog.game_providers(id)` (Game DB içi)
  - Tüm kolonlar typed kalır (~48 kolon)

- [ ] **1C.** `catalog.game_currency_limits` -- YENİ tablo (Game DB)
  - `game/tables/catalog/game_currency_limits.sql`
  - Per-game, per-currency limit bilgileri (feedback servisinden)
  - `UNIQUE(game_id, currency_code)`, `currency_type` (1=Fiat, 2=Crypto)
  - `is_active` soft delete

### Core DB (Tenant Mapping)

- [ ] **1D.** `core.tenant_games` -- MODIFY (Core DB)
  - `core/tables/core/integration/tenant_games.sql`
  - FK `game_id -> catalog.games` **KALDIRILDI** (cross-DB, backend doğrular)
  - ADD denormalize alanlar: `game_name`, `game_code`, `provider_code`, `game_type`, `thumbnail_url`
  - BO listesi cross-DB JOIN yapmadan gösterilir

### Tenant DB (Runtime)

- [ ] **1E.** `game.game_limits` -- MODIFY (Tenant DB)
  - `tenant/tables/game/game_limits.sql`
  - `currency_code` CHAR(3) -> VARCHAR(20) (crypto desteği)
  - ADD `currency_type SMALLINT NOT NULL DEFAULT 1`
  - ADD `is_active BOOLEAN NOT NULL DEFAULT true`

- [ ] **1F.** `game.game_settings` -- MODIFY (Tenant DB)
  - `tenant/tables/game/game_settings.sql`
  - ADD `allowed_countries CHAR(2)[] DEFAULT '{}'`
  - ADD `rollout_status VARCHAR(20) NOT NULL DEFAULT 'production'` (SHADOW_MODE)

### Constraint ve Index Güncellemeleri

- [ ] **1G-a.** Game DB constraints + indexes
  - [ ] `game/constraints/catalog.sql` -- FK + UQ (game_providers, games, game_currency_limits)
  - [ ] `game/indexes/catalog.sql` -- game_providers, games, game_currency_limits indexleri

- [ ] **1G-b.** Core DB constraint/index temizliği
  - [ ] `core/constraints/catalog.sql` -- games FK/UQ KALDIRILDI (Game DB'ye taşındı)
  - [ ] `core/constraints/core.sql` -- tenant_games->games FK KALDIRILDI, uq_tenant_providers EKLENDİ
  - [ ] `core/indexes/catalog.sql` -- Tüm idx_games_* KALDIRILDI (Game DB'ye taşındı)

- [ ] **1G-c.** Tenant DB constraint/index güncellemeleri
  - [ ] `tenant/constraints/game.sql` -- CHAR(3) -> VARCHAR(20) uyumu
  - [ ] `tenant/indexes/game.sql` -- `idx_game_settings_cursor` BTREE(display_order, id)

---

## Adım 2: Game DB -- Catalog Fonksiyonları (Grup A0 + A: 8)

Klasör: `game/functions/catalog/`
Pattern: SECURITY DEFINER, IDOR yok

- [ ] **#0** `game_provider_sync.sql` -- Provider sync (Core->Game DB)
  - `p_providers TEXT` -> JSONB cast, UPSERT per element
  - Backend Core'dan GAME tipli provider'ları alıp geçirir
  - Return: INTEGER (upsert sayısı)

- [ ] **#1** `game_upsert.sql` -- Tekil oyun upsert
  - Feedback servis: `(provider_id, external_game_id)` bazlı
  - Normalize: LOWER(game_code), UPPER(game_type, volatility)
  - Return: BIGINT (game id)

- [ ] **#2** `game_bulk_upsert.sql` -- Toplu oyun upsert
  - `p_provider_id BIGINT, p_games TEXT` -> JSONB cast, tek transaction
  - İlk yükleme ve periyodik tam sync için
  - Return: INTEGER (upsert sayısı)

- [ ] **#3** `game_update.sql` -- BO metadata güncelleme
  - COALESCE pattern (NULL = değiştirme)
  - Soft delete: `p_is_active := FALSE`
  - Return: VOID

- [ ] **#4** `game_get.sql` -- Tekil oyun detay
  - JOIN game_providers
  - Return: TABLE

- [ ] **#5** `game_list.sql` -- Filtreli liste
  - Filter: provider, type, status, search ILIKE
  - Return: TABLE

- [ ] **#6** `game_lookup.sql` -- Dropdown hafif liste
  - id, code, name, provider, type
  - Return: TABLE

- [ ] **#7** `game_currency_limit_sync.sql` -- Currency limit bulk upsert
  - `p_game_id BIGINT, p_limits TEXT` -> JSONB cast
  - Artık desteklenmeyen -> `is_active=false` (hard delete yok)
  - Return: VOID

---

## Adım 3: Core -- Tenant Provider Fonksiyonları (Grup B: 3)

Klasör: `core/functions/core/tenant_providers/`
Pattern: IDOR korumalı (`user_assert_access_company`)

- [ ] **#8** `tenant_provider_enable.sql` -- Provider aç + oyunları seed et
  - `p_game_data TEXT` -- Backend Game DB'den aldığı oyun listesi (JSONB array)
  - `p_rollout_status VARCHAR(20) DEFAULT 'production'` -- Shadow mode ile başlatılabilir (SHADOW_MODE)
  - core.tenant_providers UPSERT + core.tenant_games toplu INSERT (denorm alanlar ile)
  - catalog.games sorgusu YAPMAZ (cross-DB orchestration)
  - Mevcut oyunlara DOKUNMAZ (ON CONFLICT DO NOTHING)
  - Return: INTEGER (eklenen oyun sayısı)

- [ ] **#9** `tenant_provider_disable.sql` -- Provider kapat
  - Sadece flag: `is_enabled=false`
  - Oyunlara DOKUNMAZ (sorgu seviyesinde filtrelenir)
  - Return: VOID

- [ ] **#10** `tenant_provider_list.sql` -- Provider listesi
  - Sadece GAME provider'lar (provider_type_code = 'GAME')
  - gameCount subquery
  - +`rolloutStatus` çıktıda (SHADOW_MODE)
  - Return: JSONB

- [ ] **#10b** `tenant_provider_set_rollout.sql` -- Shadow/production geçişi (SHADOW_MODE YENİ)
  - `p_rollout_status VARCHAR(20)` -- 'shadow' | 'production'
  - IDOR guard: user_assert_access_tenant
  - Return: VOID

---

## Adım 4: Core -- Tenant Game Fonksiyonları (Grup C: 4)

Klasör: `core/functions/core/tenant_games/`
Pattern: IDOR korumalı

- [ ] **#11** `tenant_game_upsert.sql` -- Tekil oyun aç/düzenle
  - Customization alanları (display_order, custom_name, blocked_countries vb.)
  - catalog.games validasyonu YAPILMAZ (cross-DB, backend doğrular)
  - sync_status = 'pending'
  - Return: VOID

- [ ] **#12** `tenant_game_list.sql` -- Oyun listesi (BO admin)
  - Denormalize alanlardan sorgu, catalog.games JOIN YOK
  - Provider filtresi YOK -- tüm oyunlar görünür
  - `providerIsEnabled` bilgi amaçlı döner
  - Return: JSONB

- [ ] **#13** `tenant_game_remove.sql` -- Oyun kapat
  - Soft delete: `is_enabled=false` + `disabled_reason`
  - Return: VOID

- [ ] **#14** `tenant_game_refresh.sql` -- Yeni oyunları toplu seed et
  - `p_game_data TEXT` -- Backend Game DB'den aldığı oyun listesi
  - Provider'ın yeni oyunlarını tenant_games'e ekle (denorm alanlar ile)
  - ON CONFLICT DO NOTHING
  - Return: INTEGER

---

## Adım 5: Tenant -- Sync Fonksiyonları (Grup D: 3)

Klasör: `tenant/functions/game/`
Pattern: Auth-agnostic (backend çağırır)

- [ ] **#15** `game_settings_sync.sql` -- Core->Tenant game data upsert
  - `p_catalog_data TEXT` -> JSONB cast -> typed kolonlara extract
  - `p_rollout_status VARCHAR(20) DEFAULT 'production'` -- Provider rollout status miras alınır (SHADOW_MODE)
  - INSERT: catalog + tenant override (default değerler)
  - UPDATE: SADECE catalog alanları -- tenant override'lara DOKUNMAZ
  - Return: VOID

- [ ] **#16** `game_settings_remove.sql` -- Oyun devre dışı bırak
  - Soft delete: `is_enabled=false`
  - Fiziksel DELETE yok, game_limits korunur
  - Return: VOID

- [ ] **#17** `game_limits_sync.sql` -- Core->Tenant currency limits
  - `p_limits TEXT` -> JSONB cast
  - Artık desteklenmeyen -> `is_active=false` (hard delete yok)
  - Return: VOID

- [ ] **#17b** `game_provider_rollout_sync.sql` -- Provider rollout status toplu güncelle (SHADOW_MODE YENİ)
  - `p_provider_id BIGINT, p_rollout_status VARCHAR(20)`
  - UPDATE game.game_settings SET rollout_status WHERE provider_id
  - Return: INTEGER (güncellenen satır)

---

## Adım 6: Tenant -- BO Yönetim + Game Open (Grup E: 5)

Klasör: `tenant/functions/game/`
Pattern: Auth-agnostic

- [ ] **#18** `game_settings_get.sql` -- Tekil oyun detay (game open)
  - Game open flow: provider_id + external_game_id -> Gateway gRPC
  - Return: JSONB

- [ ] **#19** `game_settings_update.sql` -- Tenant customization
  - COALESCE pattern (NULL = değiştirme)
  - Editable: custom_name, display_order, is_visible, is_featured, blocked_countries, vb.
  - Return: VOID

- [ ] **#20** `game_settings_list.sql` -- Lobi oyun listesi
  - `p_provider_ids BIGINT[]` -- lobi filtresi (backend core'dan alır)
  - `p_player_id BIGINT DEFAULT NULL` -- NULL=anonymous, NOT NULL=logged in (SHADOW_MODE)
  - Shadow mode filtresi: production herkes görür, shadow sadece auth.shadow_testers (SHADOW_MODE)
  - Cursor pagination: (display_order, id)
  - Search: ILIKE on game_name, game_code, custom_name
  - Return: JSONB `{items, nextCursorOrder, nextCursorId, hasMore}`

- [ ] **#21** `game_limit_upsert.sql` -- Oyun limiti ekle/güncelle
  - UPSERT: (game_id, currency_code)
  - Return: VOID

- [ ] **#22** `game_limit_list.sql` -- Oyun limit listesi
  - WHERE `is_active=true`
  - Return: JSONB

---

## Adım 6b: Tenant -- Shadow Tester CRUD (Grup F: 2) — SHADOW_MODE

Klasör: `tenant/functions/auth/`
Pattern: Auth-agnostic (backend çağırır)

- [ ] **#23** `shadow_tester_add.sql` -- Shadow tester ekle (SHADOW_MODE YENİ)
  - `p_player_id BIGINT, p_note VARCHAR(255), p_added_by VARCHAR(100)`
  - ON CONFLICT (player_id) DO NOTHING (idempotent)
  - Return: VOID

- [ ] **#24** `shadow_tester_remove.sql` -- Shadow tester çıkar (SHADOW_MODE YENİ)
  - `p_player_id BIGINT`
  - DELETE FROM auth.shadow_testers WHERE player_id = p_player_id
  - Return: VOID

---

## Adım 7: Deploy Dosyaları

### deploy_game.sql (MAJOR güncelleme)
- [ ] `catalog` schema + tablolar (game_providers, games, game_currency_limits)
- [ ] Fonksiyonlar: Catalog (8: game_provider_sync + Grup A)
- [ ] Constraints: `game/constraints/catalog.sql`
- [ ] Indexes: `game/indexes/catalog.sql`

### deploy_core.sql değişiklikleri
- [ ] `catalog.games` satırı **KALDIRILDI** (Game DB'ye taşındı)
- [ ] Fonksiyonlar: Tenant Providers (3: Grup B)
- [ ] Fonksiyonlar: Tenant Games (4: Grup C)

### deploy_tenant.sql eklemeleri
- [ ] Tablo: `auth.shadow_testers` (SHADOW_MODE)
- [ ] Fonksiyonlar: Game Sync (4: Grup D, +rollout_sync)
- [ ] Fonksiyonlar: Game BO + Game Open (5: Grup E)
- [ ] Fonksiyonlar: Shadow Tester CRUD (2: Grup F, SHADOW_MODE)

---

## Adım 8: Doküman Güncellemeleri

- [x] `GAME_ARCHITECTURE.md` -- Tam güncellendi (Game DB catalog owner)
- [x] `GAME_ISSUE.md` -- Yeni dosya lokasyonları ve checklist
- [ ] `FUNCTIONS_CORE.md` güncelle
- [ ] `FUNCTIONS_TENANT.md` güncelle

---

## Uygulama Sırası

1. Game DB tablo dosyaları (game_providers, games, game_currency_limits)
2. Game DB constraints + indexes
3. Core DB temizlik (games.sql kaldır, tenant_games modify, constraints/indexes güncelle)
4. Game DB catalog fonksiyonları (Grup A0 + A: 8)
5. Core tenant_provider fonksiyonları (Grup B: 3)
6. Core tenant_game fonksiyonları (Grup C: 4)
7. Tenant DB tablo modify (game_limits, game_settings)
8. Tenant sync fonksiyonları (Grup D: 3)
9. Tenant BO + Game Open fonksiyonları (Grup E: 5)
10. Deploy dosyaları güncelle
11. Doküman: FUNCTIONS_CORE.md, FUNCTIONS_TENANT.md

## Doğrulama

- [ ] Her fonksiyonun DROP + CREATE syntax kontrolü
- [ ] Deploy script sırasının tutarlılığı
- [ ] MCP ile tenant DB'de ALTER sonrası kolon kontrolü
- [ ] Fonksiyon imza/return type doğrulama
- [ ] Cross-DB orchestration akışlarının backend seviyesinde test edilmesi
