---
description: Yeni stored procedure/function eklerken dosya yapısı ve deploy sürecini yönetir
---

# Yeni Fonksiyon Ekleme Kuralı

## Ne Zaman Uygulanır?

Kullanıcı yeni bir stored procedure veya veritabanı fonksiyonu eklemek istediğinde.

## Adımlar

### 1. Klasör Yapısını Belirle

Fonksiyonun amacına uygun klasörü seç veya oluştur:

- **Genel/Ortak Fonksiyonlar:** `core/functions/common/`
- **Modüler/Şema Bazlı Fonksiyonlar:**
    - Security (Auth, Role, Permission): `core/functions/security/<submodule>/`
    - Catalog (Language, Localization): `core/functions/catalog/<submodule>/`
    - Presentation (UI Helpers): `core/functions/presentation/`
    - Diğerleri: `core/functions/<schema_name>/`

> **Not:** Localization fonksiyonlarını `core/functions/catalog/localization/` altında düz bir yapıda veya mantıksal gruplara göre saklayabilirsiniz.

### 2. SQL Dosyası Oluştur

- Dosya adı: `snake_case` formatında fonksiyon adı ile aynı olmalı (örn: `user_authenticate.sql`).
- İçerik şunları kapsamalı:
    - Açıklayıcı header comments
    - `DROP FUNCTION IF EXISTS ...`
    - `CREATE OR REPLACE FUNCTION ...`
    - `COMMENT ON FUNCTION ...`

### 3. Deploy Script'e Ekle

`deploy_core.sql` (veya ilgili deploy dosyası) içinde `FUNCTIONS` bölümüne ekle.

- Mantıksal gruplama yaparak ekle (yorum satırlarıyla ayır).
- Bağımlılık sırasına dikkat et (Helper fonksiyonlar önce).

Örnek:

```sql
-- Localization Functions
\i core/functions/catalog/localization/localization_key_list.sql
\i core/functions/catalog/localization/localization_key_get.sql
```

## Kontrol Listesi

- [ ] Fonksiyon dosyası doğru klasöre oluşturuldu
- [ ] Dosya içinde `DROP`, `CREATE` ve `COMMENT` komutları var
- [ ] Deploy script (`deploy_core.sql`) güncellendi
- [ ] (Varsa) İlgili tablo trigger'ları ayrıca tanımlandı
