> **KULLANIM DIŞI:** Bu rehber artık güncel değildir.
> Fonksiyonel spesifikasyon için bkz. [SPEC_BONUS_ENGINE.md](SPEC_BONUS_ENGINE.md).
> Bu dosya yalnızca ek referans olarak korunmaktadır.

# Bonus Engine — Geliştirici Rehberi

Bonus sistemi **JSON-driven generic rule engine** mimarisi kullanır. Eski MSSQL'deki 14 tablolu rigid yapı yerine, 6 JSONB bileşen ile her bonus tipini tek genel yapıda tanımlar.

---

## Büyük Resim

```mermaid
flowchart TD
    subgraph bonus["Bonus DB (Shared)"]
        B1["bonus.bonus_types<br/>bonus.bonus_rules"]
        B2["campaign.campaigns<br/>promotion.promo_codes"]
    end
    subgraph tenant["Tenant DB (Per-tenant)"]
        T1["bonus.bonus_awards<br/>bonus.promo_redemptions"]
        T2["bonus.bonus_request_settings<br/>bonus.bonus_requests<br/>bonus.bonus_request_actions"]
    end
    subgraph tenant_log["Tenant Log DB"]
        L1["bonus_log.bonus_evaluation_logs<br/>(daily partition, 90 gün)"]
    end
    BO["BO Admin"] --> B1
    BO --> B2
    BO -- "Manuel bonus / talep inceleme" --> T2
    Player["Oyuncu (FE)"] -- "Bonus talebi" --> T2
    B1 -- "rule referansı (cross-DB)" --> T1
    T2 -- "Onay → bonus_award_create()" --> T1
    W["Backend / Worker"] --> T1
    W --> L1
```

