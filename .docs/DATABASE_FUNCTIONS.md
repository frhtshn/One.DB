# Veritabanı Fonksiyon ve Trigger Dokümantasyonu

Bu doküman, projede yer alan stored procedure ve trigger tanımlarını içerir.

## Core Veritabanı

### Catalog Şeması

- **`country_list`**: Comboboxlar için ülke listesini döner (Değer: country_code, Etiket: country_name).
- **`currency_list`**: Comboboxlar için aktif para birimi listesini döner (Değer: currency_code, Etiket: currency_name).
- **`language_create`**: Yeni bir dil oluşturur.
- **`language_delete`**: Bir dili yumuşak siler (is_active=false yapar, önce çevirileri kontrol eder).
- **`language_get`**: Koda göre belirli bir dilin detaylarını getirir.
- **`language_list`**: Tüm dilleri (pasifler dahil) listeler (yönetici kullanımı için).
- **`language_list_active`**: Tüm aktif dilleri listeler (public API için).
- **`language_update`**: Dil detaylarını günceller (isim, aktiflik durumu).
- **`localization_category_list`**: Farklı çeviri kategorilerini listeler.
- **`localization_domain_list`**: Farklı çeviri domainlerini listeler.
- **`localization_export`**: Belirli bir dilin çevirilerini JSON olarak dışa aktarır.
- **`localization_import`**: JSON'dan çeviri verilerini içe aktarır.
- **`localization_key_create`**: Yeni bir çeviri anahtarı oluşturur.
- **`localization_key_delete`**: Bir çeviri anahtarını ve değerlerini siler.
- **`localization_key_get`**: Bir çeviri anahtarının detaylarını ve tüm çevirilerini getirir.
- **`localization_key_list`**: Çeviri anahtarlarını sayfalama ve filtreleme ile listeler.
- **`localization_key_update`**: Bir çeviri anahtarını günceller.
- **`localization_messages_get`**: Belirli bir dilin tüm çeviri mesajlarını toplu olarak getirir (frontend için).
- **`localization_value_delete`**: Belirli bir çeviri değerini siler.
- **`localization_value_upsert`**: Bir çeviri değerini ekler veya günceller.
- **`timezone_list`**: Katalog tablosundan aktif timezone listesini döner.

### Core Şeması

- **`company_create`**: Yönetim arayüzü için yeni bir şirket kaydı oluşturur.
- **`company_delete`**: Yönetim arayüzü için bir şirket kaydını yumuşak siler.
- **`company_get`**: Yönetim arayüzü için ID ile şirket detaylarını döner.
- **`company_list`**: Yönetim arayüzü için sayfalı şirket listesi döner. İsim veya koda göre arama yapılabilir.
- **`company_update`**: Yönetim arayüzü için şirket bilgisini günceller.
- **`tenant_create`**: Yeni tenant kaydı oluşturur.
- **`tenant_currency_list`**: Bir tenant'a atanmış tüm para birimlerini listeler.
- **`tenant_currency_upsert`**: Bir tenant için para birimi atar veya günceller.
- **`tenant_delete`**: Bir tenant'ı yumuşak siler (status=0 yapar).
- **`tenant_get`**: Desteklenen konfigürasyon dahil detaylı tenant bilgisini döner.
- **`tenant_list`**: Sayfalama, filtre ve konfigürasyon detayları ile tenant listeler.
- **`tenant_setting_delete`**: Bir tenant konfigürasyon ayarını siler.
- **`tenant_setting_get`**: Belirli bir tenant ayarını JSON nesnesi olarak döner. Bulunamazsa NULL döner.
- **`tenant_setting_list`**: Bir tenant'ın tüm konfigürasyon ayarlarını (isteğe bağlı kategori filtresiyle) listeler.
- **`tenant_setting_upsert`**: Bir tenant konfigürasyon ayarını ekler veya günceller.
- **`tenant_update`**: Tenant bilgisini günceller.
- **`update_updated_at_column`**: updated_at kolonunu otomatik güncelleyen genel trigger fonksiyonu.

### Presentation Şeması

