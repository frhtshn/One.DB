-- ================================================================
-- LOBBY_SECTION_TRANSLATION_UPSERT: Lobi bölümü çevirisi ekle / güncelle
-- (lobby_section_id, language_code) üzerinden UPSERT yapılır
-- ================================================================

DROP FUNCTION IF EXISTS game.upsert_lobby_section_translation(BIGINT, VARCHAR, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION game.upsert_lobby_section_translation(
    p_lobby_section_id  BIGINT,
    p_language_code     VARCHAR(5),
    p_title             VARCHAR(200),
    p_subtitle          VARCHAR(500) DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    IF p_lobby_section_id IS NULL THEN
        RAISE EXCEPTION 'error.lobby-section-translation.section-id-required';
    END IF;
    IF p_language_code IS NULL OR TRIM(p_language_code) = '' THEN
        RAISE EXCEPTION 'error.lobby-section-translation.language-required';
    END IF;
    IF p_title IS NULL OR TRIM(p_title) = '' THEN
        RAISE EXCEPTION 'error.lobby-section-translation.title-required';
    END IF;

    INSERT INTO game.lobby_section_translations (
        lobby_section_id, language_code, title, subtitle
    )
    VALUES (
        p_lobby_section_id, LOWER(TRIM(p_language_code)), p_title, p_subtitle
    )
    ON CONFLICT ON CONSTRAINT uq_lobby_section_translation DO UPDATE SET
        title    = EXCLUDED.title,
        subtitle = EXCLUDED.subtitle
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION game.upsert_lobby_section_translation(BIGINT, VARCHAR, VARCHAR, VARCHAR) IS 'Insert or update a language translation for a lobby section. Returns the translation ID.';
