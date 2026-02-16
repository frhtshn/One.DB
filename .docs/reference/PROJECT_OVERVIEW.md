# NUCLEO DATABASE PROJESİ - GENEL BAKIŞ

Bu doküman, **NucleoDB** projesinin büyük resmini ve sistemin nasıl çalıştığını açıklar.

---

## İçindekiler

1. [Proje Hakkında](#1-proje-hakkında)
2. [Sistem Mimarisi](#2-sistem-mimarisi)
3. [Veritabanı Katmanları](#3-veritabanı-katmanları)
4. [Multi-Tenant Yapı](#4-multi-tenant-yapı)
5. [Veri Akışı](#5-veri-akışı)
6. [Proje Yapısı](#6-proje-yapısı)
7. [Deploy Süreci](#7-deploy-süreci)
8. [Geliştirici Rehberi](#8-geliştirici-rehberi)
9. [Güvenlik ve Yetkilendirme](#9-güvenlik-ve-yetkilendirme)
10. [Log ve Audit Stratejisi](#10-log-ve-audit-stratejisi)

---

## 1. Proje Hakkında

### 1.1 Ne İçin Kullanılıyor?

**Nucleo**, online gaming/betting platformları için tasarlanmış **multi-tenant (whitelabel)** bir veritabanı altyapısıdır. Platform:

- **Oyun Entegrasyonu** - Game provider'larla entegrasyon (Pragmatic, Evolution vb.)
- **Ödeme İşlemleri** - Finance provider'larla ödeme yönetimi (Stripe, Papara vb.)
- **Oyuncu Yönetimi** - Kayıt, cüzdan, işlemler, KYC süreçleri
- **Bonus Sistemi** - Promosyon ve kampanyalar
- **Mesajlaşma** - Kampanya, şablon ve oyuncu inbox (email/SMS/local)
- **Kullanıcı Mesajlaşma** - Backoffice kullanıcılar arası mesaj sistemi (draft/publish/recall/direct)
- **Affiliate Sistemi** - Ortaklık ve komisyon yönetimi
- **Multi-Tenant** - Birden fazla markanın tek platformda çalışması
- **Theme Engine** - Tenant'ların kendi frontend ve navigasyonunu yönetebilmesi
- **Fiat & Kripto Kur Takibi** - CurrencyLayer ve Coinlayer entegrasyonu
- **GeoIP Takibi** - ip-api.com entegrasyonu ile IP lokasyon çözümleme

### 1.2 Temel Prensipler

| Prensip                          | Açıklama                                                 |
| -------------------------------- | -------------------------------------------------------- |
| **Veri İzolasyonu**              | Her tenant (marka) tam veri izolasyonuna sahiptir        |
| **Sorumluluk Ayrımı**            | Her veritabanı tek bir sorumluluk taşır                  |
| **Log ≠ Audit ≠ Business**       | Farklı veri tipleri farklı DB'lerde tutulur              |
| **Core Shared, Tenant Isolated** | Merkezi veriler paylaşılır, tenant verileri izole edilir |
| **Cross-DB Yasağı**              | Fiziksel DB'ler arası doğrudan sorgu yapılamaz           |

---

## 2. Sistem Mimarisi

### 2.1 Üst Düzey Görünüm

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BACKOFFICE APPLICATION                            │
│                    (Yönetim Paneli - React/Angular/Vue)                     │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        BACKEND (.NET + Orleans + gRPC)                      │
│  REST API  │  Orleans Grains  │  gRPC Services (CryptoManager, Currency)   │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
           ┌───────────────────────────┼───────────────────────────┐
           ▼                           ▼                           ▼
┌─────────────────────┐   ┌─────────────────────┐   ┌─────────────────────┐
│   CORE DATABASES    │   │  GATEWAY DATABASES  │   │  TENANT DATABASES   │
│  core               │   │  game, game_log     │   │ tenant_XXX          │
│  core_log           │   │  finance,finance_log│   │ tenant_log_XXX      │
│  core_audit         │   │  bonus              │   │ tenant_audit_XXX    │
│  core_report        │   │                     │   │ tenant_report_XXX   │
│                     │   │                     │   │ tenant_affiliate_XXX│
└─────────────────────┘   └─────────────────────┘   └─────────────────────┘
```

### 2.2 Veritabanı Etkileşim Haritası

```
                              ┌──────────────────┐
                              │      CORE        │
                              │  (Merkezi Yapı)  │
                              │ • Companies      │
                              │ • Tenants        │
                              │ • Users/Roles    │
                              │ • Catalog Data   │
                              │ • Theme Market   │
                              │ • Messaging      │
                              └────────┬─────────┘
                                       │
           ┌───────────────────────────┼───────────────────────────┐
           │                           │                           │
           ▼                           ▼                           ▼
┌─────────────────────┐   ┌─────────────────────┐   ┌─────────────────────┐
│   CORE_LOG          │   │   CORE_AUDIT        │   │   CORE_REPORT       │
│  (Teknik Loglar)    │   │  (Denetim Kayıtları)│   │  (Merkezi Raporlar) │
│  Retention: 30-90gün│   │  Retention: 90 gün  │   │  Retention: Sınırsız│
└─────────────────────┘   └─────────────────────┘   └─────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                        GATEWAY & PLUGIN VERİTABANLARI                       │
│  game  │  game_log  │  finance  │  finance_log  │  bonus                    │
└────────────────────────────────────┬────────────────────────────────────────┘
                                     │
                 ┌───────────────────┼───────────────────┐
                 ▼                   ▼                   ▼
          ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
          │  tenant_001  │    │  tenant_002  │    │  tenant_XXX  │
          │  (Oyuncular) │    │  (Oyuncular) │    │  (Oyuncular) │
          ├──────────────┤    ├──────────────┤    ├──────────────┤
          │tenant_log_001│    │tenant_log_002│    │tenant_log_XXX│
          │tenant_aud_001│    │tenant_aud_002│    │tenant_aud_XXX│
          │tenant_rep_001│    │tenant_rep_002│    │tenant_rep_XXX│
          │tenant_aff_001│    │tenant_aff_002│    │tenant_aff_XXX│
          └──────────────┘    └──────────────┘    └──────────────┘
```

---

## 3. Veritabanı Katmanları

### 3.1 Veritabanı Matrisi

| #  | Veritabanı         | Amaç                                      | Paylaşım | Partition      | Retention     |
|----|--------------------|--------------------------------------------|----------|----------------|---------------|
| 1  | `core`             | Platform merkezi yapı ve konfigürasyon     | Shared   | Monthly (2)    | 90-180 gün    |
| 2  | `core_log`         | Merkezi teknik log kayıtları               | Shared   | Daily (4)      | 30-90 gün     |
| 3  | `core_audit`       | Backoffice güvenlik denetim kayıtları      | Shared   | Daily (1)      | 90 gün        |
| 4  | `core_report`      | Merkezi raporlama ve BI verileri           | Shared   | Monthly (5)    | Sınırsız      |
| 5  | `game`             | Oyun gateway entegrasyon durumu            | Shared   | -              | -             |
| 6  | `game_log`         | Oyun gateway teknik logları                | Shared   | -              | -             |
| 7  | `finance`          | Finans gateway entegrasyon durumu          | Shared   | -              | -             |
| 8  | `finance_log`      | Finans gateway teknik logları              | Shared   | -              | -             |
| 9  | `bonus`            | Bonus ve promosyon yapılandırması          | Shared   | -              | Sınırsız      |
| 10 | `tenant`           | Kiracıya özel iş verileri                  | Isolated | Monthly (2)    | Sınırsız*     |
| 11 | `tenant_log`       | Kiracıya özel operasyonel loglar           | Isolated | Daily (5)      | 30-90 gün     |
| 12 | `tenant_audit`     | Kiracıya özel audit kayıtları              | Isolated | Hybrid (2)     | 1-5 yıl       |
| 13 | `tenant_report`    | Kiracıya özel raporlar ve istatistikler    | Isolated | Monthly (5)    | Sınırsız      |
| 14 | `tenant_affiliate` | Affiliate tracking ve komisyon yönetimi    | Isolated | Monthly (7)    | Sınırsız      |

> **Toplam:** 14 veritabanı, 37 partitioned tablo, 10 DB'de partition yönetimi
>
> \* `core` Monthly: `messaging.user_messages` (180 gün) + `security.user_sessions` (90 gün)
> \* `tenant` Monthly: `transaction.transactions` (sınırsız) + `messaging.player_messages` (180 gün)
> \* `tenant_audit` Hybrid: `player_audit.login_attempts` Daily (365 gün) + `player_audit.login_sessions` Monthly (5 yıl)
> \* `game_log` Daily: `game_log.provider_api_requests` + `game_log.provider_api_callbacks` (7 gün)
> \* `tenant_log/game_log` Daily: `game_log.game_rounds` (30 gün)

### 3.2 Core Veritabanı (Merkezi)

Core veritabanı platformun beynidir. Tüm merkezi konfigürasyon ve yönetim verilerini barındırır.

```
CORE DATABASE
├── catalog (Referans Data)
│   ├── reference        → Ülkeler, para birimleri, kripto paralar, diller, saat dilimleri
│   ├── localization     → Lokalizasyon key/value çevirileri
│   ├── provider         → Provider tipleri, sağlayıcılar, ayarlar, ödeme metodları
│   ├── game             → Oyun kataloğu
│   ├── compliance       → Jurisdiction, KYC kuralları, data retention, RG politikaları
│   ├── uikit            → Tema marketi, widget'lar, navigasyon şablonları
│   ├── geo              → IP geo cache (ip-api.com, TTL 30 gün)
│   └── transaction      → İşlem ve operasyon tipi tanımları
│
├── core (Tenant Yönetimi)
│   ├── organization     → Şirketler, departmanlar, tenantlar
│   ├── configuration    → Platform ayarları, tenant dil/kur/kripto/jurisdiction ayarları
│   └── integration      → Tenant provider/oyun/ödeme erişimleri
│
├── security (Yetki Yönetimi)
│   ├── identity         → Backoffice kullanıcıları, oturumlar, şifre geçmişi
│   ├── rbac             → Roller, yetkiler, kullanıcı-rol atamaları
│   └── secrets          → Provider ve tenant API anahtarları
│
├── presentation (UI Yapısı)
│   ├── backoffice       → Admin panel menü, sayfa, tab, context yapısı
│   └── frontend         → Tenant tema, layout, navigasyon (Theme Engine)
│
├── messaging (Kullanıcı Mesajlaşma)
│   ├── user_message_drafts  → Draft/publish/recall yönetimi
│   └── user_messages        → Kullanıcı inbox (monthly partitioned)
│
├── billing (Faturalandırma)
│   ├── tenant_*         → Tenant faturaları (Nucleo'nun alacakları)
│   └── provider_*       → Provider ödemeleri (Nucleo'nun borçları)
│
├── routing (Provider Yönlendirme)
│   ├── provider_endpoints   → API endpoint'leri
│   └── provider_callbacks   → Callback tanımları
│
├── outbox (Event Outbox Pattern)
│   └── outbox_messages  → Transactional outbox mesajları
│
└── maintenance (Partition Yönetimi)
    └── 4 fonksiyon: create_partitions, drop_expired, partition_info, run_maintenance
```

### 3.3 Tenant Veritabanı (Oyuncu Verileri)

Her tenant (marka) için `tenant` şablon DB'si klonlanarak `tenant_<tenantid>` formatında oluşturulur.

```
TENANT DATABASE (per tenant)
├── auth         → Oyuncu kimlik, kategori, şifre yönetimi
├── profile      → Oyuncu profil ve kimlik bilgileri
├── wallet       → Cüzdan bakiyeleri ve snapshot'ları (fiat + kripto)
├── transaction  → Finansal işlemler ve workflow'lar (monthly partitioned)
├── finance      → Döviz/kripto kurları, ödeme limitleri, player limitleri
├── game         → Oyun limitleri ve ayarları
├── bonus        → Bonus kazanımları ve promosyon kullanımları
├── content      → CMS, FAQ, promosyon, slide, popup yönetimi
├── kyc          → KYC süreçleri, belgeler, limitler, kısıtlamalar
├── messaging    → Kampanya, şablon, oyuncu mesaj kutusu (monthly partitioned)
└── maintenance  → Partition yönetim fonksiyonları
```

> Detaylı tablo listeleri için bkz: **[DATABASE_ARCHITECTURE.md](DATABASE_ARCHITECTURE.md)**

---

## 4. Multi-Tenant Yapı

### 4.1 Database-Per-Tenant Model

Nucleo, her tenant için **fiziksel olarak ayrı veritabanları** kullanır. Bu model tam veri izolasyonu sağlar.

```
Tenant kaydı yapıldığında (örn: tenant_id = 5):
├── tenant_5           → Ana iş verileri
├── tenant_log_5       → Operasyonel loglar
├── tenant_audit_5     → Audit kayıtları
├── tenant_report_5    → Raporlar
└── tenant_affiliate_5 → Affiliate tracking
```

### 4.2 Cross-DB İletişim

**Her klasör = Ayrı fiziksel PostgreSQL veritabanı.** Veritabanları arası doğrudan sorgu yapılamaz.

| Yöntem | Kullanım |
|--------|----------|
| **Backend Application** (Önerilen) | Ayrı DB connection'ları ile. Core'dan okur, tenant'a yazar |
| `dblink` / `postgres_fdw` | Sadece zorunlu durumlarda |

**Örnek akış:** Backend önce Core DB'den `tenant_cryptocurrency_mapping_list()` çağırır, sonra her tenant DB'ye bağlanıp `crypto_rates_bulk_upsert()` çalıştırır.

### 4.3 Tenant Seeding

Yeni tenant oluşturulduğunda:
1. Core DB'de `tenant_create()` ile tenant kaydı yapılır
2. Backend, `deploy_tenant.sql` şablonunu klonlayarak yeni DB oluşturur
3. İlişkili log/audit/report/affiliate DB'leri de oluşturulur
4. Core DB'de tenant-currency, tenant-language gibi mapping'ler atanır

---

## 5. Veri Akışı

### 5.1 Kur Senkronizasyonu (Currency & Crypto)

```
Coinlayer API ─── gRPC ──→ CryptoManager Service
                                    │
CurrencyLayer API ── HTTP ──→ Backend (CurrencyGrain / CryptoGrain)
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
              Core DB          Tenant_001 DB    Tenant_002 DB
         cryptocurrency_      crypto_rates_    crypto_rates_
           upsert()           bulk_upsert()    bulk_upsert()
         (katalog sync)       (kur yazma)      (kur yazma)
```

**Akış:**
1. **Katalog sync:** Coinlayer `/list` → `catalog.cryptocurrency_upsert()` (Core DB)
2. **Mapping okuma:** `tenant_cryptocurrency_mapping_list()` → hangi tenant'a hangi coin (Core DB)
3. **Kur yazma:** Her tenant DB'ye `crypto_rates_bulk_upsert()` çağrısı (Tenant DB)

### 5.2 Outbox Pattern (Event-Driven)

Backend, veritabanı transaction'ı içinde hem iş verisini hem de outbox mesajını yazar. Ayrı bir worker outbox'tan okuyarak event'leri RabbitMQ'ya iletir.

### 5.3 GeoIP Çözümleme

```
Kullanıcı/Oyuncu Login
    │
    ▼
Backend → ip-api.com (22 alan)
    │
    ├─→ Core DB: catalog.ip_geo_cache (TTL 30 gün, cache hit sonraki login'ler)
    ├─→ Core DB: security.user_sessions (backoffice oturum + geo)
    ├─→ Core Audit DB: backoffice.auth_audit_log (denetim + geo)
    └─→ Tenant Audit DB: player_audit.login_attempts/sessions (oyuncu + geo)
```

---

## 6. Proje Yapısı

### 6.1 Klasör Yapısı

```
nucleoDb/
│
├── .context/                    # Claude AI context ve proje talimatları
│   └── CLAUDE.md               # Proje geliştirme kuralları
├── .docs/                       # Proje dokümantasyonu
│   ├── PROJECT_OVERVIEW.md      # Bu dosya
│   ├── DATABASE_ARCHITECTURE.md # Detaylı DB mimarisi
│   ├── DATABASE_FUNCTIONS.md    # Fonksiyon referansı (index)
│   ├── FUNCTIONS_CORE.md        # Core katmanı fonksiyonları
│   ├── FUNCTIONS_TENANT.md      # Tenant katmanı fonksiyonları
│   ├── FUNCTIONS_GATEWAY.md     # Gateway katmanı fonksiyonları
│   ├── PARTITION_ARCHITECTURE.md# Partition yapısı
│   └── LOGSTRATEGY.md           # Log/audit stratejisi
│
├── core/                        # Core veritabanı
│   ├── tables/
│   │   ├── catalog/
│   │   │   ├── reference/      # Ülkeler, para birimleri, kripto paralar, diller
│   │   │   ├── provider/       # Provider tipleri, sağlayıcılar, ödeme metodları
│   │   │   ├── compliance/     # Jurisdiction, KYC, RG politikaları
│   │   │   ├── game/           # Oyun kataloğu
│   │   │   ├── uikit/          # Tema, widget, navigasyon şablonları
│   │   │   ├── geo/            # IP geo cache
│   │   │   └── transaction/    # İşlem/operasyon tipi tanımları
│   │   ├── core/
│   │   │   ├── organization/   # Şirketler, departmanlar, tenantlar
│   │   │   ├── configuration/  # Platform/tenant ayarları, kur/kripto/dil mapping
│   │   │   └── integration/    # Tenant-provider/game/payment erişimleri
│   │   ├── security/
│   │   │   ├── identity/       # Kullanıcılar, oturumlar, şifre geçmişi
│   │   │   ├── rbac/           # Roller, yetkiler, atamalar
│   │   │   └── secrets/        # API anahtarları
│   │   ├── presentation/
│   │   │   ├── backoffice/     # Admin panel menü/sayfa/tab
│   │   │   └── frontend/       # Theme engine
│   │   ├── messaging/          # Kullanıcı mesajlaşma (draft + inbox)
│   │   ├── routing/            # Provider endpoint/callback
│   │   ├── billing/            # Faturalandırma
│   │   └── outbox/             # Event outbox
│   ├── functions/              # Stored procedures (schema/domain bazlı)
│   ├── triggers/               # Trigger'lar
│   ├── constraints/            # FK constraint'ler (schema bazlı)
│   ├── indexes/                # Performance index'ler (schema bazlı)
│   └── data/                   # Seed data (permissions, roles, menus, localization)
│
├── core_log/                    # Core log veritabanı (daily partitioned)
├── core_audit/                  # Core audit veritabanı (daily partitioned)
├── core_report/                 # Core raporlama veritabanı (monthly partitioned)
│
├── game/                        # Game gateway veritabanı
├── game_log/                    # Game log veritabanı
├── finance/                     # Finance gateway veritabanı
├── finance_log/                 # Finance log veritabanı
├── bonus/                       # Bonus plugin veritabanı
│
├── tenant/                      # Tenant şablon veritabanı
│   ├── tables/
│   │   ├── player_auth/        # Oyuncu kimlik ve güvenlik
│   │   ├── player_profile/     # Oyuncu profil
│   │   ├── finance/            # Kur, kripto kur, ödeme ayarları
│   │   ├── transaction/        # Finansal işlemler (monthly partitioned)
│   │   ├── wallet/             # Cüzdan bakiyeleri (fiat + kripto)
│   │   ├── game/               # Oyun limitleri
│   │   ├── kyc/                # KYC süreçleri
│   │   ├── bonus/              # Bonus kazanımları
│   │   ├── content/            # CMS, FAQ, promosyon, slide, popup
│   │   └── messaging/          # Kampanya, şablon, oyuncu inbox
│   ├── functions/
│   │   ├── finance/            # Kur fonksiyonları
│   │   ├── messaging/          # 14 messaging fonksiyonu
│   │   └── maintenance/        # Partition yönetimi
│   ├── views/                   # Kur view'ları (cross rates)
│   ├── constraints/             # FK constraint'ler
│   └── indexes/                 # Performance index'ler
│
├── tenant_log/                  # Tenant log veritabanı (daily partitioned)
├── tenant_audit/                # Tenant audit veritabanı (hybrid partitioned)
├── tenant_report/               # Tenant raporlama veritabanı (monthly partitioned)
├── tenant_affiliate/            # Tenant affiliate veritabanı (monthly partitioned)
│
├── deploy_core.sql              # Core production deploy
├── deploy_core_staging.sql      # Core staging deploy (seed dahil)
├── deploy_core_production.sql   # Core production deploy (seed dahil)
├── deploy_core_log.sql          # Core log deploy
├── deploy_core_audit.sql        # Core audit deploy
├── deploy_core_report.sql       # Core report deploy
├── deploy_game.sql              # Game gateway deploy
├── deploy_game_log.sql          # Game log deploy
├── deploy_finance.sql           # Finance gateway deploy
├── deploy_finance_log.sql       # Finance log deploy
├── deploy_bonus.sql             # Bonus plugin deploy
├── deploy_tenant.sql            # Tenant template deploy
├── deploy_tenant_log.sql        # Tenant log deploy
├── deploy_tenant_audit.sql      # Tenant audit deploy
├── deploy_tenant_report.sql     # Tenant report deploy
└── deploy_tenant_affiliate.sql  # Tenant affiliate deploy
```

---

## 7. Deploy Süreci

### 7.1 Deploy Sırası

Veritabanları aşağıdaki sırada deploy edilmelidir:

**1. Shared (Core + Gateway) Katmanı:**

| Sıra | Script | Açıklama |
|------|--------|----------|
| 1 | `deploy_core.sql` | Core katalog, tenant yönetimi, security, theme engine |
| 2 | `deploy_core_log.sql` | Core teknik loglar |
| 3 | `deploy_core_audit.sql` | Core denetim kayıtları |
| 4 | `deploy_core_report.sql` | Core raporlama |
| 5 | `deploy_game.sql` | Game gateway |
| 6 | `deploy_game_log.sql` | Game log |
| 7 | `deploy_finance.sql` | Finance gateway |
| 8 | `deploy_finance_log.sql` | Finance log |
| 9 | `deploy_bonus.sql` | Bonus yapılandırması |

**2. Tenant Katmanı (her tenant için):**

| Sıra | Script | Açıklama |
|------|--------|----------|
| 10 | `deploy_tenant.sql` | Tenant ana iş verileri |
| 11 | `deploy_tenant_log.sql` | Tenant operasyonel loglar |
| 12 | `deploy_tenant_audit.sql` | Tenant audit kayıtları |
| 13 | `deploy_tenant_report.sql` | Tenant raporlama |
| 14 | `deploy_tenant_affiliate.sql` | Tenant affiliate tracking |

**3. Staging / Development (opsiyonel):**

| Script | Açıklama |
|--------|----------|
| `deploy_core_staging.sql` | Core deploy + localization + seed data + permissions + roles |
| `deploy_core_production.sql` | Core deploy + permissions + roles (seed data hariç) |

### 7.2 Her Deploy Script İçindeki Sıra

```
1. SET client_encoding + BEGIN
2. CREATE SCHEMA IF NOT EXISTS ...
3. CREATE EXTENSION IF NOT EXISTS ...
4. \i tables/...            (partition tanımı + default partition dahil)
5. \i views/...             (varsa)
6. \i functions/...         (iş fonksiyonları)
7. \i constraints/...       (FK constraint'ler)
8. \i indexes/...           (performance index'ler)
9. \i functions/maintenance/ (partition yönetimi)
10. SELECT * FROM maintenance.create_partitions();  (ilk partition'ları oluştur)
11. COMMIT
```

---

## 8. Geliştirici Rehberi

### 8.1 Yeni Tablo Ekleme

1. Tablo dosyasını uygun klasöre oluştur: `{db}/tables/{schema}/{domain}/{tablo_adi}.sql`
2. Gerekirse FK constraint'i: `{db}/constraints/{schema}.sql`
3. Performance index'leri: `{db}/indexes/{schema}.sql`
4. Deploy script'e `\i` satırı ekle (doğru sıraya: tables → constraints → indexes)
5. `DATABASE_ARCHITECTURE.md` güncelle

### 8.2 Yeni Fonksiyon Ekleme

1. Fonksiyon dosyası: `{db}/functions/{schema}/{domain}/{fonksiyon_adi}.sql`
2. Deploy script'e `\i` satırı ekle
3. İlgili fonksiyon dosyasını güncelle (`FUNCTIONS_CORE.md`, `FUNCTIONS_TENANT.md` veya `FUNCTIONS_GATEWAY.md`)

### 8.3 Partition Ekleme

1. Tablo dosyasında inline tanım: `PARTITION BY RANGE (key)` + `CREATE TABLE ... DEFAULT`
2. Composite PK: `PRIMARY KEY (id, partition_key)`
3. Tabloya referans veren FK'ları kaldır (app-level bütünlük)
4. `maintenance` fonksiyonlarını güncelle (yeni tabloyu ekle)
5. `PARTITION_ARCHITECTURE.md` güncelle

### 8.4 Kod Stili

| Kural | Detay |
|-------|-------|
| **Header (tablo)** | `-- =====` (45 karakter), Türkçe |
| **Header (fonksiyon)** | `-- ====` (64 karakter), Türkçe |
| **Satır içi yorum** | Türkçe |
| **COMMENT ON** | English (TABLE ve FUNCTION için). COLUMN için kullanılmaz |
| **Değişken isimleri** | snake_case, English. Parametre: `p_`, Değişken: `v_` |
| **Hata mesajları** | English key formatı: `'error.domain.description'` |
| **Delete fonksiyonları** | Yeni fonksiyonlar soft delete (`is_active = FALSE`) |

---

## 9. Güvenlik ve Yetkilendirme

### 9.1 RBAC (Role Based Access Control)

8 sistem rolü: `superadmin`, `admin`, `companyadmin`, `tenantadmin`, `moderator`, `editor`, `operator`, `user`

175 permission, 12 kategori (`core/data/permissions_full.sql`). Yetkiler UPSERT pattern ile tanımlanır.

### 9.2 IDOR Koruması (Insecure Direct Object Reference)

Core DB `security` şemasında merkezi access control fonksiyonları:

| Fonksiyon | Açıklama |
|-----------|----------|
| `user_get_access_level(caller_id)` | Caller'ın erişim seviyesini döner |
| `user_assert_access_company(caller_id, company_id)` | Company erişim kontrolü (P0403 exception) |
| `user_assert_access_tenant(caller_id, tenant_id)` | Tenant erişim kontrolü (P0403 exception) |
| `user_assert_manage_user(caller_id, target_user_id)` | Kullanıcı yönetim kontrolü (P0403 exception) |

### 9.3 Cross-DB Güvenlik Deseni

Tenant DB fonksiyonları auth kontrolü **yapmaz**. Yetkilendirme Core DB'de, iş mantığı Tenant DB'de çalışır:

```
Backend Request
    │
    ├─ 1. Core DB: security.user_assert_access_tenant(caller_id, tenant_id)
    │      → P0403 exception fırlatırsa işlem durur
    │
    └─ 2. Tenant DB: iş fonksiyonu çağrılır (auth-agnostic)
```

### 9.4 GeoIP ile Güvenlik İzleme

Tüm login ve oturum olayları 22 GeoIP alanı ile zenginleştirilir (ip-api.com). Proxy, hosting ve mobil tespiti dahil.

---

## 10. Log ve Audit Stratejisi

### 10.1 Altın Kurallar

> 1. **"Core paylaşılır, tenant izole edilir."**
> 2. **"Log kısa ömürlüdür, audit kalıcıdır."**
> 3. **"Her tenant için ayrı veritabanı = tam izolasyon."**
> 4. **"Frontend state (tema) Core'da, business data Tenant'ta tutulur."**

### 10.2 Retention Stratejisi

| Veri Tipi | DB | Partition | Retention |
|-----------|----|-----------|-----------|
| Teknik loglar | `*_log` DB'ler | Daily | 30-90 gün |
| Auth denetim | `core_audit` | Daily | 90 gün |
| Player audit | `tenant_audit` | Hybrid | 365 gün - 5 yıl |
| İş verileri | `tenant`, `tenant_affiliate` | Monthly | Sınırsız |
| Raporlar | `*_report` DB'ler | Monthly | Sınırsız |
| Kullanıcı mesajları | `core`, `tenant` | Monthly | 180 gün |

> Detaylar: **[LOGSTRATEGY.md](LOGSTRATEGY.md)** | Partition detayları: **[PARTITION_ARCHITECTURE.md](PARTITION_ARCHITECTURE.md)**

---

## İlgili Dökümanlar

| Doküman | Açıklama |
|---------|----------|
| [DATABASE_ARCHITECTURE.md](DATABASE_ARCHITECTURE.md) | Detaylı veritabanı mimarisi, şemalar ve tablolar |
| [DATABASE_FUNCTIONS.md](DATABASE_FUNCTIONS.md) | Fonksiyon referansı (index → [Core](FUNCTIONS_CORE.md) · [Tenant](FUNCTIONS_TENANT.md) · [Gateway](FUNCTIONS_GATEWAY.md)) |
| [LOGSTRATEGY.md](LOGSTRATEGY.md) | Log, audit ve retention stratejisi |
| [PARTITION_ARCHITECTURE.md](PARTITION_ARCHITECTURE.md) | Partition yapısı ve yönetim fonksiyonları |
| [README.md](../../README.md) | Kurulum ve deploy kılavuzu |

---

_Son Güncelleme: 2026-02-10_
