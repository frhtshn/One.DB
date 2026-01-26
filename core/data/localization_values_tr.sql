-- ============================================================================
-- LOCALIZATION VALUES - TURKISH (tr)
-- ============================================================================

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

    -- Error Messages - SQL
    ('error.sql.function-name-invalid', 'Geçersiz function adı: {0}'),
    ('error.sql.identifier-too-long', '''{0}'' tanımlayıcısı çok uzun: {1} karakter (maksimum {2})'),
    ('error.sql.command-not-allowed', 'SQL komutu izin verilmiyor. İzin verilen: {0}'),
    ('error.sql.stacked-query', 'Birden fazla SQL komutu (stacked query) kullanılması yasaktır'),
    ('error.sql.system-table-access', 'Sistem tablolarına erişim yasaktır')
) AS v(key, text) ON k.localization_key = v.key
ON CONFLICT DO NOTHING;
