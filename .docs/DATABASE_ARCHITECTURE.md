# NUCLEO – VERİTABANI MİMARİSİ

Bu doküman, **Nucleo platformunun** tüm veritabanlarını, şemalarını ve tablolarını sistematik bir şekilde açıklar.

---

## 1. Genel Mimari Prensipler

- Sistem **multi-tenant (whitelabel)** çalışır
- Her whitelabel **tam veri izolasyonuna** sahiptir
- Operasyonel veriler, raporlar ve loglar **farklı DB'lerde** tutulur
- Hiçbir DB birden fazla sorumluluk taşımaz
- Tüm yazma yetkileri **kontrollü ve tekil servisler** üzerinden yapılır
- Log verileri **kısa ömürlüdür**, audit verileri **kalıcıdır**

---

## 2. Multi-Tenant Mimari Diyagramı

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                CORE (SHARED)                                │
│           (Merkezi: Şirketler, Tenantlar, Katalog, Routing)                 │
├─────────────────────────────────────────────────────────────────────────────┤
│  core   │  core_log  │  core_audit                                          │
└────────────────────────────────┬────────────────────────────────────────────┘
                                 │
┌────────────────────────────────┼────────────────────────────────────────────┐
│                    GATEWAY VE PLUGIN VERİTABANLARI                          │
│             (Game, Finance & Bonus Provider Entegrasyonu)                   │
├─────────────────────────────────────────────────────────────────────────────┤
│  game   │  game_log  │  finance  │  finance_log  │  bonus (Plugin)          │
└────────────────────────────────┬────────────────────────────────────────────┘
                                 │
                 ┌───────────────┼───────────────┐
                 ▼               ▼               ▼
          ┌────────────┐   ┌────────────┐   ┌────────────┐
          │ tenant_001 │   │ tenant_002 │   │ tenant_XXX │
          │ (Oyuncular │   │ (Oyuncular │   │ (Oyuncular │
          │  Cüzdanlar)│   │  Cüzdanlar)│   │  Cüzdanlar)│
          ├────────────┤   ├────────────┤   ├────────────┤
          │tenant_log  │   │tenant_log  │   │tenant_log  │
          │tenant_audit│   │tenant_audit│   │tenant_audit│
          │t_affiliate │   │t_affiliate │   │t_affiliate │
          └────────────┘   └────────────┘   └────────────┘
