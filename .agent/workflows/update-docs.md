---
description: Yeni tablo, şema veya veritabanı eklendiğinde dokümantasyonu güncelle
---

# Veritabanı Dokümantasyonu Güncelleme Kuralı

## Ne Zaman Uygulanır?

Bu kural aşağıdaki durumlarda otomatik olarak uygulanmalıdır:

### Tablo Değişiklikleri

1. Proje içinde herhangi bir klasöre yeni SQL tablo dosyası eklendiğinde:
    - `core/`, `core_log/`, `core_audit/`, `core_report/`
    - `tenant/`, `tenant_log/`, `tenant_audit/`, `tenant_report/`
    - `game/`, `game_log/`
    - `finance/`, `finance_log/`
2. Mevcut bir tablo silindiğinde veya yeniden adlandırıldığında

### Yapısal Değişiklikler

3. Yeni şema oluşturulduğunda (`CREATE SCHEMA`)
4. Yeni veritabanı eklendiğinde (`create_dbs.sql` güncellenmesi)
5. Deploy scriptlerine (`deploy_*.sql`) değişiklik yapıldığında
6. Yeni PostgreSQL extension eklendiğinde
7. Yeni view veya function eklendiğinde

### Mimari Değişiklikler

8. Multi-tenant yapısında değişiklik olduğunda
9. Partition stratejisi değiştiğinde
10. Retention politikası güncellendiğinde
11. Yeni bir veritabanı kategorisi eklendiğinde (log, audit, report vb.)

## Güncellenecek Dosyalar

Değişiklik yapıldığında aşağıdaki **her iki dosya** da güncellenmelidir:

| Dosya                         | İçerik                         |
| ----------------------------- | ------------------------------ |
| `.docs/DATABASE_STRUCTURE.md` | Detaylı tablo/şema yapısı      |
| `.docs/DB_ARCHITECTURE.md`    | Mimari döküman (katmanlı yapı) |

## Güncelleme Adımları

### 1. .docs/DATABASE_STRUCTURE.md Güncelleme

1. Değişikliğin türünü belirle (tablo, şema, mimari)
2. İlgili bölümü bul
3. Uygun formatta güncelleme yap:
    - Tablo ekleme: İlgili şema tablosuna satır ekle
    - Şema ekleme: Yeni bölüm oluştur
    - Mimari değişiklik: İlgili açıklama bölümünü güncelle
4. Genel özet tablosunu gerekirse güncelle

### 2. .docs/DB_ARCHITECTURE.md Güncelleme

1. Tablonun ait olduğu katmanı belirle:
    - **Core Katmanı** (Bölüm 2): `core` veritabanı tabloları
    - **Gateway Katmanı** (Bölüm 3): `game`, `finance` veritabanları
    - **Tenant Katmanı** (Bölüm 4): `tenant` veritabanı tabloları
2. İlgili tablo listesine yeni satır ekle
3. View ekleniyorsa "Views" bölümüne ekle
4. Veritabanı Özet Matrisi'ni (Bölüm 5) gerekirse güncelle

## Tablo Ekleme Formatları

### .docs/DATABASE_STRUCTURE.md formatı

```markdown
| `tablo_adi` | Tablonun kısa açıklaması |
```

### .docs/DB_ARCHITECTURE.md formatı

```markdown
| `şema` | `tablo_adi` | Tablonun kısa açıklaması |
```

## Şema Ekleme Formatı

### .docs/DATABASE_STRUCTURE.md

```markdown
### X.X yeni_sema Şeması

Şemanın amacı ve içeriği hakkında kısa açıklama.

| Tablo     | Açıklama                   |
| --------- | -------------------------- |
| `tablo_1` | İlk tablonun açıklaması    |
| `tablo_2` | İkinci tablonun açıklaması |
```

### .docs/DB_ARCHITECTURE.md

```markdown
| `yeni_sema` | `tablo_1` | İlk tablonun açıklaması |
| `yeni_sema` | `tablo_2` | İkinci tablonun açıklaması |
```

## Veritabanı Ekleme

Yeni veritabanı eklendiğinde .docs/DB_ARCHITECTURE.md'de:

1. İlgili katmana (Core/Gateway/Tenant) yeni bölüm ekle
2. Veritabanı Özet Matrisi'ne (Bölüm 5) satır ekle
3. Mimari diyagramını (Bölüm 6) güncelle

## Kontrol Listesi

- [ ] .docs/DATABASE_STRUCTURE.md güncellendi
- [ ] .docs/DB_ARCHITECTURE.md güncellendi
- [ ] Her iki dosyada format tutarlı

## Hatırlatma

> Her değişiklikte bu kuralı uygula ve **her iki** dokümantasyon dosyasını güncel tut!
> Dokümantasyon, kod kadar önemlidir.
