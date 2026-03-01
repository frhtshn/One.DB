-- ================================================================
-- ADMIN_TEMPLATE_UPDATE: Şablon bilgilerini güncelleme
-- Şablon ve çevirilerini günceller
-- Çeviriler sıfırlanıp yeniden yazılır
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_template_update(INTEGER, VARCHAR, TEXT, VARCHAR, JSONB, INTEGER);

CREATE OR REPLACE FUNCTION messaging.admin_template_update(
    p_template_id       INTEGER,            -- Şablon ID
    p_name              VARCHAR(200) DEFAULT NULL, -- Şablon adı
    p_description       TEXT DEFAULT NULL,          -- Açıklama
    p_status            VARCHAR(20) DEFAULT NULL,   -- Durum: draft, active, archived
    p_translations      JSONB DEFAULT NULL, -- Çeviri dizisi (NULL = güncelleme)
    p_updated_by        INTEGER DEFAULT NULL -- Güncelleyen kullanıcı
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    -- Şablon varlık kontrolü
    IF NOT EXISTS (SELECT 1 FROM messaging.message_templates WHERE id = p_template_id AND is_deleted = FALSE) THEN
        RAISE EXCEPTION 'error.messaging.template-not-found';
    END IF;

    -- Durum doğrulama
    IF p_status IS NOT NULL AND p_status NOT IN ('draft', 'active', 'archived') THEN
        RAISE EXCEPTION 'error.messaging.invalid-template-status';
    END IF;

    -- Şablon ana bilgilerini güncelle
    UPDATE messaging.message_templates SET
        name        = COALESCE(p_name, name),
        description = COALESCE(p_description, description),
        status      = COALESCE(p_status, status),
        updated_at  = now(),
        updated_by  = p_updated_by
    WHERE id = p_template_id;

    -- Çevirileri güncelle (sil + yeniden yaz)
    IF p_translations IS NOT NULL THEN
        DELETE FROM messaging.message_template_translations WHERE template_id = p_template_id;

        IF jsonb_array_length(p_translations) > 0 THEN
            INSERT INTO messaging.message_template_translations (
                template_id, language_code, subject, body_html, preview_text, created_by
            )
            SELECT
                p_template_id,
                (t->>'language_code')::CHAR(2),
                t->>'subject',
                t->>'body',
                t->>'preview_text',
                p_updated_by
            FROM jsonb_array_elements(p_translations) AS t;
        END IF;
    END IF;

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION messaging.admin_template_update(INTEGER, VARCHAR, TEXT, VARCHAR, JSONB, INTEGER) IS 'Update a message template with new details and translations';
