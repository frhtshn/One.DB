-- ================================================================
-- CLIENT_LAYOUT_DELETE: Layout pasifleştir (soft delete)
-- ================================================================
-- Açıklama:
--   Client layout'unu pasifleştirir.
-- Erişim:
--   - Platform Admin: Tüm client'lar
--   - CompanyAdmin: Kendi company'sindeki client'lar
--   - ClientAdmin: user_allowed_clients'taki client'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.client_layout_delete(BIGINT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION presentation.client_layout_delete(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = presentation, core, security, pg_temp
AS $$
BEGIN
    -- 1. Client varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM core.clients WHERE id = p_client_id AND status = 1) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- 2. Client erişim kontrolü
    PERFORM security.user_assert_access_client(p_caller_id, p_client_id);

    -- 3. Pasifleştir
    UPDATE presentation.client_layouts SET
        is_active = false,
        updated_at = NOW()
    WHERE id = p_id AND client_id = p_client_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client-layout.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION presentation.client_layout_delete(BIGINT, BIGINT, BIGINT) IS
'Soft-deletes a client layout (is_active=false).
Access: Platform Admin (all), CompanyAdmin (own company), ClientAdmin (allowed clients).';
