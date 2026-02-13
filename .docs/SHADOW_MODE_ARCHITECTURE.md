# Shadow Mode (Staged Rollout) - Mimari Plan

## Context

Finans ve oyun entegrasyonları sırasında şu aşamalar var:
- **Staging** → geliştirme ortamı (ayrı DB/sunucu)
- **Beta** → test ortamı (ayrı DB/sunucu)
- **Shadow Mode** → production ortamında sadece belirli oyunculara açık (production API key, prod sunucu)
- **Production** → herkese açık

Staging/Beta ayrı environment'lardır, DB'de takip edilmez. DB seviyesinde sadece **shadow <-> production** ayrımı yapılır.

**Senaryo Özeti:**
1. Superadmin yeni provider entegrasyonunu 1-3 tenant'ta shadow mode ile açar
2. Shadow tester oyuncular tenant sitesinde (lobby, cashier) bu entegrasyonu görür ve kullanır
3. Giriş yapmamış ziyaretçiler ve normal oyuncular entegrasyonu hiç göremez
4. Production test başarılı olunca superadmin production mode'a çeker, herkes görebilir
5. Diğer tenant'lara açılırken direkt production olarak enable edilir

**Kararlar:**
- **Provider seviyesinde rollout**: Tek kolon (`rollout_status`) ile kontrol. Provider'ın tüm oyunları/metodları aynı rollout durumunu paylaşır.
- **Dedicated shadow_testers tablosu**: Player group/category'ler tenant-specific olduğu için standart grup kodu dayatılamaz. Her tenant kendi shadow tester listesini yönetir.
- **Denormalize rollout_status**: Tenant DB'deki `game_settings` ve `payment_method_settings` tablolarına sync edilir. Hedefleme bilgisi denormalize edilmez (shadow_testers tablosunda kalır).
- **Ek maliyet = ~0**: Production kayıtlarda ilk `OR` hemen TRUE döner, EXISTS çalışmaz. Shadow kayıtlarda EXISTS on UNIQUE index (5-10 kayıt) → nanosaniye.
- **Superadmin yönetimi**: `rollout_status` değişikliği superadmin tarafından yapılır. Süresi önceden bilinmez, `updated_at` ile takip yeterli.

---

## Mevcut Durum

| Tablo | DB | Durum | Shadow Mode Etkisi |
|---|---|---|---|
| `core.tenant_providers` | Core | **DEPLOYED** | ADD `rollout_status` + CHECK constraint |
| `game.game_settings` | Tenant | **DEPLOYED** | ADD `rollout_status` (denormalize) |
| `finance.payment_method_settings` | Tenant | **DEPLOYED** | ADD `rollout_status` (denormalize) |
| `auth.player_groups` | Tenant | **DEPLOYED** | Etkilenmez (shadow_testers ayrı tablo) |
| `auth.player_categories` | Tenant | **DEPLOYED** | Etkilenmez |
| `auth.player_classification` | Tenant | **DEPLOYED** | Etkilenmez |
| `auth.shadow_testers` | Tenant | **YOK** | YENİ TABLO |

---

## 1. Tablo Değişiklikleri

### 1A. Core DB: `core.tenant_providers` — MODIFY

Dosya: `core/tables/core/integration/tenant_providers.sql`

Mevcut kolonlar: `id`, `tenant_id`, `provider_id`, `mode`, `is_enabled`, `created_at`, `updated_at`

```sql
-- Yeni kolon
rollout_status VARCHAR(20) NOT NULL DEFAULT 'production',    -- Rollout durumu: shadow | production

-- Yeni constraint
CONSTRAINT chk_tenant_providers_rollout CHECK (rollout_status IN ('shadow', 'production'))
```

**Neden tek kolon:**
- Superadmin değiştirir, süresi belli değil
- `updated_at` zaten tabloda → ayrı timestamp gereksiz
- `mode` (real/demo/test) API modu içindir, rollout'tan bağımsız çalışır

### 1B. Tenant DB: `auth.shadow_testers` — YENİ TABLO

Dosya: `tenant/tables/player_auth/shadow_testers.sql`

```sql
-- =============================================
-- Tablo: auth.shadow_testers
-- Açıklama: Shadow mode test oyuncuları
-- Her tenant kendi tester listesini yönetir
-- =============================================

DROP TABLE IF EXISTS auth.shadow_testers CASCADE;

CREATE TABLE auth.shadow_testers (
    id BIGSERIAL PRIMARY KEY,
    player_id BIGINT NOT NULL,                                    -- Oyuncu ID (FK: auth.players)
    note VARCHAR(255),                                            -- Açıklama: "QA Team - Ahmet"
    added_by VARCHAR(100),                                        -- Ekleyen: "platform_admin", "tenant_admin"
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW() -- Kayıt zamanı
);

COMMENT ON TABLE auth.shadow_testers IS 'Shadow mode test players for staged rollout of provider integrations per tenant';
```

