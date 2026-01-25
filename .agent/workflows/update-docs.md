---
description: Yeni tablo, şema veya veritabanı eklendiğinde dokümantasyonu güncelle
---

# Veritabanı Dokümantasyonu Güncelleme Kuralı

## Ne Zaman Uygulanır?

Bu kural aşağıdaki durumlarda otomatik olarak uygulanmalıdır:

### Tablo Değişiklikleri

1. Proje içinde herhangi bir klasöre yeni SQL tablo dosyası eklendiğinde:
    - `core/`, `core_log/`, `core_audit/`, `core_report/`, `bonus/`
    - `tenant/`, `tenant_log/`, `tenant_audit/`, `tenant_report/`, `affiliate/`
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

## Güncellenecek Dosya

| Dosya                            | İçerik                          |
| -------------------------------- | ------------------------------- |
| `.docs/DATABASE_ARCHITECTURE.md` | Mimari, şemalar ve tablo yapısı |

## Güncelleme Adımları

1. Değişikliğin türünü belirle (tablo, şema, veritabanı)
2. `.docs/DATABASE_ARCHITECTURE.md` dosyasında ilgili bölümü bul:
    - **Core tabloları** → Bölüm 4
    - **Gateway tabloları** → Bölüm 5
    - **Tenant tabloları** → Bölüm 6
    - **Log/Audit/Report** → Bölüm 7
3. Uygun formatta güncelleme yap

## Tablo Ekleme Formatı

```markdown
| `tablo_adi` | Tablonun kısa açıklaması |
```

## Şema Ekleme Formatı

İlgili veritabanı bölümüne yeni şema alt bölümü ekle:

```markdown
### X.X yeni_sema Şeması

Şemanın amacı hakkında kısa açıklama.

| Tablo     | Açıklama                |
| --------- | ----------------------- |
| `tablo_1` | İlk tablonun açıklaması |
```

## Veritabanı Ekleme

1. Bölüm 3 (Özet Matrisi) tablosuna satır ekle
2. Uygun bölüme (Core/Gateway/Tenant) yeni veritabanı bölümü ekle
3. Bölüm 2 (Diyagram) güncelle (gerekirse)

## Kontrol Listesi

- [ ] `.docs/DATABASE_ARCHITECTURE.md` güncellendi

## Hatırlatma

> Her değişiklikte bu kuralı uygula ve dokümantasyonu güncel tut!
> Dokümantasyon, kod kadar önemlidir.
