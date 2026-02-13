# Shadow Mode (Staged Rollout) - Tam Uygulama

Provider entegrasyonlarının production ortamında kontrollü açılması.
Mimari detaylar: [SHADOW_MODE_ARCHITECTURE.md](SHADOW_MODE_ARCHITECTURE.md)

## Senaryo

1. Platform admin tenant'a shadow tester oyuncular tanımlar
2. Superadmin provider'ı 1-3 tenant'ta shadow mode ile açar
3. Shadow tester'lar tenant sitesinde (lobby, cashier) entegrasyonu görür ve kullanır
4. Giriş yapmamış ziyaretçiler ve normal oyuncular entegrasyonu göremez
5. Production test başarılı → superadmin production mode'a geçirir, herkes görebilir
6. Diğer tenant'lara direkt production olarak açılır (shadow aşaması gerekmez)

## Mimari Kararlar

- **Provider seviyesinde rollout**: Tek kolon (`rollout_status`) ile kontrol, tüm oyunlar/metodlar aynı durumu paylaşır
- **Dedicated shadow_testers tablosu**: Player group/category tenant-specific → standart grup kodu dayatılamaz
- **Denormalize rollout_status**: Core'dan Tenant DB'ye sync (game_settings, payment_method_settings)
- **Hedefleme ayrı tablo**: `auth.shadow_testers` — targeting verisi denormalize edilmez
- **Ek maliyet = ~0**: Production kayıtlarda ilk OR hemen TRUE, EXISTS çalışmaz
- **Superadmin yönetimi**: `updated_at` ile takip yeterli, ayrı timestamp gereksiz

---

## Adım 1: Tablo Değişiklikleri

### Core DB

- [ ] **1A.** `core.tenant_providers` -- MODIFY (Core DB)
  - `core/tables/core/integration/tenant_providers.sql`
  - ADD `rollout_status VARCHAR(20) NOT NULL DEFAULT 'production'`
  - ADD `CONSTRAINT chk_tenant_providers_rollout CHECK (rollout_status IN ('shadow', 'production'))`
  - `mode` (real/demo/test) ve `rollout_status` (shadow/production) bağımsız çalışır

### Tenant DB

- [ ] **1B.** `auth.shadow_testers` -- YENİ TABLO (Tenant DB)
  - `tenant/tables/player_auth/shadow_testers.sql`
  - `player_id BIGINT NOT NULL` + `note VARCHAR(255)` + `added_by VARCHAR(100)`
  - `UNIQUE(player_id)` — UNIQUE constraint otomatik index oluşturur
  - FK: `player_id -> auth.players(id) ON DELETE CASCADE`
  - Tipik boyut: 5-10 kayıt per tenant

- [ ] **1C.** `game.game_settings` -- MODIFY (Tenant DB)
  - `tenant/tables/game/game_settings.sql`
  - ADD `rollout_status VARCHAR(20) NOT NULL DEFAULT 'production'`
  - Senkronizasyon bölümüne, `core_synced_at` yanına eklenir

- [ ] **1D.** `finance.payment_method_settings` -- MODIFY (Tenant DB)
  - `tenant/tables/finance/payment_method_settings.sql`
  - ADD `rollout_status VARCHAR(20) NOT NULL DEFAULT 'production'`
  - Senkronizasyon bölümüne, `core_synced_at` yanına eklenir

### Constraint ve Index Güncellemeleri

- [ ] **1E-a.** Tenant DB constraint eklenmesi
  - [ ] `tenant/constraints/auth.sql` -- shadow_testers FK + UQ
    - `fk_shadow_testers_player` → `auth.players(id) ON DELETE CASCADE`
    - `uq_shadow_testers_player` → `UNIQUE(player_id)`

- [ ] **1E-b.** Tenant DB index
  - [ ] `tenant/indexes/auth.sql` -- UNIQUE constraint otomatik index oluşturur, ek index gereksiz

---

## Adım 2: Core -- Rollout Yönetimi (Grup A: 1)

Klasör: `core/functions/core/tenant_providers/`
Pattern: IDOR korumalı (`user_assert_access_tenant`)

- [ ] **#1** `tenant_provider_set_rollout.sql` -- Rollout durumu değiştir (YENİ)
  - `p_user_id BIGINT, p_company_id BIGINT, p_tenant_id BIGINT`
  - `p_provider_id BIGINT, p_rollout_status VARCHAR(20)`
  - IDOR guard: `user_assert_access_tenant`
  - Validate: `p_rollout_status IN ('shadow', 'production')`
  - NOT FOUND → RAISE `'error.tenant_provider.not_found'`
  - Backend: Başarılı dönünce Tenant DB'ye sync tetikler (outbox event)
  - Return: VOID

---

## Adım 3: Core -- Mevcut Fonksiyon Modifikasyonları (Grup B: 2)

