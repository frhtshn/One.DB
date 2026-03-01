-- ================================================================
-- CLIENT_GAME_REFRESH: Yeni oyunları toplu seed et
-- ================================================================
-- Backend Game DB'den yeni oyun listesini alıp bu fonksiyona geçirir.
-- Mevcut kayıtlara dokunmaz (ON CONFLICT DO NOTHING).
-- Provider tip kontrolü yapılır.
-- ================================================================

DROP FUNCTION IF EXISTS core.client_game_refresh(BIGINT, BIGINT, BIGINT, TEXT);

CREATE OR REPLACE FUNCTION core.client_game_refresh(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_provider_id BIGINT,
    p_game_data TEXT
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
    -- Client varlık kontrolü
    SELECT company_id INTO v_company_id
    FROM core.clients WHERE id = p_client_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_company_id);

    -- Provider tip kontrolü (GAME olmalı)
    IF NOT EXISTS(
        SELECT 1 FROM catalog.providers p
        JOIN catalog.provider_types pt ON pt.id = p.provider_type_id
        WHERE p.id = p_provider_id AND pt.provider_type_code = 'GAME'
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.not-game-type';
    END IF;

    -- Veri kontrolü
    IF p_game_data IS NULL OR TRIM(p_game_data) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.data-required';
    END IF;

    v_games := p_game_data::JSONB;

    -- Yeni oyunları seed et
    FOR v_elem IN SELECT * FROM jsonb_array_elements(v_games)
    LOOP
        INSERT INTO core.client_games (
            client_id, game_id, game_name, game_code,
            provider_code, game_type, thumbnail_url,
            sync_status, created_by, created_at, updated_at
        ) VALUES (
            p_client_id,
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
        ON CONFLICT (client_id, game_id) DO NOTHING;

        IF FOUND THEN
            v_count := v_count + 1;
        END IF;
    END LOOP;

    RETURN v_count;
END;
$$;

COMMENT ON FUNCTION core.client_game_refresh IS 'Seeds new games for a client from backend-provided data (cross-DB orchestration). Existing games untouched (ON CONFLICT DO NOTHING). Returns inserted count. IDOR protected.';
