-- ================================================================
-- ADMIN_MESSAGE_TEMPLATE_CREATE: Yeni bildirim şablonu oluşturma
-- Şablon ve çevirilerini tek işlemde yazar
-- Kanal bazlı çeviri validasyonu (email: subject+body_html, sms: body_text)
-- Varsayılan durum: draft
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_template_create(INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TEXT, JSONB, BOOLEAN, JSONB);

CREATE OR REPLACE FUNCTION messaging.admin_message_template_create(
    p_user_id       INTEGER,                         -- İşlemi yapan kullanıcı ID
    p_code          VARCHAR(100),                    -- Benzersiz şablon kodu
    p_name          VARCHAR(200),                    -- Şablon adı
    p_channel_type  VARCHAR(10),                     -- Kanal: email, sms
    p_category      VARCHAR(30),                     -- Kategori: transactional, notification, marketing
    p_description   TEXT DEFAULT NULL,               -- Şablon açıklaması
    p_variables     JSONB DEFAULT NULL,              -- Merge tag tanımları
    p_is_system     BOOLEAN DEFAULT FALSE,           -- Sistem şablonu mu?
    p_translations  JSONB DEFAULT NULL               -- Çeviri dizisi: [{"language_code":"en","subject":"...","body_html":"...","body_text":"...","preview_text":"..."}]
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_template_id INTEGER;
    v_item JSONB;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_code IS NULL OR p_code = '' THEN
        RAISE EXCEPTION 'error.notification-template.code-required';
    END IF;

    IF p_name IS NULL OR p_name = '' THEN
        RAISE EXCEPTION 'error.notification-template.name-required';
    END IF;

    IF p_channel_type IS NULL OR p_channel_type NOT IN ('email', 'sms') THEN
        RAISE EXCEPTION 'error.notification-template.invalid-channel-type';
    END IF;

    IF p_category IS NULL OR p_category NOT IN ('transactional', 'notification', 'marketing') THEN
        RAISE EXCEPTION 'error.notification-template.invalid-category';
    END IF;

    -- Kod benzersizlik kontrolü
    IF EXISTS (SELECT 1 FROM messaging.message_templates WHERE code = p_code AND is_deleted = FALSE) THEN
        RAISE EXCEPTION 'error.notification-template.code-exists';
    END IF;

    -- Şablon oluştur
    INSERT INTO messaging.message_templates (
        code, name, channel_type, category, description, variables, is_system, created_by, updated_by
    ) VALUES (
        p_code, p_name, p_channel_type, p_category, p_description, p_variables, COALESCE(p_is_system, FALSE), p_user_id, p_user_id
    )
    RETURNING id INTO v_template_id;

    -- Çevirileri ekle (kanal bazlı validasyonla)
    IF p_translations IS NOT NULL AND jsonb_array_length(p_translations) > 0 THEN
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_translations) LOOP
            -- Email kanalı: subject ve body_html zorunlu
            IF p_channel_type = 'email' THEN
                IF (v_item->>'subject') IS NULL OR (v_item->>'subject') = '' THEN
                    RAISE EXCEPTION 'error.notification-template.email-subject-required';
                END IF;
                IF (v_item->>'body_html') IS NULL OR (v_item->>'body_html') = '' THEN
                    RAISE EXCEPTION 'error.notification-template.email-body-html-required';
                END IF;
            END IF;

            -- SMS kanalı: body_text zorunlu
            IF p_channel_type = 'sms' THEN
                IF (v_item->>'body_text') IS NULL OR (v_item->>'body_text') = '' THEN
                    RAISE EXCEPTION 'error.notification-template.sms-body-text-required';
                END IF;
            END IF;
        END LOOP;

        INSERT INTO messaging.message_template_translations (
            template_id, language_code, subject, body_html, body_text, preview_text, created_by, updated_by
        )
        SELECT
            v_template_id,
            (t->>'language_code')::CHAR(2),
            t->>'subject',
            t->>'body_html',
            COALESCE(t->>'body_text', ''),
            t->>'preview_text',
            p_user_id,
            p_user_id
        FROM jsonb_array_elements(p_translations) AS t;
    END IF;

    RETURN v_template_id;
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_template_create(INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TEXT, JSONB, BOOLEAN, JSONB) IS 'Create a new client message template with multilingual translations. Validates channel-specific content requirements.';
