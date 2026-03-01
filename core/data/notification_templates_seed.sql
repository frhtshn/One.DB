-- ================================================================
-- SORTIS ONE - NOTIFICATION TEMPLATES SEED
-- ================================================================
-- Platform bildirim şablonları: BO kullanıcılarına yönelik
-- sistem/transaksiyonel e-posta ve SMS şablonları.
-- Tüm şablonlar is_system=TRUE olarak işaretlenir.
-- ================================================================
-- Çalıştırma: psql -U postgres -d core -f core/data/notification_templates_seed.sql
-- ================================================================
-- NOT: Client şablonları backend tarafından client provisioning
-- sırasında seed'lenir (bu dosyada değil).
-- ================================================================

-- Mevcut seed verilerini temizle
DELETE FROM messaging.message_template_translations;
DELETE FROM messaging.message_templates;

-- ================================================================
-- 1. EMAIL ŞABLONLARI
-- ================================================================

-- user.welcome.email
INSERT INTO messaging.message_templates (code, name, channel_type, category, description, variables, is_system, status, created_by)
VALUES (
    'user.welcome.email',
    'User Welcome Email',
    'email',
    'transactional',
    'Yeni BO kullanıcısı hoş geldiniz e-postası',
    '[{"key": "user_name", "type": "string", "required": true, "description": "Kullanıcı adı"},
      {"key": "login_url", "type": "string", "required": true, "description": "Giriş sayfası URL"}]'::JSONB,
    TRUE,
    'active',
    -1
);

-- user.password_reset.email
INSERT INTO messaging.message_templates (code, name, channel_type, category, description, variables, is_system, status, created_by)
VALUES (
    'user.password_reset.email',
    'User Password Reset Email',
    'email',
    'transactional',
    'BO kullanıcısı şifre sıfırlama bağlantısı',
    '[{"key": "user_name", "type": "string", "required": true, "description": "Kullanıcı adı"},
      {"key": "reset_link", "type": "string", "required": true, "description": "Şifre sıfırlama URL"},
      {"key": "expiry_hours", "type": "number", "required": false, "default": 24, "description": "Link geçerlilik süresi (saat)"}]'::JSONB,
    TRUE,
    'active',
    -1
);

-- user.email_verification.email
INSERT INTO messaging.message_templates (code, name, channel_type, category, description, variables, is_system, status, created_by)
VALUES (
    'user.email_verification.email',
    'User Email Verification',
    'email',
    'transactional',
    'BO kullanıcısı e-posta doğrulama bağlantısı',
    '[{"key": "user_name", "type": "string", "required": true, "description": "Kullanıcı adı"},
      {"key": "verification_link", "type": "string", "required": true, "description": "Doğrulama URL"},
      {"key": "expiry_hours", "type": "number", "required": false, "default": 24, "description": "Link geçerlilik süresi (saat)"}]'::JSONB,
    TRUE,
    'active',
    -1
);

-- user.account_locked.email
INSERT INTO messaging.message_templates (code, name, channel_type, category, description, variables, is_system, status, created_by)
VALUES (
    'user.account_locked.email',
    'User Account Locked Email',
    'email',
    'notification',
    'BO kullanıcısı hesap kilitlendi bildirimi',
    '[{"key": "user_name", "type": "string", "required": true, "description": "Kullanıcı adı"},
      {"key": "reason", "type": "string", "required": true, "description": "Kilitlenme nedeni"},
      {"key": "unlock_instructions", "type": "string", "required": false, "description": "Kilit açma talimatları"}]'::JSONB,
    TRUE,
    'active',
    -1
);

-- user.two_factor_enabled.email
INSERT INTO messaging.message_templates (code, name, channel_type, category, description, variables, is_system, status, created_by)
VALUES (
    'user.two_factor_enabled.email',
    'User 2FA Enabled Email',
    'email',
    'notification',
    'BO kullanıcısı 2FA etkinleştirildi bildirimi',
    '[{"key": "user_name", "type": "string", "required": true, "description": "Kullanıcı adı"}]'::JSONB,
    TRUE,
    'active',
    -1
);

