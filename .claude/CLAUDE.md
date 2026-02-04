# Nucleo.DB - Claude Context

## Platform Özeti

**Nucleo**, online gaming/betting platformları için tasarlanmış, **core-centric mimariye** sahip, **multi-tenant (whitelabel)** destekli, yatayda ölçeklenebilir bir orchestration platformudur.

> Nucleo ismi, Latince "Nucleus" (çekirdek) kelimesinden gelir ve sistemin değişmeyen merkezini temsil eder.

### Mimari Prensipler
| Prensip | Açıklama |
|---------|----------|
| **Core-Centric Design** | Değişmeyen merkezi çekirdek |
| **Gateway & Plugin Oriented** | İzole entegrasyon katmanları |
| **Horizontal Scalability** | Yeni gateway ve plugin'lerle yatay büyüme |

### Platform Bileşenleri
| Bileşen | Sorumluluk |
|---------|------------|
| `Nucleo.Orchestrator` | Routing, servis yaşam döngüsü, orkestrasyon |
| `Nucleo.Core` | Domain kuralları ve merkezi veri modeli |
| `Nucleo.Gateway.*` | Game, Finance gibi provider entegrasyonları |
| `Nucleo.Plugins.*` | Bonus, Affiliate, Fraud gibi genişletilebilir servisler |

