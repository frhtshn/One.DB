> **KULLANIM DIŞI:** Bu rehber artık güncel değildir.
> Fonksiyonel spesifikasyon için bkz. [SPEC_PLATFORM_OPERATIONS.md](SPEC_PLATFORM_OPERATIONS.md).
> Bu dosya yalnızca ek referans olarak korunmaktadır.

# Shadow Mode (Staged Rollout) — Geliştirici Rehberi

Yeni provider entegrasyonlarını production ortamında sadece belirli test oyuncularına açarak güvenli test yapma mekanizması.

---

## Neden Shadow Mode?

Provider entegrasyonu sırasında geçilen aşamalar:

```
Staging (dev) → Beta (test) → Shadow Mode (prod, kısıtlı) → Production (herkese açık)
```

DB seviyesinde sadece **shadow ↔ production** ayrımı yapılır. Shadow mode ile:

- Yeni entegrasyon gerçek production ortamında test edilir (gerçek para, gerçek veriler)
- Sadece seçilen 5-10 test oyuncusu yeni entegrasyonu görür
- Normal oyuncular ve ziyaretçiler hiçbir fark görmez
- Test başarılı → tek tıkla production'a geçiş

---

## Nasıl Çalışır?

| Kullanıcı Tipi | `production` | `shadow` |
|----------------|:------------:|:--------:|
| Anonymous | Görür | Göremez |
| Normal oyuncu | Görür | Göremez |
| Shadow tester | Görür | Görür |

---

## DB Yapısı

Shadow mode 3 tabloda 1 kolon + 1 yeni tablo ile çalışır:

### rollout_status Kolonu

| Tablo | DB | Kolon |
|-------|-----|-------|
| `core.client_providers` | Core | `rollout_status VARCHAR(20) DEFAULT 'production'` |
| `game.game_settings` | Client | `rollout_status VARCHAR(20) DEFAULT 'production'` |
| `finance.payment_method_settings` | Client | `rollout_status VARCHAR(20) DEFAULT 'production'` |

CHECK constraint: `rollout_status IN ('shadow', 'production')`

### Shadow Testers Tablosu

```sql
-- Client DB: auth.shadow_testers
player_id BIGINT NOT NULL UNIQUE   -- Oyuncu ID
note VARCHAR(255)                   -- Neden shadow tester yapıldı
added_by VARCHAR(100)               -- Ekleyen kullanıcı
```

Tipik boyut: **5-10 kayıt** per client. `UNIQUE(player_id)` otomatik B-tree index oluşturur.

---

## SQL Visibility Mantığı

`game_settings_list` ve `payment_method_settings_list` fonksiyonlarında:

```sql
WHERE ...
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

| Senaryo | Oran | Maliyet |
|---------|------|---------|
| `rollout = 'production'` | %99+ | OR hemen TRUE → EXISTS çalışmaz → **ek maliyet = 0** |
| `rollout = 'shadow'` | %1 (1-3 client) | EXISTS on UNIQUE index (5-10 kayıt) → **nanosaniye** |

---

## Rollout Akışları

### 1. Shadow Tester Tanımlama

```
BO Admin → Backend:
  → Client DB: shadow_tester_add(player_id, note, added_by)
  → Idempotent: zaten varsa hata vermez
```

### 2. Provider'ı Shadow Mode ile Açma (Yeni Entegrasyon)

```
BO Admin → "Provider Aç" (rollout = shadow)
  → Core: client_provider_enable(client_id, provider_id, 'shadow')
  → Game DB / Finance DB: oyun/metot listesi çek
  → Core: client_game_upsert / client_payment_method_upsert
  → Client DB: game_settings_sync(rollout_status = 'shadow')
  → Client DB: payment_method_settings_sync(rollout_status = 'shadow')
