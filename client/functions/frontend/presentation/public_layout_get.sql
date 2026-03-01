-- ================================================================
-- PUBLIC_LAYOUT_GET: Frontend sayfa yerleşimi getir
-- Önce page_id ile arar, yoksa layout_name, yoksa 'default'
-- Fallback zinciri: page_id → layout_name → default
-- ================================================================

DROP FUNCTION IF EXISTS presentation.public_layout_get(VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION presentation.public_layout_get(
    p_layout_name       VARCHAR(50) DEFAULT NULL,   -- Layout adı
    p_page_id           BIGINT      DEFAULT NULL    -- Sayfa ID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- 1. Önce page_id ile ara
    IF p_page_id IS NOT NULL THEN
        SELECT l.structure INTO v_result
        FROM presentation.layouts l
        WHERE l.page_id = p_page_id AND l.is_active = TRUE
        LIMIT 1;

        IF v_result IS NOT NULL THEN
            RETURN v_result;
        END IF;
    END IF;

    -- 2. Layout adı ile ara
    IF p_layout_name IS NOT NULL THEN
        SELECT l.structure INTO v_result
        FROM presentation.layouts l
        WHERE l.layout_name = p_layout_name AND l.is_active = TRUE AND l.page_id IS NULL
        LIMIT 1;

        IF v_result IS NOT NULL THEN
            RETURN v_result;
        END IF;
    END IF;

    -- 3. Fallback: default layout
    SELECT l.structure INTO v_result
    FROM presentation.layouts l
    WHERE l.layout_name = 'default' AND l.is_active = TRUE AND l.page_id IS NULL
    LIMIT 1;

    -- Hiçbir layout yoksa boş array döner
    RETURN COALESCE(v_result, '[]'::JSONB);
END;
$$;

COMMENT ON FUNCTION presentation.public_layout_get(VARCHAR, BIGINT) IS 'Get page layout for frontend rendering. Fallback chain: page_id → layout_name → default. Returns empty array if no layout found.';
