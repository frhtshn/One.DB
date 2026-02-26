# Gateway, Plugin & Analytics Functions

Gateway, plugin ve analytics veritabanlarındaki tüm stored procedure, function ve trigger'ları içerir.

**Veritabanları:** `game`, `game_log`, `finance`, `finance_log`, `bonus`, `analytics`
**Toplam:** 49 fonksiyon

---

## Game Database (8 fonksiyon)

Oyun sağlayıcı ve oyun kataloğu yönetimi. Her provider kendi entegrasyon koduna sahiptir.

### Catalog Schema (8)

| Fonksiyon | Açıklama |
|-----------|----------|
| `game_provider_sync` | Provider bilgilerini senkronize eder (upsert). Provider code ile eşleştirir |
| `game_upsert` | Tekli oyun oluştur/güncelle. Provider code + game code unique |
| `game_bulk_upsert` | Toplu oyun senkronizasyonu. Provider API'den gelen listeyi upsert eder |
| `game_update` | Mevcut oyun bilgilerini güncelle (durum, RTP, kategori vb.) |
| `game_get` | ID ile oyun detayı getir |
| `game_list` | Filtrelenebilir oyun listesi (provider, kategori, durum) |
| `game_lookup` | Provider code + game code ile oyun ara |
| `game_currency_limit_sync` | Oyun bazlı para birimi limitlerini senkronize et |

---

## Game Log Database (4 fonksiyon)

Gateway seviyesi API log'ları. Paylaşımlı DB, daily partition, 7 gün retention.

### Maintenance Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `create_partitions` | İleri tarihli partition'lar oluşturur (varsayılan: 7 gün). `provider_api_requests` ve `provider_api_callbacks` tabloları |
| `drop_expired_partitions` | Süresi dolan partition'ları siler (varsayılan: 7 gün retention) |
| `partition_info` | Mevcut partition'ların boyut ve satır sayısı bilgisi |
| `run_maintenance` | Cron job ana fonksiyonu: partition oluştur + süresi dolanları sil |

---

## Finance Database (8 fonksiyon)

Ödeme sağlayıcı ve ödeme yöntemi kataloğu yönetimi.

### Catalog Schema (8)

| Fonksiyon | Açıklama |
|-----------|----------|
| `payment_provider_sync` | Ödeme sağlayıcı bilgilerini senkronize eder (upsert) |
| `payment_method_create` | Yeni ödeme yöntemi oluştur |
| `payment_method_update` | Ödeme yöntemi güncelle |
| `payment_method_delete` | Ödeme yöntemi sil (soft delete) |
| `payment_method_get` | ID ile ödeme yöntemi detayı getir |
| `payment_method_list` | Filtrelenebilir ödeme yöntemi listesi |
| `payment_method_lookup` | Kod ile ödeme yöntemi ara |
| `payment_method_currency_limit_sync` | Ödeme yöntemi bazlı para birimi limitlerini senkronize et |

---

## Finance Log Database (4 fonksiyon)

Gateway seviyesi ödeme API log'ları. Paylaşımlı DB, daily partition, 14 gün retention.

### Maintenance Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `create_partitions` | İleri tarihli partition'lar oluşturur (varsayılan: 14 gün). `provider_api_requests` ve `provider_api_callbacks` tabloları |
| `drop_expired_partitions` | Süresi dolan partition'ları siler (varsayılan: 14 gün retention) |
| `partition_info` | Mevcut partition'ların boyut ve satır sayısı bilgisi |
| `run_maintenance` | Cron job ana fonksiyonu: partition oluştur + süresi dolanları sil |

---

## Bonus Database (18 fonksiyon)

Bonus tanım, kural, kampanya ve promosyon yönetimi. JSON-driven rule engine.

### Bonus Schema (9)

| Fonksiyon | Açıklama |
|-----------|----------|
| `bonus_type_create` | Yeni bonus tipi oluştur (deposit, registration, loyalty vb.) |
| `bonus_type_update` | Bonus tipi güncelle |
| `bonus_type_get` | ID ile bonus tipi detayı getir |
| `bonus_type_list` | Bonus tipi listesi |
| `bonus_rule_create` | Bonus kuralı oluştur (JSONB: eligibility, reward, usage, lifecycle, display, metadata) |
| `bonus_rule_update` | Bonus kuralı güncelle |
| `bonus_rule_get` | ID ile bonus kuralı detayı getir |
| `bonus_rule_list` | Bonus kuralı listesi (filtreleme destekli) |
| `bonus_rule_delete` | Bonus kuralı sil (soft delete) |

### Campaign Schema (5)

| Fonksiyon | Açıklama |
|-----------|----------|
| `campaign_create` | Yeni kampanya oluştur (bonus kuralına bağlı) |
| `campaign_update` | Kampanya güncelle |
| `campaign_get` | ID ile kampanya detayı getir |
| `campaign_list` | Kampanya listesi |
| `campaign_delete` | Kampanya sil (soft delete) |

### Promotion Schema (4)

| Fonksiyon | Açıklama |
|-----------|----------|
| `promo_code_create` | Yeni promosyon kodu oluştur |
| `promo_code_update` | Promosyon kodu güncelle |
| `promo_code_get` | ID ile promosyon kodu detayı getir |
| `promo_code_list` | Promosyon kodu listesi |

---

## Analytics Database (7 fonksiyon)

Risk analiz baseline ve skor yönetimi. RiskManager skor yazar, Report Cluster baseline yazar, Backoffice Cluster okur.

### Risk Schema — RiskManager (3)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_baseline_list` | Tüm oyuncu baseline verilerini listele (cache yenileme için full scan) |
| `tenant_baseline_list` | Tüm tenant baseline verilerini listele (cache yenileme için full scan) |
| `player_score_upsert` | Oyuncu risk skorunu yaz/güncelle. high_risk_count ve evaluation_count atomik artırılır |

### Risk Schema — Report Cluster (2)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_baseline_upsert` | Oyuncu baseline verilerini yaz/güncelle (istatistiksel profil) |
| `tenant_baseline_upsert` | Tenant baseline verilerini yaz/güncelle (tenant geneli ortalamalar) |

### Risk Schema — BO Cluster (2)

| Fonksiyon | Açıklama |
|-----------|----------|
| `player_score_get` | Tekil oyuncu risk skoru getir (Redis miss fallback) |
| `player_score_list` | Oyuncu risk skoru listesi (dashboard, risk_level filtreli, anomaly_score sıralı) |
