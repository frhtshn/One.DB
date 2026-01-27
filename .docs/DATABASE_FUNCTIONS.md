# NUCLEO – VERİTABANI FONKSİYON REFERANSI

Bu doküman, projede yer alan tüm veritabanlarındaki (`core`, `tenant`, vb.) saklı yordamların (Stored Procedures) ve trigger'ların **tam listesidir**.

---

## 1. Core Veritabanı

Merkezi yönetim, güvenlik ve backoffice UI fonksiyonları.

### 1.1 Presentation Şeması (`core/functions/presentation/`)

Backoffice UI yapısını yöneten fonksiyonlar.

- **`presentation.get_structure()`**:
    - Tüm menü, sayfa ve yetki ağacını JSON olarak döner (Cache: MD5 hash).
- **`presentation.build_page_json(p_page_id BIGINT)`**:
    - Tek bir sayfanın (tablar ve contextler dahil) JSON yapısını oluşturur.

### 1.2 Security Şeması (`core/functions/security/`)

#### Auth & Oturum (`.../auth/`, `.../session/`)

- **`security.user_authenticate`**: Kullanıcı giriş ve doğrulama ana fonksiyonu (Login akışı).
- **`security.session_save`**: Yeni oturum kaydeder.
- **`security.session_revoke`**: Belirli bir oturumu sonlandırır.
- **`security.session_revoke_all`**: Kullanıcının tüm oturumlarını sonlandırır.
- **`security.session_list`**: Aktif oturumları listeler.
- **`security.session_cleanup_expired`**: Süresi dolmuş oturumları temizler (Job için).

#### Kullanıcı Yönetimi (`.../users/`)

- **`security.user_unlock`**: Kilitlenmiş kullanıcının kilidini kaldırır.
- **`security.user_login_failed_increment`**: Başarısız giriş sayacını artırır.
- **`security.user_login_failed_reset`**: Başarısız giriş sayacını sıfırlar.

#### Rol Yönetimi (`.../roles/`)

- **`security.role_create`**: Yeni rol oluşturur.
- **`security.role_update`**: Rol bilgilerini günceller.
- **`security.role_delete`**: Rolü (soft/hard) siler.
- **`security.role_restore`**: Silinmiş rolü geri yükler.
- **`security.role_get`**: Rol detayını getirir.
- **`security.role_list`**: Rolleri listeler (filtreli).
- **`security.is_system_role`**: Rolün sistem rolü olup olmadığını kontrol eder.
- **`security.role_permission_assign`**: Role tekil yetki atar.
- **`security.role_permission_bulk_assign`**: Role toplu yetki atar.
- **`security.role_permission_remove`**: Rolden yetki kaldırır.
- **`security.role_permission_list`**: Rolün yetkilerini listeler.
- **`security.user_role_assign`**: Kullanıcıya rol atar.
- **`security.user_role_remove`**: Kullanıcıdan rol alır.
- **`security.user_role_list`**: Kullanıcının rollerini listeler.
- **`security.user_tenant_role_assign`**: Kullanıcıya tenant bazlı rol atar.
- **`security.user_tenant_role_remove`**: Kullanıcıdan tenant rolünü alır.
- **`security.user_tenant_role_list`**: Kullanıcının tenant rollerini listeler.

#### Yetki Yönetimi (`.../permissions/`)

- **`security.permission_create`**: Yeni yetki tanımı oluşturur.
- **`security.permission_update`**: Yetki tanımını günceller.
- **`security.permission_delete`**: Yetkiyi siler.
- **`security.permission_restore`**: Yetkiyi geri yükler.
- **`security.permission_get`**: Yetki detayını getirir.
- **`security.permission_list`**: Yetkileri listeler.
- **`security.permission_exists`**: Yetki kodunun varlığını kontrol eder.
- **`security.permission_check`**: Kullanıcının yetkisi olup olmadığını kontrol eder (Boolean).
- **`security.permission_category_list`**: Yetki kategorilerini listeler.
- **`security.permission_cleanup_expired`**: Süresi dolmuş geçici yetkileri temizler.
- **`security.user_permission_list`**: Kullanıcının efektif (rol + override) tüm yetkilerini listeler.
- **`security.user_permission_set`**: Kullanıcıya özel (rolden bağımsız) override yetki verir.
- **`security.user_permission_remove`**: Kullanıcı özel yetkisini kaldırır.
- **`security.user_permission_override_list`**: Kullanıcıya tanımlı özel yetkileri listeler.

### 1.3 Catalog Şeması (`core/functions/catalog/`)

#### Dil Yönetimi (`.../languages/`)

- **`catalog.language_create`**: Yeni dil ekler.
- **`catalog.language_update`**: Dil ayarlarını günceller.
- **`catalog.language_delete`**: Dili siler.
- **`catalog.language_get`**: Dil detayını getirir.
- **`catalog.language_list`**: Tüm dilleri listeler.
- **`catalog.language_list_active`**: Sadece aktif dilleri listeler.

#### Lokalizasyon (`.../localization/`)

