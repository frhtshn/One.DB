-- =============================================
-- Tablo: messaging.message_templates
-- Tekrar kullanılabilir mesaj şablonları
-- Kanal bazlı şablon tanımları (email/sms/local)
-- Kampanya ve bildirim şablonları tek tabloda
-- category ile ayrılır: campaign, transactional,
-- notification, marketing
-- =============================================

DROP TABLE IF EXISTS messaging.message_templates CASCADE;

CREATE TABLE messaging.message_templates (
    id SERIAL PRIMARY KEY,
    code VARCHAR(100) NOT NULL,                   -- Benzersiz şablon kodu (welcome_email, player.welcome.email)
    name VARCHAR(200) NOT NULL,                   -- Şablon adı (BO gösterimi)
    channel_type VARCHAR(10) NOT NULL,            -- Kanal tipi: email, sms, local
    category VARCHAR(30) NOT NULL DEFAULT 'campaign', -- Kategori: campaign, transactional, notification, marketing
    description TEXT,                             -- Şablon açıklaması
    variables JSONB,                              -- Merge tag tanımları (bilgilendirme amaçlı)

    -- Kontrol alanları
    is_system BOOLEAN NOT NULL DEFAULT FALSE,     -- Sistem şablonları silinemez
    status VARCHAR(20) NOT NULL DEFAULT 'draft',  -- Durum: draft, active, archived

    -- Audit
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at TIMESTAMP WITHOUT TIME ZONE,
    deleted_by INTEGER
);

COMMENT ON TABLE messaging.message_templates IS 'Reusable message templates for email, SMS, and local inbox channels. Covers campaign and notification templates.';
