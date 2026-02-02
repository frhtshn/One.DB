# Nucleo.DB - Claude Context

## Proje Bilgisi
**Nucleo**, online gaming/bahis sektörü için multi-tenant (whitelabel) platform.
Bu repo (`Nucleo.DB`) veritabanı katmanını içerir.

## Çalışma Dizini
```
C:\Projects\Github\Nucleo\Nucleo.DB
```

## Teknoloji
- PostgreSQL 16
- Dapper ORM ile kullanılıyor
- .NET 10 backend (Nucleo.Platform)

## Veritabanı Mimarisi (14 DB)

### Paylaşılan (Shared)
| DB | Amaç |
|----|------|
| `core` | Platform config, tenant registry, kullanıcılar, roller, kataloglar |
| `core_log` | Platform operasyonel logları (30-90 gün) |
| `core_audit` | Platform denetim kayıtları (5-10 yıl) |
| `core_report` | Platform raporlama/analitik |

### Gateway (Shared Integrations)
| DB | Amaç |
|----|------|
| `game` | Oyun provider entegrasyon state |
| `game_log` | Oyun transaction logları (7-14 gün) |
| `finance` | Ödeme provider entegrasyon state |
| `finance_log` | Ödeme logları (14-30 gün) |
| `bonus` | Bonus kuralları ve konfigürasyonları |

### Tenant (İzole - Her Marka İçin Ayrı)
| DB | Amaç |
|----|------|
| `tenant` | Oyuncu, cüzdan, işlemler, bahisler |
| `tenant_log` | Tenant operasyonel logları (30-90 gün) |
| `tenant_audit` | Tenant denetim kayıtları (5-10 yıl) |
| `tenant_report` | Tenant raporlama/analitik |
| `tenant_affiliate` | Affiliate takip ve komisyonlar |

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

### Core DB (Paylaşılan Katalog)
```
catalog.jurisdictions              - Lisans otoriteleri (MGA, UKGC, GGL...)
catalog.kyc_policies               - Jurisdiction bazlı KYC kuralları
catalog.kyc_document_requirements  - Gerekli belge tipleri
catalog.kyc_level_requirements     - KYC seviye geçiş kuralları (BASIC→STANDARD→ENHANCED)
catalog.responsible_gaming_policies - Sorumlu oyun politikaları
core.tenant_jurisdictions          - Tenant-Jurisdiction bağlantısı (M:N)
```

### Tenant DB (İzole - KYC Schema)
```
kyc.player_documents          - Yüklenen belgeler
kyc.player_kyc_cases          - KYC vakaları
kyc.player_kyc_workflows      - Workflow geçmişi
kyc.player_kyc_provider_logs  - External provider logları (Sumsub, Onfido)
kyc.player_limits             - Oyuncu limitleri (deposit, loss, session)
kyc.player_restrictions       - Cooling off / Self exclusion
kyc.player_limit_history      - Limit değişiklik audit
kyc.player_jurisdiction       - Oyuncunun tabi olduğu jurisdiction
kyc.player_screening_results  - PEP/Sanctions tarama sonuçları
kyc.player_risk_assessments   - Risk değerlendirme detayları
kyc.player_aml_flags          - AML uyarıları ve SAR'lar
```

## Notlar
- Her tenant için ayrı DB klonlanır (tenant template'den)
- Log tablolarında günlük partitioning kullanılıyor
- Audit kayıtları uzun süreli saklanır (compliance)
- KYC seviye geçişleri jurisdiction'a göre belirlenir
- PEP/Sanctions taramaları periyodik olarak tekrarlanır
