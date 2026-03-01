-- ================================================================
-- GET_LAYOUT: Frontend için layout/widget verisi
-- ================================================================
-- Açıklama:
--   Frontend uygulamasının sayfa layout'unu çekmesi için.
--   Widget yerleşim yapısını döner.
--   Sadece aktif (is_active=true) layout'ları döner.
-- Kullanım:
--   Website/App frontend tarafından çağrılır.
--   Sayfa render edilirken widget'ları yerleştirmek için.
-- ================================================================

DROP FUNCTION IF EXISTS presentation.get_layout(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION presentation.get_layout(
    p_client_id BIGINT,
    p_layout_name VARCHAR(50) DEFAULT NULL,
    p_page_id BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = presentation, pg_temp
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- ========================================
    -- 1. CLIENT VARLIK KONTROLÜ
    -- ========================================
    IF NOT EXISTS (SELECT 1 FROM core.clients WHERE id = p_client_id AND status = 1) THEN
        RETURN NULL;
    END IF;

    -- ========================================
    -- 2. PARAMETRE KONTROLÜ
    -- ========================================
    IF p_layout_name IS NULL AND p_page_id IS NULL THEN
        RETURN NULL;
    END IF;

    -- ========================================
    -- 3. LAYOUT VERİSİ (Sadece aktif)
    -- ========================================
    SELECT jsonb_build_object(
        'layoutId', tl.id,
        'layoutName', tl.layout_name,
        'pageId', tl.page_id,
        'structure', tl.structure
    )
    INTO v_result
    FROM presentation.client_layouts tl
    WHERE tl.client_id = p_client_id
      AND tl.is_active = TRUE
      AND (p_layout_name IS NULL OR tl.layout_name = p_layout_name)
      AND (p_page_id IS NULL OR tl.page_id = p_page_id);

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.get_layout(BIGINT, VARCHAR, BIGINT) IS
'Returns layout/widget structure for frontend rendering.
Only returns active layouts (is_active=TRUE).
Can be queried by layout_name or page_id.
Usage: Called by website/app frontend for page layout.';
