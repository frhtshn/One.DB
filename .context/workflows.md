# OneDB - Workflow Rehberleri

Bu dosya, veritabanı geliştirme süreçlerinde izlenmesi gereken adımları içerir.

---

## Yeni Veritabanı Ekleme

### Ne Zaman Uygulanır?
Yeni bir veritabanı oluşturulduğunda veya oluşturulması istendiğinde.

### Adımlar

1. **create_dbs.sql Güncelle**
   ```sql
   SELECT
     'CREATE DATABASE yeni_db'
   WHERE NOT EXISTS (
     SELECT 1 FROM pg_database WHERE datname = 'yeni_db'
   )
   \gexec
   ```

2. **Deploy Script Oluştur** (Gerekirse)
   - `deploy_<db_adı>.sql` dosyası oluştur
   - Şema ve extension tanımlarını ekle

3. **Klasör Yapısı Oluştur**
   ```
   <db_adı>/
   ├── tables/
   ├── functions/
   ├── indexes/
   └── views/
   ```

4. **Dokümantasyonu Güncelle**
   - `.docs/DATABASE_ARCHITECTURE.md` → Bölüm 3 (Özet Matrisi) ve ilgili katmana yeni bölüm ekle

---

## Yeni Şema Ekleme

### Ne Zaman Uygulanır?
Yeni bir şema oluşturulduğunda.

### Adımlar

1. **Deploy Script'e Şema Ekle**
   - Core şemaları → `deploy_core.sql`
   - Client şemaları (iş + log + audit + report + affiliate) → `deploy_client.sql`
   ```sql
   CREATE SCHEMA IF NOT EXISTS yeni_sema;
   ```

2. **Tablo Klasörü Oluştur**
   - Core: `core/tables/<yeni_sema>/`
   - Client: `client/tables/<yeni_sema>/`

3. **Dokümantasyonu Güncelle**
   - `.docs/DATABASE_ARCHITECTURE.md` dosyasına yeni şema bölümü ekle

---

## Yeni Tablo Ekleme

### Ne Zaman Uygulanır?
Yeni bir SQL tablo dosyası eklendiğinde.

### Adımlar

1. **Tablo SQL Dosyasını Oluştur**
   - Core tabloları: `core/tables/<şema>/<tablo_adı>.sql`
   - Client tabloları: `client/tables/<şema>/<tablo_adı>.sql`
   - Diğer: `<db>/tables/<tablo_adı>.sql`

2. **Deploy Script'i Güncelle**
   - `\i` satırını ilgili şema bölümüne alfabetik/mantıksal sıraya göre ekle
   ```sql
   \i core/tables/<şema>/<tablo_adı>.sql
   ```

3. **Dokümantasyonu Güncelle**
   - `.docs/DATABASE_ARCHITECTURE.md` → İlgili şema bölümüne tablo satırı ekle

---

## Yeni Fonksiyon Ekleme

### Ne Zaman Uygulanır?
Yeni bir stored procedure veya veritabanı fonksiyonu eklendiğinde.

### Adımlar

1. **Klasör Yapısını Belirle**
   - Kalıp: `<db_folder>/functions/<schema_name>/<submodule>/`
   - Örnekler:
     - `core/functions/security/auth/`
     - `client/functions/game/logic/`

2. **SQL Dosyası Oluştur**
   - Dosya adı: `snake_case` formatında fonksiyon adı (örn: `user_authenticate.sql`)
   - İçerik:
     - Açıklayıcı header comments
     - `DROP FUNCTION IF EXISTS ...`
     - `CREATE OR REPLACE FUNCTION ...`
     - `COMMENT ON FUNCTION ...`

3. **Deploy Script'e Ekle**
   - İlgili deploy dosyasının `FUNCTIONS` bölümüne ekle
   - Bağımlılık sırasına dikkat et (Helper fonksiyonlar önce)

4. **Index Kontrolü**
   - Fonksiyon içindeki `WHERE`, `JOIN`, `ORDER BY` kolonlarını analiz et
   - Gerekirse `<db_folder>/indexes/<schema>.sql` dosyasına index ekle
   - İsimlendirme: `idx_<table_name>_<column_names>`

---

## Yeni Trigger Ekleme

### Ne Zaman Uygulanır?
Bir tabloya trigger eklendiğinde.

### Adımlar

1. **Trigger Fonksiyonu** (Opsiyonel)
   - Generic `update_updated_at` dışında özel fonksiyon gerekiyorsa:
   - `core/functions/triggers/` veya `core/functions/common/` altına ekle

2. **Trigger Tanım Dosyası**
   - Dosya yolu: `core/triggers/<schema_name>_triggers.sql`
   - İçerik:
     ```sql
     DROP TRIGGER IF EXISTS trigger_<table>_updated_at ON <schema>.<table>;
     CREATE TRIGGER trigger_<table>_updated_at
         BEFORE UPDATE ON <schema>.<table>
         FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();
     ```

