-- ============================================================================
-- LOCALIZATION KEYS
-- Key ve domain her zaman lowercase, kebab-case
-- ============================================================================

TRUNCATE TABLE catalog.localization_keys CASCADE;

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

-- Logs Exceptions (Dead Letter, Error, Audit)
('error.logs.errornotfound', 'error', 'logs', 'Error log bulunamadi'),
('error.logs.deadletternotfound', 'error', 'logs', 'Dead letter bulunamadi'),
('error.logs.auditnotfound', 'error', 'logs', 'Audit log bulunamadi'),

-- Auth - Account Status
('error.auth.account-inactive', 'error', 'auth', 'Hesap aktif degil'),

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
('error.user.create.email-exists', 'error', 'user', 'Email adresi zaten kayitli'),
('error.user.create.username-exists', 'error', 'user', 'Kullanici adi bu sirkette zaten mevcut'),
('error.user.update.is-deleted', 'error', 'user', 'Silinmis kullanici guncellenemez'),
('error.user.update.email-exists', 'error', 'user', 'Email adresi baska kullanicida kayitli'),
('error.user.update.username-exists', 'error', 'user', 'Kullanici adi bu sirkette baska kullanicida mevcut'),
('error.user.delete.already-deleted', 'error', 'user', 'Kullanici zaten silinmis'),
('error.user.reset-password.is-deleted', 'error', 'user', 'Silinmis kullanicinin sifresi sifirlanamaz'),
('error.user.restore.not-deleted', 'error', 'user', 'Kullanici silinmis degil'),

-- Company Exceptions
('error.company.not-found', 'error', 'company', 'Sirket bulunamadi veya pasif'),

-- Company CRUD & Validation Exceptions
('error.company.create.code-exists', 'error', 'company', 'Sirket kodu zaten kayitli'),
('error.company.create.name-exists', 'error', 'company', 'Sirket adi zaten kayitli'),
('error.company.update.code-exists', 'error', 'company', 'Sirket kodu baska sirkette kayitli'),
('error.company.update.name-exists', 'error', 'company', 'Sirket adi baska sirkette kayitli'),
('error.company.delete.already-deleted', 'error', 'company', 'Sirket zaten silinmis'),
('error.country.not-found', 'error', 'country', 'Ulke kodu bulunamadi'),
('error.pagination.invalid', 'error', 'pagination', 'Gecersiz sayfa veya sayfa boyutu'),

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