**Constraint:** `tenant/constraints/auth.sql`
```sql
-- shadow_testers
ALTER TABLE auth.shadow_testers
    ADD CONSTRAINT fk_shadow_testers_player FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE,
    ADD CONSTRAINT uq_shadow_testers_player UNIQUE (player_id);
```

**Index:** `tenant/indexes/auth.sql`
```sql
-- shadow_testers (UNIQUE constraint otomatik index oluşturur, ek index gereksiz)
```

### 1C. Tenant DB: `game.game_settings` — MODIFY

Dosya: `tenant/tables/game/game_settings.sql`

```sql
-- Yeni kolon (Senkronizasyon bölümüne eklenir, core_synced_at yanına)
rollout_status VARCHAR(20) NOT NULL DEFAULT 'production'          -- Core'dan sync: shadow | production
```

### 1D. Tenant DB: `finance.payment_method_settings` — MODIFY

Dosya: `tenant/tables/finance/payment_method_settings.sql`

```sql
-- Yeni kolon (Senkronizasyon bölümüne eklenir, core_synced_at yanına)
rollout_status VARCHAR(20) NOT NULL DEFAULT 'production'          -- Core'dan sync: shadow | production
```

---

## 2. Fonksiyonlar

### Grup A: Core — Rollout Yönetimi (1 yeni fonksiyon)

Klasör: `core/functions/core/tenant_providers/`
Pattern: IDOR korumalı (`user_assert_access_tenant`)

#### #1 `tenant_provider_set_rollout.sql` — YENİ

Superadmin provider'ın rollout durumunu değiştirir.

```
Input:
  p_user_id BIGINT
  p_company_id BIGINT
  p_tenant_id BIGINT
  p_provider_id BIGINT
  p_rollout_status VARCHAR(20)          -- 'shadow' | 'production'

İşlem:
  1. IDOR guard: user_assert_access_tenant(p_user_id, p_company_id, p_tenant_id)
  2. Validate: p_rollout_status IN ('shadow', 'production')
  3. UPDATE core.tenant_providers
     SET rollout_status = p_rollout_status,
         updated_at = NOW()
     WHERE tenant_id = p_tenant_id AND provider_id = p_provider_id
  4. NOT FOUND → RAISE 'error.tenant_provider.not_found'

Return: VOID
```

**Backend sorumluluğu:** Fonksiyon başarılı dönünce Tenant DB'ye sync tetiklenir (outbox event).

---

### Grup B: Core — Mevcut Fonksiyon Modifikasyonları (2)

#### `tenant_provider_enable` — +p_rollout_status parametresi

Faz 2'de (Game) zaten yazılacak. Shadow mode eklentisi:

```
Yeni parametre:
  p_rollout_status VARCHAR(20) DEFAULT 'production'

INSERT satırına eklenir:
  rollout_status = p_rollout_status
```

Provider ilk enable'da direkt shadow mode'da başlatılabilir:
```
Backend -> Core DB: tenant_provider_enable(tenant_id, provider_id, rollout_status='shadow')
```

#### `tenant_provider_list` — +rollout_status çıktısı

Faz 2'de zaten yazılacak. JSONB çıktıya eklenir:
```sql
'rolloutStatus', tp.rollout_status
```

---

### Grup C: Tenant — Shadow Tester Yönetimi (2 yeni fonksiyon)

Klasör: `tenant/functions/auth/`
Pattern: Auth-agnostic (backend çağırır)

#### #2 `shadow_tester_add.sql` — YENİ

```
Input:
  p_player_id BIGINT
  p_note VARCHAR(255) DEFAULT NULL
  p_added_by VARCHAR(100) DEFAULT NULL

İşlem:
  INSERT INTO auth.shadow_testers (player_id, note, added_by)
  VALUES (p_player_id, p_note, p_added_by)
  ON CONFLICT (player_id) DO NOTHING;

Return: VOID
```

#### #3 `shadow_tester_remove.sql` — YENİ

```
Input:
  p_player_id BIGINT

İşlem:
  DELETE FROM auth.shadow_testers WHERE player_id = p_player_id;

Return: VOID
```

---

### Grup D: Tenant — Rollout Sync (2 yeni fonksiyon)

Klasör: `tenant/functions/game/` ve `tenant/functions/finance/`
Pattern: Auth-agnostic (backend çağırır)