3. **Deploy Script'e Ekle**
   - `deploy_core.sql` içinde `TRIGGERS` bölümüne ekle

---

## Fonksiyon Dokümantasyonu Güncelleme

### Ne Zaman Uygulanır?
Fonksiyon/trigger ekleme, değiştirme veya silme sonrasında dokümantasyonun güncellenmesi gerektiğinde.

### Adımlar

1. **Tarama**
   - `*/functions` ve `*/triggers` klasörlerini tara
   - `.sql` dosyalarından şema, fonksiyon adı, parametreler ve açıklamaları çıkar

2. **Güncelleme**
   - İlgili fonksiyon dökümanını güncelle:
     - Core DB (iş + log + audit + report schema'ları) → `.docs/FUNCTIONS_CORE.md`
     - Client (birleşik DB: iş + log + audit + report + affiliate schema'ları) → `.docs/FUNCTIONS_CLIENT.md`
     - Game/finance/bonus → `.docs/FUNCTIONS_GATEWAY.md`
   - Format:
     ```markdown
     ## Core Veritabanı
     ### Security Şeması
     - **`login(username, password)`**: Kullanıcı girişi yapar.
     ```

3. **Alternatif: Script Kullan**
   - `.context/scripts/scan_functions.py` scripti çalıştırılabilir:
     ```bash
     python .context/scripts/scan_functions.py
     ```

---

## Dokümantasyon Güncelleme (Genel)

### Ne Zaman Uygulanır?
- Tablo, şema veya veritabanı ekleme/silme/değiştirme
- Deploy scriptlerinde değişiklik
- Extension, view veya function ekleme
- Multi-client yapısı, partition veya retention politikası değişikliği

### Güncellenecek Dosya
`.docs/DATABASE_ARCHITECTURE.md`

### Bölümler
- Core tabloları → Bölüm 4
- Gateway tabloları → Bölüm 5
- Client tabloları → Bölüm 6
- Log/Audit/Report → Bölüm 7

### Tablo Ekleme Formatı
```markdown
| `tablo_adi` | Tablonun kısa açıklaması |
```

### Şema Ekleme Formatı
```markdown
### X.X yeni_sema Şeması

Şemanın amacı hakkında kısa açıklama.

| Tablo     | Açıklama                |
| --------- | ----------------------- |
| `tablo_1` | İlk tablonun açıklaması |
```

---

## Deploy Script Yapısı

Deploy scriptleri belirli bir sırayla düzenlenir. Yeni öğeler ilgili bölüme eklenmelidir.

### Bölüm Sırası (deploy_core.sql örneği)

```
1. SCHEMAS         → CREATE SCHEMA IF NOT EXISTS ...
2. EXTENSIONS      → CREATE EXTENSION IF NOT EXISTS ... WITH SCHEMA infra
3. TABLES          → \i <db>/tables/<şema>/<kategori>/<tablo>.sql
4. FUNCTIONS       → \i <db>/functions/<şema>/<kategori>/<fonksiyon>.sql
5. INDEXES         → \i <db>/indexes/<şema>.sql
6. CONSTRAINTS     → \i <db>/constraints/<şema>.sql
7. TRIGGERS        → \i <db>/triggers/<şema>_triggers.sql
8. SEED DATA       → \i <db>/data/seed_<data>.sql
```

### Deploy Script Eşleştirmesi

| Veritabanı | Deploy Script | Klasör | Not |
|------------|---------------|--------|-----|
| core (16 schema: iş + log + audit + report) | `deploy_core.sql` | `core/` | Eski core_log, core_audit, core_report DB'leri bu DB'ye birleştirildi |
| game (iş + log) | `deploy_game.sql` | `game/` | Eski game_log DB'si bu DB'ye birleştirildi |
| finance (iş + log) | `deploy_finance.sql` | `finance/` | Eski finance_log DB'si bu DB'ye birleştirildi |
| bonus | `deploy_bonus.sql` | `bonus/` | |
| client (birleşik, 30 schema) | `deploy_client.sql` | `client/` | |

---

## Hızlı Referans

Detaylı format ve şablonlar için: [docs-guide.md](docs-guide.md)

### Değişiklik → Güncellenmesi Gereken Dosyalar

| Değişiklik | Deploy Script | DATABASE_ARCHITECTURE.md | DATABASE_FUNCTIONS.md |
|------------|---------------|--------------------------|----------------------|
| Tablo ekleme | ✅ | ✅ | ❌ |
| Şema ekleme | ✅ | ✅ | ❌ |
| Fonksiyon ekleme | ✅ | ❌ | ✅ (FUNCTIONS_*.md) |
| Trigger ekleme | ✅ | ❌ | ✅ (FUNCTIONS_*.md) |
| Index ekleme | ✅ | ❌ | ❌ |
| FK/Constraint ekleme | ✅ | ❌ | ❌ |
| Veritabanı ekleme | `create_dbs.sql` | ✅ | ❌ |
