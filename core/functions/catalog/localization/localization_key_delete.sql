-- localization_key_delete: Key ve çevirilerini sil

DROP FUNCTION IF EXISTS catalog.localization_key_delete(BIGINT);

CREATE OR REPLACE FUNCTION catalog.localization_key_delete(p_id BIGINT)
RETURNS TABLE(affected_translations INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT;
BEGIN
    IF NOT EXISTS(SELECT 1 FROM catalog.localization_keys WHERE id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.localization.key.not-found';
    END IF;

    -- Count translations
    SELECT COUNT(*)::INT INTO v_count FROM catalog.localization_values WHERE localization_key_id = p_id;

    -- Delete translations first (cascade)
    DELETE FROM catalog.localization_values WHERE localization_key_id = p_id;

    -- Delete key
    DELETE FROM catalog.localization_keys WHERE id = p_id;

    RETURN QUERY SELECT v_count;
END;
$$;

COMMENT ON FUNCTION catalog.localization_key_delete(BIGINT) IS 'Deletes a localization key and its values.';
