-- =============================================
-- Tablo: messaging.message_templates
-- Açıklama: Platform mesaj/bildirim şablonları
-- Otomatik tetiklenen e-posta ve SMS bildirimleri
-- BO kullanıcılarına yönelik sistem şablonları
-- Platform admin tarafından yönetilir
-- =============================================

DROP TABLE IF EXISTS messaging.message_templates CASCADE;

CREATE TABLE messaging.message_templates (
    id SERIAL PRIMARY KEY,
    code VARCHAR(100) NOT NULL,                       -- Benzersiz şablon kodu: 'user.welcome.email'
    name VARCHAR(200) NOT NULL,                       -- Görüntü adı (BO)
    channel_type VARCHAR(10) NOT NULL,                -- Kanal: 'email', 'sms'
    category VARCHAR(30) NOT NULL,                    -- Kategori: 'transactional', 'notification', 'system'
    description TEXT,                                 -- Şablon açıklaması
    variables JSONB,                                  -- Merge tag tanımları (bilgilendirme amaçlı)

    -- Kontrol alanları
    is_system BOOLEAN NOT NULL DEFAULT FALSE,         -- Sistem şablonları silinemez
    status VARCHAR(20) NOT NULL DEFAULT 'draft',      -- draft, active, archived

    -- Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by BIGINT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_by BIGINT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE           -- Soft delete
);

COMMENT ON TABLE messaging.message_templates IS 'Platform message templates for automated email and SMS delivery to backoffice users. Managed by platform admin.';
