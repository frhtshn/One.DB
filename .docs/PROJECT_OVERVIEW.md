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
- 📨 **Mesajlaşma** - Kampanya, şablon ve oyuncu inbox (email/SMS/local)
- 🤝 **Affiliate Sistemi** - Ortaklık ve komisyon yönetimi
- 🏢 **Multi-Tenant** - Birden fazla markanın tek platformda çalışması
- 🎨 **Theme Engine** - Tenant'ların kendi frontend ve navigasyonunu yönetebilmesi

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
                              │ • Theme Market   │
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
│   ├── reference        → Ülkeler, para birimleri, diller
│   ├── provider         → Provider ve ayarlar
│   ├── compliance       → Jurisdiction ve KYC kuralları
│   ├── game             → Oyun kataloğu
│   ├── uikit            → Tema marketi ve Navigasyon şablonları
│   └── ...              → Diğer kataloglar
│
├── core (Tenant Yönetimi)
│   ├── organization     → Şirket ve Tenantlar
│   ├── configuration    → Platform ve Tenant ayarları (Dış Servisler, Dil, Kur)
│   └── integration      → Tenant provider/oyun erişimleri
│
├── security (Yetki Yönetimi)
│   ├── identity         → Backoffice kullanıcıları
│   ├── rbac             → Rol ve yetkiler
│   └── secrets          → API anahtarları
│
├── presentation (UI Yapısı)
│   ├── backoffice       → Admin panel menü ve sayfaları
│   └── frontend         → Tenant tema, layout ve navigasyonu
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

(İçerik değişmedi, DATABASE_ARCHITECTURE.md referans alınır)

---

## 6. Proje Yapısı

### 6.1 Klasör Yapısı

```
nucleoDb/
│
├── 📁 .claude/                   # Claude AI context ve workflow'ları
├── 📁 .docs/                     # Proje dokümantasyonu
│
├── 📁 core/                      # Core veritabanı kaynakları
│   ├── 📁 tables/
│   │   ├── 📁 catalog/          # Referans tabloları
│   │   │   ├── 📁 reference
│   │   │   ├── 📁 provider
│   │   │   ├── 📁 compliance
│   │   │   └── 📁 uikit         # Theme Market
│   │   ├── 📁 core/             # Tenant/Şirket tabloları
│   │   │   ├── 📁 organization
│   │   │   ├── 📁 configuration
│   │   │   └── 📁 integration
│   │   ├── 📁 presentation/     # UI yapısı
│   │   │   ├── 📁 backoffice    # Admin Panel
│   │   │   └── 📁 frontend      # Theme Engine
│   │   ├── 📁 routing/
│   │   ├── 📁 security/
│   │   │   ├── 📁 identity
│   │   │   ├── 📁 rbac
│   │   │   └── 📁 secrets
│   │   └── 📁 billing/
│   │
│   ├── 📁 functions/
│   ├── 📁 triggers/
│   ├── 📁 constraints/
│   ├── 📁 indexes/
│   └── 📁 data/
│
├── 📁 tenant/                    # Tenant şablon veritabanı
│   ├── 📁 tables/
│   │   ├── 📁 messaging/        # Kampanya, şablon, oyuncu inbox
│   │   └── ...
│   └── 📁 functions/
│       ├── 📁 messaging/        # 14 messaging fonksiyonu
│       ├── 📁 maintenance/      # Partition yönetimi
│       └── ...
│
├── 📁 tenant_log/                # Tenant log veritabanı
│   ├── 📁 tables/
│   │   ├── 📁 messaging/        # message_delivery_logs (partitioned daily)
│   │   └── ...
│   └── 📁 functions/maintenance/ # Partition yönetimi
│
├── 📁 tenant_affiliate/          # Tenant Affiliate plugin
├── 📁 tenant_report/             # Tenant raporlama
├── 📁 bonus/                     # Bonus plugin (global)
├── 📁 core_log, core_audit...    # Diğer DB'ler
│
├── 📄 deploy_core.sql            # Core deploy scripti
├── 📄 deploy_tenant.sql          # Tenant deploy scripti
├── 📄 deploy_tenant_log.sql      # Tenant log deploy scripti
└── ...
```

---

## 7. Deploy Süreci

### 7.1 Deploy Sırası

1.  📦 **create_dbs.sql**: Veritabanlarını oluştur.
2.  📦 **deploy_core.sql**: Core katmanını (Katalog, Tenant, Security, Theme Engine) deploy et.
3.  📦 **deploy_bonus.sql**: Bonus kurallarını deploy et.
4.  📦 **deploy_tenant.sql**: Tenant şablonunu deploy et (messaging dahil).
5.  📦 **deploy_tenant_log.sql**: Tenant log şablonunu deploy et (messaging_log dahil).
6.  📦 **deploy_tenant_affiliate.sql**: Affiliate şablonunu deploy et.

---

## 10. Log ve Audit Stratejisi

### 10.3 Altın Kurallar

> 1. **"Core paylaşılır, tenant izole edilir."**
> 2. **"Log kısa ömürlüdür, audit kalıcıdır."**
> 3. **"Her tenant için ayrı veritabanı = tam izolasyon."**
> 4. **"Frontend state (tema) Core'da, business data Tenant'ta tutulur."**

---

## 📚 İlgili Dökümanlar

| Doküman                                              | Açıklama                                         |
| ---------------------------------------------------- | ------------------------------------------------ |
| [DATABASE_ARCHITECTURE.md](DATABASE_ARCHITECTURE.md) | Detaylı veritabanı mimarisi, şemalar ve tablolar |
| [DATABASE_FUNCTIONS.md](DATABASE_FUNCTIONS.md)       | Stored procedure ve trigger referansı            |
| [LOGSTRATEGY.md](LOGSTRATEGY.md)                     | Log, audit ve retention stratejisi               |
| [PARTITION_ARCHITECTURE.md](PARTITION_ARCHITECTURE.md)| Partition yapısı ve yönetim fonksiyonları         |
| [README.md](../README.md)                            | Kurulum ve deploy kılavuzu                       |

---

_Son Güncelleme: 2026-02-09_
