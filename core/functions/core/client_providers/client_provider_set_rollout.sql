-- ================================================================
-- CLIENT_PROVIDER_SET_ROLLOUT: Shadow/production geçişi
-- ================================================================
-- Provider'ın rollout_status değerini günceller.
-- shadow: Sadece test oyuncuları görür
-- production: Herkes görür
-- ================================================================

DROP FUNCTION IF EXISTS core.client_provider_set_rollout(BIGINT, BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION core.client_provider_set_rollout(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_provider_id BIGINT,
    p_rollout_status VARCHAR(20)
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
    PERFORM security.user_assert_access_client(p_caller_id, p_client_id);

    -- rollout_status validasyon
    IF p_rollout_status IS NULL OR p_rollout_status NOT IN ('shadow', 'production') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.invalid-rollout-status';
    END IF;

    -- Provider kaydı kontrolü + güncelleme
    UPDATE core.client_providers
    SET rollout_status = p_rollout_status, updated_at = NOW()
    WHERE client_id = p_client_id AND provider_id = p_provider_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client-provider.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION core.client_provider_set_rollout IS 'Updates provider rollout status between shadow (testers only) and production (all players). IDOR protected via user_assert_access_client.';