| Veritabanı | Tablolar | Erişim | Açıklama |
|------------|----------|--------|----------|
| **Bonus DB** (Shared) | `bonus.bonus_types`, `bonus.bonus_rules`, `campaign.campaigns`, `promotion.promo_codes` | BO Admin | Kural tanımları (shared, tüm tenant'lar için ortak yapılandırma) |
| **Tenant DB** (Per-tenant) | `bonus.bonus_awards`, `bonus.promo_redemptions` | Backend/Worker | Oyuncu bazlı bonus kazanımları ve promosyon kullanımları (izole) |
| **Tenant DB** (Per-tenant) | `bonus.bonus_request_settings`, `bonus.bonus_requests`, `bonus.bonus_request_actions` | BO + Oyuncu | Manuel bonus talepleri, ayarlar ve aksiyon logu |
| **Tenant Log DB** | `bonus_log.bonus_evaluation_logs` | Worker | Değerlendirme audit trail (daily partition, 90 gün retention) |

---

## 6 JSONB Bileşen

Her bonus kuralı (`bonus.bonus_rules`) 6 JSONB bileşenden oluşur:

| # | Bileşen | Soru | Zorunlu | Örnek |
|---|---------|------|---------|-------|
| 1 | `trigger_config` | Ne zaman tetiklenir? | **Evet** | `{"event":"first_deposit","conditions":{"min_amount":100}}` |
| 2 | `data_config` | Hangi veri gerekli? | Hayır | `{"source":"deposit_event","fields":["amount","currency"]}` |
| 3 | `eligibility_criteria` | Kim hak eder? | Hayır | `{"conditions":[{"field":"player.country","op":"in","value":["TR","DE"]}]}` |
| 4 | `reward_config` | Ne kadar verilir? | **Evet** | `{"type":"percentage","source_field":"event.amount","value":100,"max_amount":1000}` |
| 5 | `usage_criteria` | Nasıl kullanılmalı? | Hayır | `{"wagering_multiplier":30,"expires_in_days":30,"game_contributions":{"SLOT":100}}` |
| 6 | `target_config` | Bonus alt tipi? | Hayır | `{"bonus_subtype":"freebet","completion_target":"real"}` |

### Neden JSONB?

Sektörde 15+ bonus tipi var (deposit match, cashback, freebet, freespin, loyalty, referral...). Hepsi aynı 6 bileşenin farklı kombinasyonları. JSONB ile:

- Yeni bonus tipi = yeni JSON yapısı, **DB şema değişikliği yok**
- Backend handler'lar generic: expression evaluator ile koşulları değerlendirir
- Operatörler: `eq`, `neq`, `gt`, `gte`, `lt`, `lte`, `in`, `not_in`, `between`, `contains`

### Eligibility Field Kataloğu

`eligibility_criteria` koşullarında kullanılabilecek alanlar. Veri kaynağı: `auth.player_get_segmentation()` fonksiyonu.

| Field Key | Kaynak | Tip | Desteklenen Operatörler |
|-----------|--------|-----|------------------------|
| `player.category` | category.code | string | `eq`, `neq`, `in`, `not_in` |
| `player.category_level` | categoryLevel | numeric | `eq`, `gt`, `gte`, `lt`, `lte`, `between` |
| `player.groups` | groupCodes | string[] | `contains`, `in`, `not_in` |
| `player.group_max_level` | groupMaxLevel | numeric | `eq`, `gt`, `gte`, `lt`, `lte`, `between` |
| `player.country` | country | string | `eq`, `neq`, `in`, `not_in` |
| `player.account_age_days` | accountAgeDays | numeric | `eq`, `gt`, `gte`, `lt`, `lte`, `between` |
| `player.kyc_status` | kycStatus | string | `eq`, `neq`, `in` |
| `player.deposit_count` | Backend stats | numeric | `eq`, `gt`, `gte`, `lt`, `lte`, `between` |
| `player.total_deposit` | Backend stats | numeric | `eq`, `gt`, `gte`, `lt`, `lte`, `between` |
| `event.amount` | Event data | numeric | Tüm numeric operatörler |
| `event.currency` | Event data | string | `eq`, `in` |
| `event.payment_method` | Event data | string | `eq`, `in`, `not_in` |

**Değerlendirme mantığı:** Varsayılan `AND` (tüm koşullar sağlanmalı). `"logic": "or"` ile herhangi birinin sağlanması yeterli.

```json
{
  "logic": "or",
  "conditions": [
    {"field": "player.category", "op": "in", "value": ["gold", "platinum", "vip"]},
    {"field": "player.groups", "op": "contains", "value": "high_rollers"}
  ]
}
```

---

## Değerlendirme Tipleri

`bonus_rules.evaluation_type` kolonu:

| Tip | Tetiklenme | Örnek |
|-----|-----------|-------|
| `immediate` | Event-driven: deposit gelince hemen | Hoş geldin bonusu (%100 ilk yatırım) |
| `periodic` | Cron schedule ile | Haftalık cashback (Pazartesi 00:00) |
| `manual` | Admin tetikler | VIP özel bonus |
| `claim` | Oyuncu talep eder | Talep et butonu ile aktifleştirme |

---

## Wallet Mimarisi

**Kritik karar:** Tüm bonuslar HER ZAMAN **BONUS wallet**'a gider.

| Cüzdan | Tip | Açıklama |
|--------|-----|----------|
| **REAL Wallet** | `real` | Gerçek para (deposit/withdraw) |
| **BONUS Wallet** | `bonus` | Bonus para (tüm bonuslar buraya gider) |
| **LOCKED Wallet** | `locked` | Kilitli bakiye (çevrim şartı tamamlanana kadar) |

### Harcama Önceliği

Oyuncu bahis yaptığında:
1. Uygun BONUS award'ları filtrele (`usage_criteria` ile)
2. Sırala: **earliest expiry first**
3. Sırayla bonus bakiyesinden düş
4. Tüm uygun bonuslar tükendiyse → REAL wallet'tan düş

### Çevrim (Wagering) Akışı

```
Bonus: 100 TL, 30x çevrim
wagering_target = 100 × 30 = 3.000 TL

Oyuncu oynar:
  50 TL slot  (%100 katkı) → progress += 50
  100 TL live (%10 katkı)  → progress += 10
  ...
  progress >= 3.000 → wagering completed!
```

### Transfer Politikaları (Çevrim tamamlandığında)

| Politika | Davranış |
|----------|----------|
| `transfer_earned` | Kazanılan tutar REAL wallet'a, kalan bonus iptal |
| `forfeit_remaining` | Bonus bakiye iptal, sadece kazanç REAL'a |
| `forfeit_all` | Tüm bonus + kazanç iptal |

---

## DB Yapısı

### Bonus DB (Shared)

| Tablo | Şema | Açıklama |
|-------|------|----------|
| `bonus_types` | bonus | Bonus tipi tanımları (deposit_match, free_spin, cashback) |
| `bonus_rules` | bonus | 6 JSONB bileşenli kural motoru |
| `campaigns` | campaign | Kampanya yönetimi (bonus kuralına bağlı, bütçe takibi) |
| `promo_codes` | promotion | Promosyon kodları (kullanım limiti, geçerlilik) |

### Tenant DB (Per-tenant)

| Tablo | Şema | Açıklama |
|-------|------|----------|
| `bonus_awards` | bonus | Oyuncuya verilen bonuslar (durum takibi, çevrim, bakiye) |
| `promo_redemptions` | bonus | Promosyon kod kullanım kayıtları |
| `bonus_request_settings` | bonus | Manuel bonus talep ayarları (tip bazlı cooldown, uygunluk, lokalize içerik) |
| `bonus_requests` | bonus | Manuel bonus talepleri (oyuncu + operatör kaynaklı) |
| `bonus_request_actions` | bonus | Talep aksiyon logu (immutable audit trail) |

### Tenant Log DB

| Tablo | Şema | Açıklama |
|-------|------|----------|
| `bonus_evaluation_logs` | bonus_log | Worker değerlendirme audit trail (daily partition, 90 gün) |

---

## Transaction Type ID'leri

Bonus işlemleri `transaction.transactions` tablosunda şu type ID'leri kullanır:

| ID | İşlem | Açıklama |
|----|-------|----------|
| 40 | Bonus Credit | Oyuncuya bonus verilir (BONUS wallet'a) |
| 41 | Bonus Debit | Bonus iptal edilir (BONUS wallet'tan) |
| 42 | Bonus Completion | Çevrim tamamlandı → REAL wallet'a transfer |
| 50-57 | Rollback serileri | İlgili işlemlerin geri alınması |

---

## Temel Akışlar

### 1. Bonus Kuralı Oluşturma (BO Admin → Bonus DB)

```
BO Admin → Backend → bonus.bonus_rule_create(
    tenant_id, rule_code, rule_name, bonus_type_id,
    trigger_config,    -- JSONB (TEXT param → JSONB cast)
    reward_config,     -- JSONB
    eligibility_criteria, usage_criteria, ...
)
```

- `trigger_config` ve `reward_config` zorunlu
- `(tenant_id, rule_code)` unique — aynı tenant'ta aynı kod olamaz
- `tenant_id = NULL` → platform seviyesi kural (tüm tenant'lara uygulanabilir)

### 2. Bonus Verme (Backend/Worker → Tenant DB)

```
Event (deposit, registration, cron) →
  Worker:
    1. Kural değerlendir (eligibility check)
    2. Reward hesapla (percentage/fixed/tiered)
    3. bonus.bonus_award_create(player_id, bonus_rule_id, ...)
       → BONUS wallet credit (type_id=40)
       → bonus_awards INSERT (status=active)
       → rule_snapshot JSONB (kural anındaki hali)
```

### 3. Bonus İptal (BO Admin → Tenant DB)

```
bonus.bonus_award_cancel(award_id, cancelled_by, reason)
  → BONUS wallet debit (type_id=41)
  → status: active → cancelled
```

### 4. Çevrim Tamamlama (Worker → Tenant DB)

```
bonus.bonus_award_complete(award_id)
  → BONUS → REAL wallet transfer (type_id=42)
  → status: active → completed
```

### 5. Toplu Expire (Cron Worker → Tenant DB)

```
bonus.bonus_award_expire(batch_size)
  → SKIP LOCKED (concurrent worker güvenliği)
  → Süresi geçmiş aktif bonusları expire eder
  → BONUS wallet debit
```

---

## Kampanya ve Promosyon

### Kampanya Akışı

```
BO Admin → campaign_create (bonus_rule_ids, bütçe, süre, hedef segment)
         → status: draft → active → ended
         → award_strategy: automatic | claim | manual
```

- `automatic`: Event tetiklediğinde otomatik verilir
- `claim`: Oyuncu "Talep Et" butonuyla aktifleştirir
- `manual`: Admin tek tek verir

### Promosyon Kodu Akışı

```
BO Admin → promo_code_create (code, bonus_rule_id, max_redemptions, valid_from/until)

Oyuncu → promo_redeem (code)
  → Kod geçerlilik kontrolü
  → Kullanım limiti kontrolü (max_redemptions, max_per_player)
  → Süre kontrolü
  → Bonus award oluştur
```

---

## Stacking ve Çakışma Kontrolü

| Kolon | Açıklama |
|-------|----------|
| `disables_other_bonuses` | Bu bonus aktifken başka bonus alınamaz |
| `stacking_group` | Aynı grupta max 1 aktif bonus (ör: "welcome_group") |

Backend award öncesinde kontrol eder:
1. Oyuncunun aktif bonus'u var mı ve `disables_other_bonuses = true` mi?
2. Aynı `stacking_group`'ta aktif bonus var mı?

---

## Manuel Bonus Talep Sistemi

Otomatik bonusların (rule engine) yanı sıra, iki kaynaklı manuel bonus akışı vardır:

| Akış | Başlatan | Onaylayan | Açıklama |
|------|----------|-----------|----------|
| **Oyuncu Talebi** | Oyuncu (FE) | Bonus operasyon ekibi (BO) | Oyuncu bonus tipi seçer + açıklama yazar |
| **Operatör Manuel Bonus** | Operatör (BO) | Üst düzey yetkili (BO) | Operatör oyuncuya bonus vermek ister |

Her iki akış da onay sonrası mevcut `bonus_award_create()` fonksiyonuna bağlanır.

### Durum Akışı

```
pending → assigned → in_progress → approved → completed
                   → on_hold → in_progress (devam)
                   → rejected
         → cancelled
         → expired (batch)

Rollback: completed → in_progress | rejected → in_progress
```

| Durum | Açıklama |
|-------|----------|
| `pending` | Yeni talep, kuyrukta |
| `assigned` | Operatöre atandı |
| `in_progress` | Aktif inceleme — diğer operatörler "[ad] inceliyor" görür |
| `on_hold` | Beklemede (ek bilgi gerekli) |
| `approved` | Onaylandı, bonus veriliyor |
| `rejected` | Reddedildi (rollback ile geri alınabilir) |
| `completed` | Bonus award oluşturuldu (rollback ile geri alınabilir) |
| `cancelled` | İptal (final) |
| `expired` | Süre aşımı (final) |
| `failed` | Award oluşturma teknik hata |

### Oyuncu Talep Akışı

```mermaid
flowchart TD
    A["Oyuncu: Bonus Talep Et"] --> B["player_requestable_bonus_types()<br/>Uygun tipleri listele"]
    B --> C{"Uygunluk kontrolleri"}
    C -->|"Tip kapalı / grup uyumsuz<br/>cooldown aktif / pending var"| D["HATA"]
    C -->|OK| E["Talep oluşturuldu<br/>status=pending"]
    E --> F["BO operatör inceler"]
    F -->|Onayla| G["bonus_award_create()<br/>status=completed"]
    F -->|Reddet| H["review_note ile<br/>status=rejected"]
    G --> I["Oyuncuya bildirim<br/>(inbox + SignalR)"]
    H --> I
```

### Talep Uygunluk Kontrolleri

Oyuncu bonus talebi verirken sırayla kontrol edilir:

1. **Tip açık mı?** — `bonus_request_settings.is_requestable = true`
2. **Grup/kategori uygunluğu** — İki yöntem (OR mantığı):
   - Kod bazlı: `eligible_groups` / `eligible_categories` ile belirli kodlar
   - Seviye bazlı: `min_group_level` / `min_category_level` ile "bu seviye ve üzeri"
3. **Pending limit** — Aynı tipte bekleyen talep sayısı (`max_pending_per_player`)
4. **Cooldown (onay sonrası)** — Son completed talep + `cooldown_after_approved_days`
5. **Cooldown (red sonrası)** — Son rejected talep + `cooldown_after_rejected_days`

### Ayar Yapısı (bonus_request_settings)

Tenant admin her bonus tipi için şunları yapılandırır:

| Alan | Açıklama |
|------|----------|
| `display_name` | Lokalize görünen ad — JSONB: `{"tr":"Kayıp Bonusu","en":"Loss Bonus"}` |
| `rules_content` | Lokalize kural HTML — JSONB: `{"tr":"<p>Kurallar...</p>"}` (BO'da HTML editör) |
| `eligible_groups/categories` | Uygun grup/kategori kodları (JSONB array) |
| `min_group/category_level` | Minimum seviye filtresi |
| `cooldown_after_approved/rejected_days` | Cooldown süreleri (gün) |
| `max_pending_per_player` | Aynı anda kaç pending talep (default: 1) |
| `default_usage_criteria` | Varsayılan çevrim şartı — JSONB: `{"wagering_multiplier":30,"expires_in_days":30,...}` |

### Çevrim (Wagering) Şartı

Manuel bonuslarda çevrim şartı üç katmanlı öncelik zinciri ile belirlenir:

1. **Operatör override** — onay sırasında `p_usage_criteria` ile manuel giriş
2. **Setting default** — `bonus_request_settings.default_usage_criteria`
3. **Çevrim yok** — her ikisi NULL ise bonus direkt kullanılabilir

```
v_usage_criteria = COALESCE(operatör_girişi, setting_default)
```

FE gösterimi:
- **Talep öncesi:** `player_requestable_bonus_types()` response'unda `hasWagering`, `wageringMultiplier` bilgisi
- **Talep sonrası:** `player_bonus_request_list()` response'unda progress bar verisi (`wageringTarget`, `wageringProgress`, `progressPercent`)
- Çevrim şartı yoksa progress bar gösterilmez

### Rollback Mekanizması

Yanlışlıkla onaylanan veya reddedilen talepler geri alınabilir:

| Kaynak Durum | Rollback Davranışı |
|-------------|-------------------|
| `completed` | `bonus_award_cancel()` çağrılır → wallet'tan geri çekilir → talep `in_progress`'e döner |
| `rejected` | Sadece durum değişir → talep `in_progress`'e döner, yeniden değerlendirilir |

Rollback action logu `action_data` JSONB'de önceki durumu ve iptal edilen award bilgilerini saklar.

### Bildirimler

| Olay | Hedef | Kanal |
|------|-------|-------|
| Talep onaylandı/reddedildi | Oyuncu | `messaging.player_messages` + SignalR popup |
| Talep süresi doldu | Oyuncu | `messaging.player_messages` |
| Yeni oyuncu talebi | Bonus operasyon ekibi | BO dashboard notification |

### Permission'lar (6 adet)

| Permission | Açıklama |
|-----------|----------|
| `tenant.bonus-request.list` | Talep listesi |
| `tenant.bonus-request.view` | Talep detayı |
| `tenant.bonus-request.create` | Manuel talep oluşturma |
| `tenant.bonus-request.review` | Onay/red yetkisi (üst düzey roller) |
| `tenant.bonus-request.assign` | Operatöre atama |
| `tenant.bonus-request-settings.manage` | Ayar yapılandırma |

> **Detaylı tasarım:** [MANUAL_BONUS_REQUEST_DESIGN.md](../../.planning/MANUAL_BONUS_REQUEST_DESIGN.md) — durum makinesi, tablo tasarımları, fonksiyon imzaları, mermaid diyagramlar

---

## Fonksiyon Listesi

### Bonus DB (18 fonksiyon)

| Grup | Fonksiyon | Açıklama |
|------|----------|----------|
| Bonus Types | `bonus_type_create/update/get/list` | Bonus tipi CRUD |
| Bonus Rules | `bonus_rule_create/update/get/list/delete` | Kural CRUD (6 JSONB) |
| Campaigns | `campaign_create/update/get/list/delete` | Kampanya CRUD |
| Promotions | `promo_code_create/update/get/list` | Promosyon kodu CRUD |

### Tenant DB — Award & Promo (8 fonksiyon)

| Fonksiyon | Açıklama |
|----------|----------|
| `bonus_award_create` | Oyuncuya bonus ver (BONUS wallet credit, type_id=40) |
| `bonus_award_get` | Award detayı |
| `bonus_award_list` | Oyuncu bonus listesi (durum filtreleme) |
| `bonus_award_cancel` | Bonus iptal (BONUS wallet debit, type_id=41) |
| `bonus_award_complete` | Çevrim tamamlandı → REAL wallet transfer (type_id=42) |
| `bonus_award_expire` | Batch expire (SKIP LOCKED, concurrent güvenliği) |
| `promo_redeem` | Promosyon kodu kullan |
| `promo_redemption_list` | Kullanım geçmişi |

### Tenant DB — Manuel Bonus Talep (19 fonksiyon)

| Grup | Fonksiyon | Açıklama |
|------|----------|----------|
| BO — Talep | `bonus_request_create` | Talep oluştur (oyuncu/operatör kaynaklı) |
| BO — Talep | `bonus_request_get` | Tekil talep + action geçmişi |
| BO — Talep | `bonus_request_list` | Filtreli listeleme (status, source, assigned) |
| BO — Atama | `bonus_request_assign` | Operatöre ata |
| BO — Atama | `bonus_request_start_review` | İşleme al (in_progress — lock görünür) |
| BO — Atama | `bonus_request_hold` | Beklemede (on_hold — neden zorunlu) |
| BO — Karar | `bonus_request_approve` | Onayla → bonus_award_create() çağrılır |
| BO — Karar | `bonus_request_reject` | Reddet (review_note zorunlu) |
| BO — Karar | `bonus_request_rollback` | Geri al (completed/rejected → in_progress) |
| BO — Diğer | `bonus_request_cancel` | İptal (oyuncu veya operatör) |
| BO — Diğer | `bonus_request_expire` | Batch expire (günlük, SKIP LOCKED) |
| BO — Diğer | `bonus_request_cleanup` | Retention cleanup — cancelled/expired 90 gün sonra sil (haftalık) |
| Oyuncu | `player_bonus_request_create` | Oyuncu talebi (cooldown + uygunluk kontrolü) |
| Oyuncu | `player_bonus_request_list` | Kendi taleplerini listele (hassas veri yok) |
| Oyuncu | `player_bonus_request_cancel` | Kendi talebini iptal (sadece pending) |
| Ayar | `bonus_request_setting_upsert` | Talep ayarı oluştur/güncelle |
| Ayar | `bonus_request_setting_list` | Tüm ayarları listele |
| Ayar | `bonus_request_setting_get` | Tekil ayar detayı |
| Ayar | `player_requestable_bonus_types` | Oyuncuya uygun bonus tipleri (lokalize, cooldown bilgili) |

---

## Backend İçin Notlar

- **JSONB parametreler TEXT olarak geçirilir** — fonksiyon içinde `::JSONB` cast yapılır
- **Cross-DB**: Bonus kuralları Bonus DB'de, award'lar Tenant DB'de → backend ayrı connection kullanır
- **Auth**: Bonus DB fonksiyonları auth-agnostic. Backend Core DB'den yetki kontrolü yapar
- **Worker**: Periodic evaluation ve expire işlemleri için .NET Worker servisi (Quartz scheduler)
- **rule_snapshot**: Award oluşturulurken kuralın o anki hali JSONB olarak saklanır (kural sonradan değişse bile award etkilenmez)

---

_İlgili dokümanlar: [BONUS_ENGINE_DESIGN.md](../../.planning/BONUS_ENGINE_DESIGN.md) · [BONUS_ENGINE_DB_ISSUE.md](../../.planning/BONUS_ENGINE_DB_ISSUE.md) · [MANUAL_BONUS_REQUEST_DESIGN.md](../../.planning/MANUAL_BONUS_REQUEST_DESIGN.md) · [FUNCTIONS_GATEWAY.md](../reference/FUNCTIONS_GATEWAY.md)_