- **`build_page_json`**: Bir sayfa için (tab ve context dahil) JSON nesnesi oluşturur. get_structure için yardımcı fonksiyon.
- **`context_create`**: Yeni bir context oluşturur. TABLE(id BIGINT) döner.
- **`context_delete`**: Bir context'i kalıcı olarak siler. VOID döner.
- **`context_list`**: Belirli bir sayfa için context'leri listeler, items ve totalCount döner.
- **`context_update`**: Bir context'i günceller. Kısmi güncelleme destekler. VOID döner.
- **`get_structure`**: Tüm presentation yapısını iç içe JSON olarak döner. Cache invalidation için MD5 version hash kullanır.
- **`menu_create`**: Eşsiz kod kontrolü ile yeni bir menü oluşturur.
- **`menu_delete`**: Bir menüyü is_active=FALSE yaparak ve deleted_at güncelleyerek yumuşak siler.
- **`menu_get`**: Grup, alt menüler, sayfalar ve audit bilgisi dahil menü detaylarını döner.
- **`menu_group_create`**: Eşsiz kod kontrolü ile yeni bir menü grubu oluşturur.
- **`menu_group_delete`**: Bir menü grubunu is_active=FALSE yaparak yumuşak siler.
- **`menu_group_get`**: ID ile tekil menü grubu detayını döner.
- **`menu_group_list`**: order_index'e göre sıralı tüm menü gruplarını döner. Grup başına menü sayısı da içerir.
- **`menu_group_update`**: Menü grubunu kısmi güncelleme ile günceller. NULL değerler mevcut veriyi korur.
- **`menu_list`**: Belirli bir grup için menüleri listeler, items ve totalCount döner.
- **`menu_update`**: Menüde kısmi güncelleme yapar. NULL değerler mevcut veriyi korur.
- **`page_create`**: Eşsiz kod kontrolü ve parent menu/submenu kontrolü ile yeni sayfa oluşturur.
- **`page_delete`**: Bir sayfayı is_active=FALSE yaparak ve updated_at güncelleyerek yumuşak siler.
- **`page_get`**: Tab ve context dahil sayfa detaylarını döner.
- **`page_list`**: Belirli bir menü veya alt menü için sayfaları listeler, items ve totalCount döner.
- **`page_update`**: Sayfada kısmi güncelleme yapar. NULL değerler mevcut veriyi korur.
- **`submenu_create`**: Belirli bir menü için eşsiz kod kontrolü ile yeni alt menü oluşturur.
- **`submenu_delete`**: Bir alt menüyü is_active=FALSE yaparak ve updated_at güncelleyerek yumuşak siler.
- **`submenu_list`**: Belirli bir menü için alt menüleri listeler, items ve totalCount döner.
- **`submenu_update`**: Alt menüde kısmi güncelleme yapar. NULL değerler mevcut veriyi korur.
- **`tab_create`**: Belirli bir sayfa için eşsiz kod kontrolü ile yeni tab oluşturur.
- **`tab_delete`**: Bir tab'ı is_active=FALSE yaparak ve updated_at güncelleyerek yumuşak siler.
- **`tab_list`**: Belirli bir sayfa için tab'ları listeler, items ve totalCount döner.
- **`tab_update`**: Tab'da kısmi güncelleme yapar. NULL değerler mevcut veriyi korur.

### Security Şeması

