-- ================================================================
-- CLIENT_LAYOUT_UPSERT: Layout oluştur/güncelle
-- ================================================================
-- Açıklama:
--   Client için widget yerleşimi oluşturur veya günceller.
--   layout_name client bazında unique'dir.
-- Erişim:
--   - Platform Admin: Tüm client'lar
--   - CompanyAdmin: Kendi company'sindeki client'lar
--   - ClientAdmin: user_allowed_clients'taki client'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.client_layout_upsert(BIGINT, BIGINT, VARCHAR, TEXT, BIGINT, BOOLEAN);

CREATE OR REPLACE FUNCTION presentation.client_layout_upsert(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_layout_name VARCHAR(50),
    p_structure TEXT,
    p_page_id BIGINT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT TRUE
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = presentation, core, security, pg_temp
AS $$
DECLARE
    v_layout_id BIGINT;
BEGIN
    -- 1. Client varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM core.clients WHERE id = p_client_id AND status = 1) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- 2. Client erişim kontrolü
    PERFORM security.user_assert_access_client(p_caller_id, p_client_id);

    -- 3. Upsert
    INSERT INTO presentation.client_layouts (
        client_id,
        page_id,
        layout_name,
        structure,
        is_active,
        created_at,
        updated_at
    )
    VALUES (
        p_client_id,
        p_page_id,
        p_layout_name,
        p_structure::jsonb,
        p_is_active,
        NOW(),
        NOW()
    )
    ON CONFLICT (client_id, layout_name) DO UPDATE
    SET page_id = EXCLUDED.page_id,
        structure = EXCLUDED.structure,
        is_active = EXCLUDED.is_active,
        updated_at = NOW()
    RETURNING id INTO v_layout_id;

    RETURN v_layout_id;
END;
$$;

COMMENT ON FUNCTION presentation.client_layout_upsert(BIGINT, BIGINT, VARCHAR, TEXT, BIGINT, BOOLEAN) IS
'Creates or updates a client layout (widget placement).
layout_name is unique per client.
Access: Platform Admin (all), CompanyAdmin (own company), ClientAdmin (allowed clients).';
