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

### 4. Dokümantasyonu Güncelle

`.docs/DATABASE_ARCHITECTURE.md` dosyasında:

- Bölüm 3 (Özet Matrisi) tablosuna yeni veritabanını ekle
- İlgili katmana (Core/Gateway/Tenant) yeni bölüm ekle
- Bölüm 2 (Diyagram) güncelle (gerekirse)

## Kontrol Listesi

- [ ] create_dbs.sql güncellendi
- [ ] Deploy script oluşturuldu (gerekirse)
- [ ] Klasör yapısı oluşturuldu
- [ ] `.docs/DATABASE_ARCHITECTURE.md` güncellendi
