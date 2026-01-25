---
description: Yeni şema eklerken deploy script ve dokümantasyonu güncelle
---

# Yeni Şema Ekleme Kuralı

## Ne Zaman Uygulanır?

Kullanıcı yeni bir şema oluşturduğunda veya oluşturulmasını istediğinde.

## Adımlar

### 1. Deploy Script'e Şema Ekle

İlgili deploy script'in başındaki şema bloğuna ekle:

**Core şemaları için** → `deploy_core.sql`

```sql
-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS catalog;
CREATE SCHEMA IF NOT EXISTS core;
...
CREATE SCHEMA IF NOT EXISTS yeni_sema;  -- EKLENDİ
```

**Tenant şemaları için** → `deploy_tenant.sql`

```sql
-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS profile;
...
CREATE SCHEMA IF NOT EXISTS yeni_sema;  -- EKLENDİ
```

### 2. Tablo Klasörü Oluştur

Yeni şema için tablo klasörü oluştur:

- Core: `core/tables/<yeni_sema>/`
- Tenant: `tenant/tables/<yeni_sema>/`

### 3. Dokümantasyonu Güncelle

**DATABASE_STRUCTURE.md:**

- Şema listesi tablosuna yeni satır ekle
- Yeni şema için bölüm oluştur (örn: `### 3.X yeni_sema Şeması`)
- Şemanın amacını açıkla

**DB_ARCHITECTURE.md:**

- İlgili katmandaki (Core/Gateway/Tenant) tablo listesine şema satırları ekle
- Veritabanı Özet Matrisi'ni gerekirse güncelle

## Kontrol Listesi

- [ ] Deploy script'e `CREATE SCHEMA` eklendi
- [ ] Tablo klasörü oluşturuldu (gerekirse)
- [ ] DATABASE_STRUCTURE.md güncellendi
- [ ] DB_ARCHITECTURE.md güncellendi
