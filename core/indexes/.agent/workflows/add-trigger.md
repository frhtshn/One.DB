---
description: Yeni trigger eklerken dosya yapısı ve deploy sürecini yönetir
---

# Yeni Trigger Ekleme Kuralı

## Ne Zaman Uygulanır?

Kullanıcı bir tabloya trigger eklemek istediğinde.

## Adımlar

### 1. Trigger Fonksiyonu (Opsiyonel)

Eğer trigger özel bir fonksiyon çalıştıracaksa (generic `update_updated_at` dışında):

- Fonksiyonu `core/functions/triggers/` veya `core/functions/common/` altına ekle.
- `add-function` workflow'unu takip et.

### 2. Trigger Tanım Dosyası

Trigger tanımlarını (`CREATE TRIGGER ...`) şema bazlı toplu dosyalarda tutuyoruz:

- **Dosya Yolu:** `core/triggers/<schema_name>_triggers.sql` (örn: `security_triggers.sql`)
- **İçerik:**
    - `DROP TRIGGER IF EXISTS ...`
    - `CREATE TRIGGER ...`
    - Her tablo için ayrı bloklar halinde

Örnek:

```sql
-- Users
DROP TRIGGER IF EXISTS trigger_users_updated_at ON security.users;
CREATE TRIGGER trigger_users_updated_at
    BEFORE UPDATE ON security.users
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();
```

Eğer yeni bir şema için trigger ekleniyorsa, `core/triggers/` altında yeni bir dosya oluştur.

### 3. Deploy Script'e Ekle

`deploy_core.sql` içinde `TRIGGERS` bölümüne (dosyanın en sonuna) ekle.

```sql
-- TRIGGERS
\i core/triggers/security_triggers.sql
\i core/triggers/presentation_triggers.sql
```

## Kontrol Listesi

- [ ] Trigger fonksiyonu mevcut veya oluşturuldu
- [ ] `core/triggers/` altındaki ilgili `.sql` dosyası güncellendi
- [ ] Deploy script (`deploy_core.sql`) en son satırlarında trigger dosyasının import edildiği doğrulandı
