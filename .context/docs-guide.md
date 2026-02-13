# Dokümantasyon ve Deploy Script Güncelleme Rehberi

Bu rehber, veritabanı değişikliklerinde hangi dosyaların güncellenmesi gerektiğini tanımlar.

---

## Dokümantasyon Dosyaları

### Mimari Dökümanlar
| Dosya | Amaç | Ne Zaman Güncellenir |
|-------|------|---------------------|
| `.docs/PROJECT_OVERVIEW.md` | Mimari genel bakış | Büyük yapısal değişiklikler |
| `.docs/DATABASE_ARCHITECTURE.md` | Şema ve tablo yapısı | Tablo/şema ekleme, silme, değiştirme |
| `.docs/PARTITION_ARCHITECTURE.md` | Partition yapısı ve yönetimi | Partition tabloları veya retention değişiklikleri |
| `.docs/LOGSTRATEGY.md` | Retention politikaları | Log/audit tabloları veya politika değişiklikleri |

### Fonksiyon Referansları
| Dosya | Amaç | Ne Zaman Güncellenir |
|-------|------|---------------------|
| `.docs/DATABASE_FUNCTIONS.md` | Fonksiyon referansı (index) | Fonksiyon/trigger ekleme, silme (yönlendirme dosyası) |
| `.docs/FUNCTIONS_CORE.md` | Core katmanı fonksiyonları | Core, core_log, core_audit, core_report fonksiyon değişiklikleri |
| `.docs/FUNCTIONS_TENANT.md` | Tenant katmanı fonksiyonları | Tenant, tenant_log, tenant_audit, tenant_report, tenant_affiliate fonksiyon değişiklikleri |
| `.docs/FUNCTIONS_GATEWAY.md` | Gateway & plugin fonksiyonları | Game, finance, bonus fonksiyon değişiklikleri |

---

## Deploy Script Dosyaları

### Core Katmanı
| Dosya | Veritabanı | İçerik |
|-------|------------|--------|
| `deploy_core.sql` | core | Şemalar, extensionlar, catalog/core/presentation/security/billing/routing tabloları, fonksiyonlar, triggerlar |
| `deploy_core_log.sql` | core_log | Core operasyonel log tabloları |
| `deploy_core_audit.sql` | core_audit | Core denetim kayıt tabloları |
| `deploy_core_report.sql` | core_report | Core raporlama/BI tabloları |
| `deploy_core_staging.sql` | core (staging) | Staging ortamı için core deploy |
| `deploy_core_production.sql` | core (production) | Production ortamı için core deploy |

### Gateway Katmanı
| Dosya | Veritabanı | İçerik |
|-------|------------|--------|
| `deploy_game.sql` | game | Game gateway entegrasyon tabloları |
| `deploy_game_log.sql` | game_log | Game gateway log tabloları |
| `deploy_finance.sql` | finance | Finance gateway entegrasyon tabloları |
| `deploy_finance_log.sql` | finance_log | Finance gateway log tabloları |

### Plugin Katmanı
| Dosya | Veritabanı | İçerik |
|-------|------------|--------|
| `deploy_bonus.sql` | bonus | Bonus plugin tabloları |

### Tenant Katmanı
| Dosya | Veritabanı | İçerik |
|-------|------------|--------|
| `deploy_tenant.sql` | tenant | Tenant şablon tabloları ve fonksiyonları |
| `deploy_tenant_log.sql` | tenant_log | Tenant operasyonel log tabloları |
| `deploy_tenant_audit.sql` | tenant_audit | Tenant denetim kayıt tabloları |
| `deploy_tenant_report.sql` | tenant_report | Tenant raporlama tabloları |
| `deploy_tenant_affiliate.sql` | tenant_affiliate | Affiliate tracking ve komisyon tabloları |

---

## Değişiklik Türlerine Göre Güncelleme Matrisi