-- user.role_changed.email
INSERT INTO messaging.message_templates (code, name, channel_type, category, description, variables, is_system, status, created_by)
VALUES (
    'user.role_changed.email',
    'User Role Changed Email',
    'email',
    'notification',
    'BO kullanıcısı rol değişikliği bildirimi',
    '[{"key": "user_name", "type": "string", "required": true, "description": "Kullanıcı adı"},
      {"key": "old_role", "type": "string", "required": true, "description": "Eski rol adı"},
      {"key": "new_role", "type": "string", "required": true, "description": "Yeni rol adı"}]'::JSONB,
    TRUE,
    'active',
    -1
);

-- ================================================================
-- 2. SMS ŞABLONLARI
-- ================================================================

-- user.password_reset.sms
INSERT INTO messaging.message_templates (code, name, channel_type, category, description, variables, is_system, status, created_by)
VALUES (
    'user.password_reset.sms',
    'User Password Reset SMS',
    'sms',
    'transactional',
    'BO kullanıcısı şifre sıfırlama kodu SMS',
    '[{"key": "user_name", "type": "string", "required": true, "description": "Kullanıcı adı"},
      {"key": "reset_code", "type": "string", "required": true, "description": "Sıfırlama kodu"}]'::JSONB,
    TRUE,
    'active',
    -1
);

-- user.two_factor_code.sms
INSERT INTO messaging.message_templates (code, name, channel_type, category, description, variables, is_system, status, created_by)
VALUES (
    'user.two_factor_code.sms',
    'User 2FA Code SMS',
    'sms',
    'transactional',
    'BO kullanıcısı 2FA doğrulama kodu SMS',
    '[{"key": "verification_code", "type": "string", "required": true, "description": "Doğrulama kodu"}]'::JSONB,
    TRUE,
    'active',
    -1
);

-- ================================================================
-- 3. ÇEVİRİLER — İngilizce (EN)
-- ================================================================

-- user.welcome.email — EN
INSERT INTO messaging.message_template_translations (template_id, language_code, subject, body_html, body_text, preview_text, created_by)
SELECT id, 'en',
    'Welcome to Sortis One Platform',
    '<h1>Welcome, {{user_name}}!</h1><p>Your account has been created. You can log in at <a href="{{login_url}}">{{login_url}}</a>.</p>',
    'Welcome, {{user_name}}! Your account has been created. You can log in at {{login_url}}.',
    'Your account has been created',
    -1
FROM messaging.message_templates WHERE code = 'user.welcome.email';

-- user.password_reset.email — EN
INSERT INTO messaging.message_template_translations (template_id, language_code, subject, body_html, body_text, preview_text, created_by)
SELECT id, 'en',
    'Password Reset Request',
    '<h1>Hello, {{user_name}}</h1><p>Click the link below to reset your password. This link expires in {{expiry_hours}} hours.</p><p><a href="{{reset_link}}">Reset Password</a></p>',
    'Hello, {{user_name}}. Click the link to reset your password (expires in {{expiry_hours}} hours): {{reset_link}}',
    'Reset your password',
    -1
FROM messaging.message_templates WHERE code = 'user.password_reset.email';

-- user.email_verification.email — EN
INSERT INTO messaging.message_template_translations (template_id, language_code, subject, body_html, body_text, preview_text, created_by)
SELECT id, 'en',
    'Verify Your Email Address',
    '<h1>Hello, {{user_name}}</h1><p>Please verify your email address by clicking the link below. This link expires in {{expiry_hours}} hours.</p><p><a href="{{verification_link}}">Verify Email</a></p>',
    'Hello, {{user_name}}. Verify your email (expires in {{expiry_hours}} hours): {{verification_link}}',
    'Verify your email address',
    -1
FROM messaging.message_templates WHERE code = 'user.email_verification.email';

-- user.account_locked.email — EN
INSERT INTO messaging.message_template_translations (template_id, language_code, subject, body_html, body_text, preview_text, created_by)
SELECT id, 'en',
    'Your Account Has Been Locked',
    '<h1>Hello, {{user_name}}</h1><p>Your account has been locked. Reason: {{reason}}</p><p>{{unlock_instructions}}</p>',
    'Hello, {{user_name}}. Your account has been locked. Reason: {{reason}}. {{unlock_instructions}}',
    'Your account has been locked',
    -1
