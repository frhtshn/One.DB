-- =============================================
-- Tablo: support.canned_responses
-- Açıklama: Hazır yanıt şablonları. Temsilcilerin
--           sık kullandığı yanıtlar. Opsiyonel
--           kategori bağlantısı ile bağlamsal
--           öneriler sunulabilir.
-- =============================================

DROP TABLE IF EXISTS support.canned_responses CASCADE;

CREATE TABLE support.canned_responses (
    id                  BIGSERIAL       PRIMARY KEY,
    category_id         BIGINT,                                 -- İlişkili kategori (opsiyonel, FK → ticket_categories)
    title               VARCHAR(100)    NOT NULL,               -- Şablon başlığı (arama/seçim için)
    content             TEXT            NOT NULL,               -- Yanıt metni
    is_active           BOOLEAN         NOT NULL DEFAULT true,  -- Soft delete
    created_by          BIGINT,                                 -- Oluşturan BO user_id
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE support.canned_responses IS 'Pre-written response templates for support agents. Can be linked to specific ticket categories for contextual suggestions.';