```

> Her tenant için ayrı bir veritabanı klonlanır. Core veritabanı tüm tenantlar arasında paylaşılır.

---

## 3. Veritabanı Özet Matrisi

| #   | Veritabanı         | Amaç                                                      | Tenant Bağımsız | Partition | Retention   |
| --- | ------------------ | --------------------------------------------------------- | --------------- | --------- | ----------- |
| 1   | `core`             | Platform yapılandırması ve merkezi veriler                | ✅              | ❌        | Sınırsız    |
| 2   | `core_log`         | Merkezi teknik log kayıtları                              | ✅              | Daily     | 30–90 gün   |
| 3   | `core_audit`       | Platform karar ve değişiklik audit                        | ✅              | ❌        | 5–10 yıl    |
| 4   | `core_report`      | Merkezi raporlama ve BI verileri                          | ✅              | Opsiyonel | İş ihtiyacı |
| 5   | `game`             | Oyun gateway entegrasyon durumu                           | ✅              | Daily     | 14–30 gün   |
| 6   | `game_log`         | Oyun gateway teknik logları                               | ✅              | Daily     | 7–14 gün    |
| 7   | `finance`          | Finans gateway entegrasyon durumu                         | ✅              | Daily     | 14–30 gün   |
| 8   | `finance_log`      | Finans gateway teknik logları                             | ✅              | Daily     | 14–30 gün   |
| 9   | `bonus`            | Bonus ve promosyon yapılandırması                         | ✅              | ❌        | Sınırsız    |
| 10  | `tenant`           | Kiracıya özel iş verileri                                 | ❌              | Monthly   | Sınırsız    |
| 11  | `tenant_affiliate` | Affiliate tracking ve komisyon yönetimi                   | ❌              | Monthly   | Sınırsız    |
| 12  | `tenant_log`       | Kiracıya özel operasyonel loglar (dahil: `affiliate_log`) | ❌              | Daily     | 30–90 gün   |
| 13  | `tenant_audit`     | Kiracıya özel audit kayıtları (dahil: `affiliate_audit`)  | ❌              | Yearly    | 5–10 yıl    |
| 14  | `tenant_report`    | Kiracıya özel raporlar ve istatistikler                   | ❌              | Opsiyonel | İş ihtiyacı |

---

## 4. Core Veritabanı

Core veritabanı, platformun merkezi konfigürasyon ve yönetim verilerini barındırır. **Globaldir**, **read-heavy** çalışır ve **finansal state tutmaz**.

### 4.1 Şema Listesi

| Şema           | Amaç                                         |
| -------------- | -------------------------------------------- |
| `catalog`      | Referans ve master data (Kategorize)         |
| `core`         | Tenant ve şirket bilgileri                   |
| `presentation` | Backoffice ve Tenant Frontend yapılandırması |
| `routing`      | Provider endpoint ve callback yönlendirmesi  |
| `security`     | Kullanıcı, rol ve yetki yönetimi             |
| `billing`      | Komisyon ve faturalandırma                   |
| `infra`        | PostgreSQL extension'ları                    |

---

### 4.2 catalog Şeması

Referans dataları içerir. **Read-only** karakterlidir. Mantıksal gruplara ayrılmıştır:

#### Reference & Localization

| Tablo                 | Açıklama                         |
| --------------------- | -------------------------------- |
| `countries`           | Ülke listesi ve kodları          |
| `currencies`          | Para birimi tanımları (ISO 4217) |
| `languages`           | Desteklenen diller               |
| `timezones`           | Saat dilimi referans kataloğu    |
| `localization_keys`   | Lokalizasyon anahtar tanımları   |
| `localization_values` | Lokalizasyon çevirileri          |

#### Provider & Game Catalyst

| Tablo               | Açıklama                         |
| ------------------- | -------------------------------- |
| `providers`         | Provider (oyun/ödeme) tanımları  |
| `provider_types`    | Provider tip kategorileri        |
| `provider_settings` | Provider yapılandırma şablonları |
| `games`             | Global oyun kataloğu             |
| `payment_methods`   | Ödeme metodları kataloğu         |

#### Compliance (Regulatory, KYC, RG)

| Tablo                         | Açıklama                                |
| ----------------------------- | --------------------------------------- |
| `jurisdictions`               | Lisans otoriteleri (MGA, UKGC, GGL vb.) |
| `kyc_policies`                | Jurisdiction bazlı KYC kuralları        |
| `kyc_document_requirements`   | Gerekli KYC belgeleri                   |
| `responsible_gaming_policies` | Sorumlu oyun politikaları               |

#### UI Kit (Theme Market)

| Tablo                       | Açıklama                                       |
| --------------------------- | ---------------------------------------------- |
| `themes`                    | Global tema tanımları ve varsayılan configleri |
| `widgets`                   | Kullanılabilir frontend widget'ları            |
| `ui_positions`              | Sayfa üzerindeki slot alanları (header vs.)    |
| `navigation_templates`      | Hazır navigasyon şablonları (Casino/Spor vb.)  |
| `navigation_template_items` | Şablon içeriğindeki menü öğeleri (Master Data) |

#### Transaction Definitions

| Tablo               | Açıklama                                   |
| ------------------- | ------------------------------------------ |
| `operation_types`   | Operasyon tipi tanımları (DEBIT/CREDIT)    |
| `transaction_types` | İşlem tipi tanımları (BET, WIN, BONUS vb.) |

---

### 4.3 core Şeması

Tenant ve şirket yönetimi.

#### Organization

| Tablo       | Açıklama                                           |
| ----------- | -------------------------------------------------- |
| `companies` | Platform operatör şirketleri (faturalama seviyesi) |
| `tenants`   | Tenant (marka/site) tanımları                      |

#### Configuration

| Tablo                  | Açıklama                                  |
| ---------------------- | ----------------------------------------- |
| `tenant_currencies`    | Tenant'a tanımlı para birimleri           |
| `tenant_languages`     | Tenant'a tanımlı diller                   |
| `tenant_settings`      | Tenant özel konfigürasyonları             |
| `tenant_jurisdictions` | Tenant lisans/jurisdiction eşleştirmeleri |

#### Integration

| Tablo                    | Açıklama                                     |
| ------------------------ | -------------------------------------------- |
| `tenant_games`           | Tenant'a açık oyunlar                        |
| `tenant_payment_methods` | Tenant'a açık ödeme metodları                |
| `tenant_providers`       | Tenant-provider eşleştirmeleri               |
| `tenant_provider_limits` | Provider'ın tenant için belirlediği limitler |

---

### 4.4 security Şeması

Backoffice kullanıcı ve yetki yönetimi.

#### Identity

| Tablo           | Açıklama                 |
| --------------- | ------------------------ |
| `users`         | Backoffice kullanıcıları |
| `user_sessions` | Aktif oturumlar          |

#### RBAC (Role Based Access Control)

| Tablo                       | Açıklama                                 |
| --------------------------- | ---------------------------------------- |
| `roles`                     | Rol tanımları                            |
| `permissions`               | Sistem yetki tanımları                   |
| `role_permissions`          | Rol-yetki eşleştirmeleri                 |
| `user_roles`                | Kullanıcı-rol atamaları                  |
| `user_tenant_roles`         | Tenant bazlı rol atamaları               |
| `user_allowed_tenants`      | Kullanıcının erişebildiği tenantlar      |
| `user_permission_overrides` | Kullanıcı bazlı yetki override (istisna) |

#### Secrets

| Tablo              | Açıklama                                 |
| ------------------ | ---------------------------------------- |
| `secrets_provider` | Provider API key ve secret'ları (global) |
| `secrets_tenant`   | Tenant özel secret'ları (prod/staging)   |

---

### 4.5 presentation Şeması

Mantıksal olarak ikiye ayrılmıştır: **Backoffice** (Yönetim Paneli) ve **Frontend** (Tenant Sitesi).

#### Backoffice UI (Klasör: `backoffice/`)

Yönetim paneli menü ve sayfa yapısı.

| Tablo         | Açıklama             |
| ------------- | -------------------- |
| `contexts`    | UI context tanımları |
| `menu_groups` | Menü grup yapısı     |
| `menus`       | Ana menü tanımları   |
| `submenus`    | Alt menü tanımları   |
| `pages`       | Sayfa tanımları      |
| `tabs`        | Tab yapılandırması   |

#### Tenant Frontend / Theme Engine (Klasör: `frontend/`)

Tenant'ın son kullanıcıya gösterdiği yüzün yönetimi.

| Tablo               | Açıklama                                                          |
| ------------------- | ----------------------------------------------------------------- |
| `tenant_themes`     | Tenant'ın seçtiği tema ve konfigürasyonu (renk, logo)             |
| `tenant_layouts`    | Sayfa bazlı widget yerleşimleri (JSON yapısı)                     |
| `tenant_navigation` | Dinamik site menüleri (`translation_key` veya `custom_label` ile) |

> 📋 **Not**: `tenant_navigation` tablosu "Hybrid Localization" destekler. Menü başlıkları sistemdeki bir çeviri anahtarından (`translation_key`) veya doğrudan tenant'ın girdiği özel metinden (`custom_label`) gelebilir.

---

### 4.6 routing Şeması

Provider endpoint yönetimi.

| Tablo                | Açıklama                       |
| -------------------- | ------------------------------ |
| `callback_routes`    | Callback yönlendirme kuralları |
| `provider_callbacks` | Provider callback tanımları    |
| `provider_endpoints` | Provider API endpoint'leri     |

---

... (Dokümanın geri kalanı aynı) ...