FROM messaging.message_templates WHERE code = 'user.account_locked.email';

-- user.two_factor_enabled.email — EN
INSERT INTO messaging.message_template_translations (template_id, language_code, subject, body_html, body_text, preview_text, created_by)
SELECT id, 'en',
    'Two-Factor Authentication Enabled',
    '<h1>Hello, {{user_name}}</h1><p>Two-factor authentication has been enabled for your account.</p>',
    'Hello, {{user_name}}. Two-factor authentication has been enabled for your account.',
    '2FA has been enabled',
    -1
FROM messaging.message_templates WHERE code = 'user.two_factor_enabled.email';

-- user.role_changed.email — EN
INSERT INTO messaging.message_template_translations (template_id, language_code, subject, body_html, body_text, preview_text, created_by)
SELECT id, 'en',
    'Your Role Has Been Updated',
    '<h1>Hello, {{user_name}}</h1><p>Your role has been changed from <strong>{{old_role}}</strong> to <strong>{{new_role}}</strong>.</p>',
    'Hello, {{user_name}}. Your role has been changed from {{old_role}} to {{new_role}}.',
    'Your role has been updated',
    -1
FROM messaging.message_templates WHERE code = 'user.role_changed.email';

-- user.password_reset.sms — EN
INSERT INTO messaging.message_template_translations (template_id, language_code, subject, body_html, body_text, created_by)
SELECT id, 'en', NULL, NULL,
    'Your password reset code: {{reset_code}}',
    -1
FROM messaging.message_templates WHERE code = 'user.password_reset.sms';

-- user.two_factor_code.sms — EN
INSERT INTO messaging.message_template_translations (template_id, language_code, subject, body_html, body_text, created_by)
SELECT id, 'en', NULL, NULL,
    'Your verification code: {{verification_code}}',
    -1
FROM messaging.message_templates WHERE code = 'user.two_factor_code.sms';

-- ================================================================
-- 4. ÇEVİRİLER — Türkçe (TR)
-- ================================================================

-- user.welcome.email — TR
INSERT INTO messaging.message_template_translations (template_id, language_code, subject, body_html, body_text, preview_text, created_by)
SELECT id, 'tr',
    'Sortis One Platformuna Hoş Geldiniz',
    '<h1>Hoş geldiniz, {{user_name}}!</h1><p>Hesabınız oluşturuldu. <a href="{{login_url}}">{{login_url}}</a> adresinden giriş yapabilirsiniz.</p>',
    'Hoş geldiniz, {{user_name}}! Hesabınız oluşturuldu. Giriş için: {{login_url}}',
    'Hesabınız oluşturuldu',
    -1
FROM messaging.message_templates WHERE code = 'user.welcome.email';

-- user.password_reset.email — TR
INSERT INTO messaging.message_template_translations (template_id, language_code, subject, body_html, body_text, preview_text, created_by)
SELECT id, 'tr',
    'Şifre Sıfırlama Talebi',
    '<h1>Merhaba, {{user_name}}</h1><p>Şifrenizi sıfırlamak için aşağıdaki bağlantıya tıklayın. Bu bağlantı {{expiry_hours}} saat geçerlidir.</p><p><a href="{{reset_link}}">Şifremi Sıfırla</a></p>',
    'Merhaba, {{user_name}}. Şifrenizi sıfırlamak için ({{expiry_hours}} saat geçerli): {{reset_link}}',
    'Şifrenizi sıfırlayın',
    -1
FROM messaging.message_templates WHERE code = 'user.password_reset.email';

-- user.email_verification.email — TR
INSERT INTO messaging.message_template_translations (template_id, language_code, subject, body_html, body_text, preview_text, created_by)
SELECT id, 'tr',
    'E-posta Adresinizi Doğrulayın',
    '<h1>Merhaba, {{user_name}}</h1><p>Lütfen aşağıdaki bağlantıya tıklayarak e-posta adresinizi doğrulayın. Bu bağlantı {{expiry_hours}} saat geçerlidir.</p><p><a href="{{verification_link}}">E-postamı Doğrula</a></p>',
    'Merhaba, {{user_name}}. E-postanızı doğrulayın ({{expiry_hours}} saat geçerli): {{verification_link}}',
    'E-posta adresinizi doğrulayın',
    -1
