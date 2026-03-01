-- ================================================================
-- CLIENT_NAVIGATION_DELETE: Navigasyon öğesi sil
-- ================================================================
-- Açıklama:
--   Client navigasyon öğesini siler.
--   is_locked=TRUE olan öğeler silinemez (template'den gelen zorunlu öğeler).
-- Erişim:
--   - Platform Admin: Tüm client'lar
--   - CompanyAdmin: Kendi company'sindeki client'lar
--   - ClientAdmin: user_allowed_clients'taki client'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.client_navigation_delete(BIGINT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION presentation.client_navigation_delete(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = presentation, core, security, pg_temp
AS $$
DECLARE
    v_item RECORD;
BEGIN
    -- 1. Client varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM core.clients WHERE id = p_client_id AND status = 1) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- 2. Client erişim kontrolü
    PERFORM security.user_assert_access_client(p_caller_id, p_client_id);

    -- ========================================
    -- 3. MEVCUT ÖĞEYİ AL
    -- ========================================
    SELECT id, is_locked
    INTO v_item
    FROM presentation.client_navigation
    WHERE id = p_id AND client_id = p_client_id;

    IF v_item.id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client-navigation.not-found';
    END IF;

    -- ========================================
    -- 5. LOCKED KONTROLÜ
    -- ========================================
    IF v_item.is_locked THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.client-navigation.is-locked';
    END IF;

    -- ========================================
    -- 6. ALT ÖĞELERİ KONTROL ET
    -- ========================================
    IF EXISTS (
        SELECT 1 FROM presentation.client_navigation
        WHERE parent_id = p_id AND client_id = p_client_id
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.client-navigation.has-children';
    END IF;

    -- ========================================
    -- 7. SİL
    -- ========================================
    DELETE FROM presentation.client_navigation
    WHERE id = p_id AND client_id = p_client_id;
END;
$$;

COMMENT ON FUNCTION presentation.client_navigation_delete(BIGINT, BIGINT, BIGINT) IS
'Deletes a client navigation item.
Locked items (is_locked=TRUE) cannot be deleted.
Items with children cannot be deleted (delete children first).
Access: Platform Admin (all), CompanyAdmin (own company), ClientAdmin (allowed clients).';
