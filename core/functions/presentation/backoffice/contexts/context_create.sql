-- ================================================================
-- CONTEXT_CREATE: Yeni context oluşturur
-- ================================================================

DROP FUNCTION IF EXISTS presentation.context_create CASCADE;
CREATE OR REPLACE FUNCTION presentation.context_create(
    p_page_id BIGINT,
    p_code VARCHAR,
    p_type VARCHAR,
    p_label VARCHAR DEFAULT NULL,
    p_permission_edit VARCHAR DEFAULT NULL,
    p_permission_readonly VARCHAR DEFAULT NULL,
    p_permission_mask VARCHAR DEFAULT NULL
) RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    -- Check required fields
    IF p_page_id IS NULL OR p_code IS NULL OR p_type IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.context.missing-required-fields';
    END IF;

    -- Insert
    INSERT INTO presentation.contexts (
        page_id,
        code,
        context_type,
        label_localization_key,
        permission_edit,
        permission_readonly,
        permission_mask
    ) VALUES (
        p_page_id,
        p_code,
        p_type,
        p_label,
        p_permission_edit,
        p_permission_readonly,
        p_permission_mask
    ) RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION presentation.context_create IS 'Creates a new context. Returns TABLE(id BIGINT).';
