-- ================================================================
-- CLIENT_LAYOUT_GET: Client layout getir
-- ================================================================
-- Açıklama:
--   Layout'u ID, page_id veya layout_name ile getirir.
-- Erişim:
--   - Platform Admin: Tüm client'lar
--   - CompanyAdmin: Kendi company'sindeki client'lar
--   - ClientAdmin: user_allowed_clients'taki client'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.client_layout_get(BIGINT, BIGINT, BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION presentation.client_layout_get(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_id BIGINT DEFAULT NULL,
    p_page_id BIGINT DEFAULT NULL,
    p_layout_name VARCHAR(50) DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = presentation, core, security, pg_temp
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- 1. Client varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM core.clients WHERE id = p_client_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- 2. Client erişim kontrolü
    PERFORM security.user_assert_access_client(p_caller_id, p_client_id);

    -- 3. Parametre kontrolü
    IF p_id IS NULL AND p_page_id IS NULL AND p_layout_name IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.client-layout.no-filter';
    END IF;

    -- ========================================
    -- 5. LAYOUT GETİR
    -- ========================================
    SELECT jsonb_build_object(
        'id', tl.id,
        'clientId', tl.client_id,
        'pageId', tl.page_id,
        'layoutName', tl.layout_name,
        'structure', tl.structure,
        'isActive', tl.is_active,
        'createdAt', tl.created_at,
        'updatedAt', tl.updated_at
    )
    INTO v_result
    FROM presentation.client_layouts tl
    WHERE tl.client_id = p_client_id
      AND (p_id IS NULL OR tl.id = p_id)
      AND (p_page_id IS NULL OR tl.page_id = p_page_id)
      AND (p_layout_name IS NULL OR tl.layout_name = p_layout_name);

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client-layout.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.client_layout_get(BIGINT, BIGINT, BIGINT, BIGINT, VARCHAR) IS
'Gets a client layout by ID, page_id, or layout_name.
At least one filter must be provided.
Access: Platform Admin (all), CompanyAdmin (own company), ClientAdmin (allowed clients).';
