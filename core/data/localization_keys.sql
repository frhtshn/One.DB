-- ============================================================================
-- LOCALIZATION KEYS
-- Key ve domain her zaman lowercase, kebab-case
-- ============================================================================

INSERT INTO catalog.localization_keys (localization_key, domain, category, description) VALUES

-- ============================================================================
-- VALIDATION MESSAGES (LocalizedValidator'da kullanilan)
-- Pattern: validation.{domain}.{reason}
-- ============================================================================
('validation.summary', 'validation', 'summary', 'Coklu hata ozet mesaji. Args: {0}=errorCount'),
('validation.field.required', 'validation', 'field', '{0} alani icin zorunluluk mesaji'),
('validation.field.max-length', 'validation', 'field', '{0} alani max uzunluk asimi. Args: {1}=maxLength'),
('validation.field.min-length', 'validation', 'field', '{0} alani min uzunluk hatasi. Args: {1}=minLength'),
('validation.field.length', 'validation', 'field', '{0} alani uzunluk araligi. Args: {1}=min, {2}=max'),
('validation.field.exact-length', 'validation', 'field', '{0} alani tam uzunluk. Args: {1}=length'),
('validation.format.email-invalid', 'validation', 'format', 'Gecersiz email formati'),
('validation.format.url-invalid', 'validation', 'format', 'Gecersiz URL formati'),
('validation.format.invalid', 'validation', 'format', 'Gecersiz format'),
('validation.format.timezone-invalid', 'validation', 'format', 'Gecersiz timezone'),
('validation.range.greater-than-zero', 'validation', 'range', 'Sifirdan buyuk olmali'),
('validation.range.between', 'validation', 'range', 'Aralik kontrolu. Args: {1}=min, {2}=max'),
('validation.range.min', 'validation', 'range', 'Minimum deger kontrolu. Args: {1}=min'),
('validation.filter.sort-field-invalid', 'validation', 'filter', 'Gecersiz siralama alani. Args: {1}=allowedFields'),
('validation.filter.sort-order-invalid', 'validation', 'filter', 'Gecersiz siralama yonu'),
('validation.request.invalid', 'validation', 'request', 'Gecersiz istek'),

-- Password Validation (PasswordPolicyValidator'da kullanilan)
('validation.password.required', 'validation', 'password', 'Sifre zorunlu'),
('validation.password.min-length', 'validation', 'password', 'Min uzunluk. Args: {0}=minLength'),
('validation.password.max-length', 'validation', 'password', 'Max uzunluk. Args: {0}=maxLength'),
('validation.password.require-uppercase', 'validation', 'password', 'Buyuk harf gerekli'),
('validation.password.require-lowercase', 'validation', 'password', 'Kucuk harf gerekli'),
('validation.password.require-digit', 'validation', 'password', 'Rakam gerekli'),
('validation.password.require-special', 'validation', 'password', 'Ozel karakter gerekli'),

-- ============================================================================
-- ERROR MESSAGES (Exception siniflarinda kullanilan)
-- Pattern: error.{domain}.{sub-domain?}.{reason}
-- ============================================================================

-- BadRequest - Field Errors
('error.field.missing', 'error', 'field', 'Zorunlu alan eksik. Args: {0}=fieldName'),
('error.field.invalid', 'error', 'field', 'Gecersiz alan. Args: {0}=fieldName, {1}=reason'),

-- Generic CRUD Exceptions
('error.crud.create-failed', 'error', 'crud', 'Olusturma basarisiz. Args: {0}=resourceType'),
('error.crud.update-failed', 'error', 'crud', 'Guncelleme basarisiz. Args: {0}=resourceType'),

-- Business Rule Exceptions
('error.business.insufficient-balance', 'error', 'business', 'Yetersiz bakiye. Args: {0}=required, {1}=balance'),
('error.business.invalid-status-transition', 'error', 'business', 'Gecersiz durum gecisi. Args: {0}=from, {1}=to'),

-- System - Cache Exceptions
('error.system.cache.connection-failed', 'error', 'system', 'Cache baglanti hatasi'),
('error.system.cache.operation-failed', 'error', 'system', 'Cache islem hatasi. Args: {0}=operation'),

-- System - Circuit Breaker Exceptions
('error.system.circuit-breaker.database', 'error', 'system', 'Veritabani circuit breaker acik'),
('error.system.circuit-breaker.cache', 'error', 'system', 'Cache circuit breaker acik'),
('error.system.circuit-breaker.external-api', 'error', 'system', 'External API circuit breaker acik. Args: {0}=apiName'),
('error.system.circuit-breaker.messaging', 'error', 'system', 'Messaging circuit breaker acik. Args: {0}=serviceName'),

-- Conflict Exceptions
('error.conflict.duplicate', 'error', 'conflict', 'Kaynak zaten mevcut. Args: {0}=resourceType, {1}=identifier'),
('error.conflict.concurrency', 'error', 'conflict', 'Eszamanlilik cakismasi. Args: {0}=resourceType, {1}=resourceId'),

-- System - Database Exceptions
('error.system.database.connection-failed', 'error', 'system', 'Veritabani baglanti hatasi'),
('error.system.database.query-failed', 'error', 'system', 'Veritabani sorgu hatasi. Args: {0}=operation'),
('error.system.database.invalid-tenant-id', 'error', 'system', 'Gecersiz tenant ID. Args: {0}=tenantId'),
('error.system.database.command-failed', 'error', 'system', 'Veritabani islem hatasi. Args: {0}=operation'),

-- Forbidden Exceptions
('error.forbidden.resource', 'error', 'forbidden', 'Kaynak erisim yetkisi yok. Args: {0}=resource, {1}=permission'),
('error.tenant.access-denied', 'error', 'tenant', 'Tenant erisim engellendi. Args: {0}=tenantId'),

-- System - Grain Exceptions
('error.system.grain.activation-failed', 'error', 'system', 'Grain aktivasyon hatasi. Args: {0}=grainType, {1}=grainKey'),
('error.system.grain.operation-failed', 'error', 'system', 'Grain islem hatasi. Args: {0}=operation'),

-- System - Operation Timeout Exceptions
('error.system.operation.timeout', 'error', 'system', 'Islem zaman asimi. Args: {0}=operation, {1}=seconds'),

-- System - Rate Limit Exceptions
('error.system.rate-limit.exceeded', 'error', 'system', 'Rate limit asildi. Args: {0}=clientId, {1}=current, {2}=limit, {3}=retryAfter'),

-- System - Silo Exceptions
('error.system.silo.unavailable', 'error', 'system', 'Silo erisilemez'),
('error.system.silo.cluster-unavailable', 'error', 'system', 'Orleans cluster erisilemez'),
('error.system.silo.auth-init-failed', 'error', 'system', 'Auth altyapisi baslatilamadi'),

-- Tenant Exceptions
('error.tenant.not-active', 'error', 'tenant', 'Tenant aktif degil. Args: {0}=tenantId'),
('error.tenant.configuration-invalid', 'error', 'tenant', 'Tenant konfigurasyon hatasi. Args: {0}=tenantId, {1}=reason'),

-- Resource Not Found Exceptions
('error.resource.not-found', 'error', 'notfound', 'Kaynak bulunamadi. Args: {0}=resourceType, {1}=resourceId'),

-- Configuration Exceptions
('error.config.missing-required', 'error', 'config', 'Zorunlu konfigurasyon eksik. Args: {0}=configKey'),
('error.config.cannot-resolve-hostname', 'error', 'config', 'Hostname cozumlenemedi. Args: {0}=hostname'),
('error.config.invalid-value', 'error', 'config', 'Gecersiz konfigurasyon degeri. Args: {0}=configKey, {1}=reason'),

-- System - Replica Write Exceptions
('error.system.replica.write-not-allowed', 'error', 'system', 'Replica uzerinde yazma yasak. Args: {0}=identifier, {1}=operation'),

-- Auth - Token Exceptions
('error.auth.token.missing', 'error', 'auth', 'Token eksik'),
('error.auth.token.invalid', 'error', 'auth', 'Gecersiz token. Args: {0}=reason'),
('error.auth.token.expired', 'error', 'auth', 'Token suresi dolmus'),
('error.auth.token.revoked', 'error', 'auth', 'Token iptal edilmis'),
('error.auth.token.not-found', 'error', 'auth', 'Token bulunamadi'),
('error.auth.token.refresh-invalid', 'error', 'auth', 'Gecersiz veya suresi dolmus refresh token'),
('error.auth.token.refresh-required', 'error', 'auth', 'Refresh token zorunlu'),
('error.auth.token.refresh-failed', 'error', 'auth', 'Token yenileme basarisiz'),

-- Auth - Login Exceptions
('error.auth.login.throttled', 'error', 'auth', 'Cok fazla giris denemesi. Args: {0}=saniye'),
('error.auth.login.failed', 'error', 'auth', 'Genel login hatasi'),
('error.auth.login.account-locked', 'error', 'auth', 'Hesap kilitlendi. Args: {0}=acilis saati'),
('error.auth.login.invalid-credentials', 'error', 'auth', 'Gecersiz kullanici/sifre'),

-- Auth - User Exceptions
('error.auth.user.invalid-id', 'error', 'auth', 'Gecersiz kullanici kimligi'),
('error.auth.user.not-found', 'error', 'auth', 'Kullanici bulunamadi'),
('error.auth.admin.not-found', 'error', 'auth', 'Admin kullanici bilgisi alinamadi'),

-- Auth - Session Exceptions
('error.auth.session.not-found', 'error', 'auth', 'Oturum bulunamadi'),
('error.auth.session.id-required', 'error', 'auth', 'Oturum kimligi zorunlu'),
('error.auth.session.use-logout-endpoint', 'error', 'auth', 'Mevcut oturum icin logout endpoint kullanilmali'),
('error.auth.session.revoke-failed', 'error', 'auth', 'Oturum sonlandirma basarisiz'),

-- Auth - Logout Exceptions
('error.auth.logout.failed', 'error', 'auth', 'Cikis basarisiz'),
('error.auth.logout.all-failed', 'error', 'auth', 'Toplu cikis basarisiz'),

-- Auth - Unlock Exceptions
('error.auth.unlock.failed', 'error', 'auth', 'Hesap kilidi acilamadi'),

-- Auth Success Messages
('success.auth.logout', 'success', 'auth', 'Cikis basarili mesaji'),
('success.auth.logout-all', 'success', 'auth', 'Tum oturumlar sonlandirildi mesaji'),
('success.auth.session-revoked', 'success', 'auth', 'Oturum sonlandirildi mesaji'),
('success.auth.unlocked', 'success', 'auth', 'Hesap kilidi acildi'),

-- Presentation Success Messages
('success.presentation.cache-invalidated', 'success', 'presentation', 'Presentation cache temizlendi'),

-- Permission Exceptions
('error.permission.not-found', 'error', 'permission', 'Yetki bulunamadi'),
('error.permission.grant.failed', 'error', 'permission', 'Yetki verme basarisiz'),
('error.permission.deny.failed', 'error', 'permission', 'Yetki reddetme basarisiz'),
('error.permission.remove.failed', 'error', 'permission', 'Yetki kaldirma basarisiz'),
('error.permission.deleted', 'error', 'permission', 'Yetki silinmis'),
('error.permission.create.code-required', 'error', 'permission', 'Yetki kodu zorunlu'),
('error.permission.create.code-exists', 'error', 'permission', 'Yetki kodu zaten mevcut'),
('error.permission.create.code-deleted', 'error', 'permission', 'Yetki kodu silinmis. Restore kullanin'),
('error.permission.update.is-deleted', 'error', 'permission', 'Silinmis yetki guncellenemez'),
('error.permission.delete.already-deleted', 'error', 'permission', 'Yetki zaten silinmis'),
('error.permission.restore.not-deleted', 'error', 'permission', 'Yetki silinmis degil'),
('error.permission.create.failed', 'error', 'permission', 'Yetki olusturulamadi'),
('error.permission.update.failed', 'error', 'permission', 'Yetki guncellenemedi'),
('error.permission.delete.failed', 'error', 'permission', 'Yetki silinemedi'),
('error.permission.restore.failed', 'error', 'permission', 'Yetki geri yuklenemedi'),

-- Role Exceptions
('error.role.not-found', 'error', 'role', 'Rol bulunamadi'),
('error.role.create.code-exists', 'error', 'role', 'Rol kodu zaten mevcut'),
('error.role.create.code-deleted', 'error', 'role', 'Rol kodu silinmis. Restore kullanin'),
('error.role.deleted', 'error', 'role', 'Silinmis rol uzerinde islem yapilamaz'),
('error.role.delete.already-deleted', 'error', 'role', 'Rol zaten silinmis'),
('error.role.restore.not-deleted', 'error', 'role', 'Rol silinmis degil'),
('error.role.system-protected', 'error', 'role', 'Sistem rolu degistirilemez'),
('error.role.list.failed', 'error', 'role', 'Rol listesi alinamadi'),
('error.role.get.failed', 'error', 'role', 'Rol bilgisi alinamadi'),
('error.role.create.failed', 'error', 'role', 'Rol olusturulamadi'),
('error.role.update.failed', 'error', 'role', 'Rol guncellenemedi'),
('error.role.delete.failed', 'error', 'role', 'Rol silinemedi'),
('error.role.restore.failed', 'error', 'role', 'Rol geri yuklenemedi'),
('error.role.assign.failed', 'error', 'role', 'Rol atama basarisiz'),
('error.role.remove.failed', 'error', 'role', 'Rol kaldirma basarisiz'),
('error.role.bulk-assign.failed', 'error', 'role', 'Toplu yetki atama basarisiz'),
('error.role.assign-permission.failed', 'error', 'role', 'Role yetki atama basarisiz'),
('error.role.remove-permission.failed', 'error', 'role', 'Rolden yetki kaldirma basarisiz'),
('error.role.assign-tenant.failed', 'error', 'role', 'Tenant rol atama basarisiz'),
('error.role.remove-tenant.failed', 'error', 'role', 'Tenant rol kaldirma basarisiz'),
('error.role.user-not-found', 'error', 'role', 'Kullanici bulunamadi'),
('error.role.permission-not-found', 'error', 'role', 'Yetki bulunamadi'),
('error.role.permission-deleted', 'error', 'role', 'Silinmis yetki atanamaz'),
('error.role.operation-failed', 'error', 'role', 'Rol islemi basarisiz'),
('error.role.tenant-mismatch', 'error', 'role', 'Tenant uyusmazligi'),

-- User Exceptions
('error.user.not-found', 'error', 'user', 'Kullanici bulunamadi'),

-- Localization Exceptions
('error.localization.language-code-invalid', 'error', 'localization', 'Gecersiz dil kodu. Args: {0}=langCode'),
('error.localization.language-name-invalid', 'error', 'localization', 'Gecersiz dil adi'),
('error.localization.key.not-found', 'error', 'localization', 'Localization key bulunamadi'),
('error.localization.key.invalid', 'error', 'localization', 'Gecersiz localization key'),
('error.localization.key.exists', 'error', 'localization', 'Localization key zaten mevcut'),
('error.localization.domain-invalid', 'error', 'localization', 'Gecersiz domain'),
('error.localization.translation.not-found', 'error', 'localization', 'Ceviri bulunamadi'),

-- Language Management Exceptions
('error.language.not-found', 'error', 'language', 'Dil bulunamadi'),
('error.language.create.code-exists', 'error', 'language', 'Dil kodu zaten mevcut'),
('error.language.code-invalid', 'error', 'language', 'Gecersiz dil kodu (2 karakter olmali)'),
('error.language.name-invalid', 'error', 'language', 'Gecersiz dil adi (min 2 karakter)'),
('error.language.delete.has-translations', 'error', 'language', 'Dil silinemez, cevirileri mevcut'),

-- SQL Validation Exceptions
('error.sql.function-name-invalid', 'error', 'sql', 'Gecersiz function adi. Args: {0}=functionName'),
('error.sql.identifier-too-long', 'error', 'sql', 'Identifier cok uzun. Args: {0}=identifier, {1}=length, {2}=maxLength'),
('error.sql.command-not-allowed', 'error', 'sql', 'SQL komutu izin verilmiyor. Args: {0}=allowedPrefixes'),
('error.sql.stacked-query', 'error', 'sql', 'Birden fazla SQL komutu yasak'),
('error.sql.system-table-access', 'error', 'sql', 'Sistem tablosuna erisim yasak')

ON CONFLICT DO NOTHING;

-- ============================================================================
-- ENGLISH VALUES
-- ============================================================================

INSERT INTO catalog.localization_values (localization_key_id, language_code, localized_text, created_at)
SELECT k.id, 'en', v.text, NOW()
FROM catalog.localization_keys k
JOIN (VALUES
    -- Validation (LocalizedValidator)
    ('validation.summary', 'Validation failed: {0} error(s)'),
    ('validation.field.required', '{0} is required'),
    ('validation.field.max-length', '{0} cannot exceed {1} characters'),
    ('validation.field.min-length', '{0} must be at least {1} characters'),
    ('validation.field.length', '{0} must be between {1} and {2} characters'),
    ('validation.field.exact-length', '{0} must be exactly {1} characters'),
    ('validation.format.email-invalid', '{0} is not a valid email address'),
    ('validation.format.url-invalid', '{0} is not a valid URL'),
    ('validation.format.invalid', '{0} has invalid format'),
    ('validation.format.timezone-invalid', '{0} is not a valid timezone'),
    ('validation.range.greater-than-zero', '{0} must be greater than zero'),
    ('validation.range.between', '{0} must be between {1} and {2}'),
    ('validation.range.min', '{0} must be at least {1}'),
    ('validation.filter.sort-field-invalid', '{0} must be one of: {1}'),
    ('validation.filter.sort-order-invalid', '{0} must be ''asc'' or ''desc'''),
    ('validation.request.invalid', 'Invalid request'),
    ('validation.password.required', 'Password is required'),
    ('validation.password.min-length', 'Password must be at least {0} characters'),
    ('validation.password.max-length', 'Password cannot exceed {0} characters'),
    ('validation.password.require-uppercase', 'Password must contain at least one uppercase letter'),
    ('validation.password.require-lowercase', 'Password must contain at least one lowercase letter'),
    ('validation.password.require-digit', 'Password must contain at least one digit'),
    ('validation.password.require-special', 'Password must contain at least one special character'),

    -- Error Messages - Field
    ('error.field.missing', 'Required field is missing: ''{0}'''),
    ('error.field.invalid', 'Invalid field ''{0}'': {1}'),

    -- Error Messages - CRUD
    ('error.crud.create-failed', '{0} creation failed'),
    ('error.crud.update-failed', '{0} update failed'),

    -- Error Messages - Business
    ('error.business.insufficient-balance', 'Insufficient balance. Required: {0}, Available: {1}'),
    ('error.business.invalid-status-transition', 'Cannot transition from {0} to {1}'),

    -- Error Messages - System Cache
    ('error.system.cache.connection-failed', 'Cache connection failed'),
    ('error.system.cache.operation-failed', 'Cache operation failed: {0}'),

    -- Error Messages - System Circuit Breaker
    ('error.system.circuit-breaker.database', 'Database circuit breaker is open'),
    ('error.system.circuit-breaker.cache', 'Cache circuit breaker is open'),
    ('error.system.circuit-breaker.external-api', 'Circuit breaker is open for {0}'),
    ('error.system.circuit-breaker.messaging', 'Messaging circuit breaker is open for {0}'),

    -- Error Messages - Conflict
    ('error.conflict.duplicate', '{0} already exists: {1}'),
    ('error.conflict.concurrency', '{0} {1} was modified by another process'),

    -- Error Messages - System Database
    ('error.system.database.connection-failed', 'Database connection failed'),
    ('error.system.database.query-failed', 'Database query failed: {0}'),
    ('error.system.database.invalid-tenant-id', 'Invalid tenant ID: {0}'),
    ('error.system.database.command-failed', 'Database operation failed: {0}'),

    -- Error Messages - Forbidden
    ('error.forbidden.resource', 'You do not have permission to access {0}. Required permission: {1}'),
    ('error.tenant.access-denied', 'Access denied for tenant {0}'),

    -- Error Messages - System Grain
    ('error.system.grain.activation-failed', 'Grain activation failed: {0} (key: {1})'),
    ('error.system.grain.operation-failed', 'Grain operation failed: {0}'),

    -- Error Messages - System Operation
    ('error.system.operation.timeout', 'Operation ''{0}'' timed out after {1} seconds'),
    ('error.system.rate-limit.exceeded', 'Rate limit exceeded (client: ''{0}''): {1}/{2}. Retry after {3} seconds.'),

    -- Error Messages - System Silo
    ('error.system.silo.unavailable', 'Silo is unavailable'),
    ('error.system.silo.cluster-unavailable', 'Orleans cluster is unavailable'),
    ('error.system.silo.auth-init-failed', 'Auth infrastructure initialization failed'),

    -- Error Messages - Tenant
    ('error.tenant.not-active', 'Tenant {0} is not active'),
    ('error.tenant.configuration-invalid', 'Tenant {0} configuration is invalid: {1}'),

    -- Error Messages - Resource
    ('error.resource.not-found', '{0} not found: {1}'),

    -- Error Messages - Config
    ('error.config.missing-required', 'Required configuration is missing: {0}'),
    ('error.config.cannot-resolve-hostname', 'Cannot resolve hostname: {0}'),
    ('error.config.invalid-value', 'Invalid configuration value ''{0}'': {1}'),

    -- Error Messages - System Replica
    ('error.system.replica.write-not-allowed', 'Write operation not allowed on replica. Identifier: {0}, Operation: {1}. Use primary instance.'),

    -- Error Messages - Auth Token
    ('error.auth.token.missing', 'Authentication token is required'),
    ('error.auth.token.invalid', 'Invalid authentication token: {0}'),
    ('error.auth.token.expired', 'Authentication token has expired'),
    ('error.auth.token.revoked', 'Token has been revoked'),
    ('error.auth.token.not-found', 'Token not found'),
    ('error.auth.token.refresh-invalid', 'Invalid or expired refresh token'),
    ('error.auth.token.refresh-required', 'Refresh token is required'),
    ('error.auth.token.refresh-failed', 'Token refresh failed'),

    -- Error Messages - Auth Login
    ('error.auth.login.throttled', 'Too many login attempts. Please wait {0} seconds.'),
    ('error.auth.login.failed', 'Login failed'),
    ('error.auth.login.account-locked', 'Your account is locked. Please wait until {0}.'),
    ('error.auth.login.invalid-credentials', 'Invalid username or password'),

    -- Error Messages - Auth User
    ('error.auth.user.invalid-id', 'Invalid user ID'),
    ('error.auth.user.not-found', 'User not found'),
    ('error.auth.admin.not-found', 'Admin user info not found'),

    -- Error Messages - Auth Session
    ('error.auth.session.not-found', 'Session not found'),
    ('error.auth.session.id-required', 'Session ID is required'),
    ('error.auth.session.use-logout-endpoint', 'Use the logout endpoint to terminate the current session'),
    ('error.auth.session.revoke-failed', 'Session revocation failed'),

    -- Error Messages - Auth Logout
    ('error.auth.logout.failed', 'Logout failed'),
    ('error.auth.logout.all-failed', 'Logout all sessions failed'),

    -- Error Messages - Auth Unlock
    ('error.auth.unlock.failed', 'Failed to unlock account'),

    -- Success Messages - Auth
    ('success.auth.logout', 'Logged out successfully'),
    ('success.auth.logout-all', 'All sessions terminated'),
    ('success.auth.session-revoked', 'Session terminated'),
    ('success.auth.unlocked', 'Account unlocked'),

    -- Success Messages - Presentation
    ('success.presentation.cache-invalidated', 'Presentation cache invalidated'),

    -- Error Messages - Permission
    ('error.permission.not-found', 'Permission not found'),
    ('error.permission.grant.failed', 'Failed to grant permission'),
    ('error.permission.deny.failed', 'Failed to deny permission'),
    ('error.permission.remove.failed', 'Failed to remove permission'),
    ('error.permission.deleted', 'Permission has been deleted'),
    ('error.permission.create.code-required', 'Permission code is required'),
    ('error.permission.create.code-exists', 'Permission code already exists'),
    ('error.permission.create.code-deleted', 'Permission code is deleted. Use restore'),
    ('error.permission.update.is-deleted', 'Deleted permission cannot be updated'),
    ('error.permission.delete.already-deleted', 'Permission is already deleted'),
    ('error.permission.restore.not-deleted', 'Permission is not deleted'),
    ('error.permission.create.failed', 'Failed to create permission'),
    ('error.permission.update.failed', 'Failed to update permission'),
    ('error.permission.delete.failed', 'Failed to delete permission'),
    ('error.permission.restore.failed', 'Failed to restore permission'),

    -- Error Messages - Role
    ('error.role.not-found', 'Role not found'),
    ('error.role.create.code-exists', 'Role code already exists'),
    ('error.role.create.code-deleted', 'Role code is deleted. Use restore'),
    ('error.role.deleted', 'Cannot operate on deleted role'),
    ('error.role.delete.already-deleted', 'Role is already deleted'),
    ('error.role.restore.not-deleted', 'Role is not deleted'),
    ('error.role.system-protected', 'System role cannot be modified'),
    ('error.role.list.failed', 'Failed to get role list'),
    ('error.role.get.failed', 'Failed to get role'),
    ('error.role.create.failed', 'Failed to create role'),
    ('error.role.update.failed', 'Failed to update role'),
    ('error.role.delete.failed', 'Failed to delete role'),
    ('error.role.restore.failed', 'Failed to restore role'),
    ('error.role.assign.failed', 'Failed to assign role'),
    ('error.role.remove.failed', 'Failed to remove role'),
    ('error.role.bulk-assign.failed', 'Bulk permission assignment failed'),
    ('error.role.assign-permission.failed', 'Failed to assign permission to role'),
    ('error.role.remove-permission.failed', 'Failed to remove permission from role'),
    ('error.role.assign-tenant.failed', 'Failed to assign tenant role'),
    ('error.role.remove-tenant.failed', 'Failed to remove tenant role'),
    ('error.role.user-not-found', 'User not found'),
    ('error.role.permission-not-found', 'Permission not found'),
    ('error.role.permission-deleted', 'Cannot assign deleted permission'),
    ('error.role.operation-failed', 'Role operation failed'),
    ('error.role.tenant-mismatch', 'Tenant mismatch'),

    -- Error Messages - User
    ('error.user.not-found', 'User not found'),

    -- Error Messages - Localization
    ('error.localization.language-code-invalid', 'Invalid language code: {0}'),
    ('error.localization.language-name-invalid', 'Invalid language name'),
    ('error.localization.key.not-found', 'Localization key not found'),
    ('error.localization.key.invalid', 'Invalid localization key'),
    ('error.localization.key.exists', 'Localization key already exists'),
    ('error.localization.domain-invalid', 'Invalid domain'),
    ('error.localization.translation.not-found', 'Translation not found'),

    -- Error Messages - Language
    ('error.language.not-found', 'Language not found'),
    ('error.language.create.code-exists', 'This language code already exists'),
    ('error.language.code-invalid', 'Invalid language code. Must be 2 characters'),
    ('error.language.name-invalid', 'Invalid language name. Must be at least 2 characters'),
    ('error.language.delete.has-translations', 'Cannot delete language. It has existing translations'),

    -- Error Messages - SQL
    ('error.sql.function-name-invalid', 'Invalid function name: {0}'),
    ('error.sql.identifier-too-long', 'Identifier ''{0}'' is too long: {1} characters (max {2})'),
    ('error.sql.command-not-allowed', 'SQL command not allowed. Allowed prefixes: {0}'),
    ('error.sql.stacked-query', 'Multiple SQL commands (stacked queries) are not allowed'),
    ('error.sql.system-table-access', 'Access to system tables is not allowed')
) AS v(key, text) ON k.localization_key = v.key
ON CONFLICT DO NOTHING;

-- ============================================================================
-- TURKISH VALUES
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
