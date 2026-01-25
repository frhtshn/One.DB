---
description: Yeni tablo eklerken deploy script ve dokümantasyonu güncelle
---

# Yeni Tablo Ekleme Kuralı

## Ne Zaman Uygulanır?

Kullanıcı yeni bir SQL tablo dosyası eklediğinde veya eklenmesini istediğinde.

## Adımlar

### 1. Tablo SQL Dosyasını Oluştur

Dosya konumu belirle:

- Core tabloları: `core/tables/<şema>/<tablo_adı>.sql`
- Tenant tabloları: `tenant/tables/<şema>/<tablo_adı>.sql`
- Diğer veritabanları: `<db>/tables/<tablo_adı>.sql`

### 2. Deploy Script'i Güncelle

Tablonun ait olduğu veritabanına göre ilgili deploy script'e `\i` satırı ekle:

**Core tabloları için** → `deploy_core.sql`

```sql
\i core/tables/<şema>/<tablo_adı>.sql
```

**Tenant tabloları için** → `deploy_tenant.sql`

```sql
\i tenant/tables/<şema>/<tablo_adı>.sql
```

> ⚠️ `\i` satırını ilgili şema bölümüne, alfabetik veya mantıksal sıraya göre ekle.

### 3. Dokümantasyonu Güncelle

`/update-docs` kuralını uygula:

- `DATABASE_STRUCTURE.md`: İlgili şema bölümüne tablo satırı ekle
- `DB_ARCHITECTURE.md`: İlgili katman/şema tablosuna satır ekle

## Kontrol Listesi

- [ ] SQL dosyası oluşturuldu
- [ ] Deploy script güncellendi
- [ ] DATABASE_STRUCTURE.md güncellendi
- [ ] DB_ARCHITECTURE.md güncellendi
