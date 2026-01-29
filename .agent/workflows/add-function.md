---
description: Yeni stored procedure/function eklerken dosya yapısı ve deploy sürecini yönetir
---

# Yeni Fonksiyon Ekleme Kuralı

## Ne Zaman Uygulanır?

Kullanıcı yeni bir stored procedure veya veritabanı fonksiyonu eklemek istediğinde.

## Adımlar

### 1. Klasör Yapısını Belirle

Fonksiyonun hangi veritabanına (`core`, `tenant`, `bonus` vb.) ve hangi şemaya ait olduğunu belirle.

- **Kalıp:** `<db_folder>/functions/<schema_name>/<submodule>/`
- **Örnekler:**
    - `core/functions/security/auth/`
    - `tenant/functions/game/logic/`
    - `bonus/functions/rewards/calculation/`

### 2. SQL Dosyası Oluştur

- Dosya adı: `snake_case` formatında fonksiyon adı ile aynı olmalı (örn: `user_authenticate.sql`).
- İçerik şunları kapsamalı:
    - Açıklayıcı header comments
    - `DROP FUNCTION IF EXISTS ...`
    - `CREATE OR REPLACE FUNCTION ...`
    - `COMMENT ON FUNCTION ...`

### 3. Deploy Script'e Ekle

İlgili ana deploy dosyası (`deploy_core.sql`, `deploy_tenant.sql`, `deploy_bonus.sql` vb.) içinde `FUNCTIONS` bölümüne ekle.

- Mantıksal gruplama yaparak ekle (yorum satırlarıyla ayır).
- Bağımlılık sırasına dikkat et (Helper fonksiyonlar önce).

Örnek:

```sql
-- Localization Functions
\i core/functions/catalog/localization/localization_key_list.sql
\i tenant/functions/game/logic/calculate_score.sql
```

### 4. Performans Optimizasyonu ve Index Kontrolü

Yeni eklenen fonksiyonun performanslı çalışması için index kontrolü yapılmalıdır:

1. **Sorgu Analizi:**
    - Fonksiyon içindeki `WHERE`, `JOIN` ve `ORDER BY` cümlelerinde kullanılan kolonları belirle.
    - Bu kolonlar için mevcut indexleri kontrol et.

2. **Index Ekleme (Gerekirse):**
    - Eğer performans için kritik bir kolonda index eksikse, kullanıcıdan onay alarak index ekle.
    - **Dosya Konumu:** `<db_folder>/indexes/<schema>.sql` (örn: `core/indexes/security.sql`, `tenant/indexes/game.sql`).
    - **Komut:** Dosyanın sonuna `CREATE INDEX` komutunu ekle.
    - **İsimlendirme:** `idx_<table_name>_<column_names>` formatını kullan.

    > **Örnek:**
    >
    > ```sql
    > -- users.email (unique lookup - user_authenticate function)
    > CREATE INDEX IF NOT EXISTS idx_users_email ON security.users USING btree(email);
    > ```

## Kontrol Listesi

- [ ] Fonksiyon dosyası doğru klasöre (`<db_folder>/functions/...`) oluşturuldu
- [ ] Dosya içinde `DROP`, `CREATE` ve `COMMENT` komutları var
- [ ] İlgili deploy script (`deploy_<db_folder>.sql`) güncellendi
- [ ] Performans için gerekli indexler kontrol edildi ve eklendi (`<db_folder>/indexes/<schema>.sql`)
- [ ] (Varsa) İlgili tablo trigger'ları ayrıca tanımlandı
