-- =============================================
-- Popup Translations (Popup Çevirileri)
-- Popup'ların çok dilli metin içerikleri
-- =============================================

DROP TABLE IF EXISTS content.popup_translations CASCADE;

CREATE TABLE content.popup_translations (
    id SERIAL PRIMARY KEY,
    popup_id INTEGER NOT NULL,                    -- Bağlı popup
    language_code CHAR(2) NOT NULL,               -- Dil kodu

    -- Metin İçerikleri
    title VARCHAR(200),                           -- Başlık
    subtitle VARCHAR(300),                        -- Alt başlık
    body_text TEXT,                               -- Ana içerik metni (HTML destekli)

    -- Call to Action
    cta_text VARCHAR(50),                         -- Ana buton metni
    cta_secondary_text VARCHAR(50),               -- İkincil buton metni
    close_button_text VARCHAR(30),                -- Kapatma butonu metni (NULL = X ikonu)

    -- Audit
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER


);

COMMENT ON TABLE content.popup_translations IS 'Multilingual text content for popups including titles, body, and CTAs';
