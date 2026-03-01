# OneDB - Claude Context

## Platform Özeti

**Sortis One**, online gaming/betting platformları için tasarlanmış, **core-centric mimariye** sahip, **multi-client (whitelabel)** destekli, yatayda ölçeklenebilir bir orchestration platformudur.

### Mimari Prensipler
| Prensip | Açıklama |
|---------|----------|
| **Core-Centric Design** | Değişmeyen merkezi çekirdek |
| **Gateway & Plugin Oriented** | İzole entegrasyon katmanları |
| **Horizontal Scalability** | Yeni gateway ve plugin'lerle yatay büyüme |

### Platform Bileşenleri
| Bileşen | Sorumluluk |
|---------|------------|
| `SortisOne.Orchestrator` | Routing, servis yaşam döngüsü, orkestrasyon |
| `SortisOne.Core` | Domain kuralları ve merkezi veri modeli |
| `SortisOne.Gateway.*` | Game, Finance gibi provider entegrasyonları |
| `SortisOne.Plugins.*` | Bonus, Affiliate, Fraud gibi genişletilebilir servisler |

### Veritabanı Katmanları
| Katman | Veritabanları | Paylaşım |
|--------|---------------|----------|
| **Core Layer** | core (16 schema: iş + log + audit + report) | Tüm clientlar (paylaşımlı) |
| **Gateway Layer** | game (iş + log), finance (iş + log) | Tüm clientlar (paylaşımlı) |
| **Plugin Layer** | bonus | Tüm clientlar (paylaşımlı) |
| **Client Layer** | client_XXX (tek birleşik veritabanı, 30 schema) | İzole (her client'a özel) |

### Multi-Client Strateji
- Her client için **ayrı veritabanı** oluşturulur
- **Cross-DB join yapılmaz**
- Client verileri **tamamen izole**
- Paylaşılan veriler **sadece Core DB'de**

#### Cross-Database İzolasyon (KRİTİK)
**TEMEL KURAL: 5 fiziksel veritabanı vardır. Her biri izole, Cross-DB join yapılamaz. Client ise tek birleşik DB (30 schema).**

PostgreSQL veritabanları fiziksel olarak tamamen izole edilmiştir:
- `core`, `game`, `finance`, `bonus`, `client_XXX` → **Her biri ayrı database**
- Veritabanlar arası doğrudan query **YAPILAMAZ**
- Örnek HATALI query: `SELECT FROM core.catalog.table` (client DB'den)
- Örnek HATALI query: `SELECT FROM game.providers` (core DB'den)
- **Core birleşik DB:** Eski 4 ayrı DB (core, core_log, core_audit, core_report) artık **tek bir core DB** altında 16 schema olarak birleştirilmiştir.
- **Game birleşik DB:** Eski 2 ayrı DB (game, game_log) artık **tek bir game DB** altında birleştirilmiştir.
- **Finance birleşik DB:** Eski 2 ayrı DB (finance, finance_log) artık **tek bir finance DB** altında birleştirilmiştir.
- **Client birleşik DB:** Eski 5 ayrı DB (client, client_log, client_audit, client_report, client_affiliate) artık **tek bir client DB** altında 30 schema olarak birleştirilmiştir.

**Fiziksel Veritabanları (5 DB, Her biri izole):**
```
core              → Platform merkez DB (16 schema: catalog, core, presentation, routing, security, billing, infra, outbox, messaging, maintenance + backoffice_log, logs, backoffice_audit, finance_report, billing_report, performance)
game              → Oyun provider'ları + oyun logları (game, infra, catalog + game_log, maintenance)
finance           → Finansal provider'lar + finansal loglar (finance, infra, catalog + finance_log, maintenance)
bonus             → Bonus sistemi
client_XXX        → Client birleşik DB (30 schema: iş verileri + log + audit + report + affiliate)
```

**Veritabanları Arası Veri Transferi:**
1. **Backend Application** (.NET/Dapper) - ÖNERİLEN ✅
   - Her DB için ayrı connection açar
   - Transaction yönetimi ve error handling
   - Güvenlik kontrolü ve logging
2. **dblink extension** - Alternatif ⚠️
   - Cross-DB query desteği, performans/güvenlik dezavantajları
3. **postgres_fdw** (Foreign Data Wrapper) - Alternatif ⚠️
   - Foreign table tanımlama, bakım karmaşıklığı

**Client Seeding:**
- Catalog verileri (transaction_types, operation_types) CoreDB'den ClientDB'ye backend üzerinden kopyalanır
- ID tutarlılığı garanti edilir (tüm client'larda aynı ID'ler)
- Seed işlemleri `ClientSeedService` üzerinden yapılır

### Log – Audit – Business Ayrımı
| Tip | Amaç | Saklama | Konum |
|-----|------|---------|-------|
| **Log** | Teknik, operasyonel | Kısa (30-90 gün), partition'lı | Aynı DB içinde ayrı schema (backoffice_log, game_log, finance_log vb.) |
| **Audit** | Regülasyon, denetim | Uzun (5-10 yıl) | Aynı DB içinde ayrı schema (backoffice_audit vb.) |
| **Report** | Raporlama, BI | Sınırsız | Aynı DB içinde ayrı schema (finance_report, billing_report, performance vb.) |
| **Business** | Operasyonel veriler | Sınırsız | Ana schema'lar |

---

## Bu Repo (OneDB)

Bu repo veritabanı katmanını içerir: şemalar, tablolar, fonksiyonlar, triggerlar ve deploy scriptleri.

## Çalışma Dizini
```
C:\Projects\Git\Sortis One\OneDB
```

## Teknoloji
- PostgreSQL 16
- Dapper ORM ile kullanılıyor
- .NET 10 backend (SortisOne.Platform)

## Veritabanı Mimarisi

### 1. MainDB (CoreDB) - Paylaşılan Platform (16 schema)

Core DB artık eski core_log, core_audit ve core_report veritabanlarını da içerir.

**İş Schema'ları:**
| Şema | Alt Kategori | Tablolar |
|------|--------------|----------|
| `billing` | provider | provider_commission_rates, provider_commission_tiers, provider_invoice_items, provider_invoices, provider_payments, provider_settlement_clients, provider_settlements |
| `billing` | client | client_billing_periods, client_commission_aggregates, client_commission_plan_tiers, client_commission_plans, client_commission_rate_tiers, client_commission_rates, client_commissions, client_invoice_items, client_invoice_payments, client_invoices |
| `catalog` | compliance | jurisdictions, kyc_document_requirements, kyc_level_requirements, kyc_policies, responsible_gaming_policies |
| `catalog` | game | games |
| `catalog` | localization | localization_keys, localization_values |
| `catalog` | payment | payment_methods |
| `catalog` | provider | provider_settings, provider_types, providers |
| `catalog` | reference | countries, currencies, languages, timezones |
| `catalog` | geo | ip_geo_cache |
| `catalog` | transaction | operation_types, transaction_types |
| `catalog` | uikit | navigation_template_items, navigation_templates, themes, ui_positions, widgets |
| `core` | configuration | client_currencies, client_data_policies, client_jurisdictions, client_languages, client_settings |
| `core` | integration | client_games, client_payment_methods, client_provider_limits, client_providers |
| `core` | organization | companies, clients |
| `outbox` | - | outbox_messages |
| `presentation` | backoffice | contexts, menu_groups, menus, pages, submenus, tabs |
| `presentation` | frontend | client_layouts, client_navigation, client_themes |
| `routing` | - | callback_routes, provider_callbacks, provider_endpoints |
| `security` | identity | user_sessions, users |
| `security` | rbac | permissions, role_permissions, roles, user_allowed_clients, user_permission_overrides, user_roles |
| `security` | secrets | secrets_provider, secrets_client |

**Log/Audit/Report Schema'ları (eski ayrı DB'lerden birleştirildi):**
| Şema | Eski DB | Amaç |
|------|---------|------|
| `backoffice_log` | core_log (eski: backoffice) | Platform operasyonel logları |
| `logs` | core_log | Genel teknik loglar |
| `backoffice_audit` | core_audit (eski: backoffice) | Platform denetim kayıtları |
| `finance_report` | core_report (eski: finance) | Finansal raporlama |
| `billing_report` | core_report (eski: billing) | Faturalandırma raporlama |
| `performance` | core_report | Global performans metrikleri |

### 2. ClientDB (ClientDB) - Her Marka İçin Ayrı
| Şema | Alt Kategori | Tablolar |
|------|--------------|----------|
| `bonus` | - | bonus_awards, promo_redemptions |
| `content` | cms | content_attachments, content_categories, content_category_translations, content_translations, content_type_translations, content_types, content_versions, contents |
| `content` | faq | faq_categories, faq_category_translations, faq_item_translations, faq_items |
| `content` | popup | popup_images, popup_schedules, popup_translations, popup_type_translations, popup_types, popups |
| `content` | promotion | promotion_banners, promotion_display_locations, promotion_games, promotion_segments, promotion_translations, promotions |
| `content` | slide | slide_categories, slide_category_translations, slide_images, slide_placements, slide_schedules, slide_translations, slides |
| `finance` | - | currency_rates, currency_rates_latest, operation_types, payment_method_limits, payment_method_settings, payment_player_limits, transaction_types |
| `game` | - | game_limits, game_settings |
| `kyc` | - | player_aml_flags, player_documents, player_jurisdiction, player_kyc_cases, player_kyc_workflows, player_limit_history, player_limits, player_restrictions |
| `player_auth` | - | player_categories, player_classification, player_credentials, player_groups, players |
| `player_profile` | - | player_identity, player_profile |
| `transaction` | - | transaction_workflow_actions, transaction_workflows, transactions |
| `wallet` | - | wallet_snapshots, wallets |

### 3. PluginDB (BonusDB) - Bonus Sistemi
| Şema | Tablolar |
|------|----------|
| `bonus` | bonus_rules, bonus_triggers, bonus_types |
| `campaign` | campaigns |
| `promotion` | promo_codes |

### Log/Audit/Report Schema'ları (Birleşik DB'ler İçinde)

> **Not:** Eski ayrı log/audit/report veritabanları artık ana DB'lerinin içinde schema olarak birleştirilmiştir:
> - **Core DB:** backoffice_log, logs, backoffice_audit, finance_report, billing_report, performance schema'ları
> - **Game DB:** game_log schema'sı
> - **Finance DB:** finance_log schema'sı
> - **Client DB:** affiliate_log, bonus_log, game_log, kyc_log, messaging_log, support_log, affiliate_audit, kyc_audit, player_audit, finance_report, game_report, support_report, affiliate, campaign, commission, payout, tracking schema'ları

## Klasör Yapısı

### Temel Kural
5 fiziksel veritabanı vardır: core, game, finance, bonus, client. Her biri izole, Cross-DB join yapılamaz. Core, game ve finance DB'leri eski ayrı log/audit/report DB'lerini schema olarak bünyesine almıştır. Client ise tek birleşik DB'dir (30 schema).

```
OneDB/
│
├── core/                          # Core DB (16 schema: iş + log + audit + report)
│   ├── tables/                    # Tablolar (şemalara göre)
│   │   ├── catalog/               # Catalog şeması
│   │   │   ├── compliance/        # ↳ Jurisdictions, KYC policies
│   │   │   ├── game/              # ↳ Games
│   │   │   ├── localization/      # ↳ Çok dilli içerik
│   │   │   ├── payment/           # ↳ Payment methods
│   │   │   ├── provider/          # ↳ Provider settings
│   │   │   ├── reference/         # ↳ Countries, currencies, languages
│   │   │   ├── transaction/       # ↳ Transaction/operation types
│   │   │   └── uikit/             # ↳ Themes, widgets, navigation
│   │   ├── core/                  # Core şeması (clients, companies)
│   │   ├── billing/               # Billing şeması
│   │   ├── presentation/          # Presentation şeması (menus, pages)
│   │   ├── routing/               # Routing şeması
│   │   ├── security/              # Security şeması (users, roles)
│   │   ├── outbox/                # Outbox pattern
│   │   ├── backoffice_log/        # Platform operasyonel logları (eski core_log)
│   │   ├── logs/                  # Genel teknik loglar (eski core_log)
│   │   ├── backoffice_audit/      # Platform denetim kayıtları (eski core_audit)
│   │   ├── finance_report/        # Finansal raporlama (eski core_report)
│   │   ├── billing_report/        # Faturalandırma raporlama (eski core_report)
│   │   └── performance/           # Global performans metrikleri (eski core_report)
│   ├── functions/                 # Stored procedures (şemalara göre)
│   │   ├── catalog/               # Catalog fonksiyonları
│   │   │   ├── compliance/        # ↳ Jurisdiction, KYC
│   │   │   ├── countries/         # ↳ Country lookups
│   │   │   ├── currencies/        # ↳ Currency lookups
│   │   │   ├── languages/         # ↳ Language lookups
│   │   │   ├── localization/      # ↳ Localization management
│   │   │   ├── payment/           # ↳ Payment method lookups
│   │   │   ├── providers/         # ↳ Provider management
│   │   │   ├── timezones/         # ↳ Timezone lookups
│   │   │   ├── transaction/       # ↳ Transaction/operation types
│   │   │   └── uikit/             # ↳ Theme, widget management
│   │   ├── core/                  # Core fonksiyonları (client, company CRUD)
│   │   ├── presentation/          # Presentation fonksiyonları (menu, page CRUD)
│   │   └── security/              # Security fonksiyonları (auth, RBAC)
│   ├── triggers/                  # Database triggers
│   ├── constraints/               # FK constraints (şemalara göre)
│   │   ├── catalog.sql
│   │   ├── core.sql
│   │   ├── presentation.sql
│   │   └── security.sql
│   ├── indexes/                   # Performance indexes (şemalara göre)
│   │   ├── catalog.sql
│   │   ├── core.sql
│   │   └── presentation.sql
│   └── data/                      # Seed data
│       ├── transaction_types.sql  # ↳ Transaction types (ID ile)
│       ├── operation_types.sql    # ↳ Operation types (ID ile)
│       ├── permissions_full.sql   # ↳ 99 permissions
│       ├── role_permissions_full.sql
│       └── staging_seed.sql
│
├── game/                          # Game DB (iş + log schema'ları birleşik)
│
├── finance/                       # Finance DB (iş + log schema'ları birleşik)
│
├── bonus/                         # Bonus sistemi DB
│
├── client/                        # Client birleşik DB (30 schema)
│   ├── tables/                    # Client tabloları (şemalara göre)
│   │   ├── bonus/                 # Bonus awards, redemptions
│   │   ├── content/               # CMS, FAQ, Popup, Promotion, Slide
│   │   ├── finance/               # Transaction/operation types, currency rates
│   │   ├── game/                  # Game limits, settings
│   │   ├── kyc/                   # KYC cases, documents, limits
│   │   ├── player_auth/           # Players, credentials, groups
│   │   ├── player_profile/        # Player identity, profile
│   │   ├── transaction/           # Transactions, workflows
│   │   ├── wallet/                # Wallets, snapshots
│   │   ├── affiliate_log/         # Affiliate log tabloları
│   │   ├── bonus_log/             # Bonus log tabloları
│   │   ├── game_log/              # Game round/spin log tabloları
│   │   ├── kyc_log/               # KYC provider log tabloları
│   │   ├── messaging_log/         # Mesaj gönderim log tabloları
│   │   ├── support_log/           # Ticket aktivite log tabloları
│   │   ├── affiliate_audit/       # Affiliate denetim tabloları
│   │   ├── kyc_audit/             # KYC denetim tabloları
│   │   ├── player_audit/          # Player denetim tabloları
│   │   ├── finance_report/        # Finansal raporlama tabloları
│   │   ├── game_report/           # Oyun raporlama tabloları
│   │   ├── support_report/        # Destek raporlama tabloları
│   │   ├── affiliate/             # Affiliate iş verileri
│   │   ├── campaign/              # Affiliate kampanya verileri
│   │   ├── commission/            # Affiliate komisyon verileri
│   │   ├── payout/                # Affiliate ödeme verileri
│   │   └── tracking/              # Affiliate takip verileri
│   ├── functions/                 # Client fonksiyonları
│   │   ├── log/                   # Log schema fonksiyonları
│   │   └── audit/                 # Audit schema fonksiyonları
│
├── deploy_core.sql                # Core birleşik DB deploy (iş + log + audit + report)
├── deploy_core_staging.sql        # Core staging seed
├── deploy_core_production.sql     # Core production seed
├── deploy_game.sql                # Game birleşik DB deploy (iş + log)
├── deploy_finance.sql             # Finance birleşik DB deploy (iş + log)
├── deploy_bonus.sql
├── deploy_client.sql              # Client birleşik DB deploy (30 schema)
├── create_dbs.sql                 # Veritabanlarını oluştur (5 DB)
└── master_deploy.sql              # Tüm deploy (sıralı)
```

### Şema İçi Organizasyon Prensibi
**Aynı şema altındaki tablolar ve fonksiyonlar görev/domain bazında alt klasörlere ayrılmıştır:**
- `catalog` şeması → compliance, game, localization, payment, provider, reference, transaction, uikit
- `content` şeması → cms, faq, popup, promotion, slide
- Bu yapı kod organizasyonu ve bakımı kolaylaştırır

## Deploy Sırası
1. `create_dbs.sql` - Veritabanlarını oluştur (5 DB)
2. `deploy_core.sql` - Core birleşik DB (iş + log + audit + report, 16 schema)
3. `deploy_game.sql` - Game birleşik DB (iş + log)
4. `deploy_finance.sql` - Finance birleşik DB (iş + log)
5. `deploy_bonus.sql`
6. `deploy_client.sql` - Client birleşik DB (30 schema: iş + log + audit + report + affiliate)

## Önemli Dokümantasyon

### Mimari
- `.docs/reference/PROJECT_OVERVIEW.md` - Proje genel bakış, sistem mimarisi ve veri akışı
- `.docs/reference/DATABASE_ARCHITECTURE.md` - Veritabanı mimarisi, şemalar ve tablolar
- `.docs/reference/PARTITION_ARCHITECTURE.md` - Partition yapısı ve yönetim fonksiyonları
- `.docs/reference/LOGSTRATEGY.md` - Log, audit ve retention stratejisi

### Fonksiyon Referansları
- `.docs/reference/DATABASE_FUNCTIONS.md` - Fonksiyon referansı (index)
- `.docs/reference/FUNCTIONS_CORE.md` - Core katmanı fonksiyonları
- `.docs/reference/FUNCTIONS_CLIENT.md` - Client katmanı fonksiyonları
- `.docs/reference/FUNCTIONS_GATEWAY.md` - Gateway & plugin fonksiyonları

## Beta Sunucu
- Host: 207.180.241.230
- Port: 5433
- PostgreSQL 16

## KYC/Compliance Yapısı

### MainDB - catalog şeması (Paylaşılan Katalog)
| Tablo | Açıklama |
|-------|----------|
| `jurisdictions` | Lisans otoriteleri (MGA, UKGC, GGL...) |
| `kyc_policies` | Jurisdiction bazlı KYC kuralları |
| `kyc_document_requirements` | Gerekli belge tipleri |
| `kyc_level_requirements` | KYC seviye geçiş kuralları (BASIC→STANDARD→ENHANCED) |
| `responsible_gaming_policies` | Sorumlu oyun politikaları |

### MainDB - core şeması
| Tablo | Açıklama |
|-------|----------|
| `client_jurisdictions` | Client-Jurisdiction bağlantısı (M:N) |

### ClientDB - kyc şeması (Her Client İçin)
| Tablo | Açıklama |
|-------|----------|
| `player_documents` | Yüklenen belgeler |
| `player_kyc_cases` | KYC vakaları |
| `player_kyc_workflows` | Workflow geçmişi |
| `player_limits` | Oyuncu limitleri (deposit, loss, session) |
| `player_restrictions` | Cooling off / Self exclusion |
| `player_limit_history` | Limit değişiklik audit |
| `player_jurisdiction` | Oyuncunun tabi olduğu jurisdiction |
| `player_aml_flags` | AML uyarıları ve SAR'lar |

### Client DB — kyc_audit Şeması (Compliance - 5-10 yıl)
| Tablo | Açıklama |
|-------|----------|
| `kyc_audit.player_screening_results` | PEP/Sanctions tarama sonuçları |
| `kyc_audit.player_risk_assessments` | Risk değerlendirme geçmişi |

### Client DB — kyc_log Şeması (Operasyonel - 90+ gün)
| Tablo | Açıklama |
|-------|----------|
| `kyc_log.player_kyc_provider_logs` | External provider API logları (Sumsub, Onfido) |

## Backoffice Dropdown (Lookup) Fonksiyonları

### IDOR Korumalı (p_caller_id gerekli)
| Fonksiyon | Açıklama |
|-----------|----------|
| `core.company_lookup(p_caller_id)` | Platform Admin tümünü görür, diğerleri sadece kendi company'sini |
| `core.client_lookup(p_caller_id, p_company_id?)` | Platform Admin tümünü görür, CompanyAdmin kendi company client'larını, diğerleri sadece user_allowed_clients |

### IDOR Korumalı Catalog (p_caller_id gerekli)
| Fonksiyon | Yetki | Açıklama |
|-----------|-------|----------|
| `catalog.provider_type_lookup(p_caller_id)` | SuperAdmin | Provider tipi listesi |
| `catalog.provider_lookup(p_caller_id, p_type_id?)` | SuperAdmin | Provider listesi |
| `catalog.jurisdiction_lookup(p_caller_id)` | Platform Admin | Jurisdiction listesi |
| `catalog.navigation_template_lookup(p_caller_id)` | Platform Admin | Navigasyon şablonu listesi |
| `catalog.theme_lookup(p_caller_id)` | SuperAdmin | Tema listesi |
| `catalog.payment_method_lookup(p_caller_id, p_provider_id?)` | SuperAdmin | Ödeme yöntemi listesi |

### Public Catalog (Yetki gerektirmeyen)
| Fonksiyon | Açıklama |
|-----------|----------|
| `catalog.country_list()` | Ülke listesi |
| `catalog.currency_list()` | Para birimi listesi |
| `catalog.timezone_list()` | Timezone listesi |
| `catalog.language_list()` | Dil listesi |
| `catalog.transaction_type_list()` | Transaction tipi listesi |
| `catalog.operation_type_list()` | Operation tipi listesi |

## Password Management (Şifre Yönetimi)

### Core Users (Backoffice)

| Tablo | Açıklama |
|-------|----------|
| `security.users` | `password_changed_at`, `require_password_change` alanları |
| `security.user_password_history` | Son N şifre geçmişi |
| `security.password_policy` | Platform geneli policy (tek satır) |

| Policy Ayarı | Varsayılan | Açıklama |
|--------------|------------|----------|
| `expiry_days` | 30 | Şifre geçerlilik süresi (0 = sınırsız) |
| `history_count` | 3 | Kontrol edilecek eski şifre sayısı |

| Fonksiyon | Açıklama |
|-----------|----------|
| `user_change_password(user_id, current_hash, new_hash)` | Kullanıcı kendi şifresini değiştirir |
| `user_reset_password(caller_id, user_id, new_hash)` | Admin şifre sıfırlama (IDOR korumalı) |
| `user_authenticate(email)` | `requirePasswordChange` ve `passwordChangedAt` döner |

### Client Players

| Tablo | Açıklama |
|-------|----------|
| `auth.player_credentials` | `last_password_change_at`, `require_password_change` alanları |
| `auth.player_password_history` | Son N şifre geçmişi |
| `core.client_settings` | Password policy (Security kategorisi, client bazlı) |

| Setting Key | Varsayılan | Açıklama |
|-------------|------------|----------|
| `password_expiry_days` | 30 | Şifre geçerlilik süresi |
| `password_history_count` | 3 | Eski şifre kontrolü |
| `password_min_length` | 8 | Minimum uzunluk |

## Rol Hiyerarşisi ve Güvenlik

### Rol Seviyeleri
```
superadmin    : level 100, is_platform_role = TRUE
admin         : level 90,  is_platform_role = TRUE
companyadmin  : level 80,  is_platform_role = FALSE
clientadmin   : level 70,  is_platform_role = FALSE
moderator     : level 60,  is_platform_role = FALSE
editor        : level 50,  is_platform_role = FALSE
operator      : level 40,  is_platform_role = FALSE
user          : level 10,  is_platform_role = FALSE
```

### Güvenlik Kuralları
1. **Level Kontrolü:** Kullanıcı sadece kendi level'ının ALTINDA olan rolleri atayabilir
2. **Client Scope:** ClientAdmin ve altı sadece `security.user_allowed_clients` tablosunda yetkili olduğu client'larda işlem yapabilir
3. **Company Scope:** CompanyAdmin sadece kendi company'sindeki client'larda işlem yapabilir

## Mimari Kurallar

### Fiziksel İzolasyon
MainDB, ClientDB ve PluginDB fiziksel olarak ayrıdır. Tablo üretirken bu ayrımı koru, birbirine karıştırma.

### Extension Standartları
PostgreSQL eklentileri (pgcrypto, uuid-ossp, pg_stat_statements, btree_gin, btree_gist, tablefunc, citext) her zaman `infra` şeması üzerinden çağrılmalıdır.
```sql
-- Doğru kullanım
SELECT infra.gen_random_uuid();
```

### Idempotency Zorunluluğu
Finansal işlemlerde `idempotency.processed_requests` kontrolü içeren SQL blokları üretilmelidir.

### Outbox Pattern
Plugin'lerden Core'a veri gönderimi için `plugin_internal.outbox_events` tablosu kullanılmalıdır.

### Kod Yazım Standartları

**Tablo Script'leri:**
- Header: 45 char `-- =====` ile başlık bloğu
- Başlık içeriği: Türkçe (`-- Tablo: schema.table_name`, `-- Açıklama: ...`)
- Field açıklamaları: Satır sonu Türkçe comment (`-- Türkçe açıklama`)
- COMMENT ON TABLE: İngilizce

**Fonksiyon Script'leri:**
- Header: 64 char `-- ====` ile başlık bloğu
- Başlık içeriği: Türkçe (`-- FUNCTION_NAME_UPPERCASE: Açıklama`)
- Parametre/kod açıklamaları: Türkçe
- COMMENT ON FUNCTION: İngilizce

**Genel Kurallar:**
- Değişken/field isimleri: snake_case, İngilizce
- Satır içi comment'ler: Türkçe
- COMMENT ON: Sadece TABLE ve FUNCTION için (field'lar için KULLANILMAZ ❌)
- Metadata dili: İngilizce
- Error mesajları: İngilizce key'ler (`error.client.not-found`)

## Notlar
- 5 fiziksel veritabanı: core (16 schema), game, finance, bonus, client (30 schema)
- Core DB eski core_log, core_audit, core_report DB'lerini schema olarak içerir
- Game DB eski game_log DB'sini schema olarak içerir
- Finance DB eski finance_log DB'sini schema olarak içerir
- Her client için tek birleşik DB klonlanır (client template'den, 30 schema)
- Log tablolarında günlük partitioning kullanılıyor
- Audit kayıtları uzun süreli saklanır (compliance)
- KYC seviye geçişleri jurisdiction'a göre belirlenir
- PEP/Sanctions taramaları periyodik olarak tekrarlanır
- Outbox pattern kullanılıyor (transactional messaging)
