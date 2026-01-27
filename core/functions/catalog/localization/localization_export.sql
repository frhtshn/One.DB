-- ================================================================
-- LOCALIZATION_EXPORT: Çeviri Dışa Aktarma
-- Bir dilin tüm çevirilerini JSON formatında dışa aktarır.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.localization_export(CHAR(2));

CREATE OR REPLACE FUNCTION catalog.localization_export(p_lang CHAR(2))
RETURNS JSONB
LANGUAGE plpgsql STABLE
AS $$
BEGIN
    RETURN (
        SELECT COALESCE(jsonb_object_agg(k.localization_key, v.localized_text), '{}'::jsonb)
        FROM catalog.localization_keys k
        LEFT JOIN catalog.localization_values v ON v.localization_key_id = k.id AND v.language_code = p_lang
        WHERE v.localized_text IS NOT NULL
    );
END;
$$;

COMMENT ON FUNCTION catalog.localization_export(CHAR(2)) IS 'Exports translations for a specific language as JSON.';