### Tablo Ekleme

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. SQL dosyası oluştur: <db>/tables/<şema>/<tablo>.sql          │
│ 2. Deploy script güncelle: deploy_<db>.sql                      │
│ 3. Dokümantasyon: .docs/DATABASE_ARCHITECTURE.md                │
└─────────────────────────────────────────────────────────────────┘
```

**Deploy Script Format:**
```sql
-- <Kategori> (<Açıklama>)
\i <db>/tables/<şema>/<tablo>.sql
```

**Dokümantasyon Format:**
```markdown
| `tablo_adi` | Tablonun kısa açıklaması |
```

---

### Şema Ekleme

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Deploy script'in başına CREATE SCHEMA ekle                   │
│ 2. Tablo klasörü oluştur: <db>/tables/<yeni_şema>/              │
│ 3. Dokümantasyon: .docs/DATABASE_ARCHITECTURE.md                │
└─────────────────────────────────────────────────────────────────┘
```

**Deploy Script Format:**
```sql
CREATE SCHEMA IF NOT EXISTS yeni_sema;
COMMENT ON SCHEMA yeni_sema IS 'Şema açıklaması';
```

**Dokümantasyon Format:**
İlgili veritabanı bölümünde:
```markdown
### X.X yeni_sema Şeması

Şemanın amacı.

| Tablo | Açıklama |
|-------|----------|
| `tablo_1` | Açıklama |
```

---

### Fonksiyon Ekleme

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. SQL dosyası: <db>/functions/<şema>/<kategori>/<fonksiyon>.sql│
│ 2. Deploy script: FUNCTIONS bölümüne \i satırı ekle             │
│ 3. Index kontrolü: Gerekirse <db>/indexes/<şema>.sql güncelle   │
│ 4. Dokümantasyon: İlgili FUNCTIONS_*.md dosyasını güncelle      │
└─────────────────────────────────────────────────────────────────┘
```

**Hangi Döküman?**
- Core/core_log/core_audit/core_report → `.docs/FUNCTIONS_CORE.md`
- Tenant/tenant_log/tenant_audit/tenant_report/tenant_affiliate → `.docs/FUNCTIONS_TENANT.md`
- Game/game_log/finance/finance_log/bonus → `.docs/FUNCTIONS_GATEWAY.md`

**Fonksiyon Dosya Şablonu:**
```sql
-- =============================================================================
-- Fonksiyon: schema.function_name
-- Açıklama: Fonksiyonun amacı
-- =============================================================================

DROP FUNCTION IF EXISTS schema.function_name;

CREATE OR REPLACE FUNCTION schema.function_name(
    p_param1 TYPE,
    p_param2 TYPE DEFAULT NULL
)
RETURNS RETURN_TYPE
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Implementation
END;
$$;

COMMENT ON FUNCTION schema.function_name IS 'Fonksiyon açıklaması';
```

**Dokümantasyon Format:**
```markdown
- **`function_name(p_param1, p_param2)`**: Fonksiyon açıklaması.
```

---

### Trigger Ekleme

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Trigger fonksiyonu: <db>/functions/triggers/ (gerekirse)     │
│ 2. Trigger tanımı: <db>/triggers/<şema>_triggers.sql            │
│ 3. Deploy script: TRIGGERS bölümüne ekle                        │
│ 4. Dokümantasyon: İlgili FUNCTIONS_*.md dosyasını güncelle      │
└─────────────────────────────────────────────────────────────────┘
```

**Trigger Tanım Format:**
```sql
-- <Tablo Adı>
DROP TRIGGER IF EXISTS trigger_<tablo>_<event> ON <şema>.<tablo>;
CREATE TRIGGER trigger_<tablo>_<event>
    BEFORE UPDATE ON <şema>.<tablo>
    FOR EACH ROW EXECUTE FUNCTION <şema>.trigger_function();
```

---

### Index Ekleme

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Index dosyası: <db>/indexes/<şema>.sql                       │
│ 2. Deploy script: INDEXES bölümüne ekle (varsa)                 │
└─────────────────────────────────────────────────────────────────┘
```

**Index Format:**
```sql
-- <tablo>.<kolon> (<kullanım açıklaması>)
CREATE INDEX IF NOT EXISTS idx_<tablo>_<kolon>
    ON <şema>.<tablo> USING btree(<kolon>);
