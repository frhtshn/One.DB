-- ================================================================
-- ADMIN_MESSAGE_TEMPLATE_UPDATE: Bildirim şablonu güncelleme
-- Şablon ve çevirilerini günceller
-- Çeviriler sıfırlanıp yeniden yazılır (replace-all)
-- channel_type değiştirilemez
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_template_update(INTEGER, INTEGER, VARCHAR, VARCHAR, TEXT, JSONB, VARCHAR, JSONB);

CREATE OR REPLACE FUNCTION messaging.admin_message_template_update(
    p_user_id       INTEGER,                         -- İşlemi yapan kullanıcı ID
    p_id            INTEGER,                         -- Şablon ID
    p_name          VARCHAR(200) DEFAULT NULL,        -- Şablon adı
    p_category      VARCHAR(30) DEFAULT NULL,         -- Kategori
    p_description   TEXT DEFAULT NULL,                -- Açıklama
    p_variables     JSONB DEFAULT NULL,               -- Merge tag tanımları
    p_status        VARCHAR(20) DEFAULT NULL,         -- Durum: draft, active, archived
    p_translations  JSONB DEFAULT NULL                -- Çeviri dizisi (NULL = güncelleme yok)
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_channel_type VARCHAR(10);
    v_item JSONB;
BEGIN
    -- Şablon varlık ve kanal tipi kontrolü
    SELECT channel_type INTO v_channel_type
    FROM messaging.message_templates
    WHERE id = p_id AND is_deleted = FALSE;

    IF v_channel_type IS NULL THEN
        RAISE EXCEPTION 'error.notification-template.not-found';
    END IF;

    -- Durum doğrulama
    IF p_status IS NOT NULL AND p_status NOT IN ('draft', 'active', 'archived') THEN
        RAISE EXCEPTION 'error.notification-template.invalid-status';
    END IF;

    -- Kategori doğrulama
    IF p_category IS NOT NULL AND p_category NOT IN ('transactional', 'notification', 'marketing') THEN
        RAISE EXCEPTION 'error.notification-template.invalid-category';
    END IF;

    -- Şablon ana bilgilerini güncelle
    UPDATE messaging.message_templates SET
        name        = COALESCE(p_name, name),
        category    = COALESCE(p_category, category),
        description = COALESCE(p_description, description),
        variables   = COALESCE(p_variables, variables),
        status      = COALESCE(p_status, status),
        updated_at  = now(),
        updated_by  = p_user_id
    WHERE id = p_id;

    -- Çevirileri güncelle (sil + yeniden yaz)
    IF p_translations IS NOT NULL THEN
        -- Kanal bazlı validasyon
        IF jsonb_array_length(p_translations) > 0 THEN
            FOR v_item IN SELECT * FROM jsonb_array_elements(p_translations) LOOP
                IF v_channel_type = 'email' THEN
                    IF (v_item->>'subject') IS NULL OR (v_item->>'subject') = '' THEN
                        RAISE EXCEPTION 'error.notification-template.email-subject-required';
                    END IF;
                    IF (v_item->>'body_html') IS NULL OR (v_item->>'body_html') = '' THEN
                        RAISE EXCEPTION 'error.notification-template.email-body-html-required';
                    END IF;
                END IF;

                IF v_channel_type = 'sms' THEN
                    IF (v_item->>'body_text') IS NULL OR (v_item->>'body_text') = '' THEN
                        RAISE EXCEPTION 'error.notification-template.sms-body-text-required';
                    END IF;
                END IF;
            END LOOP;
        END IF;

        DELETE FROM messaging.message_template_translations WHERE template_id = p_id;

        IF jsonb_array_length(p_translations) > 0 THEN
            INSERT INTO messaging.message_template_translations (
                template_id, language_code, subject, body_html, body_text, preview_text, created_by, updated_by
            )
            SELECT
                p_id,
                (t->>'language_code')::CHAR(2),
                t->>'subject',
                t->>'body_html',
                COALESCE(t->>'body_text', ''),
                t->>'preview_text',
                p_user_id,
                p_user_id
            FROM jsonb_array_elements(p_translations) AS t;
        END IF;
    END IF;

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_template_update(INTEGER, INTEGER, VARCHAR, VARCHAR, TEXT, JSONB, VARCHAR, JSONB) IS 'Update a client message template. Translations are replaced entirely. Channel type is immutable.';
