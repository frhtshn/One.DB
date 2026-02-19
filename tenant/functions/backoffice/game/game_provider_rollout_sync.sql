-- ================================================================
-- GAME_PROVIDER_ROLLOUT_SYNC: Provider rollout status toplu güncelle
-- ================================================================
-- Provider bazlı tüm oyunların rollout_status değerini günceller.
-- Core DB'den tetiklenir (backend orchestration).
-- Auth-agnostic.
-- ================================================================

DROP FUNCTION IF EXISTS game.game_provider_rollout_sync(BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION game.game_provider_rollout_sync(
    p_provider_id BIGINT,
    p_rollout_status VARCHAR(20)
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Parametre kontrolleri
    IF p_provider_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.id-required';
    END IF;

    IF p_rollout_status IS NULL OR p_rollout_status NOT IN ('shadow', 'production') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.invalid-rollout-status';
    END IF;

    -- Toplu güncelleme
    UPDATE game.game_settings
    SET rollout_status = p_rollout_status, updated_at = NOW()
    WHERE provider_id = p_provider_id;

    GET DIAGNOSTICS v_count = ROW_COUNT;

    RETURN v_count;
END;
$$;

COMMENT ON FUNCTION game.game_provider_rollout_sync(BIGINT, VARCHAR) IS 'Bulk updates rollout_status for all games of a provider. Called by backend when provider rollout changes in Core DB. Auth-agnostic.';