#### #4 `game_provider_rollout_sync.sql` — YENİ

Provider'ın tüm oyunları için rollout status toplu güncelle.

```
Input:
  p_provider_id BIGINT
  p_rollout_status VARCHAR(20)

İşlem:
  UPDATE game.game_settings
  SET rollout_status = p_rollout_status,
      updated_at = NOW()
  WHERE provider_id = p_provider_id;

Return: INTEGER (güncellenen satır sayısı)
```

#### #5 `payment_provider_rollout_sync.sql` — YENİ

```
Input:
  p_provider_id BIGINT
  p_rollout_status VARCHAR(20)

İşlem:
  UPDATE finance.payment_method_settings
  SET rollout_status = p_rollout_status,
      updated_at = NOW()
  WHERE provider_id = p_provider_id;

Return: INTEGER (güncellenen satır sayısı)
```

---

### Grup E: Tenant — Mevcut Fonksiyon Modifikasyonları (4)

#### `game_settings_sync` — +p_rollout_status

Faz 2 Grup D'de zaten yazılacak. Yeni oyun eklendiğinde provider'ın rollout status'unu miras alır:
```
Yeni parametre:
  p_rollout_status VARCHAR(20) DEFAULT 'production'

INSERT satırına eklenir:
  rollout_status = p_rollout_status
```

#### `payment_method_settings_sync` — +p_rollout_status

Faz 3 Grup D'de zaten yazılacak. Aynı mantık.

#### `game_settings_list` — +shadow mode filtresi

Faz 2 Grup E'de zaten yazılacak. Casino lobby fonksiyonu.

```
Mevcut parametre kullanılır:
  p_player_id BIGINT DEFAULT NULL     -- NULL = giriş yapmamış ziyaretçi

WHERE clause'a eklenir:
  AND (
    gs.rollout_status = 'production'
    OR (
      gs.rollout_status = 'shadow'
      AND p_player_id IS NOT NULL
      AND EXISTS (
        SELECT 1 FROM auth.shadow_testers st
        WHERE st.player_id = p_player_id
      )
    )
  )
```

#### `payment_method_settings_list` — +shadow mode filtresi

Faz 3 Grup E'de zaten yazılacak. Cashier fonksiyonu. Aynı filtre.

---

## 3. Visibility Kuralları

### Davranış Tablosu (Tenant Sitesi)

| Durum | rollout = production | rollout = shadow |
|-------|---------------------|-----------------|
| Anonymous ziyaretçi (NULL) | GÖRÜR | GÖREMEZ |
| Giriş yapmış normal oyuncu | GÖRÜR | GÖREMEZ |
| Giriş yapmış shadow tester | GÖRÜR | GÖRÜR |

### SQL Mantığı

```sql
-- rollout_status = 'production' → ilk OR hemen TRUE, EXISTS ÇALIŞMAZ
-- rollout_status = 'shadow' + p_player_id NULL → tüm OR FALSE, satır hariç
-- rollout_status = 'shadow' + p_player_id NOT NULL → EXISTS çalışır
--   → shadow_testers'da VAR → satır dahil
--   → shadow_testers'da YOK → satır hariç

AND (
  gs.rollout_status = 'production'
  OR (
    gs.rollout_status = 'shadow'
    AND p_player_id IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM auth.shadow_testers st
      WHERE st.player_id = p_player_id
    )
  )
)
```

### Performans

```
Senaryo 1: rollout_status = 'production' (%99+ kayıt, normal durum)
  → İlk OR TRUE → satır dahil, EXISTS ÇALIŞMAZ
  → Ek maliyet: 0

Senaryo 2: rollout_status = 'shadow' (1-3 tenant'ta, az sayıda kayıt)
  → p_player_id IS NULL (anonymous) → FALSE, satır hariç
  → p_player_id IS NOT NULL (normal oyuncu) → EXISTS çalışır, bulamaz → satır hariç
  → p_player_id IS NOT NULL (shadow tester) → EXISTS çalışır, bulur → satır dahil
  → EXISTS: UNIQUE index üzerinde, 5-10 kayıtlık tablo → nanosaniye
```

---

## 4. Backend Orchestration Akışları

### Akış 1: Shadow Tester Tanımlama

```
Admin BO'dan "Shadow Testers" sayfasına gider
  |
  Admin oyuncu arar (username/email ile)
  |
  Backend -> Tenant DB: shadow_tester_add(player_id, note, added_by)
  |
  Sonuç: Oyuncu shadow tester olarak tanımlandı
```

### Akış 2: Provider Shadow Mode ile Açma