```

**Sonuç:** Sadece shadow tester'lar yeni provider'ın oyunlarını/metotlarını görür.

### 3. Mevcut Provider'ı Shadow'a Çekme

```
BO Admin → "Shadow Mode'a Al"
  → Core: client_provider_set_rollout(client_id, provider_id, 'shadow')
  → Client DB: game_provider_rollout_sync(provider_id, 'shadow')
    → Tüm oyunların rollout_status = 'shadow'
  → Client DB: payment_provider_rollout_sync(provider_id, 'shadow')
    → Tüm metotların rollout_status = 'shadow'
```

### 4. Production'a Geçiş

```
BO Admin → "Production'a Al"
  → Core: client_provider_set_rollout(client_id, provider_id, 'production')
  → Client DB: game_provider_rollout_sync(provider_id, 'production')
  → Client DB: payment_provider_rollout_sync(provider_id, 'production')
```

**Sonuç:** Herkes görür.

### 5. Başka Client'lara Açma

Test başarılı olduktan sonra diğer client'lara doğrudan production olarak enable:

```
→ Core: client_provider_enable(other_client_id, provider_id, 'production')
→ Normal akış devam eder
```

---

## Fonksiyon Listesi

### Core DB

| Fonksiyon | Açıklama |
|----------|----------|
| `client_provider_set_rollout` | Provider rollout durumunu değiştir (shadow ↔ production) |
| `client_provider_enable` | +`p_rollout_status` parametresi (varsayılan: 'production') |
| `client_provider_list` | +`rollout_status` çıktı kolonu |

### Client DB

| Fonksiyon | Açıklama |
|----------|----------|
| `shadow_tester_add` | Shadow tester ekle (idempotent) |
| `shadow_tester_remove` | Shadow tester kaldır |
| `shadow_tester_list` | Tüm shadow tester'ları listele (username dahil) |
| `shadow_tester_get` | player_id bazlı shadow tester detayı |
| `game_provider_rollout_sync` | Provider'ın tüm oyunlarının rollout durumunu toplu güncelle |
| `payment_provider_rollout_sync` | Provider'ın tüm metotlarının rollout durumunu toplu güncelle |
| `game_settings_sync` | +`p_rollout_status` parametresi |
| `payment_method_settings_sync` | +`p_rollout_status` parametresi |
| `game_settings_list` | +shadow mode WHERE filtresi |
| `payment_method_settings_list` | +shadow mode WHERE filtresi |

---

## Frontend İçin Notlar

- **Lobby/Cashier**: `game_settings_list(player_id)` ve `payment_method_settings_list(player_id)` fonksiyonları zaten shadow filtresi uygular
- **Anonymous ziyaretçi**: `player_id = NULL` gönderilir → shadow oyunlar/metotlar otomatik filtrelenir
- **Ekstra UI gerekmez**: Shadow mode tamamen backend seviyesinde çalışır, frontend değişikliği yok
- Shadow tester yönetimi BO panelinden yapılır

## Backend İçin Notlar

- **Rollout değişikliği cascade**: `client_provider_set_rollout` çağrıldıktan sonra backend Client DB'de `game_provider_rollout_sync` ve `payment_provider_rollout_sync` çağırmalı
- **Superadmin yetkisi**: rollout_status değişikliği sadece superadmin yapabilir (backend yetki kontrolü)
- **Denormalizasyon**: rollout_status Core'da `client_providers`'da, Client'ta `game_settings` ve `payment_method_settings`'de tutulur — sync ile tutarlılık sağlanır

---

_İlgili dokümanlar: [SHADOW_MODE_ARCHITECTURE.md](../../.planning/SHADOW_MODE_ARCHITECTURE.md) · [GAME_GATEWAY_GUIDE.md](GAME_GATEWAY_GUIDE.md) · [FINANCE_GATEWAY_GUIDE.md](FINANCE_GATEWAY_GUIDE.md) · [FUNCTIONS_CORE.md](../reference/FUNCTIONS_CORE.md)_
