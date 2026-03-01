-- ================================================================
-- CLIENT_PROVIDER_DISABLE: Client provider kapatma
-- ================================================================
-- Sadece flag günceller (is_enabled=false).
-- Oyunlara (core.client_games) DOKUNMAZ.
-- Provider durumu sorgu seviyesinde filtrelenir.
-- ================================================================

DROP FUNCTION IF EXISTS core.client_provider_disable(BIGINT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.client_provider_disable(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_provider_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_company_id BIGINT;
BEGIN
    -- Client varlık kontrolü
    SELECT company_id INTO v_company_id
    FROM core.clients WHERE id = p_client_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_company_id);

    -- Provider kaydı kontrolü
    IF NOT EXISTS(
        SELECT 1 FROM core.client_providers
        WHERE client_id = p_client_id AND provider_id = p_provider_id
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client-provider.not-found';
    END IF;

    -- Sadece flag güncelle
    UPDATE core.client_providers
    SET is_enabled = false, updated_at = NOW()
    WHERE client_id = p_client_id AND provider_id = p_provider_id;
END;
$$;

COMMENT ON FUNCTION core.client_provider_disable IS 'Disables a provider for client (flag only). Games remain untouched - provider status is filtered at query level.';
