-- ================================================================
-- LOCALIZATION_MESSAGES_GET: Çeviri Mesajlarını Getir
-- Frontend için toplu yükleme amacıyla tüm mesajları döner.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.localization_messages_get(CHAR(2));

CREATE OR REPLACE FUNCTION catalog.localization_messages_get(p_lang CHAR(2))
RETURNS TABLE(key VARCHAR(150), value TEXT)
LANGUAGE sql
STABLE
AS $$
    SELECT lk.localization_key AS key, lv.localized_text AS value
    FROM catalog.localization_keys lk
    INNER JOIN catalog.localization_values lv ON lv.localization_key_id = lk.id
    WHERE lv.language_code = p_lang;
$$;

COMMENT ON FUNCTION catalog.localization_messages_get IS 'Retrieves all localization messages for a specific language (for bulk loading)';