- **`is_system_role`**: Bir rol kodunun korumalı sistem rolü (örn. superadmin) olup olmadığını kontrol eder.
- **`permission_category_list`**: Aktif izin kategorilerini ve sayılarını listeler. Doğrudan JSON dizi döner.
- **`permission_check`**: Bir kullanıcının belirli bir izne sahip olup olmadığını kontrol eder (Global veya Tenant seviyesinde).
- **`permission_cleanup_expired`**: Süresi dolmuş izin override'larını temizler. Zamanlanmış görev olarak çalıştırılmalıdır.
- **`permission_create`**: Yeni bir izin oluşturur. ID döner. Kod küçük harfe normalize edilir.
- **`permission_delete`**: Bir izni yumuşak siler ve rol ilişkilerini kaldırır. Etkilenen rol sayısını döner.
- **`permission_exists`**: Bir izin kodunun var ve aktif olup olmadığını kontrol eder.
- **`permission_get`**: Koda göre izin detaylarını döner, rol sayısı dahil.
- **`permission_list`**: Sayfalı izin listesi döner. items + totalCount içerir.
- **`permission_update`**: İzin detaylarını günceller. Kod değiştirilemez.
- **`role_create`**: Yeni bir rol oluşturur. Sistem rolleri koruma altındadır.
- **`role_delete`**: Bir rolü yumuşak siler. Sistem rolleri silinemez. Etkilenen kullanıcı sayısını döner.
- **`role_get`**: Koda göre rol detaylarını döner, izinler dahil.
- **`role_list`**: Kullanıcı/izin sayıları ile birlikte sayfalı rol listesi döner. items + totalCount içerir.
- **`role_permission_assign`**: Bir role izin atar. İdempotenttir. already_assigned durumunu döner.
- **`role_permission_bulk_assign`**: Bir role toplu izin ataması yapar. Atanan ve geçersiz kod sayılarını döner.
- **`role_permission_list`**: Bir role atanmış izinleri listeler.
- **`role_permission_remove`**: Bir rolden izni kaldırır. Kaldırma durumunu döner.
- **`role_update`**: Rol detaylarını günceller. Sistem rolleri güncellenemez.
- **`session_belongs_to_user`**: Bir oturumun belirli bir kullanıcıya ait ve aktif olup olmadığını kontrol eder. Boolean döner.
- **`session_cleanup_expired`**: Süresi dolmuş ve eski iptal edilmiş oturumları toplu olarak güvenli şekilde temizler.
- **`session_list`**: Bir kullanıcı için aktif oturumları listeler.
- **`session_revoke`**: Belirli bir oturumu iptal eder.
- **`session_revoke_all`**: Bir kullanıcının tüm oturumlarını iptal eder (isteğe bağlı mevcut olan hariç).
- **`session_save`**: Yeni bir oturumu kaydeder veya mevcut olanı günceller.
- **`session_update_activity`**: Refresh token kullanımında, oturumun son aktivite zamanını geçerli zamana günceller.
- **`user_authenticate`**: Kullanıcıyı e-posta ile doğrular. Rol tipine göre (Platform vs Şirket/Tenant) yapılandırılmış kullanıcı, rol ve izin verisi döner.
- **`user_check_email_exists`**: E-posta var mı kontrol eder. Güncelleme senaryoları için excludeUserId kullanılabilir.
- **`user_check_username_exists`**: Kullanıcı adı şirket içinde var mı kontrol eder. Güncelleme için excludeUserId kullanılabilir.
- **`user_create`**: E-posta/kullanıcı adı benzersizliği ile yeni kullanıcı oluşturur.
- **`user_delete`**: Bir kullanıcıyı yumuşak siler (status=-1 yapar).
- **`user_get`**: Kullanıcı detaylarını döner (şirket, global rol, tenant rol, izinli tenantlar dahil).
- **`user_list`**: Arama, durum, şirket filtreleri ve sıralama ile sayfalı kullanıcı listesi döner.
- **`user_login_failed_increment`**: Başarısız giriş sayacını artırır, eşik aşılırsa hesabı kilitler.
- **`user_login_failed_reset`**: Başarılı giriş sonrası başarısız giriş sayacını sıfırlar.
- **`user_permission_list`**: Hibrit izin: Kullanıcı rolleri ve kullanıcıya özel override izinleri döner. Formül: (Rol + Verilen) - Reddedilen
- **`user_permission_override_list`**: Bir kullanıcı için aktif izin override'larını listeler.
- **`user_permission_remove`**: Bir kullanıcıdan izin override kuralını kaldırır. Rol tabanlı izinleri etkilemez.
- **`user_permission_set`**: Bir kullanıcıya izin verir veya reddeder. Override kaydı oluşturur/günceller.
- **`user_reset_password`**: Kullanıcı şifresini sıfırlar (yönetici işlemi). Şifre hash'lenmiş olmalıdır.
- **`user_role_assign`**: Bir kullanıcıya global rol atar. İdempotenttir.
- **`user_role_list`**: Kullanıcı rolleri (global ve tenant) listesini döner.
- **`user_role_remove`**: Bir kullanıcıdan global rolü kaldırır.
- **`user_tenant_role_assign`**: Bir kullanıcıya tenant'a özel rol atar. İdempotenttir.
- **`user_tenant_role_list`**: Bir kullanıcı için tenant'a özel rolleri listeler. Doğrudan JSON dizi döner.
- **`user_tenant_role_remove`**: Bir kullanıcıdan tenant'a özel rolü kaldırır.
- **`user_unlock`**: Kilitli kullanıcı hesabını açar (yönetici işlemi).
- **`user_update`**: Kullanıcıyı kısmi güncelleme ile günceller. NULL değerler mevcut veriyi korur. E-posta/kullanıcı adı benzersizliği kontrolü yapar.

