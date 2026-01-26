-- localization_key_get: Key detayı + tüm çeviriler

DROP FUNCTION IF EXISTS catalog.localization_key_get(VARCHAR);

CREATE OR REPLACE FUNCTION catalog.localization_key_get(p_key VARCHAR)
RETURNS JSONB
LANGUAGE plpgsql STABLE
AS $$
DECLARE
    v_key_id BIGINT;
    v_result JSONB;
BEGIN
    SELECT id INTO v_key_id FROM catalog.localization_keys WHERE localization_key = p_key;

    IF v_key_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.localization.key.not-found';
    END IF;

    SELECT jsonb_build_object(
        'id', k.id,
        'key', k.localization_key,
        'domain', k.domain,
        'category', k.category,
        'description', k.description,
        'translations', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'languageCode', v.language_code,
                'text', v.localized_text,
                'createdAt', v.created_at
            ))
            FROM catalog.localization_values v
            WHERE v.localization_key_id = k.id
        ), '[]'::jsonb)
    )
    INTO v_result
    FROM catalog.localization_keys k
    WHERE k.id = v_key_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION catalog.localization_key_get(VARCHAR) IS 'Gets a localization key details and all its translations.';
