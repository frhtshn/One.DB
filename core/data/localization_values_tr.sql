-- ============================================================================
-- LOCALIZATION VALUES - TURKISH (tr)
-- ============================================================================

DELETE FROM catalog.localization_values WHERE language_code = 'tr';

INSERT INTO catalog.localization_values (localization_key_id, language_code, localized_text, created_at)
SELECT k.id, 'tr', v.text, NOW()
FROM catalog.localization_keys k
JOIN (VALUES
    -- Validation (LocalizedValidator)
    ('validation.summary', 'Doğrulama hatası: {0} hata'),
    ('validation.field.required', '{0} alanı zorunludur'),
    ('validation.field.max-length', '{0} alanı en fazla {1} karakter olabilir'),
    ('validation.field.min-length', '{0} alanı en az {1} karakter olmalıdır'),
    ('validation.field.length', '{0} alanı {1} ile {2} karakter arasında olmalıdır'),
    ('validation.field.exact-length', '{0} alanı tam olarak {1} karakter olmalıdır'),
    ('validation.field.invalid-value', 'Geçersiz değer'),
    ('validation.field.only-one-allowed', 'Sadece bir değere izin veriliyor'),
    ('validation.format.email-invalid', '{0} geçerli bir e-posta adresi değil'),
    ('validation.format.url-invalid', '{0} geçerli bir URL değil'),
    ('validation.format.invalid', '{0} geçerli bir format değil'),
    ('validation.format.timezone-invalid', '{0} geçerli bir timezone değil'),
    ('validation.format.target-type-invalid', 'Geçersiz hedef tipi'),
    ('validation.format.environment-invalid', 'Geçersiz ortam değeri'),
    ('validation.range.greater-than-zero', '{0} sıfırdan büyük olmalıdır'),
    ('validation.range.between', '{0} değeri {1} ile {2} arasında olmalıdır'),
    ('validation.range.min', '{0} en az {1} olmalıdır'),
    ('validation.range.cooling-off-invalid', 'Cooling off minimum değeri maksimum değerden büyük olamaz'),
    ('validation.filter.sort-field-invalid', '{0} şu değerlerden biri olmalıdır: {1}'),
    ('validation.filter.sort-order-invalid', '{0} ''asc'' veya ''desc'' olmalıdır'),
    ('validation.request.invalid', 'Geçersiz istek'),
    ('validation.password.required', 'Şifre boş olamaz'),
    ('validation.password.min-length', 'Şifre en az {0} karakter olmalı'),
    ('validation.password.max-length', 'Şifre en fazla {0} karakter olabilir'),
    ('validation.password.require-uppercase', 'Şifre en az bir büyük harf içermeli'),
    ('validation.password.require-lowercase', 'Şifre en az bir küçük harf içermeli'),
    ('validation.password.require-digit', 'Şifre en az bir rakam içermeli'),
    ('validation.password.require-special', 'Şifre en az bir özel karakter içermeli'),
    ('validation.password.mismatch', 'Şifreler eşleşmiyor'),
    ('validation.kyc.level-invalid', 'Geçersiz KYC seviyesi'),
    ('validation.kyc.deadline-action-invalid', 'Geçersiz deadline action değeri'),

    -- Error Messages - Logs
    ('error.logs.errornotfound', 'Error log bulunamadı'),
    ('error.deadletter.notfound', 'Dead letter bulunamadı'),
    ('error.deadletter.bulklimitexceeded', 'Toplu işlem limiti aşıldı (maksimum 500 kayıt)'),
    ('error.logs.auditnotfound', 'Audit log bulunamadı'),

    -- Error Messages - Auth Account Status
    ('error.auth.account-inactive', 'Hesap aktif değil'),

    -- Error Messages - Field
    ('error.field.missing', 'Zorunlu alan eksik: ''{0}'''),
    ('error.field.invalid', 'Geçersiz alan ''{0}'': {1}'),

    -- Error Messages - CRUD
    ('error.crud.create-failed', '{0} oluşturma başarısız'),
    ('error.crud.update-failed', '{0} güncelleme başarısız'),

    -- Error Messages - Business
    ('error.business.insufficient-balance', 'Yetersiz bakiye. Gerekli: {0}, Mevcut: {1}'),
    ('error.business.invalid-status-transition', '{0} durumundan {1} durumuna geçiş yapılamaz'),

    -- Error Messages - System Cache
    ('error.system.cache.connection-failed', 'Cache bağlantısı kurulamadı'),
    ('error.system.cache.operation-failed', 'Cache işlemi başarısız: {0}'),

    -- Error Messages - System Circuit Breaker
    ('error.system.circuit-breaker.database', 'Veritabanı circuit breaker açık durumda'),
    ('error.system.circuit-breaker.cache', 'Cache circuit breaker açık durumda'),
    ('error.system.circuit-breaker.external-api', '{0} için circuit breaker açık durumda'),
    ('error.system.circuit-breaker.messaging', '{0} için messaging circuit breaker açık durumda'),

    -- Error Messages - Conflict
    ('error.conflict.duplicate', '{0} zaten mevcut: {1}'),
    ('error.conflict.concurrency', '{0} {1} başka bir işlem tarafından değiştirildi'),

    -- Error Messages - System Database
    ('error.system.database.connection-failed', 'Veritabanı bağlantısı kurulamadı'),
    ('error.system.database.query-failed', 'Veritabanı sorgusu başarısız: {0}'),
    ('error.system.database.invalid-tenant-id', 'Geçersiz tenant ID: {0}'),
    ('error.system.database.command-failed', 'Veritabanı işlemi başarısız: {0}'),

    -- Error Messages - Forbidden
    ('error.forbidden.resource', '{0} kaynağına erişim için yetkiniz yok. Gerekli yetki: {1}'),
    ('error.tenant.access-denied', 'Tenant {0} için erişim izniniz yok'),
    ('error.tenant.mismatch', 'Farklı bir tenant için izin değişikliği yapılamaz'),
    ('error.tenant.scope-missing', 'Tenant kapsam parametresi bulunamadı'),
    ('error.access.company-scope-denied', 'Şirket kapsamı dışında işlem yapılamaz'),
    ('error.access.tenant-scope-denied', 'Tenant kapsamı dışında işlem yapılamaz'),
    ('error.access.hierarchy-violation', 'Hiyerarşi ihlali - yetkisiz işlem'),
    ('error.access.denied', 'Erişim engellendi'),
    ('error.access.unauthorized', 'Yetkisiz erişim'),

    -- Error Messages - Caller
    ('error.caller.not-found', 'Çağıran kullanıcı bulunamadı'),
    ('error.caller.locked', 'Hesabınız kilitli'),

    -- Error Messages - System Grain
    ('error.system.grain.activation-failed', 'Grain aktifleştirilemedi: {0} (key: {1})'),
    ('error.system.grain.operation-failed', 'Grain operasyonu başarısız: {0}'),

    -- Error Messages - System Operation
    ('error.system.operation.timeout', '''{0}'' işlemi {1} saniye sonra zaman aşımına uğradı'),
    ('error.system.rate-limit.exceeded', 'Rate limit aşıldı (client: ''{0}''): {1}/{2}. {3} saniye sonra tekrar deneyin.'),

    -- Error Messages - System Silo
    ('error.system.silo.unavailable', 'Silo erişilemez durumda'),
    ('error.system.silo.cluster-unavailable', 'Orleans cluster erişilemez durumda'),
    ('error.system.silo.auth-init-failed', 'Auth altyapısı başlatılamadı'),

    -- Error Messages - Tenant
    ('error.tenant.not-active', 'Tenant {0} aktif değil'),
    ('error.tenant.configuration-invalid', 'Tenant {0} konfigürasyonu geçersiz: {1}'),

    -- Error Messages - Resource
    ('error.resource.not-found', '{0} bulunamadı: {1}'),

    -- Error Messages - Config
    ('error.config.missing-required', 'Zorunlu konfigürasyon eksik: {0}'),
    ('error.config.cannot-resolve-hostname', 'Hostname çözümlenemiyor: {0}'),
    ('error.config.invalid-value', 'Geçersiz konfigürasyon değeri ''{0}'': {1}'),

    -- Error Messages - System Replica
    ('error.system.replica.write-not-allowed', 'Write operasyonu replica üzerinde yapılamaz. Identifier: {0}, Operation: {1}. Primary instance kullanın.'),

    -- Error Messages - Auth Token
    ('error.auth.token.missing', 'Authentication token gerekli'),
    ('error.auth.token.invalid', 'Geçersiz authentication token: {0}'),
    ('error.auth.token.expired', 'Authentication token süresi dolmuş'),
    ('error.auth.token.revoked', 'Token iptal edilmiş'),
    ('error.auth.token.not-found', 'Token bulunamadı'),
    ('error.auth.token.refresh-invalid', 'Geçersiz veya süresi dolmuş refresh token'),
    ('error.auth.token.refresh-required', 'Refresh token zorunludur'),
    ('error.auth.token.refresh-failed', 'Token yenileme başarısız'),
    ('error.auth.token.refresh-in-progress', 'Yenileme işlemi zaten devam ediyor'),

    -- Error Messages - Auth Login
    ('error.auth.login.throttled', 'Çok fazla giriş denemesi. Lütfen {0} saniye bekleyin.'),
    ('error.auth.login.failed', 'Giriş başarısız'),
    ('error.auth.login.account-locked', 'Hesabınız kilitlendi. {0} tarihine kadar bekleyin.'),
    ('error.auth.login.invalid-credentials', 'Kullanıcı adı veya şifre hatalı'),

    -- Error Messages - Auth User
    ('error.auth.user.invalid-id', 'Geçersiz kullanıcı kimliği'),
    ('error.auth.user.not-found', 'Kullanıcı bulunamadı'),
    ('error.auth.admin.not-found', 'Admin kullanıcı bilgisi alınamadı'),

    -- Error Messages - Auth Session
    ('error.auth.session.not-found', 'Oturum bulunamadı'),
    ('error.auth.session.id-required', 'Oturum kimliği zorunludur'),
    ('error.auth.session.use-logout-endpoint', 'Mevcut oturumu sonlandırmak için logout endpoint kullanın'),
    ('error.auth.session.revoke-failed', 'Oturum sonlandırma başarısız'),

    -- Error Messages - Auth Logout
    ('error.auth.logout.failed', 'Çıkış başarısız'),
    ('error.auth.logout.all-failed', 'Toplu çıkış başarısız'),

    -- Error Messages - Auth Unlock
    ('error.auth.unlock.failed', 'Hesap kilidi açılamadı'),

    -- Error Messages - Auth 2FA
    ('error.auth.2fa.invalid-code', 'Geçersiz doğrulama kodu'),
    ('error.auth.2fa.token-expired', '2FA süresi doldu, lütfen tekrar giriş yapın'),
    ('error.auth.2fa.max-attempts', 'Çok fazla başarısız deneme, lütfen tekrar giriş yapın'),
    ('error.auth.2fa.already-enabled', '2FA zaten aktif'),
    ('error.auth.2fa.not-enabled', '2FA aktif değil'),
    ('error.auth.2fa.setup-expired', '2FA kurulum süresi doldu'),

    -- Success Messages - Auth
    ('success.auth.logout', 'Başarıyla çıkış yapıldı'),
    ('success.auth.logout-all', 'Tüm oturumlar sonlandırıldı'),
    ('success.auth.session-revoked', 'Oturum sonlandırıldı'),
    ('success.auth.unlocked', 'Hesap kilidi açıldı'),
    ('success.auth.password-changed', 'Şifre başarıyla değiştirildi'),

    -- Success Messages - Presentation
    ('success.presentation.cache-invalidated', 'Presentation cache temizlendi'),

    -- Error Messages - Permission
    ('error.permission.escalation', 'Yetki yükseltme girişimi engellendi'),
    ('error.permission.not-found', 'Yetki bulunamadı'),
    ('error.permission.grant.failed', 'Yetki verme başarısız'),
    ('error.permission.deny.failed', 'Yetki reddetme başarısız'),
    ('error.permission.remove.failed', 'Yetki kaldırma başarısız'),
    ('error.permission.inactive', 'Pasif yetki üzerinde işlem yapılamaz'),
    ('error.permission.create.code-required', 'Yetki kodu zorunlu'),
    ('error.permission.create.code-exists', 'Yetki kodu zaten mevcut'),
    ('error.permission.create.code-deleted', 'Yetki kodu silinmiş. Restore kullanın'),
    ('error.permission.update.is-deleted', 'Silinmiş yetki güncellenemez'),
    ('error.permission.restore.not-deleted', 'Yetki silinmiş değil'),
    ('error.permission.create.failed', 'Yetki oluşturulamadı'),
    ('error.permission.update.failed', 'Yetki güncellenemedi'),
    ('error.permission.delete.failed', 'Yetki silinemedi'),
    ('error.permission.restore.failed', 'Yetki geri yüklenemedi'),

    -- Error Messages - Role
    ('error.role.not-found', 'Rol bulunamadı'),
    ('error.role.create.code-exists', 'Rol kodu zaten mevcut'),
    ('error.role.create.code-deleted', 'Rol kodu silinmiş. Restore kullanın'),
    ('error.role.inactive', 'Pasif rol üzerinde işlem yapılamaz'),
    ('error.role.restore.not-deleted', 'Rol silinmiş değil'),
    ('error.role.system-protected', 'Sistem rolü değiştirilemez'),
    ('error.role.list.failed', 'Rol listesi alınamadı'),
    ('error.role.get.failed', 'Rol bilgisi alınamadı'),
    ('error.role.create.failed', 'Rol oluşturulamadı'),
    ('error.role.update.failed', 'Rol güncellenemedi'),
    ('error.role.delete.failed', 'Rol silinemedi'),
    ('error.role.restore.failed', 'Rol geri yüklenemedi'),
    ('error.role.assign.failed', 'Rol atama başarısız'),
    ('error.role.remove.failed', 'Rol kaldırma başarısız'),
    ('error.role.bulk-assign.failed', 'Toplu yetki atama başarısız'),
    ('error.role.assign-permission.failed', 'Role yetki atama başarısız'),
    ('error.role.remove-permission.failed', 'Rolden yetki kaldırma başarısız'),
    ('error.role.assign-tenant.failed', 'Tenant rol atama başarısız'),
    ('error.role.remove-tenant.failed', 'Tenant rol kaldırma başarısız'),
    ('error.role.user-not-found', 'Kullanıcı bulunamadı'),
    ('error.role.permission-not-found', 'Yetki bulunamadı'),
    ('error.role.permission-deleted', 'Silinmiş yetki atanamaz'),
    ('error.role.operation-failed', 'Rol işlemi başarısız'),
    ('error.role.tenant-mismatch', 'Tenant uyuşmazlığı'),

    -- Error Messages - User
    ('error.user.not-found', 'Kullanıcı bulunamadı'),
    ('error.user.create.email-exists', 'Bu e-posta adresi zaten kayıtlı'),
    ('error.user.create.username-exists', 'Bu kullanıcı adı şirkette zaten kullanılıyor'),
    ('error.user.update.is-deleted', 'Silinmiş kullanıcı güncellenemez'),
    ('error.user.update.email-exists', 'Bu e-posta adresi başka bir kullanıcıda kayıtlı'),
    ('error.user.update.username-exists', 'Bu kullanıcı adı şirkette başka bir kullanıcıda mevcut'),
    ('error.user.delete.already-deleted', 'Kullanıcı zaten silinmiş'),
    ('error.user.reset-password.is-deleted', 'Silinmiş kullanıcının şifresi sıfırlanamaz'),
    ('error.user.reset-password.self-not-allowed', 'Kendi şifrenizi değiştirmek için change-password kullanın'),
    ('error.user.restore.not-deleted', 'Kullanıcı silinmiş değil'),
    ('error.user.account-inactive', 'Hesap aktif değil'),
    ('error.user.account-locked', 'Hesap kilitli'),
    ('error.user.change-password.current-password-invalid', 'Mevcut şifre hatalı'),
    ('error.user.change-password.same-as-current', 'Yeni şifre mevcut şifre ile aynı olamaz'),
    ('error.user.change-password.recently-used', 'Bu şifre yakın zamanda kullanılmış'),

    -- Error Messages - Password Policy
    ('error.password-policy.invalid-expiry-days', 'Geçersiz şifre geçerlilik süresi'),
    ('error.password-policy.invalid-history-count', 'Şifre geçmişi sayısı 0-10 arası olmalı'),

    -- Error Messages - Company
    ('error.company.not-found', 'Şirket bulunamadı veya pasif durumda'),

    -- Error Messages - Menu Group
    ('error.menu-group.not-found', 'Menü grubu bulunamadı'),
    ('error.menu-group.code-exists', 'Menü grup kodu zaten mevcut'),
    ('error.menu-group.delete.already-deleted', 'Menü grubu zaten silinmiş'),
    ('error.menu-group.restore.not-deleted', 'Menü grubu silinmiş değil'),

    -- Error Messages - Localization
    ('error.localization.language-code-invalid', 'Geçersiz dil kodu: {0}'),
    ('error.localization.language-name-invalid', 'Geçersiz dil adı'),
    ('error.localization.key.not-found', 'Localization anahtarı bulunamadı'),
    ('error.localization.key.invalid', 'Geçersiz localization anahtarı'),
    ('error.localization.key.exists', 'Localization anahtarı zaten mevcut'),
    ('error.localization.domain-invalid', 'Geçersiz domain'),
    ('error.localization.translation.not-found', 'Çeviri bulunamadı'),

    -- Error Messages - Language
    ('error.language.not-found', 'Dil bulunamadı'),
    ('error.language.create.code-exists', 'Bu dil kodu zaten mevcut'),
    ('error.language.code-invalid', 'Geçersiz dil kodu. 2 karakter olmalı'),
    ('error.language.name-invalid', 'Geçersiz dil adı. En az 2 karakter olmalı'),
    ('error.language.delete.has-translations', 'Dil silinemez. Mevcut çevirileri var'),

    -- Error Messages - Currency
    ('error.currency.not-found', 'Para birimi bulunamadı'),
    ('error.currency.create.code-exists', 'Bu para birimi kodu zaten mevcut'),
    ('error.currency.code-invalid', 'Geçersiz para birimi kodu. 3 karakter olmalı'),
    ('error.currency.name-invalid', 'Geçersiz para birimi adı. En az 2 karakter olmalı'),
    ('error.currency.delete.in-use', 'Para birimi silinemez. Tenant tarafından kullanılıyor'),
    ('error.currency.delete.is-base-currency', 'Para birimi silinemez. Tenant tarafından base currency olarak kullanılıyor'),

    -- Error Messages - SQL
    ('error.sql.function-name-invalid', 'Geçersiz function adı: {0}'),
    ('error.sql.identifier-too-long', '''{0}'' tanımlayıcısı çok uzun: {1} karakter (maksimum {2})'),
    ('error.sql.command-not-allowed', 'SQL komutu izin verilmiyor. İzin verilen: {0}'),
    ('error.sql.stacked-query', 'Birden fazla SQL komutu (stacked query) kullanılması yasaktır'),
        ('error.sql.system-table-access', 'Sistem tablolarına erişim yasaktır'),

    -- Error Messages - Company CRUD
    ('error.company.create.code-exists', 'Şirket kodu zaten mevcut'),
    ('error.company.create.name-exists', 'Şirket adı zaten mevcut'),
    ('error.company.update.code-exists', 'Şirket kodu başka bir şirkette kullanılıyor'),
    ('error.company.update.name-exists', 'Şirket adı başka bir şirkette kullanılıyor'),
    ('error.country.not-found', 'Ülke kodu bulunamadı'),
    ('error.pagination.invalid', 'Geçersiz sayfa veya sayfa boyutu'),

    -- Error Messages - Tenant
    ('error.tenant.code-exists', 'Tenant kodu zaten mevcut'),
    ('error.tenant.not-found', 'Tenant bulunamadı'),

    -- Error Messages - Access Control
    ('error.access.superadmin-required', 'Bu işlem için SuperAdmin yetkisi gerekli'),
    ('error.access.platform-admin-required', 'Bu işlem için Platform Admin (SuperAdmin/Admin) yetkisi gerekli'),

    -- Error Messages - Provider Type
    ('error.provider-type.not-found', 'Provider tipi bulunamadı'),
    ('error.provider-type.id-required', 'Provider tip ID zorunlu'),
    ('error.provider-type.code-invalid', 'Geçersiz provider tip kodu. En az 2 karakter olmalı'),
    ('error.provider-type.name-invalid', 'Geçersiz provider tip adı. En az 2 karakter olmalı'),
    ('error.provider-type.code-exists', 'Provider tip kodu zaten mevcut'),
    ('error.provider-type.has-providers', 'Provider tipi silinemez. Bağlı provider kayıtları mevcut'),

    -- Error Messages - Provider
    ('error.provider.not-found', 'Provider bulunamadı'),
    ('error.provider.id-required', 'Provider ID zorunlu'),
    ('error.provider.type-required', 'Provider tipi zorunlu'),
    ('error.provider.code-invalid', 'Geçersiz provider kodu. En az 2 karakter olmalı'),
    ('error.provider.name-invalid', 'Geçersiz provider adı. En az 2 karakter olmalı'),
    ('error.provider.code-exists', 'Provider kodu zaten mevcut'),
    ('error.provider.has-games', 'Provider silinemez. Bağlı oyun kayıtları mevcut'),
    ('error.provider.has-payment-methods', 'Provider silinemez. Bağlı ödeme yöntemi kayıtları mevcut'),

    -- Error Messages - Provider Setting
    ('error.provider-setting.not-found', 'Provider ayarı bulunamadı'),
    ('error.provider-setting.provider-required', 'Provider ID zorunlu'),
    ('error.provider-setting.key-required', 'Ayar anahtarı zorunlu'),
    ('error.provider-setting.key-invalid', 'Geçersiz ayar anahtarı. En az 2 karakter olmalı'),
    ('error.provider-setting.value-required', 'Ayar değeri zorunlu'),

    -- Error Messages - Payment Method
    ('error.payment-method.not-found', 'Ödeme yöntemi bulunamadı'),
    ('error.payment-method.id-required', 'Ödeme yöntemi ID zorunlu'),
    ('error.payment-method.provider-required', 'Provider ID zorunlu'),
    ('error.payment-method.code-invalid', 'Geçersiz ödeme yöntemi kodu. En az 2 karakter olmalı'),
    ('error.payment-method.name-invalid', 'Geçersiz ödeme yöntemi adı. En az 2 karakter olmalı'),
    ('error.payment-method.type-invalid', 'Geçersiz ödeme tipi. CARD, EWALLET, BANK, CRYPTO, MOBILE, VOUCHER olmalı'),
    ('error.payment-method.code-exists', 'Ödeme yöntemi kodu bu provider altında zaten mevcut'),
    ('error.payment-method.in-use', 'Ödeme yöntemi silinemez. Tenant tarafından kullanılıyor'),

    -- Error Messages - Jurisdiction
    ('error.jurisdiction.not-found', 'Jurisdiction bulunamadı'),
    ('error.jurisdiction.id-required', 'Jurisdiction ID zorunlu'),
    ('error.jurisdiction.code-invalid', 'Geçersiz jurisdiction kodu. En az 2 karakter olmalı'),
    ('error.jurisdiction.name-invalid', 'Geçersiz jurisdiction adı. En az 2 karakter olmalı'),
    ('error.jurisdiction.country-code-invalid', 'Geçersiz ülke kodu. 2 karakterli ISO kodu olmalı'),
    ('error.jurisdiction.authority-type-invalid', 'Geçersiz otorite tipi. national, regional veya offshore olmalı'),
    ('error.jurisdiction.code-exists', 'Jurisdiction kodu zaten mevcut'),
    ('error.jurisdiction.has-kyc-policy', 'Jurisdiction silinemez. Bağlı KYC politikası mevcut'),
    ('error.jurisdiction.has-document-requirements', 'Jurisdiction silinemez. Bağlı belge gereksinimleri mevcut'),
    ('error.jurisdiction.has-level-requirements', 'Jurisdiction silinemez. Bağlı seviye gereksinimleri mevcut'),
    ('error.jurisdiction.has-gaming-policy', 'Jurisdiction silinemez. Bağlı sorumlu oyun politikası mevcut'),
    ('error.jurisdiction.in-use-by-tenants', 'Jurisdiction silinemez. Tenant tarafından kullanılıyor'),

    -- Error Messages - KYC Policy
    ('error.kyc-policy.not-found', 'KYC politikası bulunamadı'),
    ('error.kyc-policy.id-required', 'KYC politika ID zorunlu'),
    ('error.kyc-policy.jurisdiction-required', 'Jurisdiction ID zorunlu'),
    ('error.kyc-policy.already-exists-for-jurisdiction', 'Bu jurisdiction için KYC politikası zaten mevcut'),
    ('error.kyc-policy.verification-timing-invalid', 'Geçersiz doğrulama zamanı'),
    ('error.kyc-policy.min-age-invalid', 'Minimum yaş 18''den küçük olamaz'),

    -- Error Messages - KYC Document Requirement
    ('error.kyc-document-requirement.not-found', 'Belge gereksinimi bulunamadı'),
    ('error.kyc-document-requirement.id-required', 'Belge gereksinimi ID zorunlu'),
    ('error.kyc-document-requirement.jurisdiction-required', 'Jurisdiction ID zorunlu'),
    ('error.kyc-document-requirement.document-type-invalid', 'Geçersiz belge tipi'),
    ('error.kyc-document-requirement.required-for-invalid', 'Geçersiz zorunluluk tipi. all, deposit, withdrawal veya edd olmalı'),
    ('error.kyc-document-requirement.verification-method-invalid', 'Geçersiz doğrulama yöntemi. manual, automated veya hybrid olmalı'),
    ('error.kyc-document-requirement.already-exists', 'Bu jurisdiction ve belge tipi kombinasyonu zaten mevcut'),

    -- Error Messages - KYC Level Requirement
    ('error.kyc-level-requirement.not-found', 'Seviye gereksinimi bulunamadı'),
    ('error.kyc-level-requirement.id-required', 'Seviye gereksinimi ID zorunlu'),
    ('error.kyc-level-requirement.jurisdiction-required', 'Jurisdiction ID zorunlu'),
    ('error.kyc-level-requirement.level-invalid', 'Geçersiz KYC seviyesi. basic, standard veya enhanced olmalı'),
    ('error.kyc-level-requirement.level-order-invalid', 'Geçersiz seviye sırası. 0 veya üstü olmalı'),
    ('error.kyc-level-requirement.deadline-action-invalid', 'Geçersiz süre dolumu aksiyonu'),
    ('error.kyc-level-requirement.already-exists', 'Bu jurisdiction ve KYC seviyesi kombinasyonu zaten mevcut'),

    -- Error Messages - Responsible Gaming Policy
    ('error.responsible-gaming-policy.not-found', 'Sorumlu oyun politikası bulunamadı'),
    ('error.responsible-gaming-policy.id-required', 'Sorumlu oyun politikası ID zorunlu'),
    ('error.responsible-gaming-policy.jurisdiction-required', 'Jurisdiction ID zorunlu'),
    ('error.responsible-gaming-policy.already-exists-for-jurisdiction', 'Bu jurisdiction için sorumlu oyun politikası zaten mevcut'),

    -- Error Messages - Theme
    ('error.theme.not-found', 'Tema bulunamadı'),
    ('error.theme.id-required', 'Tema ID zorunlu'),
    ('error.theme.code-invalid', 'Geçersiz tema kodu. En az 2 karakter olmalı'),
    ('error.theme.name-invalid', 'Geçersiz tema adı. En az 2 karakter olmalı'),
    ('error.theme.code-exists', 'Tema kodu zaten mevcut'),

    -- Error Messages - Widget
    ('error.widget.not-found', 'Widget bulunamadı'),
    ('error.widget.id-required', 'Widget ID zorunlu'),
    ('error.widget.code-invalid', 'Geçersiz widget kodu. En az 2 karakter olmalı'),
    ('error.widget.name-invalid', 'Geçersiz widget adı. En az 2 karakter olmalı'),
    ('error.widget.category-invalid', 'Geçersiz widget kategorisi. CONTENT, GAME, ACCOUNT veya NAVIGATION olmalı'),
    ('error.widget.component-name-invalid', 'Geçersiz component adı. En az 2 karakter olmalı'),
    ('error.widget.code-exists', 'Widget kodu zaten mevcut'),

    -- Error Messages - UI Position
    ('error.ui-position.not-found', 'UI pozisyonu bulunamadı'),
    ('error.ui-position.id-required', 'UI pozisyon ID zorunlu'),
    ('error.ui-position.code-invalid', 'Geçersiz pozisyon kodu. En az 2 karakter olmalı'),
    ('error.ui-position.name-invalid', 'Geçersiz pozisyon adı. En az 2 karakter olmalı'),
    ('error.ui-position.code-exists', 'UI pozisyon kodu zaten mevcut'),

    -- Error Messages - Navigation Template
    ('error.navigation-template.not-found', 'Navigasyon şablonu bulunamadı'),
    ('error.navigation-template.id-required', 'Navigasyon şablon ID zorunlu'),
    ('error.navigation-template.code-invalid', 'Geçersiz şablon kodu. En az 2 karakter olmalı'),
    ('error.navigation-template.name-invalid', 'Geçersiz şablon adı. En az 2 karakter olmalı'),
    ('error.navigation-template.code-exists', 'Navigasyon şablon kodu zaten mevcut'),
    ('error.navigation-template.has-items', 'Navigasyon şablonu silinemez. Bağlı öğeleri mevcut'),

    -- Error Messages - Navigation Template Item
    ('error.navigation-template-item.not-found', 'Şablon öğesi bulunamadı'),
    ('error.navigation-template-item.id-required', 'Şablon öğesi ID zorunlu'),
    ('error.navigation-template-item.template-required', 'Şablon ID zorunlu'),
    ('error.navigation-template-item.menu-location-invalid', 'Geçersiz menü konumu. En az 2 karakter olmalı'),
    ('error.navigation-template-item.target-type-invalid', 'Geçersiz hedef tipi. INTERNAL, EXTERNAL veya ACTION olmalı'),
    ('error.navigation-template-item.parent-not-found', 'Üst öğe bulunamadı'),
    ('error.navigation-template-item.self-parent', 'Bir öğe kendi kendisinin üst öğesi olamaz'),
    ('error.navigation-template-item.has-children', 'Öğe silinemez. Alt öğeleri mevcut'),

    -- Tenant Navigation Errors
    ('error.tenant-navigation.not-found', 'Navigasyon öğesi bulunamadı'),
    ('error.tenant-navigation.already-initialized', 'Tenant navigasyonu zaten mevcut'),
    ('error.tenant-navigation.is-locked', 'Kilitli öğe silinemez'),
    ('error.tenant-navigation.has-children', 'Öğe silinemez. Alt öğeleri mevcut'),
    ('error.tenant-navigation.parent-not-found', 'Üst öğe bulunamadı'),
    ('error.tenant-navigation.self-parent', 'Bir öğe kendi kendisinin üst öğesi olamaz'),
    ('error.tenant-navigation.readonly-field-update', 'Salt okunur alan güncellenemez'),
    ('error.tenant-navigation.invalid-item-ids', 'Geçersiz öğe ID listesi'),

    -- Tenant Theme Errors
    ('error.tenant-theme.not-found', 'Tenant tema yapılandırması bulunamadı'),
    ('error.tenant-theme.no-active-theme', 'Aktif tema bulunamadı'),

    -- Tenant Layout Errors
    ('error.tenant-layout.not-found', 'Layout bulunamadı'),
    ('error.tenant-layout.no-filter', 'En az bir filtre parametresi gerekli'),

    -- Error Messages - Messaging
    ('error.messaging.sender-id-required', 'Gönderen kullanıcı ID zorunludur'),
    ('error.messaging.recipient-id-required', 'Alıcı kullanıcı ID zorunludur'),
    ('error.messaging.subject-required', 'Mesaj konusu zorunludur'),
    ('error.messaging.body-required', 'Mesaj içeriği zorunludur'),
    ('error.messaging.user-id-required', 'Kullanıcı ID zorunludur'),
    ('error.messaging.invalid-parameters', 'Geçersiz parametreler'),
    ('error.messaging.draft-id-required', 'Draft ID zorunludur'),
    ('error.messaging.draft-not-found', 'Draft bulunamadı veya silinmiş'),
    ('error.messaging.draft-not-found-or-published', 'Draft bulunamadı veya zaten yayınlanmış'),
    ('error.messaging.draft-already-published', 'Draft zaten yayınlanmış'),
    ('error.messaging.draft-not-published', 'Draft yayınlanmamış, geri alınamaz'),
    ('error.messaging.cannot-send-to-self', 'Kendinize mesaj gönderemezsiniz'),
    ('error.messaging.recipient-not-found', 'Alıcı bulunamadı veya aktif değil'),
    ('error.messaging.no-recipients', 'Belirtilen filtrelerle eşleşen alıcı bulunamadı'),
    ('error.messaging.not-draft-owner', 'Bu taslağın sahibi değilsiniz'),
    ('error.messaging.draft-not-editable', 'Taslak düzenlenebilir durumda değil'),
    ('error.messaging.draft-not-scheduled', 'Taslak zamanlanmış durumda değil'),
    ('error.messaging.too-many-recipients', 'Çok fazla alıcı (maksimum 10000)'),
    ('error.messaging.draft-already-cancelled', 'Taslak zaten iptal edilmiş'),
    ('validation.messaging.at-least-one-field', 'En az bir alan doldurulmalıdır'),
    ('validation.messaging.invalid-priority', 'Öncelik normal, important veya urgent olmalıdır'),
    ('validation.messaging.invalid-message-type', 'Geçersiz mesaj tipi'),
    ('error.field.unauthorized-modification', 'Bu alanı değiştirme yetkiniz bulunmamaktadır'),

    -- Erişim Kontrolü (yeni)
    ('error.access.permission-denied', 'Bu işlem için yetki yok'),
    ('error.access.user-scope-denied', 'Kullanıcı kapsamı dışında işlem yapılamaz'),

    -- Rol (yeni)
    ('error.role.global-only', 'Bu rol sadece global kapsamda kullanılabilir'),
    ('error.role.hierarchy-violation', 'Rol hiyerarşi ihlali'),
    ('error.role.insufficient-level', 'Yetersiz rol seviyesi'),
    ('error.role.target-level-violation', 'Hedef rol seviyesi ihlali'),
    ('error.role.tenant-required', 'Tenant ID zorunludur'),

    -- Kullanıcı (yeni)
    ('error.user.concurrent-modification', 'Kullanıcı başka bir işlem tarafından değiştirildi'),
    ('error.user.delete.self-not-allowed', 'Kendi hesabınızı silemezsiniz'),
    ('error.user.unlock.is-deleted', 'Silinmiş kullanıcının kilidi açılamaz'),
    ('error.user.unlock.self-not-allowed', 'Kendi hesabınızın kilidini açamazsınız'),

    -- Departman
    ('error.department.not-found', 'Departman bulunamadı'),

    -- Tenant (yeni)
    ('error.tenant.id-required', 'Tenant ID zorunludur'),
    ('error.tenant-provider.not-found', 'Tenant provider kaydı bulunamadı'),
    ('error.tenant-game.not-found', 'Tenant oyun kaydı bulunamadı'),
    ('error.tenant-payment-method.not-found', 'Tenant ödeme yöntemi kaydı bulunamadı'),

    -- Provider (yeni)
    ('error.provider.invalid-rollout-status', 'Geçersiz rollout durumu'),
    ('error.provider.not-game-type', 'Provider oyun tipinde değil'),
    ('error.provider.not-payment-type', 'Provider ödeme tipinde değil'),

    -- Oyun (Game DB)
    ('error.game.not-found', 'Oyun bulunamadı'),
    ('error.game.id-required', 'Oyun ID zorunludur'),
    ('error.game.catalog-data-required', 'Katalog verisi zorunludur'),
    ('error.game.currency-code-required', 'Para birimi kodu zorunludur'),
    ('error.game.limits-data-required', 'Limit verisi zorunludur'),
    ('error.game.limits-invalid-format', 'Geçersiz limit veri formatı'),
    ('error.game.player-required', 'Oyuncu ID zorunludur'),
    ('error.game.session-not-found', 'Oyun oturumu bulunamadı'),
    ('error.game.session-expired', 'Oyun oturumunun süresi dolmuş'),

    -- Cüzdan (Game Gateway)
    ('error.wallet.player-not-found', 'Oyuncu bulunamadı'),
    ('error.wallet.player-frozen', 'Oyuncu hesabı dondurulmuş veya pasif'),
    ('error.wallet.wallet-not-found', 'Belirtilen para birimi için cüzdan bulunamadı'),
    ('error.wallet.insufficient-balance', 'Yetersiz bakiye'),
    ('error.wallet.amount-required', 'Tutar zorunludur ve pozitif olmalıdır'),
    ('error.wallet.idempotency-key-required', 'İdempotency anahtarı zorunludur'),

    -- Ödeme Yöntemi (Finance DB — yeni)
    ('error.payment-method.data-required', 'Ödeme yöntemi verisi zorunludur'),
    ('error.payment-method.currency-code-required', 'Para birimi kodu zorunludur'),
    ('error.payment-method.limits-data-required', 'Limit verisi zorunludur'),
    ('error.payment-method.limits-invalid-format', 'Geçersiz limit veri formatı'),

    -- Oyuncu (Tenant DB)
    ('error.player.id-required', 'Oyuncu ID zorunludur'),
    ('error.player-limit.invalid-type', 'Geçersiz limit tipi'),

    -- Finansal Limit
    ('error.financial-limit.currency-code-required', 'Para birimi kodu zorunludur'),
    ('error.financial-limit.invalid-type', 'Geçersiz finansal limit tipi'),

    -- İşlem / Operasyon Tipi Senkronizasyonu
    ('error.transaction-type.data-required', 'İşlem tipi verisi zorunludur'),
    ('error.transaction-type.invalid-format', 'İşlem tipi verisi JSON dizisi olmalıdır'),
    ('error.operation-type.data-required', 'Operasyon tipi verisi zorunludur'),
    ('error.operation-type.invalid-format', 'Operasyon tipi verisi JSON dizisi olmalıdır'),

    -- Shadow Mode
    ('error.shadow-tester.player-id-required', 'Oyuncu ID zorunludur'),
    ('error.shadow-tester.not-found', 'Shadow tester bulunamadı'),

    -- Oyuncu Segmentasyonu (Kategori & Grup)
    ('error.player-category.code-required', 'Kategori kodu zorunludur'),
    ('error.player-category.name-required', 'Kategori adı zorunludur'),
    ('error.player-category.code-exists', 'Kategori kodu zaten mevcut'),
    ('error.player-category.not-found', 'Oyuncu kategorisi bulunamadı'),
    ('error.player-category.already-inactive', 'Oyuncu kategorisi zaten deaktif'),

    ('error.player-group.code-required', 'Grup kodu zorunludur'),
    ('error.player-group.name-required', 'Grup adı zorunludur'),
    ('error.player-group.code-exists', 'Grup kodu zaten mevcut'),
    ('error.player-group.not-found', 'Oyuncu grubu bulunamadı'),
    ('error.player-group.already-inactive', 'Oyuncu grubu zaten deaktif'),

    -- Oyuncu Sınıflandırma
    ('error.player-classification.player-not-found', 'Oyuncu bulunamadı'),
    ('error.player-classification.group-not-found', 'Grup bulunamadı veya aktif değil'),
    ('error.player-classification.category-not-found', 'Kategori bulunamadı veya aktif değil'),
    ('error.player-classification.no-assignment', 'En az bir grup veya kategori gereklidir'),
    ('error.player-classification.no-players', 'Oyuncu listesi boş'),

    -- Jurisdiction (yeni)
    ('error.jurisdiction.has-retention-policies', 'Jurisdiction silinemez. Bağlı veri saklama politikası mevcut'),

    -- Veri Saklama Politikası
    ('error.data-retention-policy.not-found', 'Veri saklama politikası bulunamadı'),
    ('error.data-retention-policy.id-required', 'Politika ID zorunludur'),
    ('error.data-retention-policy.jurisdiction-required', 'Jurisdiction ID zorunludur'),
    ('error.data-retention-policy.data-category-invalid', 'Geçersiz veri kategorisi'),
    ('error.data-retention-policy.retention-days-invalid', 'Geçersiz saklama süresi'),
    ('error.data-retention-policy.already-exists', 'Bu jurisdiction ve kategori için politika zaten mevcut'),

    -- Kripto Para
    ('error.cryptocurrency.not-found', 'Kripto para bulunamadı'),
    ('error.cryptocurrency.symbol-required', 'Kripto para sembolü zorunludur'),
    ('error.cryptocurrency.name-invalid', 'Geçersiz kripto para adı'),
    ('error.cryptocurrency.delete.in-use', 'Kripto para silinemez. Kullanımda'),

    -- Döviz Kurları
    ('error.currency-rates.base-currency-required', 'Baz para birimi zorunludur'),
    ('error.currency-rates.provider-required', 'Kur sağlayıcısı zorunludur'),
    ('error.currency-rates.rates-empty', 'Kur verisi boş olamaz'),
    ('error.currency-rates.timestamp-required', 'Zaman damgası zorunludur'),

    -- Kripto Kurları
    ('error.crypto-rates.base-currency-required', 'Baz para birimi zorunludur'),
    ('error.crypto-rates.provider-required', 'Kur sağlayıcısı zorunludur'),
    ('error.crypto-rates.rates-empty', 'Kur verisi boş olamaz'),
    ('error.crypto-rates.timestamp-required', 'Zaman damgası zorunludur'),

    -- Mesajlaşma — Tenant (kampanya, şablon, gelen kutusu)
    ('error.messaging.player-id-required', 'Oyuncu ID zorunludur'),
    ('error.messaging.message-not-found', 'Mesaj bulunamadı'),
    ('error.messaging.invalid-message-type', 'Geçersiz mesaj tipi'),
    ('error.messaging.invalid-channel-type', 'Geçersiz kanal tipi'),
    ('error.messaging.template-not-found', 'Mesaj şablonu bulunamadı'),
    ('error.messaging.template-code-required', 'Şablon kodu zorunludur'),
    ('error.messaging.template-code-exists', 'Şablon kodu zaten mevcut'),
    ('error.messaging.template-name-required', 'Şablon adı zorunludur'),
    ('error.messaging.invalid-template-status', 'Geçersiz şablon durumu'),
    ('error.messaging.campaign-not-found', 'Mesajlaşma kampanyası bulunamadı'),
    ('error.messaging.campaign-name-required', 'Kampanya adı zorunludur'),
    ('error.messaging.campaign-not-editable', 'Kampanya düzenlenemez'),
    ('error.messaging.campaign-not-publishable', 'Kampanya yayınlanamaz'),
    ('error.messaging.campaign-not-cancellable', 'Kampanya iptal edilemez'),

    -- Bonus Motoru — Bonus Tipleri
    ('error.bonus-type.not-found', 'Bonus tipi bulunamadı'),
    ('error.bonus-type.id-required', 'Bonus tip ID zorunludur'),
    ('error.bonus-type.code-required', 'Bonus tip kodu zorunludur'),
    ('error.bonus-type.code-exists', 'Bonus tip kodu zaten mevcut'),
    ('error.bonus-type.name-required', 'Bonus tip adı zorunludur'),
    ('error.bonus-type.category-required', 'Bonus kategorisi zorunludur'),
    ('error.bonus-type.value-type-required', 'Değer tipi zorunludur'),

    -- Bonus Motoru — Bonus Kuralları
    ('error.bonus-rule.not-found', 'Bonus kuralı bulunamadı'),
    ('error.bonus-rule.not-found-or-inactive', 'Bonus kuralı bulunamadı veya aktif değil'),
    ('error.bonus-rule.id-required', 'Bonus kural ID zorunludur'),
    ('error.bonus-rule.code-required', 'Bonus kural kodu zorunludur'),
    ('error.bonus-rule.code-exists', 'Bonus kural kodu zaten mevcut'),
    ('error.bonus-rule.name-required', 'Bonus kural adı zorunludur'),
    ('error.bonus-rule.trigger-config-required', 'Trigger konfigürasyonu zorunludur'),
    ('error.bonus-rule.reward-config-required', 'Ödül konfigürasyonu zorunludur'),
    ('error.bonus-rule.invalid-evaluation-type', 'Geçersiz değerlendirme tipi'),

    -- Bonus Motoru — Bonus Ödülleri
    ('error.bonus-award.not-found', 'Bonus ödülü bulunamadı'),
    ('error.bonus-award.id-required', 'Bonus ödül ID zorunludur'),
    ('error.bonus-award.player-required', 'Oyuncu ID zorunludur'),
    ('error.bonus-award.rule-required', 'Bonus kural ID zorunludur'),
    ('error.bonus-award.currency-required', 'Para birimi zorunludur'),
    ('error.bonus-award.wallet-not-found', 'Bonus cüzdanı bulunamadı'),
    ('error.bonus-award.cannot-cancel', 'Bonus ödülü iptal edilemez'),
    ('error.bonus-award.not-completable', 'Bonus ödülü tamamlanamaz'),
    ('error.bonus-award.wagering-not-complete', 'Çevrim şartı karşılanmadı'),
    ('error.bonus-award.amount-required', 'Bonus tutarı zorunludur'),

    -- Bonus Talep (Manuel bonus talep sistemi)
    ('error.bonus-request.not-found', 'Bonus talebi bulunamadı'),
    ('error.bonus-request.invalid-status', 'Bu işlem için geçersiz talep durumu'),
    ('error.bonus-request.player-required', 'Oyuncu ID zorunludur'),
    ('error.bonus-request.invalid-source', 'Geçersiz talep kaynağı. player veya operator olmalıdır'),
    ('error.bonus-request.type-required', 'Bonus tipi zorunludur'),
    ('error.bonus-request.description-required', 'Açıklama zorunludur'),
    ('error.bonus-request.amount-required', 'Operatör talepleri için tutar zorunludur'),
    ('error.bonus-request.currency-required', 'Operatör talepleri için para birimi zorunludur'),
    ('error.bonus-request.hold-reason-required', 'Beklemeye alma nedeni zorunludur'),
    ('error.bonus-request.review-note-required', 'Ret için inceleme notu zorunludur'),
    ('error.bonus-request.rollback-reason-required', 'Geri alma nedeni zorunludur'),
    ('error.bonus-request.rollback-not-allowed', 'Bu durumdan geri alma yapılamaz'),
    ('error.bonus-request.type-not-requestable', 'Bu bonus tipi için talep oluşturulamaz'),
    ('error.bonus-request.player-not-eligible', 'Oyuncu bu bonus tipine uygun değil'),
    ('error.bonus-request.pending-exists', 'Bu bonus tipi için bekleyen talep zaten mevcut'),
    ('error.bonus-request.cooldown-after-approved', 'Onaylanan talep sonrası bekleme süresi henüz dolmadı'),
    ('error.bonus-request.cooldown-after-rejected', 'Reddedilen talep sonrası bekleme süresi henüz dolmadı'),
    ('error.bonus-request.not-owner', 'Bu talebin sahibi değilsiniz'),

    -- Bonus Talep Ayarları
    ('error.bonus-request-settings.not-found', 'Bonus talep ayarı bulunamadı'),
    ('error.bonus-request-settings.display-name-required', 'Görüntü adı zorunludur'),
    ('error.bonus-request-settings.invalid-display-name', 'Geçersiz görüntü adı JSON formatı'),
    ('error.bonus-request-settings.invalid-rules-content', 'Geçersiz kurallar içeriği JSON formatı'),
    ('error.bonus-request-settings.invalid-eligible-groups', 'Geçersiz uygun gruplar JSON formatı'),
    ('error.bonus-request-settings.invalid-eligible-categories', 'Geçersiz uygun kategoriler JSON formatı'),
    ('error.bonus-request-settings.invalid-usage-criteria', 'Geçersiz kullanım kriterleri JSON formatı'),

    -- Bonus Eşleme (Provider bonus takibi)
    ('error.bonus-mapping.award-required', 'Bonus ödül ID zorunludur'),
    ('error.bonus-mapping.provider-required', 'Sağlayıcı kodu zorunludur'),
    ('error.bonus-mapping.data-required', 'Bonus eşleme verisi zorunludur'),
    ('error.bonus-mapping.not-found', 'Sağlayıcı bonus eşlemesi bulunamadı'),
    ('error.bonus-mapping.invalid-status', 'Geçersiz bonus eşleme durumu'),

    -- Uzlaştırma (Provider uzlaştırma)
    ('error.reconciliation.provider-required', 'Uzlaştırma için sağlayıcı kodu zorunludur'),
    ('error.reconciliation.date-required', 'Rapor tarihi zorunludur'),

    -- Bonus Motoru — Kampanyalar
    ('error.campaign.not-found', 'Kampanya bulunamadı'),
    ('error.campaign.id-required', 'Kampanya ID zorunludur'),
    ('error.campaign.code-required', 'Kampanya kodu zorunludur'),
    ('error.campaign.code-exists', 'Kampanya kodu zaten mevcut'),
    ('error.campaign.name-required', 'Kampanya adı zorunludur'),
    ('error.campaign.type-required', 'Kampanya tipi zorunludur'),
    ('error.campaign.dates-required', 'Kampanya tarihleri zorunludur'),
    ('error.campaign.end-before-start', 'Bitiş tarihi başlangıçtan önce olamaz'),
    ('error.campaign.invalid-status', 'Geçersiz kampanya durumu'),
    ('error.campaign.invalid-award-strategy', 'Geçersiz ödül stratejisi'),

    -- Bonus Motoru — Promosyon Kodları
    ('error.promo.not-found', 'Promosyon bulunamadı'),
    ('error.promo.id-required', 'Promosyon ID zorunludur'),
    ('error.promo.code-required', 'Promosyon kodu zorunludur'),
    ('error.promo.code-id-required', 'Promosyon kod ID zorunludur'),
    ('error.promo.code-exists', 'Promosyon kodu zaten mevcut'),
    ('error.promo.name-required', 'Promosyon adı zorunludur'),
    ('error.promo.invalid-status', 'Geçersiz promosyon durumu'),
    ('error.promo.player-required', 'Oyuncu ID zorunludur'),

    -- Finance Gateway — Ödeme Oturumları
    ('error.finance.session-player-required', 'Ödeme oturumu için oyuncu ID zorunludur'),
    ('error.finance.session-type-required', 'Oturum tipi zorunludur'),
    ('error.finance.session-amount-required', 'Ödeme oturumu için tutar zorunludur'),
    ('error.finance.session-not-found', 'Ödeme oturumu bulunamadı'),
    ('error.finance.session-expired', 'Ödeme oturumunun süresi dolmuş'),

    -- Finance Gateway — Para Yatırma
    ('error.deposit.player-required', 'Oyuncu ID zorunludur'),
    ('error.deposit.invalid-amount', 'Para yatırma tutarı sıfırdan büyük olmalıdır'),
    ('error.deposit.idempotency-required', 'İdempotency anahtarı zorunludur'),
    ('error.deposit.player-not-active', 'Oyuncu hesabı aktif değil'),
    ('error.deposit.wallet-not-found', 'Oyuncu cüzdanı bulunamadı'),
    ('error.deposit-confirm.transaction-not-found', 'Bekleyen para yatırma işlemi bulunamadı'),
    ('error.deposit-confirm.player-mismatch', 'Oyuncu ID para yatırma işlemiyle eşleşmiyor'),
    ('error.deposit-fail.already-confirmed', 'Onaylanmış para yatırma başarısız yapılamaz'),

    -- Finance Gateway — Para Çekme
    ('error.withdrawal.insufficient-balance', 'Para çekme için yetersiz bakiye'),
    ('error.withdrawal.active-wagering-incomplete', 'Aktif bonus çevrim şartı tamamlanmamış'),
    ('error.withdrawal-cancel.already-confirmed', 'Onaylanmış para çekme iptal edilemez'),
    ('error.withdrawal-fail.already-confirmed', 'Onaylanmış para çekme başarısız yapılamaz'),

    -- Finance Gateway — Onay Akışı
    ('error.workflow.invalid-type', 'Geçersiz onay akışı tipi'),
    ('error.workflow.already-pending', 'Bu işlem için aktif bir onay akışı zaten mevcut'),
    ('error.workflow.not-found', 'Onay akışı bulunamadı'),
    ('error.workflow.not-pending', 'Onay akışı beklemede durumunda değil'),
    ('error.workflow.not-in-review', 'Onay akışı inceleme durumunda değil'),

    -- Finance Gateway — Hesap Düzeltme
    ('error.adjustment.not-found', 'Düzeltme kaydı bulunamadı'),
    ('error.adjustment.not-pending', 'Düzeltme beklemede durumunda değil'),
    ('error.adjustment.invalid-direction', 'Yön CREDIT veya DEBIT olmalıdır'),
    ('error.adjustment.invalid-wallet-type', 'Cüzdan tipi REAL veya BONUS olmalıdır'),
    ('error.adjustment.invalid-type', 'Geçersiz düzeltme tipi'),
    ('error.adjustment.provider-required', 'Oyun düzeltmesi için provider ID zorunludur'),
    ('error.adjustment.insufficient-balance', 'Borç düzeltmesi için yetersiz bakiye'),

    -- Finance Gateway — Komisyon Hesaplama
    ('error.calculate-fee.invalid-direction', 'Fee hesaplaması için geçersiz yön'),
    ('error.calculate-fee.method-not-found', 'Ödeme yöntemi limitleri bulunamadı'),

    -- Support — Ticket Sistemi
    ('error.support.player-required', 'Oyuncu ID zorunludur'),
    ('error.support.subject-required', 'Ticket başlığı zorunludur'),
    ('error.support.description-required', 'Ticket açıklaması zorunludur'),
    ('error.support.invalid-channel', 'Geçersiz iletişim kanalı'),
    ('error.support.invalid-priority', 'Geçersiz öncelik seviyesi'),
    ('error.support.invalid-created-by-type', 'Geçersiz oluşturucu tipi'),
    ('error.support.ticket-not-found', 'Ticket bulunamadı'),
    ('error.support.ticket-invalid-status', 'Bu işlem için geçersiz ticket durumu'),
    ('error.support.ticket-not-owner', 'Bu ticket bu oyuncuya ait değil'),
    ('error.support.ticket-already-assigned', 'Ticket zaten bu temsilciye atanmış'),
    ('error.support.ticket-closed', 'Kapalı ticket üzerinde işlem yapılamaz'),
    ('error.support.resolve-note-required', 'Çözüm notu zorunludur'),
    ('error.support.max-open-tickets-reached', 'Açık ticket limiti dolmuş'),
    ('error.support.ticket-cooldown-active', 'Ticket oluşturma bekleme süresi dolmamış'),

    -- Support — Oyuncu Notu
    ('error.support.note-not-found', 'Not bulunamadı'),
    ('error.support.note-already-deleted', 'Not zaten silinmiş'),
    ('error.support.note-content-required', 'Not içeriği zorunludur'),
    ('error.support.invalid-note-type', 'Geçersiz not tipi'),

    -- Support — Temsilci Atama
    ('error.support.representative-reason-required', 'Temsilci değişiklik nedeni zorunludur'),
    ('error.support.representative-already-assigned', 'Aynı temsilci zaten atanmış'),

    -- Support — Hoşgeldin Araması
    ('error.support.welcome-task-not-found', 'Hoşgeldin araması görevi bulunamadı'),
    ('error.support.welcome-task-not-in-progress', 'Görev uygun durumda değil'),
    ('error.support.welcome-task-not-assignable', 'Görev atanamaz durumda'),
    ('error.support.invalid-call-result', 'Geçersiz arama sonucu'),
    ('error.support.invalid-reschedule-result', 'Geçersiz yeniden planlama sonucu'),
    ('error.support.assigned-to-required', 'Atanan kişi ID zorunludur'),

    -- Support — Kategori
    ('error.support.category-not-found', 'Ticket kategorisi bulunamadı'),
    ('error.support.parent-category-not-found', 'Üst kategori bulunamadı'),
    ('error.support.category-has-children', 'Alt kategorisi olan kategori silinemez'),
    ('error.support.category-code-exists', 'Kategori kodu zaten mevcut'),
    ('error.support.category-code-required', 'Kategori kodu zorunludur'),
    ('error.support.category-name-required', 'Kategori adı zorunludur'),
    ('error.support.invalid-category-name-format', 'Geçersiz kategori adı JSON formatı'),
    ('error.support.invalid-category-description-format', 'Geçersiz kategori açıklama JSON formatı'),

    -- Support — Etiket
    ('error.support.tag-not-found', 'Etiket bulunamadı'),
    ('error.support.tag-name-exists', 'Etiket adı zaten mevcut'),
    ('error.support.tag-name-required', 'Etiket adı zorunludur'),
    ('error.support.invalid-tag-color', 'Geçersiz renk kodu (HEX formatı bekleniyor)'),

    -- Support — Hazır Yanıt
    ('error.support.canned-response-not-found', 'Hazır yanıt bulunamadı'),

    -- Support — Genel
    ('error.support.no-fields-to-update', 'Güncellenecek en az bir alan gereklidir'),

    -- Oyuncu Kayıt
    ('error.player-register.username-required', 'Kullanıcı adı zorunludur'),
    ('error.player-register.email-required', 'E-posta adresi zorunludur'),
    ('error.player-register.password-required', 'Şifre zorunludur'),
    ('error.player-register.token-required', 'Doğrulama tokeni zorunludur'),
    ('error.player-register.username-exists', 'Kullanıcı adı zaten mevcut'),
    ('error.player-register.email-exists', 'E-posta adresi zaten kayıtlı'),

    -- Oyuncu E-posta Doğrulama
    ('error.player-verify.token-required', 'Doğrulama tokeni zorunludur'),
    ('error.player-verify.token-not-found', 'Doğrulama tokeni bulunamadı'),
    ('error.player-verify.token-expired', 'Doğrulama tokeninin süresi dolmuş'),
    ('error.player-verify.already-verified', 'E-posta zaten doğrulanmış'),
    ('error.player-verify.player-required', 'Oyuncu ID zorunludur'),
    ('error.player-verify.player-not-found', 'Oyuncu bulunamadı'),

    -- Oyuncu Kimlik Doğrulama
    ('error.player-auth.email-required', 'E-posta adresi zorunludur'),
    ('error.player-auth.invalid-credentials', 'Geçersiz kimlik bilgileri'),
    ('error.player-auth.account-locked', 'Hesap kilitli'),
    ('error.player-auth.account-suspended', 'Hesap askıya alınmış'),
    ('error.player-auth.account-closed', 'Hesap kapatılmış'),
    ('error.player-auth.player-required', 'Oyuncu ID zorunludur'),
    ('error.player-auth.player-not-found', 'Oyuncu bulunamadı'),

    -- Oyuncu Şifre
    ('error.player-password.player-required', 'Oyuncu ID zorunludur'),
    ('error.player-password.password-required', 'Şifre zorunludur'),
    ('error.player-password.player-not-found', 'Oyuncu bulunamadı'),
    ('error.player-password.account-inactive', 'Hesap aktif değil'),
    ('error.player-password.token-required', 'Sıfırlama tokeni zorunludur'),
    ('error.player-password.token-not-found', 'Sıfırlama tokeni bulunamadı'),
    ('error.player-password.token-expired', 'Sıfırlama tokeninin süresi dolmuş'),

    -- Oyuncu Profil
    ('error.player-profile.player-required', 'Oyuncu ID zorunludur'),
    ('error.player-profile.player-not-found', 'Oyuncu bulunamadı'),
    ('error.player-profile.already-exists', 'Profil zaten mevcut'),
    ('error.player-profile.not-found', 'Profil bulunamadı'),

    -- Oyuncu Kimlik Belgesi
    ('error.player-identity.player-required', 'Oyuncu ID zorunludur'),
    ('error.player-identity.identity-required', 'Kimlik numarası zorunludur'),
    ('error.player-identity.player-not-found', 'Oyuncu bulunamadı'),

    -- Oyuncu BO Yönetimi
    ('error.player.player-required', 'Oyuncu ID zorunludur'),
    ('error.player.not-found', 'Oyuncu bulunamadı'),
    ('error.player.invalid-status', 'Geçersiz oyuncu durumu'),
    ('error.player.status-unchanged', 'Durum zaten aynı'),

    -- Cüzdan
    ('error.wallet.player-required', 'Oyuncu ID zorunludur'),
    ('error.wallet.currency-required', 'Para birimi kodu zorunludur'),
    ('error.wallet.player-not-active', 'Oyuncu hesabı aktif değil'),

    -- KYC Vaka
    ('error.kyc-case.player-required', 'Oyuncu ID zorunludur'),
    ('error.kyc-case.player-not-found', 'Oyuncu bulunamadı'),
    ('error.kyc-case.case-required', 'Vaka ID zorunludur'),
    ('error.kyc-case.not-found', 'KYC vakası bulunamadı'),
    ('error.kyc-case.status-required', 'Durum zorunludur'),
    ('error.kyc-case.status-unchanged', 'Durum zaten aynı'),
    ('error.kyc-case.reviewer-required', 'İnceleyici ID zorunludur'),

    -- KYC Belge
    ('error.kyc-document.player-required', 'Oyuncu ID zorunludur'),
    ('error.kyc-document.player-not-found', 'Oyuncu bulunamadı'),
    ('error.kyc-document.document-required', 'Belge ID zorunludur'),
    ('error.kyc-document.not-found', 'Belge bulunamadı'),
    ('error.kyc-document.type-required', 'Belge türü zorunludur'),
    ('error.kyc-document.storage-type-required', 'Depolama türü zorunludur'),
    ('error.kyc-document.hash-required', 'Dosya hash değeri zorunludur'),
    ('error.kyc-document.status-required', 'Durum zorunludur'),
    ('error.kyc-document.case-not-found', 'KYC vakası bulunamadı'),

    -- KYC Kısıtlama
    ('error.kyc-restriction.player-required', 'Oyuncu ID zorunludur'),
    ('error.kyc-restriction.player-not-found', 'Oyuncu bulunamadı'),
    ('error.kyc-restriction.restriction-required', 'Kısıtlama ID zorunludur'),
    ('error.kyc-restriction.type-required', 'Kısıtlama türü zorunludur'),
    ('error.kyc-restriction.not-found', 'Kısıtlama bulunamadı'),
    ('error.kyc-restriction.not-active', 'Kısıtlama aktif değil'),
    ('error.kyc-restriction.cannot-revoke', 'Kısıtlama kaldırılamaz'),
    ('error.kyc-restriction.min-duration-not-met', 'Minimum süre henüz dolmadı'),

    -- KYC Limit
    ('error.kyc-limit.player-required', 'Oyuncu ID zorunludur'),
    ('error.kyc-limit.player-not-found', 'Oyuncu bulunamadı'),
    ('error.kyc-limit.limit-required', 'Limit ID zorunludur'),
    ('error.kyc-limit.type-required', 'Limit türü zorunludur'),
    ('error.kyc-limit.value-required', 'Limit değeri zorunludur'),
    ('error.kyc-limit.not-found', 'Limit bulunamadı'),
    ('error.kyc-limit.not-active', 'Limit aktif değil'),

    -- KYC AML
    ('error.kyc-aml.player-required', 'Oyuncu ID zorunludur'),
    ('error.kyc-aml.player-not-found', 'Oyuncu bulunamadı'),
    ('error.kyc-aml.flag-required', 'AML işareti ID zorunludur'),
    ('error.kyc-aml.flag-type-required', 'İşaret türü zorunludur'),
    ('error.kyc-aml.severity-required', 'Ciddiyet seviyesi zorunludur'),
    ('error.kyc-aml.description-required', 'Açıklama zorunludur'),
    ('error.kyc-aml.not-found', 'AML işareti bulunamadı'),
    ('error.kyc-aml.status-required', 'Durum zorunludur'),
    ('error.kyc-aml.status-unchanged', 'Durum zaten aynı'),
    ('error.kyc-aml.assignee-required', 'Atanan kişi ID zorunludur'),
    ('error.kyc-aml.decision-required', 'Karar zorunludur'),
    ('error.kyc-aml.decision-by-required', 'Karar veren kişi ID zorunludur'),

    -- KYC Yetki Alanı
    ('error.kyc-jurisdiction.player-required', 'Oyuncu ID zorunludur'),
    ('error.kyc-jurisdiction.player-not-found', 'Oyuncu bulunamadı'),
    ('error.kyc-jurisdiction.country-required', 'Ülke kodu zorunludur'),
    ('error.kyc-jurisdiction.already-exists', 'Yetki alanı kaydı zaten mevcut'),
    ('error.kyc-jurisdiction.not-found', 'Yetki alanı kaydı bulunamadı'),

    -- KYC Tarama
    ('error.kyc-screening.player-required', 'Oyuncu ID zorunludur'),
    ('error.kyc-screening.screening-required', 'Tarama ID zorunludur'),
    ('error.kyc-screening.type-required', 'Tarama türü zorunludur'),
    ('error.kyc-screening.provider-required', 'Sağlayıcı kodu zorunludur'),
    ('error.kyc-screening.status-required', 'Sonuç durumu zorunludur'),
    ('error.kyc-screening.decision-required', 'İnceleme kararı zorunludur'),
    ('error.kyc-screening.reviewer-required', 'İnceleyici ID zorunludur'),
    ('error.kyc-screening.not-found', 'Tarama sonucu bulunamadı'),

    -- KYC Risk
    ('error.kyc-risk.player-required', 'Oyuncu ID zorunludur'),
    ('error.kyc-risk.type-required', 'Değerlendirme türü zorunludur'),
    ('error.kyc-risk.level-required', 'Risk seviyesi zorunludur'),

    -- KYC Sağlayıcı Log
    ('error.kyc-provider-log.player-required', 'Oyuncu ID zorunludur'),
    ('error.kyc-provider-log.case-required', 'Vaka ID zorunludur'),
    ('error.kyc-provider-log.provider-required', 'Sağlayıcı kodu zorunludur'),

    -- Tenant Backoffice — İçerik Yönetimi (CMS)
    ('error.content.id-required', 'İçerik ID zorunludur'),
    ('error.content.not-found', 'İçerik bulunamadı'),
    ('error.content.slug-required', 'Slug zorunludur'),
    ('error.content.translations-required', 'En az bir çeviri zorunludur'),
    ('error.content.user-id-required', 'Kullanıcı ID zorunludur'),
    ('error.content.category-code-required', 'Kategori kodu zorunludur'),
    ('error.content.category-id-required', 'Kategori ID zorunludur'),
    ('error.content.category-not-found', 'Kategori bulunamadı'),
    ('error.content.category-has-active-types', 'Aktif içerik tipleri olan kategori silinemez'),
    ('error.content.type-code-required', 'İçerik tipi kodu zorunludur'),
    ('error.content.type-id-required', 'İçerik tipi ID zorunludur'),
    ('error.content.type-not-found', 'İçerik tipi bulunamadı'),
    ('error.content.type-has-active-contents', 'Aktif içerikleri olan tip silinemez'),

    -- Tenant Backoffice — FAQ Yönetimi
    ('error.faq.user-id-required', 'Kullanıcı ID zorunludur'),
    ('error.faq.category-code-required', 'FAQ kategori kodu zorunludur'),
    ('error.faq.category-id-required', 'FAQ kategori ID zorunludur'),
    ('error.faq.category-not-found', 'FAQ kategorisi bulunamadı'),
    ('error.faq.category-has-active-items', 'Aktif öğeleri olan FAQ kategorisi silinemez'),
    ('error.faq.item-id-required', 'FAQ öğesi ID zorunludur'),
    ('error.faq.item-not-found', 'FAQ öğesi bulunamadı'),

    -- Tenant Backoffice — Layout Yönetimi
    ('error.layout.id-required', 'Layout ID zorunludur'),
    ('error.layout.not-found', 'Layout bulunamadı'),
    ('error.layout.name-required', 'Layout adı zorunludur'),
    ('error.layout.structure-required', 'Layout yapısı zorunludur'),

    -- Tenant Backoffice — Mesaj Tercihleri
    ('error.messaging.preference.invalid-channel-type', 'Geçersiz tercih kanal tipi'),
    ('error.messaging.preference.opted-in-required', 'Tercih durumu (opted_in) zorunludur'),

    -- Tenant Backoffice — Navigasyon Yönetimi
    ('error.navigation.id-required', 'Navigasyon öğesi ID zorunludur'),
    ('error.navigation.item-not-found', 'Navigasyon öğesi bulunamadı'),
    ('error.navigation.item-locked', 'Kilitli navigasyon öğesi silinemez'),
    ('error.navigation.has-children', 'Alt öğeleri olan navigasyon öğesi silinemez'),
    ('error.navigation.parent-not-found', 'Üst navigasyon öğesi bulunamadı'),
    ('error.navigation.location-required', 'Menü konumu zorunludur'),
    ('error.navigation.label-required', 'Etiket veya çeviri anahtarı zorunludur'),
    ('error.navigation.item-ids-required', 'Öğe ID listesi zorunludur'),

    -- Tenant Backoffice — Popup Yönetimi
    ('error.popup.id-required', 'Popup ID zorunludur'),
    ('error.popup.not-found', 'Popup bulunamadı'),
    ('error.popup.user-id-required', 'Kullanıcı ID zorunludur'),
    ('error.popup.type-code-required', 'Popup tipi kodu zorunludur'),
    ('error.popup.type-id-required', 'Popup tipi ID zorunludur'),
    ('error.popup.type-not-found', 'Popup tipi bulunamadı'),

    -- Tenant Backoffice — Promosyon Yönetimi
    ('error.promotion.id-required', 'Promosyon ID zorunludur'),
    ('error.promotion.not-found', 'Promosyon bulunamadı'),
    ('error.promotion.code-required', 'Promosyon kodu zorunludur'),
    ('error.promotion.user-id-required', 'Kullanıcı ID zorunludur'),
    ('error.promotion.type-code-required', 'Promosyon tipi kodu zorunludur'),
    ('error.promotion.type-id-required', 'Promosyon tipi ID zorunludur'),
    ('error.promotion.type-not-found', 'Promosyon tipi bulunamadı'),

    -- Tenant Backoffice — Slide/Banner Yönetimi
    ('error.slide.id-required', 'Slide ID zorunludur'),
    ('error.slide.not-found', 'Slide bulunamadı'),
    ('error.slide.user-id-required', 'Kullanıcı ID zorunludur'),
    ('error.slide.placement-id-required', 'Placement ID zorunludur'),
    ('error.slide.placement-code-required', 'Placement kodu zorunludur'),
    ('error.slide.placement-name-required', 'Placement adı zorunludur'),
    ('error.slide.placement-not-found', 'Placement bulunamadı'),
    ('error.slide.slide-ids-required', 'Slide ID listesi zorunludur'),
    ('error.slide.category-code-required', 'Slide kategori kodu zorunludur'),
    ('error.slide.category-not-found', 'Slide kategorisi bulunamadı'),

    -- Tenant Backoffice — Tema Yönetimi (ek)
    ('error.theme.theme-id-required', 'Tema referans ID zorunludur'),

    -- Tenant Backoffice — Güven Logoları
    ('error.trust-logo.code-required', 'Logo kodu zorunludur'),
    ('error.trust-logo.type-required', 'Logo tipi zorunludur'),
    ('error.trust-logo.name-required', 'Logo adı zorunludur'),
    ('error.trust-logo.logo-url-required', 'Logo URL zorunludur'),
    ('error.trust-logo.items-required', 'Logo listesi zorunludur'),
    ('error.trust-logo.id-required', 'Logo ID zorunludur'),
    ('error.trust-logo.not-found', 'Logo bulunamadı'),

    -- Tenant Backoffice — Operatör Lisansları
    ('error.operator-license.jurisdiction-required', 'Yetki alanı zorunludur'),
    ('error.operator-license.license-number-required', 'Lisans numarası zorunludur'),
    ('error.operator-license.expiry-before-issued', 'Bitiş tarihi başlangıç tarihinden önce olamaz'),
    ('error.operator-license.id-required', 'Lisans ID zorunludur'),
    ('error.operator-license.not-found', 'Lisans bulunamadı'),

    -- Tenant Backoffice — SEO Yönlendirme
    ('error.seo-redirect.from-slug-required', 'Kaynak URL zorunludur'),
    ('error.seo-redirect.to-url-required', 'Hedef URL zorunludur'),
    ('error.seo-redirect.invalid-redirect-type', 'Geçersiz yönlendirme tipi (301 veya 302 olmalıdır)'),
    ('error.seo-redirect.circular-redirect', 'Döngüsel yönlendirme tespit edildi'),
    ('error.seo-redirect.items-required', 'Yönlendirme listesi zorunludur'),
    ('error.seo-redirect.id-required', 'Yönlendirme ID zorunludur'),
    ('error.seo-redirect.not-found', 'Yönlendirme bulunamadı'),

    -- Tenant Backoffice — İçerik SEO Meta
    ('error.content-seo-meta.content-id-required', 'İçerik ID zorunludur'),
    ('error.content-seo-meta.language-required', 'Dil kodu zorunludur'),
    ('error.content-seo-meta.invalid-twitter-card', 'Geçersiz Twitter kart tipi'),
    ('error.content-seo-meta.translation-not-found', 'İçerik çevirisi bulunamadı'),

    -- Tenant Backoffice — Sosyal Medya Bağlantıları
    ('error.social-link.platform-required', 'Platform adı zorunludur'),
    ('error.social-link.url-required', 'URL zorunludur'),
    ('error.social-link.items-required', 'Bağlantı listesi zorunludur'),
    ('error.social-link.id-required', 'Bağlantı ID zorunludur'),
    ('error.social-link.not-found', 'Sosyal medya bağlantısı bulunamadı'),

    -- Tenant Backoffice — Site Ayarları
    ('error.site-settings.field-name-required', 'Alan adı zorunludur'),
    ('error.site-settings.value-required', 'Alan değeri zorunludur'),
    ('error.site-settings.invalid-field', 'Geçersiz alan adı'),
    ('error.site-settings.not-found', 'Site ayarları bulunamadı'),

    -- Tenant Backoffice — Duyuru Çubukları
    ('error.announcement-bar.code-required', 'Duyuru çubuğu kodu zorunludur'),
    ('error.announcement-bar.invalid-audience', 'Geçersiz hedef kitle'),
    ('error.announcement-bar.ends-before-starts', 'Bitiş tarihi başlangıçtan önce olamaz'),
    ('error.announcement-bar.id-required', 'Duyuru çubuğu ID zorunludur'),
    ('error.announcement-bar.not-found', 'Duyuru çubuğu bulunamadı'),
    ('error.announcement-bar-translation.bar-id-required', 'Duyuru çubuğu ID zorunludur'),
    ('error.announcement-bar-translation.language-required', 'Dil kodu zorunludur'),
    ('error.announcement-bar-translation.text-required', 'Duyuru metni zorunludur'),

    -- Tenant Backoffice — Lobi Bölümleri
    ('error.lobby-section.code-required', 'Bölüm kodu zorunludur'),
    ('error.lobby-section.max-items-invalid', 'Maksimum öğe sayısı geçersiz'),
    ('error.lobby-section.id-required', 'Bölüm ID zorunludur'),
    ('error.lobby-section.not-found', 'Lobi bölümü bulunamadı'),
    ('error.lobby-section-translation.section-id-required', 'Bölüm ID zorunludur'),
    ('error.lobby-section-translation.language-required', 'Dil kodu zorunludur'),
    ('error.lobby-section-translation.title-required', 'Başlık zorunludur'),
    ('error.lobby-section-game.section-id-required', 'Bölüm ID zorunludur'),
    ('error.lobby-section-game.game-id-required', 'Oyun ID zorunludur'),
    ('error.lobby-section-game.section-not-found', 'Lobi bölümü bulunamadı'),
    ('error.lobby-section-game.section-not-manual', 'Bölüm manuel küratörlük tipinde değil'),
    ('error.lobby-section-game.not-found', 'Bölüm-oyun ilişkisi bulunamadı'),

    -- Tenant Backoffice — Oyun Etiketleri
    ('error.game-label.game-id-required', 'Oyun ID zorunludur'),
    ('error.game-label.label-type-required', 'Etiket tipi zorunludur'),
    ('error.game-label.expires-in-past', 'Bitiş tarihi geçmişte olamaz'),
    ('error.game-label.id-required', 'Etiket ID zorunludur'),
    ('error.game-label.not-found', 'Oyun etiketi bulunamadı'),

    -- Navigasyon Menü Etiketleri
    ('menu.main.casino', 'Casino'),
    ('menu.main.live-casino', 'Canlı Casino'),
    ('menu.main.sports', 'Spor'),
    ('menu.main.promotions', 'Promosyonlar'),
    ('menu.main.tournaments', 'Turnuvalar'),
    ('menu.main.vip', 'VIP'),
    ('menu.main.login', 'Giriş'),
    ('menu.main.register', 'Kayıt Ol'),
    ('menu.casino.slots', 'Slot Oyunları'),
    ('menu.casino.table-games', 'Masa Oyunları'),
    ('menu.casino.jackpots', 'Jackpot'),
    ('menu.casino.new-games', 'Yeni Oyunlar'),
    ('menu.live-casino.roulette', 'Canlı Rulet'),
    ('menu.live-casino.blackjack', 'Canlı Blackjack'),
    ('menu.live-casino.baccarat', 'Canlı Baccarat'),
    ('menu.live-casino.game-shows', 'Oyun Şovları'),
    ('menu.sports.football', 'Futbol'),
    ('menu.sports.basketball', 'Basketbol'),
    ('menu.sports.tennis', 'Tenis'),
    ('menu.sports.live', 'Canlı Bahis'),
    ('menu.footer.about', 'Hakkımızda'),
    ('menu.footer.responsible-gaming', 'Sorumlu Oyun'),
    ('menu.footer.privacy', 'Gizlilik Politikası'),
    ('menu.footer.terms', 'Şartlar ve Koşullar'),
    ('menu.footer.casino', 'Casino'),
    ('menu.footer.live-casino', 'Canlı Casino'),
    ('menu.footer.sports', 'Spor'),
    ('menu.footer.promotions', 'Promosyonlar'),
    ('menu.footer.help', 'Yardım Merkezi'),
    ('menu.footer.contact', 'Bize Ulaşın'),
    ('menu.footer.affiliates', 'İş Ortaklığı'),
    ('menu.footer.account', 'Hesabım'),
    ('menu.footer.deposit', 'Para Yatır'),
    ('menu.footer.withdraw', 'Para Çek'),
    ('menu.mobile.home', 'Ana Sayfa'),
    ('menu.mobile.casino', 'Casino'),
    ('menu.mobile.sports', 'Spor'),
    ('menu.mobile.promotions', 'Promosyonlar'),
    ('menu.mobile.account', 'Hesabım')
) AS v(key, text) ON k.localization_key = v.key
ON CONFLICT DO NOTHING;