Bu fonksiyonlar Faz 2 (Game) kapsamında zaten yazılacak. Shadow mode eklentileri:

- [ ] **#2** `tenant_provider_enable` -- +p_rollout_status parametresi (MODIFY)
  - Yeni parametre: `p_rollout_status VARCHAR(20) DEFAULT 'production'`
  - INSERT satırına: `rollout_status = p_rollout_status`
  - Provider ilk enable'da direkt shadow mode ile başlatılabilir
  - GAME_ISSUE #8 ile birlikte uygulanır

- [ ] **#3** `tenant_provider_list` -- +rollout_status çıktısı (MODIFY)
  - JSONB çıktıya: `'rolloutStatus', tp.rollout_status`
  - GAME_ISSUE #10 ile birlikte uygulanır

---

## Adım 4: Tenant -- Shadow Tester Yönetimi (Grup C: 2)

Klasör: `tenant/functions/auth/`
Pattern: Auth-agnostic (backend çağırır)

- [ ] **#4** `shadow_tester_add.sql` -- Shadow tester ekle (YENİ)
  - `p_player_id BIGINT, p_note VARCHAR(255) DEFAULT NULL, p_added_by VARCHAR(100) DEFAULT NULL`
  - Idempotent: `ON CONFLICT (player_id) DO NOTHING`
  - Return: VOID

- [ ] **#5** `shadow_tester_remove.sql` -- Shadow tester çıkar (YENİ)
  - `p_player_id BIGINT`
  - `DELETE FROM auth.shadow_testers WHERE player_id = p_player_id`
  - Return: VOID

---

## Adım 5: Tenant -- Rollout Sync (Grup D: 2)

Backend Core'dan tetiklenir, provider'ın tüm ürünleri için rollout status toplu günceller.

- [ ] **#6** `game_provider_rollout_sync.sql` -- Game rollout sync (YENİ)
  - `tenant/functions/game/game_provider_rollout_sync.sql`
  - `p_provider_id BIGINT, p_rollout_status VARCHAR(20)`
  - `UPDATE game.game_settings SET rollout_status, updated_at WHERE provider_id`
  - Return: INTEGER (güncellenen satır sayısı)
  - GAME_ISSUE #17b ile aynı

- [ ] **#7** `payment_provider_rollout_sync.sql` -- Finance rollout sync (YENİ)
  - `tenant/functions/finance/payment_provider_rollout_sync.sql`
  - `p_provider_id BIGINT, p_rollout_status VARCHAR(20)`
  - `UPDATE finance.payment_method_settings SET rollout_status, updated_at WHERE provider_id`
  - Return: INTEGER (güncellenen satır sayısı)
  - FINANCE_ISSUE #17b ile aynı

---

## Adım 6: Tenant -- Mevcut Fonksiyon Modifikasyonları (Grup E: 4)

Bu fonksiyonlar Faz 2 (Game) ve Faz 3 (Finance) kapsamında zaten yazılacak. Shadow mode eklentileri:

### Sync Fonksiyonları (+p_rollout_status)

- [ ] **#8** `game_settings_sync` -- +rollout_status miras alır (MODIFY)
  - Yeni parametre: `p_rollout_status VARCHAR(20) DEFAULT 'production'`
  - Yeni oyun eklendiğinde provider'ın rollout status'unu miras alır
  - GAME_ISSUE #15 ile birlikte uygulanır

- [ ] **#9** `payment_method_settings_sync` -- +rollout_status miras alır (MODIFY)
  - Yeni parametre: `p_rollout_status VARCHAR(20) DEFAULT 'production'`
  - Aynı mantık, finance tarafında
  - FINANCE_ISSUE #15 ile birlikte uygulanır

### Tenant Site Fonksiyonları (+shadow mode filtresi)

- [ ] **#10** `game_settings_list` -- +shadow mode filtresi (MODIFY)
  - Mevcut parametre: `p_player_id BIGINT DEFAULT NULL` (NULL = anonymous)
  - WHERE clause'a shadow mode filtresi eklenir
  - GAME_ISSUE #20 ile birlikte uygulanır

- [ ] **#11** `payment_method_settings_list` -- +shadow mode filtresi (MODIFY)
  - Mevcut parametre: `p_player_id BIGINT DEFAULT NULL` (NULL = anonymous)
  - WHERE clause'a shadow mode filtresi eklenir
  - FINANCE_ISSUE #20 ile birlikte uygulanır

### Shadow Mode Filtre SQL (tüm tenant site fonksiyonlarında aynı)

```sql
AND (
  gs.rollout_status = 'production'                -- Production: herkes görür
  OR (
    gs.rollout_status = 'shadow'                  -- Shadow: sadece tester'lar görür
    AND p_player_id IS NOT NULL                   -- Giriş yapmış olmalı
    AND EXISTS (
      SELECT 1 FROM auth.shadow_testers st
      WHERE st.player_id = p_player_id
    )
  )
)
```