```

---

### Foreign Key / Constraint Ekleme

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Constraint dosyası: <db>/constraints/<şema>.sql              │
│ 2. Deploy script: CONSTRAINTS bölümüne ekle                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## Deploy Script Yapısı (deploy_core.sql Örneği)

```sql
SET client_encoding = 'UTF8';
BEGIN;

-- ═══════════════════════════════════════════════════════════════
-- SCHEMAS
-- ═══════════════════════════════════════════════════════════════
CREATE SCHEMA IF NOT EXISTS catalog;
CREATE SCHEMA IF NOT EXISTS core;
-- ...

-- ═══════════════════════════════════════════════════════════════
-- EXTENSIONS
-- ═══════════════════════════════════════════════════════════════
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA infra;
-- ...

-- ═══════════════════════════════════════════════════════════════
-- TABLES (Şema/Kategori bazlı gruplar)
-- ═══════════════════════════════════════════════════════════════

-- catalog/reference
\i core/tables/catalog/reference/countries.sql
\i core/tables/catalog/reference/currencies.sql

-- catalog/provider
\i core/tables/catalog/provider/provider_types.sql

-- ═══════════════════════════════════════════════════════════════
-- FUNCTIONS (Şema bazlı gruplar)
-- ═══════════════════════════════════════════════════════════════

-- Catalog Functions
\i core/functions/catalog/reference/country_list.sql

-- Security Functions
\i core/functions/security/auth/user_authenticate.sql

-- ═══════════════════════════════════════════════════════════════
-- INDEXES
-- ═══════════════════════════════════════════════════════════════
\i core/indexes/security.sql

-- ═══════════════════════════════════════════════════════════════
-- CONSTRAINTS (FK ve Check)
-- ═══════════════════════════════════════════════════════════════
\i core/constraints/catalog.sql

-- ═══════════════════════════════════════════════════════════════
-- TRIGGERS (En sonda - tablolar ve fonksiyonlar hazır olmalı)
-- ═══════════════════════════════════════════════════════════════
\i core/triggers/security_triggers.sql

-- ═══════════════════════════════════════════════════════════════
-- SEED DATA
-- ═══════════════════════════════════════════════════════════════
\i core/data/seed_countries.sql

COMMIT;
```

---

## DATABASE_ARCHITECTURE.md Yapısı

```markdown
## X. <Veritabanı> Veritabanı

### X.1 Şema Listesi

| Şema | Amaç |
|------|------|
| `şema_adı` | Şema açıklaması |

### X.2 <şema> Şeması

#### <Kategori>

| Tablo | Açıklama |
|-------|----------|
| `tablo_adı` | Tablo açıklaması |
```

---

## Fonksiyon Döküman Yapısı

Fonksiyon referansları 3 ayrı dosyaya bölünmüştür. `DATABASE_FUNCTIONS.md` yönlendirme (index) dosyasıdır.

| Dosya | Kapsam |
|-------|--------|
| `FUNCTIONS_CORE.md` | core, core_log, core_audit, core_report |
| `FUNCTIONS_TENANT.md` | tenant, tenant_log, tenant_audit, tenant_report, tenant_affiliate |
| `FUNCTIONS_GATEWAY.md` | game, game_log, finance, finance_log, bonus |

```markdown
## <Veritabanı> Database

### <Şema> Schema

- **`fonksiyon_adı(parametreler)`**: Fonksiyon açıklaması.

### Triggers

- **`trigger_adı`**: Trigger açıklaması.
```

---

## Otomatik Güncelleme

Fonksiyon dokümantasyonunu otomatik güncellemek için:

```bash
python .context/scripts/scan_functions.py
```

Bu script tüm `*/functions/` ve `*/triggers/` klasörlerini tarar ve fonksiyon dökümanlarını yeniden oluşturur.

---

## Kontrol Listesi

Her değişiklik sonrası kontrol et:

- [ ] SQL dosyası doğru konumda mı?
- [ ] Deploy script güncellendi mi?
- [ ] `.docs/DATABASE_ARCHITECTURE.md` güncellendi mi? (tablo/şema için)
- [ ] İlgili `FUNCTIONS_*.md` güncellendi mi? (fonksiyon/trigger için)
- [ ] Index ihtiyacı değerlendirildi mi?
- [ ] FK/Constraint gerekli mi?
