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
    ('validation.format.email-invalid', '{0} geçerli bir e-posta adresi değil'),
    ('validation.format.url-invalid', '{0} geçerli bir URL değil'),
    ('validation.format.invalid', '{0} geçerli bir format değil'),
    ('validation.format.timezone-invalid', '{0} geçerli bir timezone değil'),
    ('validation.range.greater-than-zero', '{0} sıfırdan büyük olmalıdır'),
    ('validation.range.between', '{0} değeri {1} ile {2} arasında olmalıdır'),
    ('validation.range.min', '{0} en az {1} olmalıdır'),
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

    -- Error Messages - Logs
    ('error.logs.errornotfound', 'Error log bulunamadı'),
    ('error.logs.deadletternotfound', 'Dead letter bulunamadı'),
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

    -- Success Messages - Auth
    ('success.auth.logout', 'Başarıyla çıkış yapıldı'),
    ('success.auth.logout-all', 'Tüm oturumlar sonlandırıldı'),
    ('success.auth.session-revoked', 'Oturum sonlandırıldı'),
    ('success.auth.unlocked', 'Hesap kilidi açıldı'),

    -- Success Messages - Presentation
    ('success.presentation.cache-invalidated', 'Presentation cache temizlendi'),

    -- Error Messages - Permission
    ('error.permission.not-found', 'Yetki bulunamadı'),
    ('error.permission.grant.failed', 'Yetki verme başarısız'),
    ('error.permission.deny.failed', 'Yetki reddetme başarısız'),
    ('error.permission.remove.failed', 'Yetki kaldırma başarısız'),
    ('error.permission.deleted', 'Yetki silinmiş'),
    ('error.permission.create.code-required', 'Yetki kodu zorunlu'),
    ('error.permission.create.code-exists', 'Yetki kodu zaten mevcut'),
    ('error.permission.create.code-deleted', 'Yetki kodu silinmiş. Restore kullanın'),
    ('error.permission.update.is-deleted', 'Silinmiş yetki güncellenemez'),
    ('error.permission.delete.already-deleted', 'Yetki zaten silinmiş'),
    ('error.permission.restore.not-deleted', 'Yetki silinmiş değil'),
    ('error.permission.create.failed', 'Yetki oluşturulamadı'),
    ('error.permission.update.failed', 'Yetki güncellenemedi'),
    ('error.permission.delete.failed', 'Yetki silinemedi'),
    ('error.permission.restore.failed', 'Yetki geri yüklenemedi'),

    -- Error Messages - Role
    ('error.role.not-found', 'Rol bulunamadı'),
    ('error.role.create.code-exists', 'Rol kodu zaten mevcut'),
    ('error.role.create.code-deleted', 'Rol kodu silinmiş. Restore kullanın'),
    ('error.role.deleted', 'Silinmiş rol üzerinde işlem yapılamaz'),
    ('error.role.delete.already-deleted', 'Rol zaten silinmiş'),
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
    ('error.company.delete.already-deleted', 'Şirket zaten silinmiş'),
    ('error.country.not-found', 'Ülke kodu bulunamadı'),
    ('error.pagination.invalid', 'Geçersiz sayfa veya sayfa boyutu'),

    -- Error Messages - Tenant
    ('error.tenant.code-exists', 'Tenant kodu zaten mevcut'),
    ('error.tenant.not-found', 'Tenant bulunamadı'),
    ('error.tenant.already-deleted', 'Tenant zaten silinmiş'),

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
    ('error.tenant-layout.no-filter', 'En az bir filtre parametresi gerekli')
) AS v(key, text) ON k.localization_key = v.key
ON CONFLICT DO NOTHING;
