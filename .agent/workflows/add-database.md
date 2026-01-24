---
description: Yeni veritabanı eklerken create_dbs.sql ve dokümantasyonu güncelle
---

# Yeni Veritabanı Ekleme Kuralı

## Ne Zaman Uygulanır?

Kullanıcı yeni bir veritabanı oluşturduğunda veya oluşturulmasını istediğinde.

## Adımlar

### 1. create_dbs.sql Güncelle

İlgili kategoriye veritabanı oluşturma bloğu ekle:

```sql
-- Yeni veritabanı açıklaması
SELECT
  'CREATE DATABASE yeni_db'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'yeni_db'
)
\gexec
```

### 2. Deploy Script Oluştur (Gerekirse)

Eğer veritabanının kendi şemaları ve tabloları olacaksa:

- `deploy_<db_adı>.sql` dosyası oluştur
- Şema ve extension tanımlarını ekle

### 3. Klasör Yapısı Oluştur

```
<db_adı>/
├── tables/
├── functions/
├── indexes/
└── views/
```

### 4. DATABASE_STRUCTURE.md Güncelle

- Bölüm 1'deki genel özet tablosuna yeni veritabanını ekle
- Yeni veritabanı için bölüm oluştur
- Amacı, partition stratejisi ve retention bilgilerini ekle

## Kontrol Listesi

- [ ] create_dbs.sql güncellendi
- [ ] Deploy script oluşturuldu (gerekirse)
- [ ] Klasör yapısı oluşturuldu
- [ ] DATABASE_STRUCTURE.md güncellendi
