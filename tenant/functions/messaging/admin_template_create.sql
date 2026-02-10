-- ================================================================
-- TEMPLATE_CREATE: Yeni mesaj şablonu oluşturma
-- Şablon ve çevirilerini tek işlemde yazar
-- Varsayılan durum: draft
-- ================================================================

DROP FUNCTION IF EXISTS messaging.template_create(VARCHAR, VARCHAR, VARCHAR, TEXT, JSONB, INTEGER);

CREATE OR REPLACE FUNCTION messaging.template_create(
    p_code              VARCHAR(50),        -- Benzersiz şablon kodu
    p_name              VARCHAR(200),       -- Şablon adı
    p_channel_type      VARCHAR(10),        -- Kanal tipi: email, sms, local
    p_description       TEXT DEFAULT NULL,   -- Şablon açıklaması
    p_translations      JSONB DEFAULT NULL, -- Çeviri dizisi: [{"language_code":"en","subject":"...","body":"...","preview_text":"..."}]
    p_created_by        INTEGER DEFAULT NULL -- Oluşturan kullanıcı
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_template_id INTEGER;
BEGIN
    -- Parametre doğrulama
    IF p_code IS NULL OR p_code = '' THEN
        RAISE EXCEPTION 'error.messaging.template-code-required';
    END IF;

    IF p_name IS NULL OR p_name = '' THEN
        RAISE EXCEPTION 'error.messaging.template-name-required';
    END IF;

    IF p_channel_type IS NULL OR p_channel_type NOT IN ('email', 'sms', 'local') THEN
        RAISE EXCEPTION 'error.messaging.invalid-channel-type';
    END IF;

    -- Kod benzersizlik kontrolü
    IF EXISTS (SELECT 1 FROM messaging.message_templates WHERE code = p_code AND is_deleted = FALSE) THEN
        RAISE EXCEPTION 'error.messaging.template-code-exists';
    END IF;

    -- Şablon oluştur
    INSERT INTO messaging.message_templates (
        code, name, channel_type, description, created_by
    ) VALUES (
        p_code, p_name, p_channel_type, p_description, p_created_by
    )
    RETURNING id INTO v_template_id;

    -- Çevirileri ekle
    IF p_translations IS NOT NULL AND jsonb_array_length(p_translations) > 0 THEN
        INSERT INTO messaging.message_template_translations (
            template_id, language_code, subject, body, preview_text, created_by
        )
        SELECT
            v_template_id,
            (t->>'language_code')::CHAR(2),
            t->>'subject',
            t->>'body',
            t->>'preview_text',
            p_created_by
        FROM jsonb_array_elements(p_translations) AS t;
    END IF;

    RETURN v_template_id;
END;
$$;

COMMENT ON FUNCTION messaging.template_create(VARCHAR, VARCHAR, VARCHAR, TEXT, JSONB, INTEGER) IS 'Create a new message template with multilingual translations in a single transaction';
