-- ================================================================
-- CLIENT_LAYOUT_LIST: Client layout listesi
-- ================================================================
-- Açıklama:
--   Client'ın tüm widget yerleşimlerini listeler.
-- Erişim:
--   - Platform Admin: Tüm client'lar
--   - CompanyAdmin: Kendi company'sindeki client'lar
--   - ClientAdmin: user_allowed_clients'taki client'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.client_layout_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION presentation.client_layout_list(
    p_caller_id BIGINT,
    p_client_id BIGINT
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

    -- 3. Layout listesi
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', tl.id,
            'clientId', tl.client_id,
            'pageId', tl.page_id,
            'layoutName', tl.layout_name,
            'structure', tl.structure,
            'isActive', tl.is_active,
            'createdAt', tl.created_at,
            'updatedAt', tl.updated_at
        ) ORDER BY tl.layout_name
    ), '[]'::jsonb)
    INTO v_result
    FROM presentation.client_layouts tl
    WHERE tl.client_id = p_client_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.client_layout_list(BIGINT, BIGINT) IS
'Lists all client layouts (widget placements).
Access: Platform Admin (all), CompanyAdmin (own company), ClientAdmin (allowed clients).';