```
Superadmin yeni provider'ı tenant'a açar (shadow mode)
  |
  Backend -> Core DB: tenant_provider_enable(
    tenant_id, provider_id,
    rollout_status = 'shadow',
    p_game_data = '...'            -- Game DB'den alınan oyun listesi
  )
  |
  Backend -> Tenant DB: game_settings_sync(
    ..., rollout_status = 'shadow'  -- Her oyun shadow olarak sync
  )
  |
  Sonuç: Provider'ın oyunları tenant sitesinde:
    - Shadow tester'lar görebilir ve oynayabilir
    - Diğer oyuncular göremez
    - Production API key ve sunucular kullanılır
```

### Akış 3: Mevcut Provider'ı Shadow'a Çekme

```
Superadmin mevcut provider'ın rollout'unu değiştirir
  |
  Backend -> Core DB: tenant_provider_set_rollout(
    tenant_id, provider_id, 'shadow'
  )
  |
  Backend -> Tenant DB: game_provider_rollout_sync(
    provider_id, 'shadow'
  )
  |
  Sonuç: Provider'ın tüm oyunları shadow'a geçti
```

### Akış 4: Production'a Geçiş

```
Shadow test başarılı, superadmin "Production'a Al" tıklar
  |
  Backend -> Core DB: tenant_provider_set_rollout(
    tenant_id, provider_id, 'production'
  )
  |
  Backend -> Tenant DB: game_provider_rollout_sync(
    provider_id, 'production'
  )
  |
  Sonuç: Tüm oyuncular (shadow tester'lar dahil) görebilir
```

### Akış 5: Diğer Tenant'lara Açma

```
Production test tamamlandı, superadmin diğer tenant'lara açar
  |
  Backend -> Core DB: tenant_provider_enable(
    tenant_id_X, provider_id,
    rollout_status = 'production'     -- Direkt production
  )
  |
  Sonuç: Shadow aşaması gerekmez, herkese açık
```

---

## 5. Fonksiyon Dağıtımı

| # | Fonksiyon | DB | Grup | Durum |
|---|----------|-----|------|-------|
| 1 | tenant_provider_set_rollout | Core | A | YENİ |
| — | tenant_provider_enable | Core | B | MODIFY (+p_rollout_status) |
| — | tenant_provider_list | Core | B | MODIFY (+rollout çıktısı) |
| 2 | shadow_tester_add | Tenant | C | YENİ |
| 3 | shadow_tester_remove | Tenant | C | YENİ |
| 4 | game_provider_rollout_sync | Tenant | D | YENİ |
| 5 | payment_provider_rollout_sync | Tenant | D | YENİ |
| — | game_settings_sync | Tenant | E | MODIFY (+p_rollout_status) |
| — | payment_method_settings_sync | Tenant | E | MODIFY (+p_rollout_status) |
| — | game_settings_list | Tenant | E | MODIFY (+shadow filtresi) |
| — | payment_method_settings_list | Tenant | E | MODIFY (+shadow filtresi) |

**Toplam:** 5 yeni fonksiyon + 6 modifikasyon = **11 fonksiyon etkisi**

---

## 6. Etki Özeti

| Kategori | Adet | Detay |
|----------|------|-------|
| Yeni tablo | 1 | auth.shadow_testers (Tenant DB, her tenant'ta ayrı) |
| Tablo modify | 3 | tenant_providers + game_settings + payment_method_settings |
| Yeni fonksiyon | 5 | set_rollout + 2 rollout_sync + tester_add + tester_remove |
| Fonksiyon modify | 6 | enable, list, 2 settings_sync, 2 settings_list |
| Constraint/index | 2 | shadow_testers FK + UQ (tenant/constraints/auth.sql) |
| **Toplam** | **17** | 1 tablo + 3 modify + 11 fonksiyon + 2 constraint |

---

## 7. Doğrulama

- [ ] `rollout_status DEFAULT 'production'` → mevcut providerlar otomatik production, kırılma yok
- [ ] Anonymous ziyaretçi (`p_player_id IS NULL`) shadow oyunları/metodları göremez
- [ ] Shadow tester giriş yaptığında shadow ürünleri görebilir ve kullanabilir
- [ ] Normal oyuncu giriş yaptığında shadow ürünleri göremez
- [ ] Production'a geçişte tüm oyuncular (shadow tester dahil) görebilir
- [ ] Production kayıtlarda ek maliyet 0 (ilk OR hemen TRUE)
- [ ] `auth.shadow_testers` her tenant'ın kendi DB'sinde, cross-DB query yok
- [ ] `mode` (real/demo/test) ve `rollout_status` (shadow/production) bağımsız çalışır