---

## Visibility Kuralları

| Durum | rollout = production | rollout = shadow |
|-------|---------------------|-----------------|
| Anonymous ziyaretçi (NULL) | GÖRÜR | GÖREMEZ |
| Giriş yapmış normal oyuncu | GÖRÜR | GÖREMEZ |
| Giriş yapmış shadow tester | GÖRÜR | GÖRÜR |

---

## Backend Orchestration Akışları

### Akış 1: Shadow Tester Tanımlama (provider'dan bağımsız)
```
Admin -> Tenant DB: shadow_tester_add(player_id, note, added_by)
```

### Akış 2: Provider Shadow Mode ile Açma (1-3 tenant'ta)
```
Backend -> Core DB: tenant_provider_enable(tenant_id, provider_id, rollout_status='shadow', p_game_data='...')
Backend -> Tenant DB: game_settings_sync(..., rollout_status='shadow')
```

### Akış 3: Production'a Geçiş
```
Backend -> Core DB: tenant_provider_set_rollout(tenant_id, provider_id, 'production')
Backend -> Tenant DB: game_provider_rollout_sync(provider_id, 'production')
```

### Akış 4: Diğer Tenant'lara Açma
```
Backend -> Core DB: tenant_provider_enable(tenant_id_X, provider_id, rollout_status='production')
-- Shadow aşaması gerekmez
```

---

## Deploy Dosyaları

### deploy_core.sql değişiklikleri
- [ ] `core.tenant_providers` tablo modify (+rollout_status, +CHECK)
- [ ] Fonksiyon: `tenant_provider_set_rollout` (YENİ)
- [ ] Fonksiyon: `tenant_provider_enable` (MODIFY)
- [ ] Fonksiyon: `tenant_provider_list` (MODIFY)

### deploy_tenant.sql eklemeleri
- [ ] Tablo: `auth.shadow_testers` (YENİ)
- [ ] Constraint: `tenant/constraints/auth.sql`
- [ ] Fonksiyon: `shadow_tester_add` (YENİ)
- [ ] Fonksiyon: `shadow_tester_remove` (YENİ)
- [ ] Fonksiyon: `game_provider_rollout_sync` (YENİ)
- [ ] Fonksiyon: `payment_provider_rollout_sync` (YENİ)
- [ ] Fonksiyon: `game_settings_sync` (MODIFY)
- [ ] Fonksiyon: `payment_method_settings_sync` (MODIFY)
- [ ] Fonksiyon: `game_settings_list` (MODIFY)
- [ ] Fonksiyon: `payment_method_settings_list` (MODIFY)

---

## Uygulama Sırası

Shadow mode itemleri mevcut fazlara entegre edilmiştir:

1. **Faz 0** — Tablo değişiklikleri (1A-1E): tenant_providers modify, shadow_testers yeni tablo, game_settings modify, payment_method_settings modify
2. **Faz 2 Grup B** — `tenant_provider_set_rollout` (YENİ) + enable/list modifikasyonları
3. **Faz 2 Grup D** — `game_provider_rollout_sync` (YENİ) + game_settings_sync modifikasyonu
4. **Faz 2 Grup E** — `game_settings_list` shadow mode filtresi
5. **Faz 2 Grup F** — `shadow_tester_add` + `shadow_tester_remove` (YENİ)
6. **Faz 3 Grup D** — `payment_provider_rollout_sync` (YENİ) + payment_method_settings_sync modifikasyonu
7. **Faz 3 Grup E** — `payment_method_settings_list` shadow mode filtresi

---

## Doğrulama

- [ ] `rollout_status DEFAULT 'production'` → mevcut providerlar otomatik production, kırılma yok
- [ ] `mode` (real/demo/test) ve `rollout_status` (shadow/production) bağımsız çalışır
- [ ] Anonymous ziyaretçi (`p_player_id IS NULL`) shadow ürünleri göremez
- [ ] Normal oyuncu giriş yaptığında shadow ürünleri göremez
- [ ] Shadow tester giriş yaptığında shadow ürünleri görebilir ve kullanabilir
- [ ] Production'a geçişte tüm oyuncular (shadow tester dahil) görebilir
- [ ] Production kayıtlarda ek maliyet 0 (ilk OR hemen TRUE)
- [ ] Shadow kayıtlarda EXISTS on UNIQUE index → nanosaniye
- [ ] `auth.shadow_testers` her tenant'ın kendi DB'sinde, cross-DB query yok
- [ ] Deploy script sırasının tutarlılığı (tablo -> constraint -> fonksiyon)
- [ ] IMPLEMENTATION_ORDER.md ile checklist tutarlılığı
