# NUCLEO DATABASE PROJESİ - GENEL BAKIŞ

Bu doküman, **NucleoDB** projesinin büyük resmini ve sistemin nasıl çalıştığını açıklar.

---

## 📋 İçindekiler

1. [Proje Hakkında](#1-proje-hakkında)
2. [Sistem Mimarisi](#2-sistem-mimarisi)
3. [Veritabanı Katmanları](#3-veritabanı-katmanları)
4. [Multi-Tenant Yapı](#4-multi-tenant-yapı)
5. [Veri Akışı](#5-veri-akışı)
6. [Proje Yapısı](#6-proje-yapısı)
7. [Deploy Süreci](#7-deploy-süreci)
8. [Geliştirici Workflow'ları](#8-geliştirici-workflowları)
9. [Güvenlik ve Yetkilendirme](#9-güvenlik-ve-yetkilendirme)
10. [Log ve Audit Stratejisi](#10-log-ve-audit-stratejisi)

---

## 1. Proje Hakkında

### 1.1 Ne İçin Kullanılıyor?

**Nucleo**, online gaming/betting platformları için tasarlanmış **multi-tenant (whitelabel)** bir veritabanı altyapısıdır. Platform:

- 🎰 **Oyun Entegrasyonu** - Game provider'larla entegrasyon
- 💳 **Ödeme İşlemleri** - Finance provider'larla ödeme yönetimi
- 👥 **Oyuncu Yönetimi** - Kayıt, cüzdan, işlemler
- 🎁 **Bonus Sistemi** - Promosyon ve kampanyalar
- 🤝 **Affiliate Sistemi** - Ortaklık ve komisyon yönetimi
- 🏢 **Multi-Tenant** - Birden fazla markanın tek platformda çalışması

### 1.2 Temel Prensipler

| Prensip                          | Açıklama                                                 |
| -------------------------------- | -------------------------------------------------------- |
| **Veri İzolasyonu**              | Her tenant (marka) tam veri izolasyonuna sahiptir        |
| **Sorumluluk Ayrımı**            | Her veritabanı tek bir sorumluluk taşır                  |
| **Log ≠ Audit ≠ Business**       | Farklı veri tipleri farklı DB'lerde tutulur              |
| **Core Shared, Tenant Isolated** | Merkezi veriler paylaşılır, tenant verileri izole edilir |

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
│                              API GATEWAY LAYER                              │
│                          (REST API / GraphQL)                               │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
           ┌───────────────────────────┼───────────────────────────┐
           ▼                           ▼                           ▼
┌─────────────────────┐   ┌─────────────────────┐   ┌─────────────────────┐
│   CORE SERVICES     │   │  GATEWAY SERVICES   │   │  TENANT SERVICES    │
│ (Platform Yönetimi) │   │ (Game/Finance/Bonus)│   │ (Oyuncu İşlemleri)  │
└──────────┬──────────┘   └──────────┬──────────┘   └──────────┬──────────┘
           │                         │                         │
           ▼                         ▼                         ▼
┌─────────────────────┐   ┌─────────────────────┐   ┌─────────────────────┐
│    CORE DATABASE    │   │  GATEWAY DATABASES  │   │  TENANT DATABASES   │
│  (core, core_log,   │   │  (game, finance,    │   │ (tenant_XXX,        │
│   core_audit)       │   │   bonus)            │   │  tenant_affiliate)  │
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
                              └────────┬─────────┘
                                       │
           ┌───────────────────────────┼───────────────────────────┐
           │                           │                           │
           ▼                           ▼                           ▼
┌─────────────────────┐   ┌─────────────────────┐   ┌─────────────────────┐
│   CORE_LOG          │   │   CORE_AUDIT        │   │     BONUS           │
│  (Teknik Loglar)    │   │  (Denetim Kayıtları)│   │(Global Konfigürasyon)│
│  Retention: 30-90gün│   │  Retention: 5-10yıl │   │  Retention: Sınırsız │
└─────────────────────┘   └─────────────────────┘   └──────────┬──────────┘
                                                               │
                                                               │ Bonus Kuralları
                                                               ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                              TENANT KATMANI                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ tenant_001  │  │ tenant_002  │  │ tenant_XXX  │  │ tenant_affiliate_XXX│  │
│  │ (Oyuncular) │  │ (Oyuncular) │  │ (Oyuncular) │  │   (Ortaklık Takibi) │  │
│  │ (Cüzdanlar) │  │ (Cüzdanlar) │  │ (Cüzdanlar) │  │   (Komisyonlar)     │  │
│  │ (İşlemler)  │  │ (İşlemler)  │  │ (İşlemler)  │  │   (Ödemeler)        │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Veritabanı Katmanları

### 3.1 Katman Özeti

| Katman             | Veritabanları                                | Amaç                     | Paylaşım                          |
| ------------------ | -------------------------------------------- | ------------------------ | --------------------------------- |
| **Core Layer**     | `core`, `core_log`, `core_audit`             | Platform merkezi yapısı  | Tüm tenantlar arasında paylaşılır |
| **Gateway Layer**  | `game`, `game_log`, `finance`, `finance_log` | Provider entegrasyonları | Tüm tenantlar arasında paylaşılır |
| **Plugin Layer**   | `bonus`                                      | Bonus konfigürasyonu     | Tüm tenantlar arasında paylaşılır |
| **Tenant Layer**   | `tenant_XXX`                                 | Oyuncu verileri          | Her tenant'a özel                 |
| **Tenant Plugins** | `tenant_affiliate_XXX`                       | Affiliate sistemi        | Her tenant'a özel                 |

### 3.2 Core Veritabanı (Merkezi)

Core veritabanı platformun beynidir. Tüm merkezi konfigürasyon ve yönetim verilerini barındırır.

```
CORE DATABASE
├── catalog (Referans Data)
│   ├── countries        → Ülkeler
│   ├── currencies       → Para birimleri
│   ├── languages        → Diller
│   ├── timezones        → Saat dilimleri
│   ├── games            → Global oyun kataloğu
│   ├── providers        → Oyun/Ödeme provider'ları
│   └── payment_methods  → Ödeme metodları
│
├── core (Tenant Yönetimi)
│   ├── companies        → Operatör şirketleri
│   ├── tenants          → Markalar/Siteler
│   ├── tenant_settings  → Tenant konfigürasyonları
│   └── tenant_*         → Tenant-provider eşleştirmeleri
│
├── security (Yetki Yönetimi)
│   ├── users            → Backoffice kullanıcıları
│   ├── roles            → Rol tanımları
│   ├── permissions      → Yetki tanımları
│   └── user_sessions    → Oturum yönetimi
│
├── presentation (UI Yapısı)
│   ├── menu_groups      → Menü grupları
│   ├── menus            → Menüler
│   ├── pages            → Sayfalar
│   └── tabs             → Tab'lar
│
├── billing (Faturalandırma)
│   ├── tenant_*         → Tenant faturaları (Nucleo'nun alacakları)
│   └── provider_*       → Provider ödemeleri (Nucleo'nun borçları)
│
└── routing (Provider Yönlendirme)
    ├── provider_endpoints  → API endpoint'leri
    └── provider_callbacks  → Callback tanımları
```

### 3.3 Tenant Veritabanı (Oyuncu Verileri)

Her tenant (marka) için ayrı bir veritabanı oluşturulur. `tenant` şablon DB'si klonlanarak `tenant_<code>` formatında oluşturulur.

```
TENANT DATABASE (tenant_XXX)
├── auth (Kimlik Doğrulama)
│   ├── players              → Ana oyuncu kaydı
│   ├── player_credentials   → Giriş bilgileri
│   └── player_groups        → Oyuncu grupları
│
├── profile (Profil Bilgileri)
│   ├── player_identity      → Kimlik bilgileri (şifreli)
│   └── player_profile       → Adres, telefon (şifreli)
│
├── wallet (Cüzdan Yönetimi)
│   ├── wallets              → Bakiyeler
│   └── wallet_snapshots     → Anlık görüntüler
│
├── transaction (İşlemler)
│   ├── transactions         → Tüm finansal işlemler
│   └── transaction_workflows → İşlem süreçleri
│
├── finance (Finansal Referans)
│   ├── currency_rates       → Döviz kurları
│   └── payment_method_limits → Ödeme limitleri
│
├── game (Oyun Ayarları)
│   └── game_settings        → Tenant özel oyun ayarları
│
├── kyc (Doğrulama)
│   ├── player_kyc_cases     → KYC vakaları
│   └── player_documents     → Yüklenen belgeler
│
├── bonus (Bonus Uygulama)
│   ├── bonus_awards         → Oyuncu bonusları
│   └── promo_redemptions    → Kod kullanımları
│
└── content (İçerik Yönetimi)
    ├── contents             → CMS içerikleri
    ├── faq_items            → SSS
    ├── promotions           → Promosyonlar
    ├── slides               → Banner/Slider'lar
    └── popups               → Popup'lar
```

### 3.4 Bonus Veritabanı (Global Plugin)

Bonus konfigürasyon katmanı. Tüm tenantlar tarafından paylaşılır.

```
BONUS DATABASE
├── bonus (Kural Motoru)
│   ├── bonus_types      → Bonus tipleri (Deposit, FreeSpin)
│   ├── bonus_rules      → Çevrim kuralları
│   └── bonus_triggers   → Otomatik tetikleyiciler
│
├── promotion (Promosyonlar)
│   └── promo_codes      → Promosyon kodları
│
└── campaign (Kampanyalar)
    └── campaigns        → Global kampanya tanımları
```

### 3.5 Tenant Affiliate Veritabanı (Plugin)

Bağımsız bir plugin olarak her tenant için ayrı veritabanı (`tenant_affiliate_XXX`).

```
TENANT AFFILIATE DATABASE
├── affiliate (Ortaklık)
│   ├── affiliates           → Affiliate kayıtları
│   └── affiliate_network    → MLM yapısı
│
├── campaign (Trafik)
│   ├── traffic_sources      → Trafik kaynakları
│   └── campaigns            → Kampanyalar
│
├── commission (Komisyon)
│   ├── commission_plans     → Komisyon planları
│   ├── commission_tiers     → Kademe sistemi
│   └── commissions          → Hesaplanan komisyonlar
│
├── payout (Ödeme)
│   ├── payout_requests      → Ödeme talepleri
│   └── payouts              → Kesinleşen ödemeler
│
└── tracking (Takip)
    ├── player_affiliate_current  → Oyuncu-Affiliate ilişkisi
    ├── affiliate_stats_daily     → Günlük istatistikler
    └── affiliate_stats_monthly   → Aylık istatistikler
```

---

## 4. Multi-Tenant Yapı

### 4.1 Tenant Oluşturma Akışı

```
1. Core DB'de tenant kaydı oluştur
   └── core.tenants tablosuna INSERT

2. Tenant veritabanını klonla
   └── CREATE DATABASE tenant_XXX WITH TEMPLATE tenant;

3. Tenant affiliate veritabanını klonla (opsiyonel)
   └── CREATE DATABASE tenant_affiliate_XXX WITH TEMPLATE tenant_affiliate;

4. Tenant konfigürasyonlarını ata
   ├── core.tenant_currencies (Para birimleri)
   ├── core.tenant_languages (Diller)
   ├── core.tenant_providers (Provider'lar)
   └── core.tenant_settings (Ayarlar)
```

### 4.2 Veri İzolasyonu

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              SHARED (Core)                                  │
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Currencies │  │  Languages  │  │   Games     │  │  Providers  │        │
│  │  (Tümü)     │  │  (Tümü)     │  │  (Tümü)     │  │  (Tümü)     │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Tenant Configurations (tenant_id ile filtrelenmiş erişim)          │   │
│  │  • tenant_001: TRY, USD, EUR | TR, EN | Provider A, B               │   │
│  │  • tenant_002: BRL, USD | PT, EN | Provider A, C                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                       │
                                       │ Tenant Code ile Routing
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            ISOLATED (Tenant DBs)                            │
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│  │   tenant_001    │  │   tenant_002    │  │   tenant_XXX    │             │
│  │  ──────────────  │  │  ──────────────  │  │  ──────────────  │             │
│  │  Players: 50K   │  │  Players: 120K  │  │  Players: X     │             │
│  │  Wallets: 150K  │  │  Wallets: 360K  │  │  Wallets: X     │             │
│  │  Transactions   │  │  Transactions   │  │  Transactions   │             │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘             │
│                                                                             │
│  ⚠️ Cross-DB Query YAPILMAZ! Denormalizasyon ile çözülür.                  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.3 Denormalizasyon Stratejisi

PostgreSQL'de cross-database join yapılamadığı için bazı veriler tenant DB'ye kopyalanır:

| Tenant Tablosu                    | Kopyalanan Alanlar                                                         | Kaynak                         |
| --------------------------------- | -------------------------------------------------------------------------- | ------------------------------ |
| `game.game_settings`              | `game_id`, `game_code`, `provider_id`, `provider_code`                     | `core.catalog.games`           |
| `finance.payment_method_settings` | `payment_method_id`, `payment_method_code`, `provider_id`, `provider_code` | `core.catalog.payment_methods` |
| `bonus.bonus_awards`              | `player_id`, `player_username`                                             | `tenant.auth.players`          |

---

## 5. Veri Akışı

### 5.1 Oyuncu Kaydı Akışı

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              OYUNCU KAYDI                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Frontend → API Request (tenant_code: "site001", player data)           │
│                    │                                                        │
│                    ▼                                                        │
│  2. API Gateway → Tenant Routing (tenant_code → tenant_001 DB)             │
│                    │                                                        │
│                    ▼                                                        │
│  3. tenant_001.auth.players → INSERT (player record)                       │
│                    │                                                        │
│                    ├──→ tenant_001.profile.player_identity (KYC bilgileri)  │
│                    ├──→ tenant_001.auth.player_credentials (şifre)          │
│                    └──→ tenant_001.wallet.wallets (varsayılan cüzdan)       │
│                                                                             │
│  4. Affiliate tracking (varsa)                                             │
│         └──→ tenant_affiliate_001.tracking.player_registrations            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.2 Para Yatırma Akışı

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              PARA YATIRMA                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Player → Deposit Request (100 TRY)                                     │
│         │                                                                   │
│         ▼                                                                   │
│  2. core.routing.provider_endpoints → Provider seçimi                      │
│         │                                                                   │
│         ▼                                                                   │
│  3. Finance Gateway → Provider API call                                    │
│         │                                                                   │
│         ├──→ finance.transactions (gateway state)                          │
│         └──→ finance_log (API request/response)                            │
│                                                                             │
│  4. Callback → Transaction confirmed                                       │
│         │                                                                   │
│         ▼                                                                   │
│  5. tenant_001.transaction.transactions → INSERT                           │
│         │                                                                   │
│         └──→ tenant_001.wallet.wallets → UPDATE balance (+100 TRY)         │
│                                                                             │
│  6. Bonus check → bonus.bonus_triggers                                     │
│         │                                                                   │
│         └──→ tenant_001.bonus.bonus_awards (varsa)                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.3 Backoffice Login Akışı

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BACKOFFICE LOGIN                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Admin → Login Request (email, password)                                │
│         │                                                                   │
│         ▼                                                                   │
│  2. security.user_authenticate() → Kimlik doğrulama                        │
│         │                                                                   │
│         ├──→ core.security.users (kullanıcı kontrolü)                      │
│         ├──→ core.security.user_roles (global roller)                      │
│         ├──→ core.security.user_tenant_roles (tenant rolleri)              │
│         └──→ core.security.role_permissions (yetkiler)                     │
│                                                                             │
│  3. Session → security.session_save()                                      │
│         │                                                                   │
│         ├──→ core.security.user_sessions (oturum bilgisi)                  │
│         └──→ core_audit.backoffice.auth_audit_log (audit kaydı)            │
│                                                                             │
│  4. Response → JWT Token + User Profile + Permissions                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Proje Yapısı

### 6.1 Klasör Yapısı

```
nucleoDb/
│
├── 📁 .agent/                    # AI Agent konfigürasyonu
│   └── 📁 workflows/             # Otomasyon workflow'ları
│       ├── add-database.md       # Yeni veritabanı ekleme
│       ├── add-function.md       # Yeni fonksiyon ekleme
│       ├── add-schema.md         # Yeni şema ekleme
│       ├── add-table.md          # Yeni tablo ekleme
│       ├── add-trigger.md        # Yeni trigger ekleme
│       ├── scan-and-update-functions.md  # Fonksiyon tarama
│       └── update-docs.md        # Dokümantasyon güncelleme
│
├── 📁 .docs/                     # Proje dokümantasyonu
│   ├── DATABASE_ARCHITECTURE.md  # Veritabanı mimarisi
│   ├── DATABASE_FUNCTIONS.md     # Fonksiyon referansı
│   ├── LOGSTRATEGY.md            # Log/Audit stratejisi
│   └── PROJECT_OVERVIEW.md       # Bu doküman
│
├── 📁 core/                      # Core veritabanı kaynakları
│   ├── 📁 tables/               # 59 tablo tanımı
│   │   ├── 📁 catalog/          # Referans tabloları
│   │   ├── 📁 core/             # Tenant/Şirket tabloları
│   │   ├── 📁 presentation/     # UI yapısı
│   │   ├── 📁 routing/          # Provider routing
│   │   ├── 📁 security/         # Yetki yönetimi
│   │   └── 📁 billing/          # Faturalandırma
│   ├── 📁 functions/            # 116 stored procedure
│   ├── 📁 triggers/             # 3 trigger dosyası
│   ├── 📁 constraints/          # 6 FK constraint dosyası
│   ├── 📁 indexes/              # 6 index dosyası
│   └── 📁 data/                 # 11 seed data dosyası
│
├── 📁 core_log/                  # Core Log veritabanı
│   ├── 📁 tables/               # Log tabloları
│   ├── 📁 functions/            # Log fonksiyonları
│   └── 📁 indexes/              # Log indexleri
│
├── 📁 core_audit/                # Core Audit veritabanı
│   ├── 📁 tables/               # Audit tabloları
│   ├── 📁 functions/            # Audit fonksiyonları
│   └── 📁 indexes/              # Audit indexleri
│
├── 📁 tenant/                    # Tenant şablon veritabanı
│   ├── 📁 tables/               # 57 tablo tanımı
│   ├── 📁 views/                # 2 view
│   ├── 📁 constraints/          # 7 constraint dosyası
│   └── 📁 indexes/              # 9 index dosyası
│
├── 📁 tenant_affiliate/          # Tenant Affiliate plugin
│   ├── 📁 tables/               # 30 tablo tanımı
│   ├── 📁 constraints/          # 5 constraint dosyası
│   └── 📁 indexes/              # 5 index dosyası
│
├── 📁 bonus/                     # Bonus plugin (global)
│   ├── 📁 tables/               # 5 tablo tanımı
│   ├── 📁 constraints/          # Constraint'ler
│   └── 📁 indexes/              # Index'ler
│
├── 📁 tenant_log/                # Tenant Log şablonu
├── 📁 tenant_audit/              # Tenant Audit şablonu
├── 📁 game/                      # Game gateway (TBD)
├── 📁 game_log/                  # Game log (TBD)
├── 📁 finance/                   # Finance gateway (TBD)
├── 📁 finance_log/               # Finance log (TBD)
│
├── 📄 create_dbs.sql             # Veritabanları oluşturma
├── 📄 deploy_core.sql            # Core deploy scripti
├── 📄 deploy_core_log.sql        # Core Log deploy scripti
├── 📄 deploy_core_audit.sql      # Core Audit deploy scripti
├── 📄 deploy_tenant.sql          # Tenant deploy scripti
├── 📄 deploy_tenant_affiliate.sql # Affiliate deploy scripti
├── 📄 deploy_bonus.sql           # Bonus deploy scripti
├── 📄 deploy_tenant_log.sql      # Tenant Log deploy scripti
├── 📄 deploy_tenant_audit.sql    # Tenant Audit deploy scripti
│
└── 📄 README.md                  # Kurulum kılavuzu
```

### 6.2 Dosya Adlandırma Kuralları

| Dosya Tipi | Format                                      | Örnek                                          |
| ---------- | ------------------------------------------- | ---------------------------------------------- |
| Tablo      | `snake_case.sql`                            | `player_credentials.sql`                       |
| Fonksiyon  | `action_noun.sql`                           | `user_create.sql`, `session_save.sql`          |
| Trigger    | `schema_triggers.sql`                       | `security_triggers.sql`                        |
| Constraint | `schema.sql`                                | `security.sql`                                 |
| Index      | `schema.sql`                                | `catalog.sql`                                  |
| Seed Data  | `table_name.sql` veya `table_name_lang.sql` | `currencies.sql`, `localization_values_tr.sql` |

---

## 7. Deploy Süreci

### 7.1 Deploy Sırası

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              DEPLOY SIRASI                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. 📦 create_dbs.sql      → Tüm veritabanlarını oluştur (boş)             │
│                                                                             │
│  2. 📦 deploy_core.sql     → Core veritabanını deploy et                   │
│         ├── Schemas                                                         │
│         ├── Extensions                                                      │
│         ├── Tables (catalog → core → presentation → security → billing)    │
│         ├── Seed Data                                                       │
│         ├── Functions                                                       │
│         ├── Triggers                                                        │
│         ├── Constraints (en son!)                                          │
│         └── Indexes (en son!)                                              │
│                                                                             │
│  3. 📦 deploy_core_log.sql → Core Log veritabanını deploy et               │
│                                                                             │
│  4. 📦 deploy_core_audit.sql → Core Audit veritabanını deploy et           │
│                                                                             │
│  5. 📦 deploy_bonus.sql    → Bonus veritabanını deploy et                  │
│                                                                             │
│  6. 📦 deploy_tenant.sql   → Tenant şablon veritabanını deploy et          │
│                                                                             │
│  7. 📦 deploy_tenant_affiliate.sql → Affiliate şablonunu deploy et         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.2 Deploy Komutları

```bash
# Şifre ayarla
set PGPASSWORD=your_password

# 1. Veritabanlarını oluştur
psql -h localhost -U postgres -d postgres -f create_dbs.sql

# 2. Core deploy
psql -h localhost -U postgres -d core -f deploy_core.sql

# 3. Core Log deploy
psql -h localhost -U postgres -d core_log -f deploy_core_log.sql

# 4. Core Audit deploy
psql -h localhost -U postgres -d core_audit -f deploy_core_audit.sql

# 5. Bonus deploy
psql -h localhost -U postgres -d bonus -f deploy_bonus.sql

# 6. Tenant şablon deploy
psql -h localhost -U postgres -d tenant -f deploy_tenant.sql

# 7. Tenant Affiliate şablon deploy
psql -h localhost -U postgres -d tenant_affiliate -f deploy_tenant_affiliate.sql
```

### 7.3 Yeni Tenant Oluşturma

```sql
-- Tenant veritabanını klonla
CREATE DATABASE tenant_ferhatbet WITH TEMPLATE tenant;

-- Affiliate veritabanını klonla (opsiyonel)
CREATE DATABASE tenant_affiliate_ferhatbet WITH TEMPLATE tenant_affiliate;
```

---

## 8. Geliştirici Workflow'ları

### 8.1 Tanımlı Workflow'lar

| Workflow                     | Komut                  | Açıklama                                     |
| ---------------------------- | ---------------------- | -------------------------------------------- |
| `/add-database`              | Yeni veritabanı ekle   | `create_dbs.sql` ve dokümantasyonu günceller |
| `/add-schema`                | Yeni şema ekle         | Deploy script ve dokümantasyonu günceller    |
| `/add-table`                 | Yeni tablo ekle        | Deploy script ve dokümantasyonu günceller    |
| `/add-function`              | Yeni fonksiyon ekle    | Dosya yapısı ve deploy sürecini yönetir      |
| `/add-trigger`               | Yeni trigger ekle      | Dosya yapısı ve deploy sürecini yönetir      |
| `/update-docs`               | Dokümantasyon güncelle | Tüm ".md" dosyalarını günceller              |
| `/scan-and-update-functions` | Fonksiyon tarama       | `DATABASE_FUNCTIONS.md` dosyasını günceller  |

### 8.2 Tipik Geliştirme Akışı

```
1. Yeni özellik için tablo tasarla
   └── /add-table komutu kullan

2. Gerekli fonksiyonları yaz
   └── /add-function komutu kullan

3. Deploy scriptini test et
   └── psql -f deploy_xxx.sql

4. Dokümantasyonu güncelle
   └── /update-docs komutu kullan

5. Commit ve push
   └── git add . && git commit -m "feat: ..."
```

---

## 9. Güvenlik ve Yetkilendirme

### 9.1 Rol Hiyerarşisi

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              ROL HİYERARŞİSİ                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────┐                   │
│  │              PLATFORM LEVEL (Global)                │                   │
│  │  ┌───────────────────────────────────────────────┐ │                   │
│  │  │ superadmin  → Tüm yetkiler, silinmez          │ │                   │
│  │  │ admin       → Platform yönetimi               │ │                   │
│  │  │ support     → Destek operasyonları            │ │                   │
│  │  └───────────────────────────────────────────────┘ │                   │
│  └─────────────────────────────────────────────────────┘                   │
│                             │                                               │
│                             ▼                                               │
│  ┌─────────────────────────────────────────────────────┐                   │
│  │              TENANT LEVEL (Per Tenant)              │                   │
│  │  ┌───────────────────────────────────────────────┐ │                   │
│  │  │ tenant_admin    → Tenant tam yönetimi         │ │                   │
│  │  │ tenant_manager  → Operasyon yönetimi          │ │                   │
│  │  │ tenant_operator → Günlük işlemler             │ │                   │
│  │  │ tenant_viewer   → Sadece okuma                │ │                   │
│  │  └───────────────────────────────────────────────┘ │                   │
│  └─────────────────────────────────────────────────────┘                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 9.2 Yetki Sistemi

```sql
-- Yetki kontrol örneği
SELECT * FROM security.permission_check(
  p_user_id := 123,
  p_permission_code := 'player.view',
  p_tenant_id := 1  -- NULL ise global kontrol
);

-- Kullanıcı yetkileri
-- Formula: (Rol Yetkileri + Verilen Yetkiler) - Reddedilen Yetkiler
```

---

## 10. Log ve Audit Stratejisi

### 10.1 Log vs Audit vs Business

| Kategori     | Amaç                                 | Retention | Örnek                                  |
| ------------ | ------------------------------------ | --------- | -------------------------------------- |
| **Log**      | Hata ayıklama, operasyonel izleme    | 7-90 gün  | API hataları, teknik loglar            |
| **Audit**    | Regülasyon, güvenlik, izlenebilirlik | 5-10 yıl  | Login denemeleri, yetki değişiklikleri |
| **Business** | İş verisi, raporlama                 | Sınırsız  | İşlemler, bakiyeler, oyuncu verileri   |

### 10.2 Retention Matrisi

| Veritabanı     | Partition | Retention | Temizleme      |
| -------------- | --------- | --------- | -------------- |
| `core`         | ❌        | Sınırsız  | ❌             |
| `core_log`     | Daily     | 30-90 gün | DROP partition |
| `core_audit`   | ❌        | 5-10 yıl  | ❌             |
| `game_log`     | Daily     | 7-14 gün  | DROP partition |
| `finance_log`  | Daily     | 14-30 gün | DROP partition |
| `tenant`       | ❌        | Sınırsız  | ❌             |
| `tenant_log`   | Daily     | 30-90 gün | DROP partition |
| `tenant_audit` | Yearly    | 5-10 yıl  | ❌             |

### 10.3 Altın Kurallar

> 1. **"Core paylaşılır, tenant izole edilir."**
> 2. **"Log kısa ömürlüdür, audit kalıcıdır."**
> 3. **"Her tenant için ayrı veritabanı = tam izolasyon."**
> 4. **"Retention süresi dolduysa, partition silinir; silinmeyen log teknik borçtur."**

---

## 📚 İlgili Dökümanlar

| Doküman                                              | Açıklama                                         |
| ---------------------------------------------------- | ------------------------------------------------ |
| [DATABASE_ARCHITECTURE.md](DATABASE_ARCHITECTURE.md) | Detaylı veritabanı mimarisi, şemalar ve tablolar |
| [DATABASE_FUNCTIONS.md](DATABASE_FUNCTIONS.md)       | Stored procedure ve trigger referansı            |
| [LOGSTRATEGY.md](LOGSTRATEGY.md)                     | Log, audit ve retention stratejisi               |
| [README.md](../README.md)                            | Kurulum ve deploy kılavuzu                       |

---

_Son Güncelleme: 2026-01-28_
