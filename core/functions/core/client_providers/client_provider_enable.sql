-- ================================================================
-- TENANT_PROVIDER_ENABLE: Tenant'a game provider aç + oyunları seed et
-- ================================================================
-- Backend Game DB'den oyun listesini alır, p_game_data TEXT olarak
-- bu fonksiyona geçirir. Fonksiyon catalog.games sorgusu YAPMAZ.
-- Mevcut oyunların is_enabled durumuna dokunmaz.
-- Yeni oyunlar ON CONFLICT DO NOTHING ile seed edilir.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_provider_enable(BIGINT, BIGINT, BIGINT, TEXT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION core.tenant_provider_enable(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_provider_id BIGINT,
    p_game_data TEXT DEFAULT NULL,
    p_mode VARCHAR(20) DEFAULT 'real',
    p_rollout_status VARCHAR(20) DEFAULT 'production'
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_company_id BIGINT;
    v_games JSONB;
    v_elem JSONB;
    v_count INTEGER := 0;
BEGIN
    -- Tenant varlık kontrolü
    SELECT company_id INTO v_company_id
    FROM core.tenants WHERE id = p_tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_company_id);

    -- Provider varlık + tip kontrolü
    IF NOT EXISTS(
        SELECT 1 FROM catalog.providers p
        JOIN catalog.provider_types pt ON pt.id = p.provider_type_id
        WHERE p.id = p_provider_id AND pt.provider_type_code = 'GAME'
    ) THEN
        IF NOT EXISTS(SELECT 1 FROM catalog.providers WHERE id = p_provider_id) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider.not-found';
        ELSE
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.not-game-type';
        END IF;
    END IF;

    -- rollout_status validasyon
    IF p_rollout_status NOT IN ('shadow', 'production') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.invalid-rollout-status';
    END IF;

    -- tenant_providers UPSERT
    INSERT INTO core.tenant_providers (tenant_id, provider_id, mode, is_enabled, rollout_status, created_at, updated_at)
    VALUES (p_tenant_id, p_provider_id, p_mode, true, p_rollout_status, NOW(), NOW())
    ON CONFLICT (tenant_id, provider_id) DO UPDATE SET
        is_enabled = true,
        mode = p_mode,
        rollout_status = p_rollout_status,
        updated_at = NOW();

    -- Oyunları seed et (varsa)
    IF p_game_data IS NOT NULL AND TRIM(p_game_data) != '' THEN
        v_games := p_game_data::JSONB;

        FOR v_elem IN SELECT * FROM jsonb_array_elements(v_games)
        LOOP
            INSERT INTO core.tenant_games (
                tenant_id, game_id, game_name, game_code,
                provider_code, game_type, thumbnail_url,
                sync_status, created_by, created_at, updated_at
            ) VALUES (
                p_tenant_id,
                (v_elem->>'game_id')::BIGINT,
                v_elem->>'game_name',
                v_elem->>'game_code',
                v_elem->>'provider_code',
                v_elem->>'game_type',
                v_elem->>'thumbnail_url',
                'pending',
                p_caller_id,
                NOW(),
                NOW()
            )
            ON CONFLICT (tenant_id, game_id) DO NOTHING;

            IF FOUND THEN
                v_count := v_count + 1;
            END IF;
        END LOOP;
    END IF;

    RETURN v_count;
END;
$$;

COMMENT ON FUNCTION core.tenant_provider_enable IS 'Enables a GAME provider for tenant and seeds games from backend-provided data (cross-DB orchestration). Existing games untouched (ON CONFLICT DO NOTHING). Supports shadow rollout mode.';