FROM messaging.message_templates WHERE code = 'user.email_verification.email';

-- user.account_locked.email — TR
INSERT INTO messaging.message_template_translations (template_id, language_code, subject, body_html, body_text, preview_text, created_by)
SELECT id, 'tr',
    'Hesabınız Kilitlendi',
    '<h1>Merhaba, {{user_name}}</h1><p>Hesabınız kilitlendi. Neden: {{reason}}</p><p>{{unlock_instructions}}</p>',
    'Merhaba, {{user_name}}. Hesabınız kilitlendi. Neden: {{reason}}. {{unlock_instructions}}',
    'Hesabınız kilitlendi',
    -1
FROM messaging.message_templates WHERE code = 'user.account_locked.email';

-- user.two_factor_enabled.email — TR
INSERT INTO messaging.message_template_translations (template_id, language_code, subject, body_html, body_text, preview_text, created_by)
SELECT id, 'tr',
    'İki Faktörlü Doğrulama Etkinleştirildi',
    '<h1>Merhaba, {{user_name}}</h1><p>Hesabınız için iki faktörlü doğrulama etkinleştirildi.</p>',
    'Merhaba, {{user_name}}. Hesabınız için iki faktörlü doğrulama etkinleştirildi.',
    '2FA etkinleştirildi',
    -1
FROM messaging.message_templates WHERE code = 'user.two_factor_enabled.email';

-- user.role_changed.email — TR
INSERT INTO messaging.message_template_translations (template_id, language_code, subject, body_html, body_text, preview_text, created_by)
SELECT id, 'tr',
    'Rolünüz Güncellendi',
    '<h1>Merhaba, {{user_name}}</h1><p>Rolünüz <strong>{{old_role}}</strong> yerine <strong>{{new_role}}</strong> olarak değiştirildi.</p>',
    'Merhaba, {{user_name}}. Rolünüz {{old_role}} yerine {{new_role}} olarak değiştirildi.',
    'Rolünüz güncellendi',
    -1
FROM messaging.message_templates WHERE code = 'user.role_changed.email';

-- user.password_reset.sms — TR
INSERT INTO messaging.message_template_translations (template_id, language_code, subject, body_html, body_text, created_by)
SELECT id, 'tr', NULL, NULL,
    'Şifre sıfırlama kodunuz: {{reset_code}}',
    -1
FROM messaging.message_templates WHERE code = 'user.password_reset.sms';

-- user.two_factor_code.sms — TR
INSERT INTO messaging.message_template_translations (template_id, language_code, subject, body_html, body_text, created_by)
SELECT id, 'tr', NULL, NULL,
    'Doğrulama kodunuz: {{verification_code}}',
    -1
FROM messaging.message_templates WHERE code = 'user.two_factor_code.sms';

-- ================================================================
-- VALIDATION
-- ================================================================
DO $$
DECLARE
    v_templates INT;
    v_translations INT;
    v_email INT;
    v_sms INT;
BEGIN
    SELECT COUNT(*) INTO v_templates FROM messaging.message_templates;
    SELECT COUNT(*) INTO v_translations FROM messaging.message_template_translations;
    SELECT COUNT(*) INTO v_email FROM messaging.message_templates WHERE channel_type = 'email';
    SELECT COUNT(*) INTO v_sms FROM messaging.message_templates WHERE channel_type = 'sms';

    RAISE NOTICE '================================================';
    RAISE NOTICE 'NOTIFICATION TEMPLATES SEED COMPLETED';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Templates:     % (expected: 8)', v_templates;
    RAISE NOTICE '  Email:       % (expected: 6)', v_email;
    RAISE NOTICE '  SMS:         % (expected: 2)', v_sms;
    RAISE NOTICE 'Translations:  % (expected: 16 = 8 x 2 lang)', v_translations;
    RAISE NOTICE '================================================';
END $$;
