-- ================================================================
-- ANNOUNCEMENT_BAR_TRANSLATION_UPSERT: Duyuru çubuğu çevirisi ekle / güncelle
-- (announcement_bar_id, language_code) üzerinden UPSERT yapılır
-- ================================================================

DROP FUNCTION IF EXISTS presentation.upsert_announcement_bar_translation(BIGINT, VARCHAR, TEXT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION presentation.upsert_announcement_bar_translation(
    p_announcement_bar_id   BIGINT,
    p_language_code         VARCHAR(5),
    p_text                  TEXT,
    p_link_url              VARCHAR(500)    DEFAULT NULL,
    p_link_label            VARCHAR(100)    DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    IF p_announcement_bar_id IS NULL THEN
        RAISE EXCEPTION 'error.announcement-bar-translation.bar-id-required';
    END IF;
    IF p_language_code IS NULL OR TRIM(p_language_code) = '' THEN
        RAISE EXCEPTION 'error.announcement-bar-translation.language-required';
    END IF;
    IF p_text IS NULL OR TRIM(p_text) = '' THEN
        RAISE EXCEPTION 'error.announcement-bar-translation.text-required';
    END IF;

    INSERT INTO presentation.announcement_bar_translations (
        announcement_bar_id, language_code, text, link_url, link_label
    )
    VALUES (
        p_announcement_bar_id, LOWER(TRIM(p_language_code)), p_text, p_link_url, p_link_label
    )
    ON CONFLICT ON CONSTRAINT uq_announcement_bar_translation DO UPDATE SET
        text        = EXCLUDED.text,
        link_url    = EXCLUDED.link_url,
        link_label  = EXCLUDED.link_label
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION presentation.upsert_announcement_bar_translation(BIGINT, VARCHAR, TEXT, VARCHAR, VARCHAR) IS 'Insert or update a language translation for an announcement bar. Returns the translation ID.';
