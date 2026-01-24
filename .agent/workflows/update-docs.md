---
description: Yeni tablo eklendiğinde DATABASE_STRUCTURE.md dosyasını güncelle
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

## Güncelleme Adımları

1. Değişikliğin türünü belirle (tablo, şema, mimari)
2. `DATABASE_STRUCTURE.md` dosyasında ilgili bölümü bul
3. Uygun formatta güncelleme yap:
    - Tablo ekleme: İlgili şema tablosuna satır ekle
    - Şema ekleme: Yeni bölüm oluştur
    - Mimari değişiklik: İlgili açıklama bölümünü güncelle
4. Genel özet tablosunu (Bölüm 1) gerekirse güncelle

## Tablo Ekleme Formatı

```markdown
| `tablo_adi` | Tablonun kısa açıklaması |
```

## Şema Ekleme Formatı

```markdown
### X.X yeni_sema Şeması

Şemanın amacı ve içeriği hakkında kısa açıklama.

| Tablo     | Açıklama                   |
| --------- | -------------------------- |
| `tablo_1` | İlk tablonun açıklaması    |
| `tablo_2` | İkinci tablonun açıklaması |
```

## Hatırlatma

> Her değişiklikte bu kuralı uygula ve DATABASE_STRUCTURE.md dosyasını güncel tut!
> Dokümantasyon, kod kadar önemlidir.
