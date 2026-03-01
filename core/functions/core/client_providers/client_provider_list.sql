-- ================================================================
-- CLIENT_PROVIDER_LIST: Client game provider listesi
-- ================================================================
-- Sadece GAME tipli provider'ları döner.
-- gameCount subquery ile oyun sayısı eklenir.
-- rolloutStatus shadow mode durumunu gösterir.
-- ================================================================

DROP FUNCTION IF EXISTS core.client_provider_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.client_provider_list(
    p_caller_id BIGINT,
    p_client_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_company_id BIGINT;
    v_result JSONB;
BEGIN
    -- Client varlık kontrolü
    SELECT company_id INTO v_company_id
    FROM core.clients WHERE id = p_client_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_company_id);

    -- Provider listesi
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', tp.id,
            'providerId', tp.provider_id,
            'providerCode', p.provider_code,
            'providerName', p.provider_name,
            'mode', tp.mode,
            'isEnabled', tp.is_enabled,
            'rolloutStatus', tp.rollout_status,
            'gameCount', (
                SELECT COUNT(*)
                FROM core.client_games tg
                WHERE tg.client_id = tp.client_id
                  AND EXISTS(
                      SELECT 1 FROM catalog.providers prov
                      WHERE prov.id = tp.provider_id
                        AND prov.provider_code = tg.provider_code
                  )
            ),
            'createdAt', tp.created_at,
            'updatedAt', tp.updated_at
        ) ORDER BY p.provider_name
    ), '[]'::jsonb)
    INTO v_result
    FROM core.client_providers tp
    JOIN catalog.providers p ON p.id = tp.provider_id
    JOIN catalog.provider_types pt ON pt.id = p.provider_type_id
    WHERE tp.client_id = p_client_id
      AND pt.provider_type_code = 'GAME';

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.client_provider_list IS 'Returns GAME-type provider list for a client with game counts and rollout status. IDOR protected.';