## Core Audit Veritabanı

### Backoffice Şeması

- **`auth_audit_create`**: Kimlik doğrulama denetim kaydı ekler. BIGINT döner.
- **`auth_audit_failed_logins`**: Kaba kuvvet saldırısı tespiti için başarısız giriş denemelerini getirir.
- **`auth_audit_list_by_type`**: Olay türüne göre kimlik doğrulama denetim kayıtlarını JSONB dizisi olarak getirir.
- **`auth_audit_list_by_user`**: Belirli bir kullanıcı için kimlik doğrulama denetim kayıtlarını JSONB dizisi olarak getirir.

## Core Log Veritabanı

### Backoffice Şeması

- **`audit_create`**: Varlık denetim kaydı (entity audit log) ekler. UUID döner.
- **`audit_get`**: ID'ye göre varlık denetim kaydını JSONB olarak getirir.
- **`audit_list`**: Sayfalı varlık denetim kayıtlarını JSONB olarak getirir.

### Logs Şeması

- **`core_audit_create`**: Çekirdek denetim kaydı (core audit log) ekler. UUID döner.
- **`core_audit_list`**: Filtrelenmiş çekirdek denetim kayıtlarını JSONB dizisi olarak getirir.
- **`dead_letter_create`**: İşlenemeyen mesaj (dead letter) kaydı ekler. UUID döner.
- **`dead_letter_get`**: ID'ye göre işlenemeyen mesaj detaylarını getirir.
- **`dead_letter_list_pending`**: İşlenmeyi bekleyen işlenemeyen mesajları (dead letters) getirir.
- **`dead_letter_retry`**: Bir mesaj için tekrar deneme sayısını artırır ve durumu RETRYING olarak ayarlar.
- **`dead_letter_stats`**: İşlenemeyen mesaj istatistiklerini (duruma göre sayılar vb.) hesaplar.
- **`dead_letter_update_status`**: Bir işlenemeyen mesajın durumunu ve çözüm detaylarını günceller.
- **`error_get`**: ID'ye göre hata detayını JSONB olarak getirir.
- **`error_list`**: Filtrelenmiş uygulama hatalarını JSONB dizisi olarak getirir.
- **`error_log`**: Uygulama hata kaydı ekler. ID döner.
- **`error_stats`**: Hata istatistiklerini (sayılar, en çok karşılaşılan hatalar vb.) hesaplar.

## Tenant Veritabanı

Henüz özel fonksiyon tanımlanmamıştır.

## Tenant Affiliate Veritabanı

Henüz özel fonksiyon tanımlanmamıştır.

## Tenant Audit Veritabanı

Henüz özel fonksiyon tanımlanmamıştır.

## Tenant Log Veritabanı

Henüz özel fonksiyon tanımlanmamıştır.

## Tenant Report Veritabanı

Henüz özel fonksiyon tanımlanmamıştır.

## Finance Veritabanı

Henüz özel fonksiyon tanımlanmamıştır.

## Finance Log Veritabanı

Henüz özel fonksiyon tanımlanmamıştır.

## Game Veritabanı

Henüz özel fonksiyon tanımlanmamıştır.

## Game Log Veritabanı

Henüz özel fonksiyon tanımlanmamıştır.