### Veritabanı Katmanları
| Katman | Veritabanları | Paylaşım |
|--------|---------------|----------|
| **Core Layer** | core, core_log, core_audit, core_report | Tüm tenantlar (paylaşımlı) |
| **Gateway Layer** | game, game_log, finance, finance_log | Tüm tenantlar (paylaşımlı) |
| **Plugin Layer** | bonus | Tüm tenantlar (paylaşımlı) |
| **Tenant Layer** | tenant_XXX, tenant_log_XXX, tenant_audit_XXX, tenant_report_XXX | İzole (her tenant'a özel) |
| **Tenant Plugin** | tenant_affiliate_XXX | İzole (her tenant'a özel) |

### Multi-Tenant Strateji
- Her tenant için **ayrı veritabanı** oluşturulur
- **Cross-DB join yapılmaz**
- Tenant verileri **tamamen izole**
- Paylaşılan veriler **sadece Core DB'de**

### Log – Audit – Business Ayrımı
| Tip | Amaç | Saklama |
|-----|------|---------|
| **Log** | Teknik, operasyonel | Kısa (30-90 gün), partition'lı |
| **Audit** | Regülasyon, denetim | Uzun (5-10 yıl) |
| **Business** | Operasyonel veriler | Sınırsız |

---

## Bu Repo (Nucleo.DB)

Bu repo veritabanı katmanını içerir: şemalar, tablolar, fonksiyonlar, triggerlar ve deploy scriptleri.

## Çalışma Dizini
```
C:\Projects\Git\nucleoDb
```

## Teknoloji
- PostgreSQL 16
- Dapper ORM ile kullanılıyor
- .NET 10 backend (Nucleo.Platform)

## Veritabanı Mimarisi

### 1. MainDB (CoreDB) - Paylaşılan Platform
| Şema | Alt Kategori | Tablolar |
|------|--------------|----------|
| `billing` | provider | provider_commission_rates, provider_commission_tiers, provider_invoice_items, provider_invoices, provider_payments, provider_settlement_tenants, provider_settlements |
| `billing` | tenant | tenant_billing_periods, tenant_commission_aggregates, tenant_commission_plan_tiers, tenant_commission_plans, tenant_commission_rate_tiers, tenant_commission_rates, tenant_commissions, tenant_invoice_items, tenant_invoice_payments, tenant_invoices |
| `catalog` | compliance | jurisdictions, kyc_document_requirements, kyc_level_requirements, kyc_policies, responsible_gaming_policies |
| `catalog` | game | games |
| `catalog` | localization | localization_keys, localization_values |
| `catalog` | payment | payment_methods |
| `catalog` | provider | provider_settings, provider_types, providers |
| `catalog` | reference | countries, currencies, languages, timezones |
| `catalog` | transaction | operation_types, transaction_types |
| `catalog` | uikit | navigation_template_items, navigation_templates, themes, ui_positions, widgets |
| `core` | configuration | tenant_currencies, tenant_data_policies, tenant_jurisdictions, tenant_languages, tenant_settings |
| `core` | integration | tenant_games, tenant_payment_methods, tenant_provider_limits, tenant_providers |
| `core` | organization | companies, tenants |
| `outbox` | - | outbox_messages |
| `presentation` | backoffice | contexts, menu_groups, menus, pages, submenus, tabs |
| `presentation` | frontend | tenant_layouts, tenant_navigation, tenant_themes |
| `routing` | - | callback_routes, provider_callbacks, provider_endpoints |
| `security` | identity | user_sessions, users |
| `security` | rbac | permissions, role_permissions, roles, user_allowed_tenants, user_permission_overrides, user_roles |
| `security` | secrets | secrets_provider, secrets_tenant |

### 2. ClientDB (TenantDB) - Her Marka İçin Ayrı
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

### Log/Audit/Report Veritabanları
| DB | Amaç | Retention |
|----|------|-----------|
| `core_log` | Platform operasyonel logları | 30-90 gün |
| `core_audit` | Platform denetim kayıtları | 5-10 yıl |
| `core_report` | Platform raporlama/analitik | - |
| `tenant_log` | Tenant operasyonel logları | 30-90 gün |
| `tenant_audit` | Tenant denetim kayıtları | 5-10 yıl |
| `tenant_report` | Tenant raporlama/analitik | - |
| `tenant_affiliate` | Affiliate takip ve komisyonlar | - |
| `game_log` | Oyun transaction logları | 7-14 gün |
| `finance_log` | Ödeme logları | 14-30 gün |

## Klasör Yapısı
```
Nucleo.DB/
├── core/                 # Core DB şeması
│   ├── tables/           # Tablolar (catalog, core, presentation, security, routing, billing)
│   ├── functions/        # Stored procedures
│   ├── triggers/         # Triggerlar
│   ├── constraints/      # FK ve check constraints
│   ├── indexes/          # Performans indexleri
│   └── data/             # Seed data
├── tenant/               # Tenant template DB
├── bonus/                # Bonus sistemi
├── core_log/, core_audit/, core_report/
├── tenant_log/, tenant_audit/, tenant_report/, tenant_affiliate/
├── game/, game_log/
├── finance/, finance_log/
├── deploy_*.sql          # Her DB için deploy scripti
├── create_dbs.sql        # DB oluşturma
└── master_deploy.sql     # Tüm deploy
```

## Deploy Sırası
1. `create_dbs.sql` - Veritabanlarını oluştur
2. `deploy_core.sql` - Core platform
3. `deploy_core_log.sql`, `deploy_core_audit.sql`, `deploy_core_report.sql`
4. `deploy_game.sql`, `deploy_game_log.sql`
5. `deploy_finance.sql`, `deploy_finance_log.sql`
6. `deploy_bonus.sql`
7. `deploy_tenant.sql` - Tenant template
8. `deploy_tenant_log.sql`, `deploy_tenant_audit.sql`, `deploy_tenant_report.sql`
9. `deploy_tenant_affiliate.sql`

## Önemli Dokümantasyon
- `.docs/PROJECT_OVERVIEW.md` - Mimari genel bakış
- `.docs/DATABASE_ARCHITECTURE.md` - Şema detayları
- `.docs/DATABASE_FUNCTIONS.md` - Stored procedure referansı
- `.docs/LOGSTRATEGY.md` - Log/audit retention politikaları

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
| `tenant_jurisdictions` | Tenant-Jurisdiction bağlantısı (M:N) |

### ClientDB - kyc şeması (Her Tenant İçin)
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

### Tenant Audit DB (Compliance - 5-10 yıl)
| Tablo | Açıklama |
|-------|----------|
| `kyc_audit.player_screening_results` | PEP/Sanctions tarama sonuçları |
| `kyc_audit.player_risk_assessments` | Risk değerlendirme geçmişi |

### Tenant Log DB (Operasyonel - 90+ gün)
| Tablo | Açıklama |
|-------|----------|
| `kyc_log.player_kyc_provider_logs` | External provider API logları (Sumsub, Onfido) |

## Backoffice Dropdown (Lookup) Fonksiyonları

### IDOR Korumalı (p_caller_id gerekli)
| Fonksiyon | Açıklama |
|-----------|----------|
| `core.company_lookup(p_caller_id)` | Platform Admin tümünü görür, diğerleri sadece kendi company'sini |
| `core.tenant_lookup(p_caller_id, p_company_id?)` | Platform Admin tümünü görür, CompanyAdmin kendi company tenant'larını, diğerleri sadece user_allowed_tenants |

### IDOR Korumalı Catalog (p_caller_id gerekli)
| Fonksiyon | Yetki | Açıklama |
|-----------|-------|----------|
| `catalog.provider_type_lookup(p_caller_id)` | SuperAdmin | Provider tipi listesi |
| `catalog.provider_lookup(p_caller_id, p_type_id?)` | SuperAdmin | Provider listesi |
| `catalog.jurisdiction_lookup(p_caller_id)` | Platform Admin | Jurisdiction listesi |
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

### Tenant Players

| Tablo | Açıklama |
|-------|----------|
| `auth.player_credentials` | `last_password_change_at`, `require_password_change` alanları |
| `auth.player_password_history` | Son N şifre geçmişi |
| `core.tenant_settings` | Password policy (Security kategorisi, tenant bazlı) |

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
tenantadmin   : level 70,  is_platform_role = FALSE
moderator     : level 60,  is_platform_role = FALSE
editor        : level 50,  is_platform_role = FALSE
operator      : level 40,  is_platform_role = FALSE
user          : level 10,  is_platform_role = FALSE
```

### Güvenlik Kuralları
1. **Level Kontrolü:** Kullanıcı sadece kendi level'ının ALTINDA olan rolleri atayabilir
2. **Tenant Scope:** TenantAdmin ve altı sadece `security.user_allowed_tenants` tablosunda yetkili olduğu tenant'larda işlem yapabilir
3. **Company Scope:** CompanyAdmin sadece kendi company'sindeki tenant'larda işlem yapabilir

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

## Notlar
- Her tenant için ayrı ClientDB klonlanır (tenant template'den)
- Log tablolarında günlük partitioning kullanılıyor
- Audit kayıtları uzun süreli saklanır (compliance)
- KYC seviye geçişleri jurisdiction'a göre belirlenir
- PEP/Sanctions taramaları periyodik olarak tekrarlanır
- Outbox pattern kullanılıyor (transactional messaging)
