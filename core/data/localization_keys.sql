-- ============================================================================
-- LOCALIZATION KEYS
-- Key ve domain her zaman lowercase, kebab-case
-- ============================================================================

TRUNCATE TABLE catalog.localization_keys CASCADE;

INSERT INTO catalog.localization_keys (localization_key, domain, category, description) VALUES

-- ============================================================================
-- VALIDATION MESSAGES (LocalizedValidator'da kullanılan)
-- Pattern: validation.{domain}.{reason}
-- ============================================================================

('validation.summary', 'validation', 'summary', 'Çoklu hata özet mesajı. Args: {0}=errorCount'),
('validation.field.required', 'validation', 'field', '{0} alanı için zorunluluk mesajı'),
('validation.field.max-length', 'validation', 'field', '{0} alanı maksimum uzunluk aşıldı. Args: {1}=maxLength'),
('validation.field.min-length', 'validation', 'field', '{0} alanı minimum uzunluk hatası. Args: {1}=minLength'),
('validation.field.length', 'validation', 'field', '{0} alanı uzunluk aralığı. Args: {1}=min, {2}=max'),
('validation.field.exact-length', 'validation', 'field', '{0} alanı tam uzunluk. Args: {1}=length'),
('validation.field.invalid-value', 'validation', 'field', 'Geçersiz değer'),
('validation.field.only-one-allowed', 'validation', 'field', 'Sadece bir değer izin veriliyor'),
('validation.format.email-invalid', 'validation', 'format', 'Geçersiz e-posta formatı'),
('validation.format.url-invalid', 'validation', 'format', 'Geçersiz URL formatı'),
('validation.format.invalid', 'validation', 'format', 'Geçersiz format'),
('validation.format.timezone-invalid', 'validation', 'format', 'Geçersiz zaman dilimi'),
('validation.format.target-type-invalid', 'validation', 'format', 'Geçersiz hedef tipi'),
('validation.format.environment-invalid', 'validation', 'format', 'Geçersiz ortam değeri'),
('validation.range.greater-than-zero', 'validation', 'range', 'Sıfırdan büyük olmalı'),
('validation.range.between', 'validation', 'range', 'Aralık kontrolü. Args: {1}=min, {2}=max'),
('validation.range.min', 'validation', 'range', 'Minimum değer kontrolü. Args: {1}=min'),
('validation.range.cooling-off-invalid', 'validation', 'range', 'Cooling off minimum değeri maksimum değerden büyük olamaz'),
('validation.filter.sort-field-invalid', 'validation', 'filter', 'Geçersiz sıralama alanı. Args: {1}=allowedFields'),
('validation.filter.sort-order-invalid', 'validation', 'filter', 'Geçersiz sıralama yönü'),
('validation.request.invalid', 'validation', 'request', 'Geçersiz istek'),

-- Şifre Doğrulama (PasswordPolicyValidator'da kullanılan)
('validation.password.required', 'validation', 'password', 'Şifre zorunlu'),
('validation.password.min-length', 'validation', 'password', 'Minimum uzunluk. Args: {0}=minLength'),
('validation.password.max-length', 'validation', 'password', 'Maksimum uzunluk. Args: {0}=maxLength'),
('validation.password.require-uppercase', 'validation', 'password', 'Büyük harf gerekli'),
('validation.password.require-lowercase', 'validation', 'password', 'Küçük harf gerekli'),
('validation.password.require-digit', 'validation', 'password', 'Rakam gerekli'),
('validation.password.require-special', 'validation', 'password', 'Özel karakter gerekli'),
('validation.password.mismatch', 'validation', 'password', 'Şifre tekrarı uyuşmuyor'),

-- KYC Doğrulama
('validation.kyc.level-invalid', 'validation', 'kyc', 'Geçersiz KYC seviyesi'),
('validation.kyc.deadline-action-invalid', 'validation', 'kyc', 'Geçersiz deadline action değeri'),

-- ============================================================================
-- ERROR MESSAGES (Exception sınıflarında kullanılan)
-- Pattern: error.{domain}.{sub-domain?}.{reason}
-- ============================================================================

-- Logs Exceptions (Dead Letter, Error, Audit)
('error.logs.errornotfound', 'error', 'logs', 'Error log bulunamadı'),
('error.deadletter.notfound', 'error', 'deadletter', 'Dead letter bulunamadı'),
('error.deadletter.bulklimitexceeded', 'error', 'deadletter', 'Toplu işlem limiti aşıldı (max 500)'),
('error.logs.auditnotfound', 'error', 'logs', 'Audit log bulunamadı'),

-- Auth - Account Status
('error.auth.account-inactive', 'error', 'auth', 'Hesap aktif değil'),

-- BadRequest - Field Errors
('error.field.missing', 'error', 'field', 'Zorunlu alan eksik. Args: {0}=fieldName'),
('error.field.invalid', 'error', 'field', 'Geçersiz alan. Args: {0}=fieldName, {1}=reason'),

-- Generic CRUD Exceptions
('error.crud.create-failed', 'error', 'crud', 'Oluşturma başarısız. Args: {0}=resourceType'),
('error.crud.update-failed', 'error', 'crud', 'Güncelleme başarısız. Args: {0}=resourceType'),

-- Business Rule Exceptions
('error.business.insufficient-balance', 'error', 'business', 'Yetersiz bakiye. Args: {0}=required, {1}=balance'),
('error.business.invalid-status-transition', 'error', 'business', 'Geçersiz durum geçişi. Args: {0}=from, {1}=to'),

-- System - Cache Exceptions
('error.system.cache.connection-failed', 'error', 'system', 'Cache bağlantı hatası'),
('error.system.cache.operation-failed', 'error', 'system', 'Cache işlem hatası. Args: {0}=operation'),

-- System - Circuit Breaker Exceptions
('error.system.circuit-breaker.database', 'error', 'system', 'Veritabanı circuit breaker açık'),
('error.system.circuit-breaker.cache', 'error', 'system', 'Cache circuit breaker açık'),
('error.system.circuit-breaker.external-api', 'error', 'system', 'External API circuit breaker açık. Args: {0}=apiName'),
('error.system.circuit-breaker.messaging', 'error', 'system', 'Messaging circuit breaker açık. Args: {0}=serviceName'),

-- Conflict Exceptions
('error.conflict.duplicate', 'error', 'conflict', 'Kaynak zaten mevcut. Args: {0}=resourceType, {1}=identifier'),
('error.conflict.concurrency', 'error', 'conflict', 'Eşzamanlılık çakışması. Args: {0}=resourceType, {1}=resourceId'),

-- System - Database Exceptions
('error.system.database.connection-failed', 'error', 'system', 'Veritabanı bağlantı hatası'),
('error.system.database.query-failed', 'error', 'system', 'Veritabanı sorgu hatası. Args: {0}=operation'),
('error.system.database.invalid-tenant-id', 'error', 'system', 'Geçersiz tenant ID. Args: {0}=tenantId'),
('error.system.database.command-failed', 'error', 'system', 'Veritabanı işlem hatası. Args: {0}=operation'),

-- Forbidden Exceptions
('error.forbidden.resource', 'error', 'forbidden', 'Kaynak erişim yetkisi yok. Args: {0}=resource, {1}=permission'),
('error.tenant.access-denied', 'error', 'tenant', 'Tenant erişim engellendi. Args: {0}=tenantId'),
('error.tenant.mismatch', 'error', 'tenant', 'Tenant uyuşmazlığı - farklı tenant için işlem yapılamaz'),
('error.tenant.scope-missing', 'error', 'tenant', 'Tenant kapsam parametresi bulunamadı'),
('error.access.company-scope-denied', 'error', 'access', 'Şirket kapsamı dışında işlem yapılamaz'),
('error.access.tenant-scope-denied', 'error', 'access', 'Tenant kapsamı dışında işlem yapılamaz'),
('error.access.hierarchy-violation', 'error', 'access', 'Hiyerarşi ihlali - yetkisiz işlem'),
('error.access.denied', 'error', 'access', 'Erişim engellendi'),

-- Access Control
('error.access.unauthorized', 'error', 'access', 'Yetkisiz erişim'),

-- Caller Exceptions
('error.caller.locked', 'error', 'caller', 'Hesabınız kilitli'),

-- System - Grain Exceptions
('error.system.grain.activation-failed', 'error', 'system', 'Grain aktivasyon hatası. Args: {0}=grainType, {1}=grainKey'),
('error.system.grain.operation-failed', 'error', 'system', 'Grain işlem hatası. Args: {0}=operation'),

-- System - Operation Timeout Exceptions
('error.system.operation.timeout', 'error', 'system', 'İşlem zaman aşımı. Args: {0}=operation, {1}=seconds'),

-- System - Rate Limit Exceptions
('error.system.rate-limit.exceeded', 'error', 'system', 'Rate limit aşıldı. Args: {0}=clientId, {1}=current, {2}=limit, {3}=retryAfter'),

-- System - Silo Exceptions
('error.system.silo.unavailable', 'error', 'system', 'Silo erişilemez'),
('error.system.silo.cluster-unavailable', 'error', 'system', 'Orleans cluster erişilemez'),
('error.system.silo.auth-init-failed', 'error', 'system', 'Auth altyapısı başlatılamadı'),

-- Tenant Exceptions
('error.tenant.not-active', 'error', 'tenant', 'Tenant aktif değil. Args: {0}=tenantId'),
('error.tenant.configuration-invalid', 'error', 'tenant', 'Tenant konfigürasyon hatası. Args: {0}=tenantId, {1}=reason'),
('error.tenant.code-exists', 'error', 'tenant', 'Tenant kodu zaten mevcut'),
('error.tenant.not-found', 'error', 'tenant', 'Tenant bulunamadı'),

-- Resource Not Found Exceptions
('error.resource.not-found', 'error', 'notfound', 'Kaynak bulunamadı. Args: {0}=resourceType, {1}=resourceId'),

-- Configuration Exceptions
('error.config.missing-required', 'error', 'config', 'Zorunlu konfigürasyon eksik. Args: {0}=configKey'),
('error.config.cannot-resolve-hostname', 'error', 'config', 'Hostname çözümlenemedi. Args: {0}=hostname'),
('error.config.invalid-value', 'error', 'config', 'Geçersiz konfigürasyon değeri. Args: {0}=configKey, {1}=reason'),

-- System - Replica Write Exceptions
('error.system.replica.write-not-allowed', 'error', 'system', 'Replica üzerinde yazma yasak. Args: {0}=identifier, {1}=operation'),

-- Auth - Token Exceptions
('error.auth.token.missing', 'error', 'auth', 'Token eksik'),
('error.auth.token.invalid', 'error', 'auth', 'Geçersiz token. Args: {0}=reason'),
('error.auth.token.expired', 'error', 'auth', 'Token süresi dolmuş'),
('error.auth.token.revoked', 'error', 'auth', 'Token iptal edilmiş'),
('error.auth.token.not-found', 'error', 'auth', 'Token bulunamadı'),
('error.auth.token.refresh-invalid', 'error', 'auth', 'Geçersiz veya süresi dolmuş refresh token'),
('error.auth.token.refresh-required', 'error', 'auth', 'Refresh token zorunlu'),
('error.auth.token.refresh-failed', 'error', 'auth', 'Token yenileme başarısız'),
('error.auth.token.refresh-in-progress', 'error', 'auth', 'Refresh işlemi zaten devam ediyor'),

-- Auth - Login Exceptions
('error.auth.login.throttled', 'error', 'auth', 'Çok fazla giriş denemesi. Args: {0}=saniye'),
('error.auth.login.failed', 'error', 'auth', 'Genel giriş hatası'),
('error.auth.login.account-locked', 'error', 'auth', 'Hesap kilitlendi. Args: {0}=açılış saati'),
('error.auth.login.invalid-credentials', 'error', 'auth', 'Geçersiz kullanıcı/şifre'),

-- Auth - User Exceptions
('error.auth.user.invalid-id', 'error', 'auth', 'Geçersiz kullanıcı kimliği'),
('error.auth.user.not-found', 'error', 'auth', 'Kullanıcı bulunamadı'),
('error.auth.admin.not-found', 'error', 'auth', 'Admin kullanıcı bilgisi alınamadı'),

-- Auth - Session Exceptions
('error.auth.session.not-found', 'error', 'auth', 'Oturum bulunamadı'),
('error.auth.session.id-required', 'error', 'auth', 'Oturum kimliği zorunlu'),
('error.auth.session.use-logout-endpoint', 'error', 'auth', 'Mevcut oturum için logout endpoint kullanılmalı'),
('error.auth.session.revoke-failed', 'error', 'auth', 'Oturum sonlandırma başarısız'),

-- Auth - Logout Exceptions
('error.auth.logout.failed', 'error', 'auth', 'Çıkış başarısız'),
('error.auth.logout.all-failed', 'error', 'auth', 'Toplu çıkış başarısız'),

-- Auth - Unlock Exceptions
('error.auth.unlock.failed', 'error', 'auth', 'Hesap kilidi açılamadı'),

-- Auth - 2FA Exceptions
('error.auth.2fa.invalid-code', 'error', 'auth', 'Geçersiz 2FA doğrulama kodu'),
('error.auth.2fa.token-expired', 'error', 'auth', '2FA token süresi dolmuş, tekrar giriş gerekli'),
('error.auth.2fa.max-attempts', 'error', 'auth', 'Çok fazla başarısız 2FA denemesi, tekrar giriş gerekli'),
('error.auth.2fa.already-enabled', 'error', 'auth', '2FA zaten aktif'),
('error.auth.2fa.not-enabled', 'error', 'auth', '2FA aktif değil'),
('error.auth.2fa.setup-expired', 'error', 'auth', '2FA kurulum süresi dolmuş'),

-- Auth Success Messages
('success.auth.logout', 'success', 'auth', 'Çıkış başarılı mesajı'),
('success.auth.logout-all', 'success', 'auth', 'Tüm oturumlar sonlandırıldı mesajı'),
('success.auth.session-revoked', 'success', 'auth', 'Oturum sonlandırıldı mesajı'),
('success.auth.unlocked', 'success', 'auth', 'Hesap kilidi açıldı'),
('success.auth.password-changed', 'success', 'auth', 'Şifre değiştirildi mesajı'),

-- Presentation Success Messages
('success.presentation.cache-invalidated', 'success', 'presentation', 'Presentation cache temizlendi'),

-- Permission Exceptions
('error.permission.escalation', 'error', 'auth', 'Yetki yükseltme girişimi engellendi'),
('error.permission.not-found', 'error', 'permission', 'Yetki bulunamadı'),
('error.permission.grant.failed', 'error', 'permission', 'Yetki verme başarısız'),
('error.permission.deny.failed', 'error', 'permission', 'Yetki reddetme başarısız'),
('error.permission.remove.failed', 'error', 'permission', 'Yetki kaldırma başarısız'),
('error.permission.inactive', 'error', 'permission', 'Pasif yetki üzerinde işlem yapılamaz'),
('error.permission.create.code-required', 'error', 'permission', 'Yetki kodu zorunlu'),
('error.permission.create.code-exists', 'error', 'permission', 'Yetki kodu zaten mevcut'),
('error.permission.create.code-deleted', 'error', 'permission', 'Yetki kodu silinmiş. Restore kullanın'),
('error.permission.update.is-deleted', 'error', 'permission', 'Silinmiş yetki güncellenemez'),
('error.permission.restore.not-deleted', 'error', 'permission', 'Yetki silinmiş değil'),
('error.permission.create.failed', 'error', 'permission', 'Yetki oluşturulamadı'),
('error.permission.update.failed', 'error', 'permission', 'Yetki güncellenemedi'),
('error.permission.delete.failed', 'error', 'permission', 'Yetki silinemedi'),
('error.permission.restore.failed', 'error', 'permission', 'Yetki geri yüklenemedi'),

-- Role Exceptions
('error.role.not-found', 'error', 'role', 'Rol bulunamadı'),
('error.role.create.code-exists', 'error', 'role', 'Rol kodu zaten mevcut'),
('error.role.create.code-deleted', 'error', 'role', 'Rol kodu silinmiş. Restore kullanın'),
('error.role.inactive', 'error', 'role', 'Pasif rol üzerinde işlem yapılamaz'),
('error.role.restore.not-deleted', 'error', 'role', 'Rol silinmiş değil'),
('error.role.system-protected', 'error', 'role', 'Sistem rolü değiştirilemez'),
('error.role.list.failed', 'error', 'role', 'Rol listesi alınamadı'),
('error.role.get.failed', 'error', 'role', 'Rol bilgisi alınamadı'),
('error.role.create.failed', 'error', 'role', 'Rol oluşturulamadı'),
('error.role.update.failed', 'error', 'role', 'Rol güncellenemedi'),
('error.role.delete.failed', 'error', 'role', 'Rol silinemedi'),
('error.role.restore.failed', 'error', 'role', 'Rol geri yüklenemedi'),
('error.role.assign.failed', 'error', 'role', 'Rol atama başarısız'),
('error.role.remove.failed', 'error', 'role', 'Rol kaldırma başarısız'),
('error.role.bulk-assign.failed', 'error', 'role', 'Toplu yetki atama başarısız'),
('error.role.assign-permission.failed', 'error', 'role', 'Role yetki atama başarısız'),
('error.role.remove-permission.failed', 'error', 'role', 'Rolden yetki kaldırma başarısız'),
('error.role.assign-tenant.failed', 'error', 'role', 'Tenant rol atama başarısız'),
('error.role.remove-tenant.failed', 'error', 'role', 'Tenant rol kaldırma başarısız'),
('error.role.user-not-found', 'error', 'role', 'Kullanıcı bulunamadı'),
('error.role.permission-not-found', 'error', 'role', 'Yetki bulunamadı'),
('error.role.permission-deleted', 'error', 'role', 'Silinmiş yetki atanamaz'),
('error.role.operation-failed', 'error', 'role', 'Rol işlemi başarısız'),
('error.role.tenant-mismatch', 'error', 'role', 'Tenant uyuşmazlığı'),

-- User Exceptions
('error.user.not-found', 'error', 'user', 'Kullanıcı bulunamadı'),
('error.user.create.email-exists', 'error', 'user', 'Email adresi zaten kayıtlı'),
('error.user.create.username-exists', 'error', 'user', 'Kullanıcı adı bu şirkette zaten mevcut'),
('error.user.update.is-deleted', 'error', 'user', 'Silinmiş kullanıcı güncellenemez'),
('error.user.update.email-exists', 'error', 'user', 'Email adresi başka kullanıcıda kayıtlı'),
('error.user.update.username-exists', 'error', 'user', 'Kullanıcı adı bu şirkette başka kullanıcıda mevcut'),
('error.user.delete.already-deleted', 'error', 'user', 'Kullanıcı zaten silinmiş'),
('error.user.reset-password.is-deleted', 'error', 'user', 'Silinmiş kullanıcının şifresi sıfırlanamaz'),
('error.user.reset-password.self-not-allowed', 'error', 'user', 'Kendi şifrenizi sıfırlamak için change-password kullanın'),
('error.user.restore.not-deleted', 'error', 'user', 'Kullanıcı silinmiş değil'),
('error.user.account-inactive', 'error', 'user', 'Hesap aktif değil'),
('error.user.account-locked', 'error', 'user', 'Hesap kilitli'),
('error.user.change-password.current-password-invalid', 'error', 'user', 'Mevcut şifre hatalı'),
('error.user.change-password.same-as-current', 'error', 'user', 'Yeni şifre mevcut şifre ile aynı olamaz'),
('error.user.change-password.recently-used', 'error', 'user', 'Bu şifre yakın zamanda kullanılmış'),

-- Password Policy Exceptions
('error.password-policy.invalid-expiry-days', 'error', 'password-policy', 'Geçersiz şifre geçerlilik süresi'),
('error.password-policy.invalid-history-count', 'error', 'password-policy', 'Şifre geçmişi sayısı 0-10 arası olmalı'),

-- Company Exceptions
('error.company.not-found', 'error', 'company', 'Şirket bulunamadı veya pasif'),

-- Company CRUD & Validation Exceptions
('error.company.create.code-exists', 'error', 'company', 'Şirket kodu zaten kayıtlı'),
('error.company.create.name-exists', 'error', 'company', 'Şirket adı zaten kayıtlı'),
('error.company.update.code-exists', 'error', 'company', 'Şirket kodu başka şirkette kayıtlı'),
('error.company.update.name-exists', 'error', 'company', 'Şirket adı başka şirkette kayıtlı'),
('error.country.not-found', 'error', 'country', 'Ülke kodu bulunamadı'),
('error.pagination.invalid', 'error', 'pagination', 'Geçersiz sayfa veya sayfa boyutu'),

-- Localization Exceptions
('error.localization.language-code-invalid', 'error', 'localization', 'Geçersiz dil kodu. Args: {0}=langCode'),
('error.localization.language-name-invalid', 'error', 'localization', 'Geçersiz dil adı'),
('error.localization.key.not-found', 'error', 'localization', 'Localization key bulunamadı'),
('error.localization.key.invalid', 'error', 'localization', 'Geçersiz localization key'),
('error.localization.key.exists', 'error', 'localization', 'Localization key zaten mevcut'),
('error.localization.domain-invalid', 'error', 'localization', 'Geçersiz domain'),
('error.localization.translation.not-found', 'error', 'localization', 'Çeviri bulunamadı'),

-- Language Management Exceptions
('error.language.not-found', 'error', 'language', 'Dil bulunamadı'),
('error.language.create.code-exists', 'error', 'language', 'Dil kodu zaten mevcut'),
('error.language.code-invalid', 'error', 'language', 'Geçersiz dil kodu (2 karakter olmalı)'),
('error.language.name-invalid', 'error', 'language', 'Geçersiz dil adı (min 2 karakter)'),
('error.language.delete.has-translations', 'error', 'language', 'Dil silinemez, çevirileri mevcut'),

-- Currency Management Exceptions
('error.currency.not-found', 'error', 'currency', 'Para birimi bulunamadı'),
('error.currency.create.code-exists', 'error', 'currency', 'Para birimi kodu zaten mevcut'),
('error.currency.code-invalid', 'error', 'currency', 'Geçersiz para birimi kodu (3 karakter olmalı)'),
('error.currency.name-invalid', 'error', 'currency', 'Geçersiz para birimi adı (min 2 karakter)'),
('error.currency.delete.in-use', 'error', 'currency', 'Para birimi silinemez, tenant tarafından kullanılıyor'),
('error.currency.delete.is-base-currency', 'error', 'currency', 'Para birimi silinemez, tenant base currency olarak kullanıyor'),

-- SQL Validation Exceptions
('error.sql.function-name-invalid', 'error', 'sql', 'Geçersiz function adı. Args: {0}=functionName'),
('error.sql.identifier-too-long', 'error', 'sql', 'Identifier çok uzun. Args: {0}=identifier, {1}=length, {2}=maxLength'),
('error.sql.command-not-allowed', 'error', 'sql', 'SQL komutu izin verilmiyor. Args: {0}=allowedPrefixes'),
('error.sql.stacked-query', 'error', 'sql', 'Birden fazla SQL komutu yasak'),
('error.sql.system-table-access', 'error', 'sql', 'Sistem tablosuna erişim yasak'),

-- ============================================================================
-- CATALOG - ACCESS CONTROL EXCEPTIONS
-- ============================================================================

-- Access Control
('error.access.superadmin-required', 'error', 'access', 'Bu işlem için SuperAdmin yetkisi gerekli'),
('error.access.platform-admin-required', 'error', 'access', 'Bu işlem için Platform Admin (SuperAdmin/Admin) yetkisi gerekli'),

-- ============================================================================
-- CATALOG - PROVIDER EXCEPTIONS
-- ============================================================================

-- Provider Type Exceptions
('error.provider-type.not-found', 'error', 'provider-type', 'Provider tipi bulunamadı'),
('error.provider-type.id-required', 'error', 'provider-type', 'Provider tip ID zorunlu'),
('error.provider-type.code-invalid', 'error', 'provider-type', 'Geçersiz provider tip kodu (min 2 karakter)'),
('error.provider-type.name-invalid', 'error', 'provider-type', 'Geçersiz provider tip adı (min 2 karakter)'),
('error.provider-type.code-exists', 'error', 'provider-type', 'Provider tip kodu zaten mevcut'),
('error.provider-type.has-providers', 'error', 'provider-type', 'Provider tipi silinemez, bağlı provider kayıtları mevcut'),

-- Provider Exceptions
('error.provider.not-found', 'error', 'provider', 'Provider bulunamadı'),
('error.provider.id-required', 'error', 'provider', 'Provider ID zorunlu'),
('error.provider.type-required', 'error', 'provider', 'Provider tipi zorunlu'),
('error.provider.code-invalid', 'error', 'provider', 'Geçersiz provider kodu (min 2 karakter)'),
('error.provider.name-invalid', 'error', 'provider', 'Geçersiz provider adı (min 2 karakter)'),
('error.provider.code-exists', 'error', 'provider', 'Provider kodu zaten mevcut'),
('error.provider.has-games', 'error', 'provider', 'Provider silinemez, bağlı oyun kayıtları mevcut'),
('error.provider.has-payment-methods', 'error', 'provider', 'Provider silinemez, bağlı ödeme yöntemi kayıtları mevcut'),

-- Provider Setting Exceptions
('error.provider-setting.not-found', 'error', 'provider-setting', 'Provider ayarı bulunamadı'),
('error.provider-setting.provider-required', 'error', 'provider-setting', 'Provider ID zorunlu'),
('error.provider-setting.key-required', 'error', 'provider-setting', 'Ayar anahtarı zorunlu'),
('error.provider-setting.key-invalid', 'error', 'provider-setting', 'Geçersiz ayar anahtarı (min 2 karakter)'),
('error.provider-setting.value-required', 'error', 'provider-setting', 'Ayar değeri zorunlu'),

-- ============================================================================
-- CATALOG - PAYMENT METHOD EXCEPTIONS
-- ============================================================================

('error.payment-method.not-found', 'error', 'payment-method', 'Ödeme yöntemi bulunamadı'),
('error.payment-method.id-required', 'error', 'payment-method', 'Ödeme yöntemi ID zorunlu'),
('error.payment-method.provider-required', 'error', 'payment-method', 'Provider ID zorunlu'),
('error.payment-method.code-invalid', 'error', 'payment-method', 'Geçersiz ödeme yöntemi kodu (min 2 karakter)'),
('error.payment-method.name-invalid', 'error', 'payment-method', 'Geçersiz ödeme yöntemi adı (min 2 karakter)'),
('error.payment-method.type-invalid', 'error', 'payment-method', 'Geçersiz ödeme tipi (CARD, EWALLET, BANK, CRYPTO, MOBILE, VOUCHER)'),
('error.payment-method.code-exists', 'error', 'payment-method', 'Ödeme yöntemi kodu bu provider altında zaten mevcut'),
('error.payment-method.in-use', 'error', 'payment-method', 'Ödeme yöntemi silinemez, tenant tarafından kullanılıyor'),

-- ============================================================================
-- CATALOG - COMPLIANCE EXCEPTIONS
-- ============================================================================

-- Jurisdiction Exceptions
('error.jurisdiction.not-found', 'error', 'jurisdiction', 'Jurisdiction bulunamadı'),
('error.jurisdiction.id-required', 'error', 'jurisdiction', 'Jurisdiction ID zorunlu'),
('error.jurisdiction.code-invalid', 'error', 'jurisdiction', 'Geçersiz jurisdiction kodu (min 2 karakter)'),
('error.jurisdiction.name-invalid', 'error', 'jurisdiction', 'Geçersiz jurisdiction adı (min 2 karakter)'),
('error.jurisdiction.country-code-invalid', 'error', 'jurisdiction', 'Geçersiz ülke kodu (2 karakter ISO kodu)'),
('error.jurisdiction.authority-type-invalid', 'error', 'jurisdiction', 'Geçersiz otorite tipi (national, regional, offshore)'),
('error.jurisdiction.code-exists', 'error', 'jurisdiction', 'Jurisdiction kodu zaten mevcut'),
('error.jurisdiction.has-kyc-policy', 'error', 'jurisdiction', 'Jurisdiction silinemez, bağlı KYC politikası mevcut'),
('error.jurisdiction.has-document-requirements', 'error', 'jurisdiction', 'Jurisdiction silinemez, bağlı belge gereksinimleri mevcut'),
('error.jurisdiction.has-level-requirements', 'error', 'jurisdiction', 'Jurisdiction silinemez, bağlı seviye gereksinimleri mevcut'),
('error.jurisdiction.has-gaming-policy', 'error', 'jurisdiction', 'Jurisdiction silinemez, bağlı sorumlu oyun politikası mevcut'),
('error.jurisdiction.in-use-by-tenants', 'error', 'jurisdiction', 'Jurisdiction silinemez, tenant tarafından kullanılıyor'),

-- KYC Policy Exceptions
('error.kyc-policy.not-found', 'error', 'kyc-policy', 'KYC politikası bulunamadı'),
('error.kyc-policy.id-required', 'error', 'kyc-policy', 'KYC politika ID zorunlu'),
('error.kyc-policy.jurisdiction-required', 'error', 'kyc-policy', 'Jurisdiction ID zorunlu'),
('error.kyc-policy.already-exists-for-jurisdiction', 'error', 'kyc-policy', 'Bu jurisdiction için KYC politikası zaten mevcut'),
('error.kyc-policy.verification-timing-invalid', 'error', 'kyc-policy', 'Geçersiz doğrulama zamanı'),
('error.kyc-policy.min-age-invalid', 'error', 'kyc-policy', 'Minimum yaş 18 den küçük olamaz'),

-- KYC Document Requirement Exceptions
('error.kyc-document-requirement.not-found', 'error', 'kyc-document-requirement', 'Belge gereksinimi bulunamadı'),
('error.kyc-document-requirement.id-required', 'error', 'kyc-document-requirement', 'Belge gereksinimi ID zorunlu'),
('error.kyc-document-requirement.jurisdiction-required', 'error', 'kyc-document-requirement', 'Jurisdiction ID zorunlu'),
('error.kyc-document-requirement.document-type-invalid', 'error', 'kyc-document-requirement', 'Geçersiz belge tipi'),
('error.kyc-document-requirement.required-for-invalid', 'error', 'kyc-document-requirement', 'Geçersiz zorunluluk tipi (all, deposit, withdrawal, edd)'),
('error.kyc-document-requirement.verification-method-invalid', 'error', 'kyc-document-requirement', 'Geçersiz doğrulama yöntemi (manual, automated, hybrid)'),
('error.kyc-document-requirement.already-exists', 'error', 'kyc-document-requirement', 'Bu jurisdiction ve belge tipi kombinasyonu zaten mevcut'),

-- KYC Level Requirement Exceptions
('error.kyc-level-requirement.not-found', 'error', 'kyc-level-requirement', 'Seviye gereksinimi bulunamadı'),
('error.kyc-level-requirement.id-required', 'error', 'kyc-level-requirement', 'Seviye gereksinimi ID zorunlu'),
('error.kyc-level-requirement.jurisdiction-required', 'error', 'kyc-level-requirement', 'Jurisdiction ID zorunlu'),
('error.kyc-level-requirement.level-invalid', 'error', 'kyc-level-requirement', 'Geçersiz KYC seviyesi (basic, standard, enhanced)'),
('error.kyc-level-requirement.level-order-invalid', 'error', 'kyc-level-requirement', 'Geçersiz seviye sırası (0 veya üstü olmalı)'),
('error.kyc-level-requirement.deadline-action-invalid', 'error', 'kyc-level-requirement', 'Geçersiz süre dolumu aksiyonu'),
('error.kyc-level-requirement.already-exists', 'error', 'kyc-level-requirement', 'Bu jurisdiction ve KYC seviyesi kombinasyonu zaten mevcut'),

-- Responsible Gaming Policy Exceptions
('error.responsible-gaming-policy.not-found', 'error', 'responsible-gaming-policy', 'Sorumlu oyun politikası bulunamadı'),
('error.responsible-gaming-policy.id-required', 'error', 'responsible-gaming-policy', 'Sorumlu oyun politikası ID zorunlu'),
('error.responsible-gaming-policy.jurisdiction-required', 'error', 'responsible-gaming-policy', 'Jurisdiction ID zorunlu'),
('error.responsible-gaming-policy.already-exists-for-jurisdiction', 'error', 'responsible-gaming-policy', 'Bu jurisdiction için sorumlu oyun politikası zaten mevcut'),

-- ============================================================================
-- CATALOG - UIKIT EXCEPTIONS
-- ============================================================================

-- Theme Exceptions
('error.theme.not-found', 'error', 'theme', 'Tema bulunamadı'),
('error.theme.id-required', 'error', 'theme', 'Tema ID zorunlu'),
('error.theme.code-invalid', 'error', 'theme', 'Geçersiz tema kodu (min 2 karakter)'),
('error.theme.name-invalid', 'error', 'theme', 'Geçersiz tema adı (min 2 karakter)'),
('error.theme.code-exists', 'error', 'theme', 'Tema kodu zaten mevcut'),

-- Widget Exceptions
('error.widget.not-found', 'error', 'widget', 'Widget bulunamadı'),
('error.widget.id-required', 'error', 'widget', 'Widget ID zorunlu'),
('error.widget.code-invalid', 'error', 'widget', 'Geçersiz widget kodu (min 2 karakter)'),
('error.widget.name-invalid', 'error', 'widget', 'Geçersiz widget adı (min 2 karakter)'),
('error.widget.category-invalid', 'error', 'widget', 'Geçersiz widget kategorisi (CONTENT, GAME, ACCOUNT, NAVIGATION)'),
('error.widget.component-name-invalid', 'error', 'widget', 'Geçersiz component adı (min 2 karakter)'),
('error.widget.code-exists', 'error', 'widget', 'Widget kodu zaten mevcut'),

-- UI Position Exceptions
('error.ui-position.not-found', 'error', 'ui-position', 'UI pozisyonu bulunamadı'),
('error.ui-position.id-required', 'error', 'ui-position', 'UI pozisyon ID zorunlu'),
('error.ui-position.code-invalid', 'error', 'ui-position', 'Geçersiz pozisyon kodu (min 2 karakter)'),
('error.ui-position.name-invalid', 'error', 'ui-position', 'Geçersiz pozisyon adı (min 2 karakter)'),
('error.ui-position.code-exists', 'error', 'ui-position', 'UI pozisyon kodu zaten mevcut'),

-- Navigation Template Exceptions
('error.navigation-template.not-found', 'error', 'navigation-template', 'Navigasyon şablonu bulunamadı'),
('error.navigation-template.id-required', 'error', 'navigation-template', 'Navigasyon şablon ID zorunlu'),
('error.navigation-template.code-invalid', 'error', 'navigation-template', 'Geçersiz şablon kodu (min 2 karakter)'),
('error.navigation-template.name-invalid', 'error', 'navigation-template', 'Geçersiz şablon adı (min 2 karakter)'),
('error.navigation-template.code-exists', 'error', 'navigation-template', 'Navigasyon şablon kodu zaten mevcut'),
('error.navigation-template.has-items', 'error', 'navigation-template', 'Navigasyon şablonu silinemez, bağlı öğeler mevcut'),

-- Navigation Template Item Exceptions
('error.navigation-template-item.not-found', 'error', 'navigation-template-item', 'Şablon öğesi bulunamadı'),
('error.navigation-template-item.id-required', 'error', 'navigation-template-item', 'Şablon öğesi ID zorunlu'),
('error.navigation-template-item.template-required', 'error', 'navigation-template-item', 'Şablon ID zorunlu'),
('error.navigation-template-item.menu-location-invalid', 'error', 'navigation-template-item', 'Geçersiz menü konumu (min 2 karakter)'),
('error.navigation-template-item.target-type-invalid', 'error', 'navigation-template-item', 'Geçersiz hedef tipi (INTERNAL, EXTERNAL, ACTION)'),
('error.navigation-template-item.parent-not-found', 'error', 'navigation-template-item', 'Üst öğe bulunamadı'),
('error.navigation-template-item.self-parent', 'error', 'navigation-template-item', 'Bir öğe kendi kendisinin üst öğesi olamaz'),
('error.navigation-template-item.has-children', 'error', 'navigation-template-item', 'Öğe silinemez, alt öğeleri mevcut'),

-- Tenant Navigation Errors
('error.tenant-navigation.not-found', 'error', 'tenant-navigation', 'Navigasyon öğesi bulunamadı'),
('error.tenant-navigation.already-initialized', 'error', 'tenant-navigation', 'Tenant navigasyonu zaten mevcut'),
('error.tenant-navigation.is-locked', 'error', 'tenant-navigation', 'Kilitli öğe silinemez'),
('error.tenant-navigation.has-children', 'error', 'tenant-navigation', 'Öğe silinemez, alt öğeleri mevcut'),
('error.tenant-navigation.parent-not-found', 'error', 'tenant-navigation', 'Üst öğe bulunamadı'),
('error.tenant-navigation.self-parent', 'error', 'tenant-navigation', 'Bir öğe kendi kendisinin üst öğesi olamaz'),
('error.tenant-navigation.readonly-field-update', 'error', 'tenant-navigation', 'Salt okunur alan güncellenemez'),
('error.tenant-navigation.invalid-item-ids', 'error', 'tenant-navigation', 'Geçersiz öğe ID listesi'),

-- Tenant Theme Errors
('error.tenant-theme.not-found', 'error', 'tenant-theme', 'Tenant tema yapılandırması bulunamadı'),
('error.tenant-theme.no-active-theme', 'error', 'tenant-theme', 'Aktif tema bulunamadı'),

-- Tenant Layout Errors
('error.tenant-layout.not-found', 'error', 'tenant-layout', 'Layout bulunamadı'),
('error.tenant-layout.no-filter', 'error', 'tenant-layout', 'En az bir filtre parametresi gerekli'),

-- ============================================================================
-- MESSAGING EXCEPTIONS
-- ============================================================================
('error.messaging.sender-id-required', 'error', 'messaging', 'Gönderen kullanıcı ID zorunlu'),
('error.messaging.recipient-id-required', 'error', 'messaging', 'Alıcı kullanıcı ID zorunlu'),
('error.messaging.subject-required', 'error', 'messaging', 'Mesaj konusu zorunlu'),
('error.messaging.body-required', 'error', 'messaging', 'Mesaj içeriği zorunlu'),
('error.messaging.user-id-required', 'error', 'messaging', 'Kullanıcı ID zorunlu'),
('error.messaging.invalid-parameters', 'error', 'messaging', 'Geçersiz parametreler'),
('error.messaging.draft-id-required', 'error', 'messaging', 'Draft ID zorunlu'),
('error.messaging.draft-not-found', 'error', 'messaging', 'Draft bulunamadı veya silinmiş'),
('error.messaging.draft-not-found-or-published', 'error', 'messaging', 'Draft bulunamadı veya yayınlanmış'),
('error.messaging.draft-already-published', 'error', 'messaging', 'Draft zaten yayınlanmış'),
('error.messaging.draft-not-published', 'error', 'messaging', 'Draft yayınlanmamış, geri alınamaz'),
('error.messaging.cannot-send-to-self', 'error', 'messaging', 'Kendine mesaj gönderilemez'),
('error.messaging.recipient-not-found', 'error', 'messaging', 'Alıcı bulunamadı veya aktif değil'),
('error.messaging.no-recipients', 'error', 'messaging', 'Filtreler hiç alıcı çözümleyemedi'),
('error.messaging.not-draft-owner', 'error', 'messaging', 'Draft sahibi değilsiniz'),
('error.messaging.draft-not-editable', 'error', 'messaging', 'Draft düzenlenebilir durumda değil'),
('error.messaging.draft-not-scheduled', 'error', 'messaging', 'Draft zamanlanmış durumda değil'),
('error.messaging.too-many-recipients', 'error', 'messaging', 'Çok fazla alıcı (maksimum 10000)'),
('error.messaging.draft-already-cancelled', 'error', 'messaging', 'Draft zaten iptal edilmiş'),
('validation.messaging.at-least-one-field', 'validation', 'messaging', 'En az bir alan doldurulmalıdır'),
('validation.messaging.invalid-priority', 'validation', 'messaging', 'Öncelik normal, important veya urgent olmalıdır'),
('validation.messaging.invalid-message-type', 'validation', 'messaging', 'Geçersiz mesaj tipi'),

-- Protected Field System
('error.field.unauthorized-modification', 'error', 'field', 'Korunmalı alanı değiştirme yetkisi yok'),

-- ============================================================================
-- CALLER EXCEPTIONS
-- ============================================================================
('error.caller.not-found', 'error', 'caller', 'Çağıran kullanıcı bulunamadı'),

-- ============================================================================
-- MENU GROUP EXCEPTIONS
-- ============================================================================
('error.menu-group.not-found', 'error', 'menu-group', 'Menü grubu bulunamadı'),
('error.menu-group.code-exists', 'error', 'menu-group', 'Menü grup kodu zaten mevcut'),
('error.menu-group.delete.already-deleted', 'error', 'menu-group', 'Menü grubu zaten silinmiş'),
('error.menu-group.restore.not-deleted', 'error', 'menu-group', 'Menü grubu silinmiş değil'),

-- ============================================================================
-- ACCESS CONTROL (ek)
-- ============================================================================
('error.access.permission-denied', 'error', 'access', 'İşlem yetkisi yok'),
('error.access.user-scope-denied', 'error', 'access', 'Kullanıcı kapsamı dışında işlem yapılamaz'),

-- ============================================================================
-- ROLE (ek)
-- ============================================================================
('error.role.global-only', 'error', 'role', 'Bu rol sadece global kapsamda kullanılabilir'),
('error.role.hierarchy-violation', 'error', 'role', 'Rol hiyerarşi ihlali'),
('error.role.insufficient-level', 'error', 'role', 'Yetersiz rol seviyesi'),
('error.role.target-level-violation', 'error', 'role', 'Hedef rol seviyesi ihlali'),
('error.role.tenant-required', 'error', 'role', 'Tenant ID zorunlu'),

-- ============================================================================
-- USER (ek)
-- ============================================================================
('error.user.concurrent-modification', 'error', 'user', 'Kullanıcı başka bir işlem tarafından değiştirildi'),
('error.user.delete.self-not-allowed', 'error', 'user', 'Kendi hesabınızı silemezsiniz'),
('error.user.unlock.is-deleted', 'error', 'user', 'Silinmiş kullanıcının kilidi açılamaz'),
('error.user.unlock.self-not-allowed', 'error', 'user', 'Kendi hesabınızın kilidini açamazsınız'),

-- ============================================================================
-- DEPARTMENT
-- ============================================================================
('error.department.not-found', 'error', 'department', 'Departman bulunamadı'),

-- ============================================================================
-- TENANT (ek)
-- ============================================================================
('error.tenant.id-required', 'error', 'tenant', 'Tenant ID zorunlu'),
('error.tenant-provider.not-found', 'error', 'tenant-provider', 'Tenant provider kaydı bulunamadı'),
('error.tenant-game.not-found', 'error', 'tenant-game', 'Tenant oyun kaydı bulunamadı'),
('error.tenant-payment-method.not-found', 'error', 'tenant-payment-method', 'Tenant ödeme yöntemi kaydı bulunamadı'),

-- ============================================================================
-- PROVIDER (ek)
-- ============================================================================
('error.provider.invalid-rollout-status', 'error', 'provider', 'Geçersiz rollout durumu'),
('error.provider.not-game-type', 'error', 'provider', 'Provider oyun tipinde değil'),
('error.provider.not-payment-type', 'error', 'provider', 'Provider ödeme tipinde değil'),

-- ============================================================================
-- GAME (Game DB)
-- ============================================================================
('error.game.not-found', 'error', 'game', 'Oyun bulunamadı'),
('error.game.id-required', 'error', 'game', 'Oyun ID zorunlu'),
('error.game.catalog-data-required', 'error', 'game', 'Katalog verisi zorunlu'),
('error.game.currency-code-required', 'error', 'game', 'Para birimi kodu zorunlu'),
('error.game.limits-data-required', 'error', 'game', 'Limit verisi zorunlu'),
('error.game.limits-invalid-format', 'error', 'game', 'Geçersiz limit veri formatı'),
('error.game.player-required', 'error', 'game', 'Oyuncu ID zorunlu'),
('error.game.session-not-found', 'error', 'game', 'Oyun oturumu bulunamadı'),
('error.game.session-expired', 'error', 'game', 'Oyun oturumunun süresi dolmuş'),

-- ============================================================================
-- WALLET (Game Gateway)
-- ============================================================================
('error.wallet.player-not-found', 'error', 'wallet', 'Oyuncu bulunamadı'),
('error.wallet.player-frozen', 'error', 'wallet', 'Oyuncu hesabı dondurulmuş veya pasif'),
('error.wallet.wallet-not-found', 'error', 'wallet', 'Belirtilen para birimi için cüzdan bulunamadı'),
('error.wallet.insufficient-balance', 'error', 'wallet', 'Yetersiz bakiye'),
('error.wallet.amount-required', 'error', 'wallet', 'Tutar zorunlu ve pozitif olmalı'),
('error.wallet.idempotency-key-required', 'error', 'wallet', 'İdempotency anahtarı zorunlu'),

-- ============================================================================
-- BONUS MAPPING (Provider bonus takibi)
-- ============================================================================
('error.bonus-mapping.award-required', 'error', 'bonus-mapping', 'Bonus ödül ID zorunludur'),
('error.bonus-mapping.provider-required', 'error', 'bonus-mapping', 'Sağlayıcı kodu zorunludur'),
('error.bonus-mapping.data-required', 'error', 'bonus-mapping', 'Bonus eşleme verisi zorunludur'),
('error.bonus-mapping.not-found', 'error', 'bonus-mapping', 'Sağlayıcı bonus eşlemesi bulunamadı'),
('error.bonus-mapping.invalid-status', 'error', 'bonus-mapping', 'Geçersiz bonus eşleme durumu'),

-- ============================================================================
-- RECONCILIATION (Provider uzlaştırma)
-- ============================================================================
('error.reconciliation.provider-required', 'error', 'reconciliation', 'Uzlaştırma için sağlayıcı kodu zorunludur'),
('error.reconciliation.date-required', 'error', 'reconciliation', 'Rapor tarihi zorunludur'),

-- ============================================================================
-- PAYMENT METHOD (Finance DB — ek)
-- ============================================================================
('error.payment-method.data-required', 'error', 'payment-method', 'Ödeme yöntemi verisi zorunlu'),
('error.payment-method.currency-code-required', 'error', 'payment-method', 'Para birimi kodu zorunlu'),
('error.payment-method.limits-data-required', 'error', 'payment-method', 'Limit verisi zorunlu'),
('error.payment-method.limits-invalid-format', 'error', 'payment-method', 'Geçersiz limit veri formatı'),

-- ============================================================================
-- PLAYER (Tenant DB)
-- ============================================================================
('error.player.id-required', 'error', 'player', 'Oyuncu ID zorunlu'),
('error.player-limit.invalid-type', 'error', 'player-limit', 'Geçersiz limit tipi'),

-- ============================================================================
-- FINANCIAL LIMIT (Oyuncu Genel Finansal Limitleri)
-- ============================================================================
('error.financial-limit.currency-code-required', 'error', 'financial-limit', 'Para birimi kodu zorunlu'),
('error.financial-limit.invalid-type', 'error', 'financial-limit', 'Geçersiz finansal limit tipi'),

-- ============================================================================
-- TRANSACTION / OPERATION TYPE SYNC
-- ============================================================================
('error.transaction-type.data-required', 'error', 'transaction-type', 'İşlem tipi verisi zorunlu'),
('error.transaction-type.invalid-format', 'error', 'transaction-type', 'İşlem tipi verisi geçersiz format'),
('error.operation-type.data-required', 'error', 'operation-type', 'Operasyon tipi verisi zorunlu'),
('error.operation-type.invalid-format', 'error', 'operation-type', 'Operasyon tipi verisi geçersiz format'),

-- ============================================================================
-- SHADOW MODE
-- ============================================================================
('error.shadow-tester.player-id-required', 'error', 'shadow-tester', 'Oyuncu ID zorunlu'),
('error.shadow-tester.not-found', 'error', 'shadow-tester', 'Shadow tester bulunamadı'),

-- ============================================================================
-- PLAYER SEGMENTATION (Player Category & Group)
-- ============================================================================
('error.player-category.code-required', 'error', 'player-category', 'Kategori kodu zorunlu'),
('error.player-category.name-required', 'error', 'player-category', 'Kategori adı zorunlu'),
('error.player-category.code-exists', 'error', 'player-category', 'Kategori kodu zaten mevcut'),
('error.player-category.not-found', 'error', 'player-category', 'Kategori bulunamadı'),
('error.player-category.already-inactive', 'error', 'player-category', 'Kategori zaten deaktif'),

('error.player-group.code-required', 'error', 'player-group', 'Grup kodu zorunlu'),
('error.player-group.name-required', 'error', 'player-group', 'Grup adı zorunlu'),
('error.player-group.code-exists', 'error', 'player-group', 'Grup kodu zaten mevcut'),
('error.player-group.not-found', 'error', 'player-group', 'Grup bulunamadı'),
('error.player-group.already-inactive', 'error', 'player-group', 'Grup zaten deaktif'),

('error.player-classification.player-not-found', 'error', 'player-classification', 'Oyuncu bulunamadı'),
('error.player-classification.group-not-found', 'error', 'player-classification', 'Grup bulunamadı veya aktif değil'),
('error.player-classification.category-not-found', 'error', 'player-classification', 'Kategori bulunamadı veya aktif değil'),
('error.player-classification.no-assignment', 'error', 'player-classification', 'En az bir grup veya kategori gerekli'),
('error.player-classification.no-players', 'error', 'player-classification', 'Oyuncu listesi boş'),

-- ============================================================================
-- JURISDICTION (ek)
-- ============================================================================
('error.jurisdiction.has-retention-policies', 'error', 'jurisdiction', 'Jurisdiction silinemez, bağlı veri saklama politikası mevcut'),

-- ============================================================================
-- DATA RETENTION POLICY
-- ============================================================================
('error.data-retention-policy.not-found', 'error', 'data-retention-policy', 'Veri saklama politikası bulunamadı'),
('error.data-retention-policy.id-required', 'error', 'data-retention-policy', 'Politika ID zorunlu'),
('error.data-retention-policy.jurisdiction-required', 'error', 'data-retention-policy', 'Jurisdiction ID zorunlu'),
('error.data-retention-policy.data-category-invalid', 'error', 'data-retention-policy', 'Geçersiz veri kategorisi'),
('error.data-retention-policy.retention-days-invalid', 'error', 'data-retention-policy', 'Geçersiz saklama süresi'),
('error.data-retention-policy.already-exists', 'error', 'data-retention-policy', 'Bu jurisdiction ve kategori için politika zaten mevcut'),

-- ============================================================================
-- CRYPTOCURRENCY
-- ============================================================================
('error.cryptocurrency.not-found', 'error', 'cryptocurrency', 'Kripto para bulunamadı'),
('error.cryptocurrency.symbol-required', 'error', 'cryptocurrency', 'Kripto para sembolü zorunlu'),
('error.cryptocurrency.name-invalid', 'error', 'cryptocurrency', 'Geçersiz kripto para adı'),
('error.cryptocurrency.delete.in-use', 'error', 'cryptocurrency', 'Kripto para silinemez, kullanımda'),

-- ============================================================================
-- CURRENCY RATES
-- ============================================================================
('error.currency-rates.base-currency-required', 'error', 'currency-rates', 'Baz para birimi zorunlu'),
('error.currency-rates.provider-required', 'error', 'currency-rates', 'Sağlayıcı zorunlu'),
('error.currency-rates.rates-empty', 'error', 'currency-rates', 'Kur verisi boş olamaz'),
('error.currency-rates.timestamp-required', 'error', 'currency-rates', 'Zaman damgası zorunlu'),

-- ============================================================================
-- CRYPTO RATES
-- ============================================================================
('error.crypto-rates.base-currency-required', 'error', 'crypto-rates', 'Baz para birimi zorunlu'),
('error.crypto-rates.provider-required', 'error', 'crypto-rates', 'Sağlayıcı zorunlu'),
('error.crypto-rates.rates-empty', 'error', 'crypto-rates', 'Kur verisi boş olamaz'),
('error.crypto-rates.timestamp-required', 'error', 'crypto-rates', 'Zaman damgası zorunlu'),

-- ============================================================================
-- MESSAGING — TENANT (campaign, template, inbox)
-- ============================================================================
('error.messaging.player-id-required', 'error', 'messaging', 'Oyuncu ID zorunlu'),
('error.messaging.message-not-found', 'error', 'messaging', 'Mesaj bulunamadı'),
('error.messaging.invalid-message-type', 'error', 'messaging', 'Geçersiz mesaj tipi'),
('error.messaging.invalid-channel-type', 'error', 'messaging', 'Geçersiz kanal tipi'),
('error.messaging.template-not-found', 'error', 'messaging', 'Mesaj şablonu bulunamadı'),
('error.messaging.template-code-required', 'error', 'messaging', 'Şablon kodu zorunlu'),
('error.messaging.template-code-exists', 'error', 'messaging', 'Şablon kodu zaten mevcut'),
('error.messaging.template-name-required', 'error', 'messaging', 'Şablon adı zorunlu'),
('error.messaging.invalid-template-status', 'error', 'messaging', 'Geçersiz şablon durumu'),
('error.messaging.campaign-not-found', 'error', 'messaging', 'Kampanya bulunamadı'),
('error.messaging.campaign-name-required', 'error', 'messaging', 'Kampanya adı zorunlu'),
('error.messaging.campaign-not-editable', 'error', 'messaging', 'Kampanya düzenlenemez'),
('error.messaging.campaign-not-publishable', 'error', 'messaging', 'Kampanya yayınlanamaz'),
('error.messaging.campaign-not-cancellable', 'error', 'messaging', 'Kampanya iptal edilemez'),

-- ============================================================================
-- NOTIFICATION TEMPLATES (platform + tenant)
-- ============================================================================
('error.notification-template.code-required', 'error', 'notification-template', 'Şablon kodu zorunlu'),
('error.notification-template.name-required', 'error', 'notification-template', 'Şablon adı zorunlu'),
('error.notification-template.invalid-channel-type', 'error', 'notification-template', 'Geçersiz kanal tipi'),
('error.notification-template.invalid-category', 'error', 'notification-template', 'Geçersiz kategori'),
('error.notification-template.invalid-status', 'error', 'notification-template', 'Geçersiz şablon durumu'),
('error.notification-template.code-exists', 'error', 'notification-template', 'Şablon kodu zaten mevcut'),
('error.notification-template.not-found', 'error', 'notification-template', 'Bildirim şablonu bulunamadı'),
('error.notification-template.translation-not-found', 'error', 'notification-template', 'Şablon çevirisi bulunamadı'),
('error.notification-template.email-subject-required', 'error', 'notification-template', 'E-posta konusu zorunlu'),
('error.notification-template.email-body-html-required', 'error', 'notification-template', 'E-posta HTML gövdesi zorunlu'),
('error.notification-template.sms-body-text-required', 'error', 'notification-template', 'SMS metin içeriği zorunlu'),
('error.notification-template.system-template-cannot-be-deleted', 'error', 'notification-template', 'Sistem şablonu silinemez'),

-- ============================================================================
-- BONUS ENGINE — Bonus Types
-- ============================================================================
('error.bonus-type.not-found', 'error', 'bonus-type', 'Bonus tipi bulunamadı'),
('error.bonus-type.id-required', 'error', 'bonus-type', 'Bonus tip ID zorunlu'),
('error.bonus-type.code-required', 'error', 'bonus-type', 'Bonus tip kodu zorunlu'),
('error.bonus-type.code-exists', 'error', 'bonus-type', 'Bonus tip kodu zaten mevcut'),
('error.bonus-type.name-required', 'error', 'bonus-type', 'Bonus tip adı zorunlu'),
('error.bonus-type.category-required', 'error', 'bonus-type', 'Bonus kategorisi zorunlu'),
('error.bonus-type.value-type-required', 'error', 'bonus-type', 'Değer tipi zorunlu'),

-- ============================================================================
-- BONUS ENGINE — Bonus Rules
-- ============================================================================
('error.bonus-rule.not-found', 'error', 'bonus-rule', 'Bonus kuralı bulunamadı'),
('error.bonus-rule.not-found-or-inactive', 'error', 'bonus-rule', 'Bonus kuralı bulunamadı veya aktif değil'),
('error.bonus-rule.id-required', 'error', 'bonus-rule', 'Bonus kural ID zorunlu'),
('error.bonus-rule.code-required', 'error', 'bonus-rule', 'Bonus kural kodu zorunlu'),
('error.bonus-rule.code-exists', 'error', 'bonus-rule', 'Bonus kural kodu zaten mevcut'),
('error.bonus-rule.name-required', 'error', 'bonus-rule', 'Bonus kural adı zorunlu'),
('error.bonus-rule.trigger-config-required', 'error', 'bonus-rule', 'Trigger konfigürasyonu zorunlu'),
('error.bonus-rule.reward-config-required', 'error', 'bonus-rule', 'Ödül konfigürasyonu zorunlu'),
('error.bonus-rule.invalid-evaluation-type', 'error', 'bonus-rule', 'Geçersiz değerlendirme tipi'),

-- ============================================================================
-- BONUS ENGINE — Bonus Awards
-- ============================================================================
('error.bonus-award.not-found', 'error', 'bonus-award', 'Bonus ödülü bulunamadı'),
('error.bonus-award.id-required', 'error', 'bonus-award', 'Bonus ödül ID zorunlu'),
('error.bonus-award.player-required', 'error', 'bonus-award', 'Oyuncu ID zorunlu'),
('error.bonus-award.rule-required', 'error', 'bonus-award', 'Bonus kural ID zorunlu'),
('error.bonus-award.currency-required', 'error', 'bonus-award', 'Para birimi zorunlu'),
('error.bonus-award.wallet-not-found', 'error', 'bonus-award', 'Bonus cüzdanı bulunamadı'),
('error.bonus-award.cannot-cancel', 'error', 'bonus-award', 'Bonus iptal edilemez'),
('error.bonus-award.not-completable', 'error', 'bonus-award', 'Bonus tamamlanamaz'),
('error.bonus-award.wagering-not-complete', 'error', 'bonus-award', 'Çevrim tamamlanmadı'),
('error.bonus-award.amount-required', 'error', 'bonus-award', 'Bonus tutarı zorunlu'),

-- ============================================================================
-- BONUS REQUEST (Manuel bonus talep sistemi)
-- ============================================================================
('error.bonus-request.not-found', 'error', 'bonus-request', 'Bonus talebi bulunamadı'),
('error.bonus-request.invalid-status', 'error', 'bonus-request', 'Geçersiz talep durumu'),
('error.bonus-request.player-required', 'error', 'bonus-request', 'Oyuncu ID zorunlu'),
('error.bonus-request.invalid-source', 'error', 'bonus-request', 'Geçersiz talep kaynağı'),
('error.bonus-request.type-required', 'error', 'bonus-request', 'Bonus tipi zorunlu'),
('error.bonus-request.description-required', 'error', 'bonus-request', 'Açıklama zorunlu'),
('error.bonus-request.amount-required', 'error', 'bonus-request', 'Tutar zorunlu (operatör talebi için)'),
('error.bonus-request.currency-required', 'error', 'bonus-request', 'Para birimi zorunlu (operatör talebi için)'),
('error.bonus-request.hold-reason-required', 'error', 'bonus-request', 'Beklemeye alma nedeni zorunlu'),
('error.bonus-request.review-note-required', 'error', 'bonus-request', 'İnceleme notu zorunlu (ret için)'),
('error.bonus-request.rollback-reason-required', 'error', 'bonus-request', 'Geri alma nedeni zorunlu'),
('error.bonus-request.rollback-not-allowed', 'error', 'bonus-request', 'Bu durumdan geri alma yapılamaz'),
('error.bonus-request.type-not-requestable', 'error', 'bonus-request', 'Bu bonus tipi için talep oluşturulamaz'),
('error.bonus-request.player-not-eligible', 'error', 'bonus-request', 'Oyuncu bu bonus tipine uygun değil'),
('error.bonus-request.pending-exists', 'error', 'bonus-request', 'Aynı tip için bekleyen talep mevcut'),
('error.bonus-request.cooldown-after-approved', 'error', 'bonus-request', 'Onaylanan talep sonrası bekleme süresi dolmadı'),
('error.bonus-request.cooldown-after-rejected', 'error', 'bonus-request', 'Reddedilen talep sonrası bekleme süresi dolmadı'),
('error.bonus-request.not-owner', 'error', 'bonus-request', 'Talep sahibi değil'),

-- Bonus Request Settings
('error.bonus-request-settings.not-found', 'error', 'bonus-request-settings', 'Bonus talep ayarı bulunamadı'),
('error.bonus-request-settings.display-name-required', 'error', 'bonus-request-settings', 'Görüntü adı zorunlu'),
('error.bonus-request-settings.invalid-display-name', 'error', 'bonus-request-settings', 'Geçersiz görüntü adı JSON formatı'),
('error.bonus-request-settings.invalid-rules-content', 'error', 'bonus-request-settings', 'Geçersiz kurallar içeriği JSON formatı'),
('error.bonus-request-settings.invalid-eligible-groups', 'error', 'bonus-request-settings', 'Geçersiz uygun gruplar JSON formatı'),
('error.bonus-request-settings.invalid-eligible-categories', 'error', 'bonus-request-settings', 'Geçersiz uygun kategoriler JSON formatı'),
('error.bonus-request-settings.invalid-usage-criteria', 'error', 'bonus-request-settings', 'Geçersiz kullanım kriterleri JSON formatı'),

-- ============================================================================
-- BONUS ENGINE — Campaigns
-- ============================================================================
('error.campaign.not-found', 'error', 'campaign', 'Kampanya bulunamadı'),
('error.campaign.id-required', 'error', 'campaign', 'Kampanya ID zorunlu'),
('error.campaign.code-required', 'error', 'campaign', 'Kampanya kodu zorunlu'),
('error.campaign.code-exists', 'error', 'campaign', 'Kampanya kodu zaten mevcut'),
('error.campaign.name-required', 'error', 'campaign', 'Kampanya adı zorunlu'),
('error.campaign.type-required', 'error', 'campaign', 'Kampanya tipi zorunlu'),
('error.campaign.dates-required', 'error', 'campaign', 'Kampanya tarihleri zorunlu'),
('error.campaign.end-before-start', 'error', 'campaign', 'Bitiş tarihi başlangıçtan önce olamaz'),
('error.campaign.invalid-status', 'error', 'campaign', 'Geçersiz kampanya durumu'),
('error.campaign.invalid-award-strategy', 'error', 'campaign', 'Geçersiz ödül stratejisi'),

-- ============================================================================
-- BONUS ENGINE — Promo Codes
-- ============================================================================
('error.promo.not-found', 'error', 'promo', 'Promosyon bulunamadı'),
('error.promo.id-required', 'error', 'promo', 'Promosyon ID zorunlu'),
('error.promo.code-required', 'error', 'promo', 'Promosyon kodu zorunlu'),
('error.promo.code-id-required', 'error', 'promo', 'Promosyon kod ID zorunlu'),
('error.promo.code-exists', 'error', 'promo', 'Promosyon kodu zaten mevcut'),
('error.promo.name-required', 'error', 'promo', 'Promosyon adı zorunlu'),
('error.promo.invalid-status', 'error', 'promo', 'Geçersiz promosyon durumu'),
('error.promo.player-required', 'error', 'promo', 'Oyuncu ID zorunlu'),

-- ============================================================================
-- FINANCE GATEWAY — Payment Sessions
-- ============================================================================
('error.finance.session-player-required', 'error', 'finance', 'Ödeme oturumu için oyuncu ID zorunlu'),
('error.finance.session-type-required', 'error', 'finance', 'Oturum tipi zorunlu'),
('error.finance.session-amount-required', 'error', 'finance', 'Ödeme oturumu için tutar zorunlu'),
('error.finance.session-not-found', 'error', 'finance', 'Ödeme oturumu bulunamadı'),
('error.finance.session-expired', 'error', 'finance', 'Ödeme oturumunun süresi dolmuş'),

-- ============================================================================
-- FINANCE GATEWAY — Deposit
-- ============================================================================
('error.deposit.player-required', 'error', 'deposit', 'Oyuncu ID zorunlu'),
('error.deposit.invalid-amount', 'error', 'deposit', 'Para yatırma tutarı sıfırdan büyük olmalı'),
('error.deposit.idempotency-required', 'error', 'deposit', 'İdempotency anahtarı zorunlu'),
('error.deposit.player-not-active', 'error', 'deposit', 'Oyuncu hesabı aktif değil'),
('error.deposit.wallet-not-found', 'error', 'deposit', 'Oyuncu cüzdanı bulunamadı'),
('error.deposit-confirm.transaction-not-found', 'error', 'deposit', 'Bekleyen para yatırma işlemi bulunamadı'),
('error.deposit-confirm.player-mismatch', 'error', 'deposit', 'Oyuncu ID para yatırma işlemiyle eşleşmiyor'),
('error.deposit-fail.already-confirmed', 'error', 'deposit', 'Onaylanmış para yatırma başarısız yapılamaz'),

-- ============================================================================
-- FINANCE GATEWAY — Withdrawal
-- ============================================================================
('error.withdrawal.insufficient-balance', 'error', 'withdrawal', 'Para çekme için yetersiz bakiye'),
('error.withdrawal.active-wagering-incomplete', 'error', 'withdrawal', 'Aktif bonus çevrim şartı tamamlanmamış'),
('error.withdrawal-cancel.already-confirmed', 'error', 'withdrawal', 'Onaylanmış para çekme iptal edilemez'),
('error.withdrawal-fail.already-confirmed', 'error', 'withdrawal', 'Onaylanmış para çekme başarısız yapılamaz'),

-- ============================================================================
-- FINANCE GATEWAY — Workflow
-- ============================================================================
('error.workflow.invalid-type', 'error', 'workflow', 'Geçersiz onay akışı tipi'),
('error.workflow.already-pending', 'error', 'workflow', 'Bu işlem için aktif onay akışı zaten mevcut'),
('error.workflow.not-found', 'error', 'workflow', 'Onay akışı bulunamadı'),
('error.workflow.not-pending', 'error', 'workflow', 'Onay akışı beklemede durumunda değil'),
('error.workflow.not-in-review', 'error', 'workflow', 'Onay akışı inceleme durumunda değil'),

-- ============================================================================
-- FINANCE GATEWAY — Account Adjustment
-- ============================================================================
('error.adjustment.not-found', 'error', 'adjustment', 'Düzeltme kaydı bulunamadı'),
('error.adjustment.not-pending', 'error', 'adjustment', 'Düzeltme beklemede durumunda değil'),
('error.adjustment.invalid-direction', 'error', 'adjustment', 'Yön CREDIT veya DEBIT olmalıdır'),
('error.adjustment.invalid-wallet-type', 'error', 'adjustment', 'Cüzdan tipi REAL veya BONUS olmalıdır'),
('error.adjustment.invalid-type', 'error', 'adjustment', 'Geçersiz düzeltme tipi'),
('error.adjustment.provider-required', 'error', 'adjustment', 'Oyun düzeltmesi için provider ID zorunludur'),
('error.adjustment.insufficient-balance', 'error', 'adjustment', 'Borç düzeltmesi için yetersiz bakiye'),

-- ============================================================================
-- FINANCE GATEWAY — Fee Calculation
-- ============================================================================
('error.calculate-fee.invalid-direction', 'error', 'fee', 'Fee hesaplaması için geçersiz yön'),
('error.calculate-fee.method-not-found', 'error', 'fee', 'Ödeme yöntemi limitleri bulunamadı'),

-- ============================================================================
-- SUPPORT — Ticket Sistemi
-- ============================================================================
('error.support.player-required', 'error', 'support', 'Oyuncu ID zorunlu'),
('error.support.subject-required', 'error', 'support', 'Ticket başlığı zorunlu'),
('error.support.description-required', 'error', 'support', 'Ticket açıklaması zorunlu'),
('error.support.invalid-channel', 'error', 'support', 'Geçersiz iletişim kanalı'),
('error.support.invalid-priority', 'error', 'support', 'Geçersiz öncelik seviyesi'),
('error.support.invalid-created-by-type', 'error', 'support', 'Geçersiz oluşturucu tipi'),
('error.support.ticket-not-found', 'error', 'support', 'Ticket bulunamadı'),
('error.support.ticket-invalid-status', 'error', 'support', 'Bu işlem için geçersiz ticket durumu'),
('error.support.ticket-not-owner', 'error', 'support', 'Bu ticket bu oyuncuya ait değil'),
('error.support.ticket-already-assigned', 'error', 'support', 'Ticket zaten bu temsilciye atanmış'),
('error.support.ticket-closed', 'error', 'support', 'Kapalı ticket üzerinde işlem yapılamaz'),
('error.support.resolve-note-required', 'error', 'support', 'Çözüm notu zorunlu'),
('error.support.max-open-tickets-reached', 'error', 'support', 'Açık ticket limiti dolmuş'),
('error.support.ticket-cooldown-active', 'error', 'support', 'Ticket oluşturma bekleme süresi dolmamış'),

-- SUPPORT — Player Note
('error.support.note-not-found', 'error', 'support', 'Not bulunamadı'),
('error.support.note-already-deleted', 'error', 'support', 'Not zaten silinmiş'),
('error.support.note-content-required', 'error', 'support', 'Not içeriği zorunlu'),
('error.support.invalid-note-type', 'error', 'support', 'Geçersiz not tipi'),

-- SUPPORT — Representative
('error.support.representative-reason-required', 'error', 'support', 'Temsilci değişiklik nedeni zorunlu'),
('error.support.representative-already-assigned', 'error', 'support', 'Aynı temsilci zaten atanmış'),

-- SUPPORT — Welcome Call
('error.support.welcome-task-not-found', 'error', 'support', 'Hoşgeldin araması görevi bulunamadı'),
('error.support.welcome-task-not-in-progress', 'error', 'support', 'Görev uygun durumda değil'),
('error.support.welcome-task-not-assignable', 'error', 'support', 'Görev atanamaz durumda'),
('error.support.invalid-call-result', 'error', 'support', 'Geçersiz arama sonucu'),
('error.support.invalid-reschedule-result', 'error', 'support', 'Geçersiz yeniden planlama sonucu'),
('error.support.assigned-to-required', 'error', 'support', 'Atanan kişi ID zorunlu'),

-- SUPPORT — Category
('error.support.category-not-found', 'error', 'support', 'Ticket kategorisi bulunamadı'),
('error.support.parent-category-not-found', 'error', 'support', 'Üst kategori bulunamadı'),
('error.support.category-has-children', 'error', 'support', 'Alt kategorisi olan kategori silinemez'),
('error.support.category-code-exists', 'error', 'support', 'Kategori kodu zaten mevcut'),
('error.support.category-code-required', 'error', 'support', 'Kategori kodu zorunlu'),
('error.support.category-name-required', 'error', 'support', 'Kategori adı zorunlu'),
('error.support.invalid-category-name-format', 'error', 'support', 'Geçersiz kategori adı JSON formatı'),
('error.support.invalid-category-description-format', 'error', 'support', 'Geçersiz kategori açıklama JSON formatı'),

-- SUPPORT — Tag
('error.support.tag-not-found', 'error', 'support', 'Etiket bulunamadı'),
('error.support.tag-name-exists', 'error', 'support', 'Etiket adı zaten mevcut'),
('error.support.tag-name-required', 'error', 'support', 'Etiket adı zorunlu'),
('error.support.invalid-tag-color', 'error', 'support', 'Geçersiz renk kodu (HEX formatı bekleniyor)'),

-- SUPPORT — Canned Response
('error.support.canned-response-not-found', 'error', 'support', 'Hazır yanıt bulunamadı'),

-- SUPPORT — Genel
('error.support.no-fields-to-update', 'error', 'support', 'Güncellenecek en az bir alan gerekli'),

-- ============================================================================
-- PLAYER AUTH — Kayıt ve Doğrulama
-- ============================================================================
('error.player-register.username-required', 'error', 'player-register', 'Kullanıcı adı zorunlu'),
('error.player-register.email-required', 'error', 'player-register', 'Email zorunlu'),
('error.player-register.password-required', 'error', 'player-register', 'Şifre zorunlu'),
('error.player-register.token-required', 'error', 'player-register', 'Doğrulama token zorunlu'),
('error.player-register.username-exists', 'error', 'player-register', 'Kullanıcı adı zaten mevcut'),
('error.player-register.email-exists', 'error', 'player-register', 'Email zaten kayıtlı'),

-- PLAYER AUTH — Email Doğrulama
('error.player-verify.token-required', 'error', 'player-verify', 'Doğrulama token zorunlu'),
('error.player-verify.token-not-found', 'error', 'player-verify', 'Doğrulama token bulunamadı'),
('error.player-verify.token-expired', 'error', 'player-verify', 'Doğrulama token süresi dolmuş'),
('error.player-verify.already-verified', 'error', 'player-verify', 'Email zaten doğrulanmış'),
('error.player-verify.player-required', 'error', 'player-verify', 'Oyuncu ID zorunlu'),
('error.player-verify.player-not-found', 'error', 'player-verify', 'Oyuncu bulunamadı'),

-- PLAYER AUTH — Kimlik Doğrulama
('error.player-auth.email-required', 'error', 'player-auth', 'Email zorunlu'),
('error.player-auth.invalid-credentials', 'error', 'player-auth', 'Geçersiz kimlik bilgileri'),
('error.player-auth.account-locked', 'error', 'player-auth', 'Hesap kilitli'),
('error.player-auth.account-suspended', 'error', 'player-auth', 'Hesap askıya alınmış'),
('error.player-auth.account-closed', 'error', 'player-auth', 'Hesap kapatılmış'),
('error.player-auth.player-required', 'error', 'player-auth', 'Oyuncu ID zorunlu'),
('error.player-auth.player-not-found', 'error', 'player-auth', 'Oyuncu bulunamadı'),

-- PLAYER AUTH — Şifre Yönetimi
('error.player-password.player-required', 'error', 'player-password', 'Oyuncu ID zorunlu'),
('error.player-password.password-required', 'error', 'player-password', 'Şifre zorunlu'),
('error.player-password.player-not-found', 'error', 'player-password', 'Oyuncu bulunamadı'),
('error.player-password.account-inactive', 'error', 'player-password', 'Hesap aktif değil'),
('error.player-password.token-required', 'error', 'player-password', 'Sıfırlama token zorunlu'),
('error.player-password.token-not-found', 'error', 'player-password', 'Sıfırlama token bulunamadı'),
('error.player-password.token-expired', 'error', 'player-password', 'Sıfırlama token süresi dolmuş'),

-- PLAYER — Profil
('error.player-profile.player-required', 'error', 'player-profile', 'Oyuncu ID zorunlu'),
('error.player-profile.player-not-found', 'error', 'player-profile', 'Oyuncu bulunamadı'),
('error.player-profile.already-exists', 'error', 'player-profile', 'Profil zaten mevcut'),
('error.player-profile.not-found', 'error', 'player-profile', 'Profil bulunamadı'),

-- PLAYER — Kimlik
('error.player-identity.player-required', 'error', 'player-identity', 'Oyuncu ID zorunlu'),
('error.player-identity.identity-required', 'error', 'player-identity', 'Kimlik numarası zorunlu'),
('error.player-identity.player-not-found', 'error', 'player-identity', 'Oyuncu bulunamadı'),

-- PLAYER — BO Yönetim
('error.player.player-required', 'error', 'player', 'Oyuncu ID zorunlu'),
('error.player.not-found', 'error', 'player', 'Oyuncu bulunamadı'),
('error.player.invalid-status', 'error', 'player', 'Geçersiz oyuncu durumu'),
('error.player.status-unchanged', 'error', 'player', 'Durum zaten aynı'),

-- WALLET — Cüzdan Oluşturma
('error.wallet.player-required', 'error', 'wallet', 'Oyuncu ID zorunlu'),
('error.wallet.currency-required', 'error', 'wallet', 'Para birimi zorunlu'),
('error.wallet.player-not-active', 'error', 'wallet', 'Oyuncu hesabı aktif değil'),

-- ============================================================================
-- KYC — Case Yönetimi
-- ============================================================================
('error.kyc-case.player-required', 'error', 'kyc-case', 'Oyuncu ID zorunlu'),
('error.kyc-case.player-not-found', 'error', 'kyc-case', 'Oyuncu bulunamadı'),
('error.kyc-case.case-required', 'error', 'kyc-case', 'Case ID zorunlu'),
('error.kyc-case.not-found', 'error', 'kyc-case', 'KYC case bulunamadı'),
('error.kyc-case.status-required', 'error', 'kyc-case', 'Durum zorunlu'),
('error.kyc-case.status-unchanged', 'error', 'kyc-case', 'Durum zaten aynı'),
('error.kyc-case.reviewer-required', 'error', 'kyc-case', 'İncelemeci ID zorunlu'),

-- KYC — Doküman Yönetimi
('error.kyc-document.player-required', 'error', 'kyc-document', 'Oyuncu ID zorunlu'),
('error.kyc-document.player-not-found', 'error', 'kyc-document', 'Oyuncu bulunamadı'),
('error.kyc-document.document-required', 'error', 'kyc-document', 'Doküman ID zorunlu'),
('error.kyc-document.not-found', 'error', 'kyc-document', 'Doküman bulunamadı'),
('error.kyc-document.type-required', 'error', 'kyc-document', 'Doküman tipi zorunlu'),
('error.kyc-document.storage-type-required', 'error', 'kyc-document', 'Depolama tipi zorunlu'),
('error.kyc-document.hash-required', 'error', 'kyc-document', 'Dosya hash zorunlu'),
('error.kyc-document.status-required', 'error', 'kyc-document', 'Durum zorunlu'),
('error.kyc-document.case-not-found', 'error', 'kyc-document', 'KYC case bulunamadı'),

-- KYC — Kısıtlama Yönetimi
('error.kyc-restriction.player-required', 'error', 'kyc-restriction', 'Oyuncu ID zorunlu'),
('error.kyc-restriction.player-not-found', 'error', 'kyc-restriction', 'Oyuncu bulunamadı'),
('error.kyc-restriction.restriction-required', 'error', 'kyc-restriction', 'Kısıtlama ID zorunlu'),
('error.kyc-restriction.type-required', 'error', 'kyc-restriction', 'Kısıtlama tipi zorunlu'),
('error.kyc-restriction.not-found', 'error', 'kyc-restriction', 'Kısıtlama bulunamadı'),
('error.kyc-restriction.not-active', 'error', 'kyc-restriction', 'Kısıtlama aktif değil'),
('error.kyc-restriction.cannot-revoke', 'error', 'kyc-restriction', 'Kısıtlama iptal edilemez'),
('error.kyc-restriction.min-duration-not-met', 'error', 'kyc-restriction', 'Minimum süre henüz dolmamış'),

-- KYC — Limit Yönetimi
('error.kyc-limit.player-required', 'error', 'kyc-limit', 'Oyuncu ID zorunlu'),
('error.kyc-limit.player-not-found', 'error', 'kyc-limit', 'Oyuncu bulunamadı'),
('error.kyc-limit.limit-required', 'error', 'kyc-limit', 'Limit ID zorunlu'),
('error.kyc-limit.type-required', 'error', 'kyc-limit', 'Limit tipi zorunlu'),
('error.kyc-limit.value-required', 'error', 'kyc-limit', 'Limit değeri zorunlu'),
('error.kyc-limit.not-found', 'error', 'kyc-limit', 'Limit bulunamadı'),
('error.kyc-limit.not-active', 'error', 'kyc-limit', 'Limit aktif değil'),

-- KYC — AML Bayrak Yönetimi
('error.kyc-aml.player-required', 'error', 'kyc-aml', 'Oyuncu ID zorunlu'),
('error.kyc-aml.player-not-found', 'error', 'kyc-aml', 'Oyuncu bulunamadı'),
('error.kyc-aml.flag-required', 'error', 'kyc-aml', 'AML bayrak ID zorunlu'),
('error.kyc-aml.flag-type-required', 'error', 'kyc-aml', 'Bayrak tipi zorunlu'),
('error.kyc-aml.severity-required', 'error', 'kyc-aml', 'Önem derecesi zorunlu'),
('error.kyc-aml.description-required', 'error', 'kyc-aml', 'Açıklama zorunlu'),
('error.kyc-aml.not-found', 'error', 'kyc-aml', 'AML bayrak bulunamadı'),
('error.kyc-aml.status-required', 'error', 'kyc-aml', 'Durum zorunlu'),
('error.kyc-aml.status-unchanged', 'error', 'kyc-aml', 'Durum zaten aynı'),
('error.kyc-aml.assignee-required', 'error', 'kyc-aml', 'Atanan kişi ID zorunlu'),
('error.kyc-aml.decision-required', 'error', 'kyc-aml', 'Karar zorunlu'),
('error.kyc-aml.decision-by-required', 'error', 'kyc-aml', 'Karar veren kişi ID zorunlu'),

-- KYC — Jurisdiction Yönetimi
('error.kyc-jurisdiction.player-required', 'error', 'kyc-jurisdiction', 'Oyuncu ID zorunlu'),
('error.kyc-jurisdiction.player-not-found', 'error', 'kyc-jurisdiction', 'Oyuncu bulunamadı'),
('error.kyc-jurisdiction.country-required', 'error', 'kyc-jurisdiction', 'Ülke kodu zorunlu'),
('error.kyc-jurisdiction.already-exists', 'error', 'kyc-jurisdiction', 'Jurisdiction kaydı zaten mevcut'),
('error.kyc-jurisdiction.not-found', 'error', 'kyc-jurisdiction', 'Jurisdiction kaydı bulunamadı'),

-- KYC — Tarama Sonuçları (tenant_audit)
('error.kyc-screening.player-required', 'error', 'kyc-screening', 'Oyuncu ID zorunlu'),
('error.kyc-screening.screening-required', 'error', 'kyc-screening', 'Tarama ID zorunlu'),
('error.kyc-screening.type-required', 'error', 'kyc-screening', 'Tarama tipi zorunlu'),
('error.kyc-screening.provider-required', 'error', 'kyc-screening', 'Sağlayıcı kodu zorunlu'),
('error.kyc-screening.status-required', 'error', 'kyc-screening', 'Sonuç durumu zorunlu'),
('error.kyc-screening.decision-required', 'error', 'kyc-screening', 'İnceleme kararı zorunlu'),
('error.kyc-screening.reviewer-required', 'error', 'kyc-screening', 'İncelemeci ID zorunlu'),
('error.kyc-screening.not-found', 'error', 'kyc-screening', 'Tarama sonucu bulunamadı'),

-- KYC — Risk Değerlendirme (tenant_audit)
('error.kyc-risk.player-required', 'error', 'kyc-risk', 'Oyuncu ID zorunlu'),
('error.kyc-risk.type-required', 'error', 'kyc-risk', 'Değerlendirme tipi zorunlu'),
('error.kyc-risk.level-required', 'error', 'kyc-risk', 'Risk seviyesi zorunlu'),

-- KYC — Provider Log (tenant_log)
('error.kyc-provider-log.player-required', 'error', 'kyc-provider-log', 'Oyuncu ID zorunlu'),
('error.kyc-provider-log.case-required', 'error', 'kyc-provider-log', 'Case ID zorunlu'),
('error.kyc-provider-log.provider-required', 'error', 'kyc-provider-log', 'Sağlayıcı kodu zorunlu'),

-- ============================================================================
-- TENANT BACKOFFICE — Content Management (CMS)
-- ============================================================================
('error.content.id-required', 'error', 'content', 'İçerik ID zorunlu'),
('error.content.not-found', 'error', 'content', 'İçerik bulunamadı'),
('error.content.slug-required', 'error', 'content', 'Slug zorunlu'),
('error.content.translations-required', 'error', 'content', 'En az bir çeviri zorunlu'),
('error.content.user-id-required', 'error', 'content', 'Kullanıcı ID zorunlu'),
('error.content.category-code-required', 'error', 'content', 'Kategori kodu zorunlu'),
('error.content.category-id-required', 'error', 'content', 'Kategori ID zorunlu'),
('error.content.category-not-found', 'error', 'content', 'Kategori bulunamadı'),
('error.content.category-has-active-types', 'error', 'content', 'Aktif içerik tipleri olan kategori silinemez'),
('error.content.type-code-required', 'error', 'content', 'İçerik tipi kodu zorunlu'),
('error.content.type-id-required', 'error', 'content', 'İçerik tipi ID zorunlu'),
('error.content.type-not-found', 'error', 'content', 'İçerik tipi bulunamadı'),
('error.content.type-has-active-contents', 'error', 'content', 'Aktif içerikleri olan tip silinemez'),

-- ============================================================================
-- TENANT BACKOFFICE — FAQ Yönetimi
-- ============================================================================
('error.faq.user-id-required', 'error', 'faq', 'Kullanıcı ID zorunlu'),
('error.faq.category-code-required', 'error', 'faq', 'FAQ kategori kodu zorunlu'),
('error.faq.category-id-required', 'error', 'faq', 'FAQ kategori ID zorunlu'),
('error.faq.category-not-found', 'error', 'faq', 'FAQ kategorisi bulunamadı'),
('error.faq.category-has-active-items', 'error', 'faq', 'Aktif öğeleri olan FAQ kategorisi silinemez'),
('error.faq.item-id-required', 'error', 'faq', 'FAQ öğesi ID zorunlu'),
('error.faq.item-not-found', 'error', 'faq', 'FAQ öğesi bulunamadı'),

-- ============================================================================
-- TENANT BACKOFFICE — Layout Yönetimi
-- ============================================================================
('error.layout.id-required', 'error', 'layout', 'Layout ID zorunlu'),
('error.layout.not-found', 'error', 'layout', 'Layout bulunamadı'),
('error.layout.name-required', 'error', 'layout', 'Layout adı zorunlu'),
('error.layout.structure-required', 'error', 'layout', 'Layout yapısı zorunlu'),

-- ============================================================================
-- TENANT BACKOFFICE — Mesaj Tercihleri
-- ============================================================================
('error.messaging.preference.invalid-channel-type', 'error', 'messaging', 'Geçersiz tercih kanal tipi'),
('error.messaging.preference.opted-in-required', 'error', 'messaging', 'Tercih durumu (opted_in) zorunlu'),

-- ============================================================================
-- TENANT BACKOFFICE — Navigation Yönetimi
-- ============================================================================
('error.navigation.id-required', 'error', 'navigation', 'Navigasyon öğesi ID zorunlu'),
('error.navigation.item-not-found', 'error', 'navigation', 'Navigasyon öğesi bulunamadı'),
('error.navigation.item-locked', 'error', 'navigation', 'Kilitli navigasyon öğesi silinemez'),
('error.navigation.has-children', 'error', 'navigation', 'Alt öğeleri olan navigasyon öğesi silinemez'),
('error.navigation.parent-not-found', 'error', 'navigation', 'Üst navigasyon öğesi bulunamadı'),
('error.navigation.location-required', 'error', 'navigation', 'Menü konumu zorunlu'),
('error.navigation.label-required', 'error', 'navigation', 'Etiket veya çeviri anahtarı zorunlu'),
('error.navigation.item-ids-required', 'error', 'navigation', 'Öğe ID listesi zorunlu'),

-- ============================================================================
-- TENANT BACKOFFICE — Popup Yönetimi
-- ============================================================================
('error.popup.id-required', 'error', 'popup', 'Popup ID zorunlu'),
('error.popup.not-found', 'error', 'popup', 'Popup bulunamadı'),
('error.popup.user-id-required', 'error', 'popup', 'Kullanıcı ID zorunlu'),
('error.popup.type-code-required', 'error', 'popup', 'Popup tipi kodu zorunlu'),
('error.popup.type-id-required', 'error', 'popup', 'Popup tipi ID zorunlu'),
('error.popup.type-not-found', 'error', 'popup', 'Popup tipi bulunamadı'),

-- ============================================================================
-- TENANT BACKOFFICE — Promosyon Yönetimi
-- ============================================================================
('error.promotion.id-required', 'error', 'promotion', 'Promosyon ID zorunlu'),
('error.promotion.not-found', 'error', 'promotion', 'Promosyon bulunamadı'),
('error.promotion.code-required', 'error', 'promotion', 'Promosyon kodu zorunlu'),
('error.promotion.user-id-required', 'error', 'promotion', 'Kullanıcı ID zorunlu'),
('error.promotion.type-code-required', 'error', 'promotion', 'Promosyon tipi kodu zorunlu'),
('error.promotion.type-id-required', 'error', 'promotion', 'Promosyon tipi ID zorunlu'),
('error.promotion.type-not-found', 'error', 'promotion', 'Promosyon tipi bulunamadı'),

-- ============================================================================
-- TENANT BACKOFFICE — Slide/Banner Yönetimi
-- ============================================================================
('error.slide.id-required', 'error', 'slide', 'Slide ID zorunlu'),
('error.slide.not-found', 'error', 'slide', 'Slide bulunamadı'),
('error.slide.user-id-required', 'error', 'slide', 'Kullanıcı ID zorunlu'),
('error.slide.placement-id-required', 'error', 'slide', 'Placement ID zorunlu'),
('error.slide.placement-code-required', 'error', 'slide', 'Placement kodu zorunlu'),
('error.slide.placement-name-required', 'error', 'slide', 'Placement adı zorunlu'),
('error.slide.placement-not-found', 'error', 'slide', 'Placement bulunamadı'),
('error.slide.slide-ids-required', 'error', 'slide', 'Slide ID listesi zorunlu'),
('error.slide.category-code-required', 'error', 'slide', 'Slide kategori kodu zorunlu'),
('error.slide.category-not-found', 'error', 'slide', 'Slide kategorisi bulunamadı'),

-- ============================================================================
-- TENANT BACKOFFICE — Tema Yönetimi (ek)
-- ============================================================================
('error.theme.theme-id-required', 'error', 'theme', 'Tema referans ID zorunlu'),

-- ============================================================================
-- TENANT BACKOFFICE — Güven Elementleri (Trust Logos)
-- ============================================================================
('error.trust-logo.code-required', 'error', 'trust-logo', 'Logo kodu zorunlu'),
('error.trust-logo.type-required', 'error', 'trust-logo', 'Logo tipi zorunlu'),
('error.trust-logo.name-required', 'error', 'trust-logo', 'Logo adı zorunlu'),
('error.trust-logo.logo-url-required', 'error', 'trust-logo', 'Logo URL zorunlu'),
('error.trust-logo.items-required', 'error', 'trust-logo', 'Logo listesi zorunlu'),
('error.trust-logo.not-found', 'error', 'trust-logo', 'Logo bulunamadı'),
('error.trust-logo.id-required', 'error', 'trust-logo', 'Logo ID zorunlu'),

-- ============================================================================
-- TENANT BACKOFFICE — Operatör Lisansları
-- ============================================================================
('error.operator-license.jurisdiction-required', 'error', 'operator-license', 'Yetki alanı zorunlu'),
('error.operator-license.license-number-required', 'error', 'operator-license', 'Lisans numarası zorunlu'),
('error.operator-license.expiry-before-issued', 'error', 'operator-license', 'Bitiş tarihi başlangıç tarihinden önce olamaz'),
('error.operator-license.id-required', 'error', 'operator-license', 'Lisans ID zorunlu'),
('error.operator-license.not-found', 'error', 'operator-license', 'Lisans bulunamadı'),

-- ============================================================================
-- TENANT BACKOFFICE — SEO Yönlendirme
-- ============================================================================
('error.seo-redirect.from-slug-required', 'error', 'seo-redirect', 'Kaynak URL zorunlu'),
('error.seo-redirect.to-url-required', 'error', 'seo-redirect', 'Hedef URL zorunlu'),
('error.seo-redirect.invalid-redirect-type', 'error', 'seo-redirect', 'Geçersiz yönlendirme tipi (301 veya 302 olmalı)'),
('error.seo-redirect.circular-redirect', 'error', 'seo-redirect', 'Döngüsel yönlendirme tespit edildi'),
('error.seo-redirect.items-required', 'error', 'seo-redirect', 'Yönlendirme listesi zorunlu'),
('error.seo-redirect.id-required', 'error', 'seo-redirect', 'Yönlendirme ID zorunlu'),
('error.seo-redirect.not-found', 'error', 'seo-redirect', 'Yönlendirme bulunamadı'),

-- ============================================================================
-- TENANT BACKOFFICE — İçerik SEO Meta
-- ============================================================================
('error.content-seo-meta.content-id-required', 'error', 'content-seo-meta', 'İçerik ID zorunlu'),
('error.content-seo-meta.language-required', 'error', 'content-seo-meta', 'Dil kodu zorunlu'),
('error.content-seo-meta.invalid-twitter-card', 'error', 'content-seo-meta', 'Geçersiz Twitter kart tipi'),
('error.content-seo-meta.translation-not-found', 'error', 'content-seo-meta', 'İçerik çevirisi bulunamadı'),

-- ============================================================================
-- TENANT BACKOFFICE — Sosyal Medya Bağlantıları
-- ============================================================================
('error.social-link.platform-required', 'error', 'social-link', 'Platform adı zorunlu'),
('error.social-link.url-required', 'error', 'social-link', 'URL zorunlu'),
('error.social-link.items-required', 'error', 'social-link', 'Bağlantı listesi zorunlu'),
('error.social-link.id-required', 'error', 'social-link', 'Bağlantı ID zorunlu'),
('error.social-link.not-found', 'error', 'social-link', 'Bağlantı bulunamadı'),

-- ============================================================================
-- TENANT BACKOFFICE — Site Ayarları
-- ============================================================================
('error.site-settings.field-name-required', 'error', 'site-settings', 'Alan adı zorunlu'),
('error.site-settings.value-required', 'error', 'site-settings', 'Alan değeri zorunlu'),
('error.site-settings.invalid-field', 'error', 'site-settings', 'Geçersiz alan adı'),
('error.site-settings.not-found', 'error', 'site-settings', 'Site ayarları bulunamadı'),

-- ============================================================================
-- TENANT BACKOFFICE — Duyuru Çubukları
-- ============================================================================
('error.announcement-bar.code-required', 'error', 'announcement-bar', 'Duyuru çubuğu kodu zorunlu'),
('error.announcement-bar.invalid-audience', 'error', 'announcement-bar', 'Geçersiz hedef kitle'),
('error.announcement-bar.ends-before-starts', 'error', 'announcement-bar', 'Bitiş tarihi başlangıçtan önce olamaz'),
('error.announcement-bar.id-required', 'error', 'announcement-bar', 'Duyuru çubuğu ID zorunlu'),
('error.announcement-bar.not-found', 'error', 'announcement-bar', 'Duyuru çubuğu bulunamadı'),
('error.announcement-bar-translation.bar-id-required', 'error', 'announcement-bar-translation', 'Duyuru çubuğu ID zorunlu'),
('error.announcement-bar-translation.language-required', 'error', 'announcement-bar-translation', 'Dil kodu zorunlu'),
('error.announcement-bar-translation.text-required', 'error', 'announcement-bar-translation', 'Duyuru metni zorunlu'),

-- ============================================================================
-- TENANT BACKOFFICE — Lobi Bölümleri
-- ============================================================================
('error.lobby-section.code-required', 'error', 'lobby-section', 'Bölüm kodu zorunlu'),
('error.lobby-section.max-items-invalid', 'error', 'lobby-section', 'Maksimum öğe sayısı geçersiz'),
('error.lobby-section.id-required', 'error', 'lobby-section', 'Bölüm ID zorunlu'),
('error.lobby-section.not-found', 'error', 'lobby-section', 'Bölüm bulunamadı'),
('error.lobby-section-translation.section-id-required', 'error', 'lobby-section-translation', 'Bölüm ID zorunlu'),
('error.lobby-section-translation.language-required', 'error', 'lobby-section-translation', 'Dil kodu zorunlu'),
('error.lobby-section-translation.title-required', 'error', 'lobby-section-translation', 'Başlık zorunlu'),
('error.lobby-section-game.section-id-required', 'error', 'lobby-section-game', 'Bölüm ID zorunlu'),
('error.lobby-section-game.game-id-required', 'error', 'lobby-section-game', 'Oyun ID zorunlu'),
('error.lobby-section-game.section-not-found', 'error', 'lobby-section-game', 'Bölüm bulunamadı'),
('error.lobby-section-game.section-not-manual', 'error', 'lobby-section-game', 'Bölüm manuel küratörlük tipinde değil'),
('error.lobby-section-game.not-found', 'error', 'lobby-section-game', 'Bölüm-oyun ilişkisi bulunamadı'),

-- ============================================================================
-- TENANT BACKOFFICE — Oyun Etiketleri
-- ============================================================================
('error.game-label.game-id-required', 'error', 'game-label', 'Oyun ID zorunlu'),
('error.game-label.label-type-required', 'error', 'game-label', 'Etiket tipi zorunlu'),
('error.game-label.expires-in-past', 'error', 'game-label', 'Bitiş tarihi geçmişte olamaz'),
('error.game-label.id-required', 'error', 'game-label', 'Etiket ID zorunlu'),
('error.game-label.not-found', 'error', 'game-label', 'Etiket bulunamadı'),

-- ============================================================================
-- NAVIGATION MENU LABELS (UIKit navigasyon şablon öğeleri)
-- Pattern: menu.{location}.{item}
-- ============================================================================

-- Main Header
('menu.main.casino', 'menu', 'main', 'Ana menü: Casino'),
('menu.main.live-casino', 'menu', 'main', 'Ana menü: Canlı Casino'),
('menu.main.sports', 'menu', 'main', 'Ana menü: Spor'),
('menu.main.promotions', 'menu', 'main', 'Ana menü: Promosyonlar'),
('menu.main.tournaments', 'menu', 'main', 'Ana menü: Turnuvalar'),
('menu.main.vip', 'menu', 'main', 'Ana menü: VIP'),
('menu.main.login', 'menu', 'main', 'Ana menü: Giriş'),
('menu.main.register', 'menu', 'main', 'Ana menü: Kayıt Ol'),

-- Casino Alt Menü
('menu.casino.slots', 'menu', 'casino', 'Casino alt menü: Slot Oyunları'),
('menu.casino.table-games', 'menu', 'casino', 'Casino alt menü: Masa Oyunları'),
('menu.casino.jackpots', 'menu', 'casino', 'Casino alt menü: Jackpot'),
('menu.casino.new-games', 'menu', 'casino', 'Casino alt menü: Yeni Oyunlar'),

-- Live Casino Alt Menü
('menu.live-casino.roulette', 'menu', 'live-casino', 'Canlı Casino alt menü: Rulet'),
('menu.live-casino.blackjack', 'menu', 'live-casino', 'Canlı Casino alt menü: Blackjack'),
('menu.live-casino.baccarat', 'menu', 'live-casino', 'Canlı Casino alt menü: Baccarat'),
('menu.live-casino.game-shows', 'menu', 'live-casino', 'Canlı Casino alt menü: Oyun Şovları'),

-- Sports Alt Menü
('menu.sports.football', 'menu', 'sports', 'Spor alt menü: Futbol'),
('menu.sports.basketball', 'menu', 'sports', 'Spor alt menü: Basketbol'),
('menu.sports.tennis', 'menu', 'sports', 'Spor alt menü: Tenis'),
('menu.sports.live', 'menu', 'sports', 'Spor alt menü: Canlı Bahis'),

-- Footer
('menu.footer.about', 'menu', 'footer', 'Footer: Hakkımızda'),
('menu.footer.responsible-gaming', 'menu', 'footer', 'Footer: Sorumlu Oyun'),
('menu.footer.privacy', 'menu', 'footer', 'Footer: Gizlilik Politikası'),
('menu.footer.terms', 'menu', 'footer', 'Footer: Şartlar ve Koşullar'),
('menu.footer.casino', 'menu', 'footer', 'Footer: Casino'),
('menu.footer.live-casino', 'menu', 'footer', 'Footer: Canlı Casino'),
('menu.footer.sports', 'menu', 'footer', 'Footer: Spor'),
('menu.footer.promotions', 'menu', 'footer', 'Footer: Promosyonlar'),
('menu.footer.help', 'menu', 'footer', 'Footer: Yardım Merkezi'),
('menu.footer.contact', 'menu', 'footer', 'Footer: Bize Ulaşın'),
('menu.footer.affiliates', 'menu', 'footer', 'Footer: İş Ortaklığı'),
('menu.footer.account', 'menu', 'footer', 'Footer: Hesabım'),
('menu.footer.deposit', 'menu', 'footer', 'Footer: Para Yatır'),
('menu.footer.withdraw', 'menu', 'footer', 'Footer: Para Çek'),

-- Mobile Bottom
('menu.mobile.home', 'menu', 'mobile', 'Mobil: Ana Sayfa'),
('menu.mobile.casino', 'menu', 'mobile', 'Mobil: Casino'),
('menu.mobile.sports', 'menu', 'mobile', 'Mobil: Spor'),
('menu.mobile.promotions', 'menu', 'mobile', 'Mobil: Promosyonlar'),
('menu.mobile.account', 'menu', 'mobile', 'Mobil: Hesabım')

ON CONFLICT DO NOTHING;