- **`catalog.localization_key_create`**: Çeviri anahtarı oluşturur.
- **`catalog.localization_key_update`**: Anahtarı günceller.
- **`catalog.localization_key_delete`**: Anahtarı siler.
- **`catalog.localization_key_get`**: Anahtar detayını getirir.
- **`catalog.localization_key_list`**: Anahtarları listeler (filtreli).
- **`catalog.localization_value_upsert`**: Çeviri değerini ekler/günceller.
- **`catalog.localization_value_delete`**: Çeviri değerini siler.
- **`catalog.localization_messages_get`**: Belirli bir dil için tüm mesajları getirir (Frontend için).
- **`catalog.localization_export`**: Çevirileri dışa aktarır.
- **`catalog.localization_import`**: Çevirileri içe aktarır.
- **`catalog.localization_category_list`**: Çeviri kategorilerini listeler.
- **`catalog.localization_domain_list`**: Çeviri domainlerini (backend, frontend vb.) listeler.

---

## 2. Core Log Veritabanı

Sistem ve operasyonel logların yönetimi.

### 2.1 Backoffice Şeması (`core_log/functions/backoffice/`)

- **`backoffice.audit_create`**: Backoffice işlem denetim kaydı oluşturur.
- **`backoffice.audit_get`**: Tekil audit kaydını detaylarıyla getirir.
- **`backoffice.audit_list`**: Audit kayıtlarını filtreleyerek listeler.

### 2.2 Log Şeması (`core_log/functions/logs/`)

- **`logs.core_audit_create`**: Core sistem audit kaydı oluşturur.
- **`logs.core_audit_list`**: Core audit kayıtlarını listeler.
- **`logs.dead_letter_create`**: İşlenemeyen mesaj/log kaydı oluşturur.
- **`logs.dead_letter_get`**: Dead letter kaydı detayını getirir.
- **`logs.dead_letter_list_pending`**: Bekleyen (henüz retry edilmemiş) dead letter kayıtlarını listeler.
- **`logs.dead_letter_retry`**: Dead letter kaydını yeniden işlemeyi dener, durumunu günceller.
- **`logs.dead_letter_stats`**: Dead letter istatistiklerini (toplam, bekleyen, çözülen) döner.
- **`logs.dead_letter_update_status`**: Kaydın durumunu manuel günceller.
- **`logs.error_log`**: Genel hata log kaydı atar.
- **`logs.error_get`**: Hata log detayını getirir.
- **`logs.error_list`**: Hata loglarını zaman/tip filtresiyle listeler.
- **`logs.error_stats`**: Hata istatistiklerini raporlar.

---

## 3. Core Audit Veritabanı

Kalıcı ve yasal saklama gerektiren denetim izleri.

### 3.1 Backoffice Şeması (`core_audit/functions/backoffice/`)

- **`backoffice.auth_audit_create`**: Oturum/Giriş denetim kaydı oluşturur.
- **`backoffice.auth_audit_failed_logins`**: Başarısız giriş denemelerini raporlar.
- **`backoffice.auth_audit_list_by_type`**: İşlem tipine göre (Login, Logout, Failed) audit kayıtlarını listeler.
- **`backoffice.auth_audit_list_by_user`**: Belirli bir kullanıcının tüm giriş hareketlerini listeler.

---

## 4. Diğer Veritabanları

### 4.1 Core Report Veritabanı

_(Henüz özel fonksiyon tanımlanmamıştır)_

### 4.2 Game & Game Log Veritabanları

_(Henüz özel fonksiyon tanımlanmamıştır)_

### 4.3 Finance & Finance Log Veritabanları

_(Henüz özel fonksiyon tanımlanmamıştır)_

### 4.4 Bonus Veritabanı

_(Henüz özel fonksiyon tanımlanmamıştır)_

### 4.5 Tenant Veritabanı

_(Henüz özel fonksiyon tanımlanmamıştır)_

### 4.6 Tenant Affiliate Veritabanı

_(Henüz özel fonksiyon tanımlanmamıştır)_

### 4.7 Tenant Log & Audit & Report Veritabanları

_(Sadece partitioning ve otomatik temizlik triggerları mevcuttur)_

---

## 5. Triggerlar (Tüm Veritabanları)

Veri bütünlüğünü sağlamak ve audit loglarını oluşturmak için kullanılan otomatik tetikleyiciler.

### 3.1 Genel Triggerlar (`core/triggers/`)

- **`update_updated_at_column`**:
    - `core.update_updated_at_column()` fonksiyonunu çağırır.
    - Kayıt güncellendiğinde `updated_at` kolonunu otomatik olarak `NOW()` yapar.

### 3.2 Security Triggerlar (`core/triggers/security_triggers.sql`)

Aşağıdaki tablolarda yapılan değişiklikleri `core_audit` veritabanına loglar:

- `security.users`
- `security.roles`
- `security.permissions`
- `security.user_roles`
- `security.role_permissions`

### 3.3 Presentation Triggerlar (`core/triggers/presentation_triggers.sql`)

Aşağıdaki tablolarda değişiklik olduğunda `updated_at` alanını güncelleyerek cache invalidation sağlar:

- `presentation.menus`
- `presentation.pages`
- `presentation.menu_groups`
- `presentation.submenus`
- `presentation.tabs`
