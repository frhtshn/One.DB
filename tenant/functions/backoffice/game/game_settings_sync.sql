-- ================================================================
-- GAME_SETTINGS_SYNC: Core->Tenant game data upsert
-- ================================================================
-- Backend tarafından çağrılır (auth-agnostic, cross-DB auth pattern).
-- p_catalog_data TEXT → JSONB cast → typed kolonlara extract.
-- INSERT: catalog + tenant override (default değerler)
-- UPDATE: SADECE catalog alanları — tenant override'lara DOKUNMAZ
-- ================================================================

DROP FUNCTION IF EXISTS game.game_settings_sync(BIGINT, TEXT, TEXT, VARCHAR);

CREATE OR REPLACE FUNCTION game.game_settings_sync(
    p_game_id BIGINT,
    p_catalog_data TEXT,
    p_tenant_overrides TEXT DEFAULT NULL,
    p_rollout_status VARCHAR(20) DEFAULT 'production'
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_catalog JSONB;
    v_overrides JSONB;
    v_exists BOOLEAN;
BEGIN
    -- Parametre kontrolleri
    IF p_game_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.id-required';
    END IF;

    IF p_catalog_data IS NULL OR TRIM(p_catalog_data) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.catalog-data-required';
    END IF;

    v_catalog := p_catalog_data::JSONB;
    v_overrides := COALESCE(NULLIF(TRIM(p_tenant_overrides), ''), '{}')::JSONB;

    -- Mevcut kayıt kontrolü
    SELECT EXISTS(SELECT 1 FROM game.game_settings WHERE game_id = p_game_id) INTO v_exists;

    IF v_exists THEN
        -- UPDATE: Sadece catalog alanları güncellenir, tenant override'lara DOKUNULMAZ
        UPDATE game.game_settings SET
            provider_id = COALESCE((v_catalog->>'provider_id')::BIGINT, provider_id),
            external_game_id = COALESCE(v_catalog->>'external_game_id', external_game_id),
            game_code = COALESCE(v_catalog->>'game_code', game_code),
            game_name = COALESCE(v_catalog->>'game_name', game_name),
            provider_code = COALESCE(v_catalog->>'provider_code', provider_code),
            studio = COALESCE(v_catalog->>'studio', studio),
            game_type = COALESCE(v_catalog->>'game_type', game_type),
            game_subtype = COALESCE(v_catalog->>'game_subtype', game_subtype),
            categories = COALESCE(
                (SELECT array_agg(x::VARCHAR(50)) FROM jsonb_array_elements_text(v_catalog->'categories') x),
                categories
            ),
            tags = COALESCE(
                (SELECT array_agg(x::VARCHAR(50)) FROM jsonb_array_elements_text(v_catalog->'tags') x),
                tags
            ),
            rtp = COALESCE((v_catalog->>'rtp')::DECIMAL(5,2), rtp),
            volatility = COALESCE(v_catalog->>'volatility', volatility),
            max_multiplier = COALESCE((v_catalog->>'max_multiplier')::DECIMAL(10,2), max_multiplier),
            paylines = COALESCE((v_catalog->>'paylines')::INTEGER, paylines),
            thumbnail_url = COALESCE(v_catalog->>'thumbnail_url', thumbnail_url),
            background_url = COALESCE(v_catalog->>'background_url', background_url),
            logo_url = COALESCE(v_catalog->>'logo_url', logo_url),
            features = COALESCE(
                (SELECT array_agg(x::VARCHAR(50)) FROM jsonb_array_elements_text(v_catalog->'features') x),
                features
            ),
            has_demo = COALESCE((v_catalog->>'has_demo')::BOOLEAN, has_demo),
            has_jackpot = COALESCE((v_catalog->>'has_jackpot')::BOOLEAN, has_jackpot),
            jackpot_type = COALESCE(v_catalog->>'jackpot_type', jackpot_type),
            has_bonus_buy = COALESCE((v_catalog->>'has_bonus_buy')::BOOLEAN, has_bonus_buy),
            is_mobile = COALESCE((v_catalog->>'is_mobile')::BOOLEAN, is_mobile),
            is_desktop = COALESCE((v_catalog->>'is_desktop')::BOOLEAN, is_desktop),
            core_synced_at = NOW(),
            updated_at = NOW()
        WHERE game_id = p_game_id;
    ELSE
        -- INSERT: catalog alanları + tenant override default değerleri
        INSERT INTO game.game_settings (
            game_id, provider_id, external_game_id, game_code, game_name, provider_code, studio,
            game_type, game_subtype, categories, tags,
            rtp, volatility, max_multiplier, paylines,
            thumbnail_url, background_url, logo_url,
            features, has_demo, has_jackpot, jackpot_type, has_bonus_buy,
            is_mobile, is_desktop,
            display_order, is_visible, is_enabled, is_featured,
            blocked_countries, allowed_countries,
            rollout_status,
            core_synced_at, created_at, updated_at
        ) VALUES (
            p_game_id,
            (v_catalog->>'provider_id')::BIGINT,
            v_catalog->>'external_game_id',
            v_catalog->>'game_code',
            v_catalog->>'game_name',
            v_catalog->>'provider_code',
            v_catalog->>'studio',
            COALESCE(v_catalog->>'game_type', 'SLOT'),
            v_catalog->>'game_subtype',
            COALESCE((SELECT array_agg(x::VARCHAR(50)) FROM jsonb_array_elements_text(v_catalog->'categories') x), '{}'),
            COALESCE((SELECT array_agg(x::VARCHAR(50)) FROM jsonb_array_elements_text(v_catalog->'tags') x), '{}'),
            (v_catalog->>'rtp')::DECIMAL(5,2),
            v_catalog->>'volatility',
            (v_catalog->>'max_multiplier')::DECIMAL(10,2),
            (v_catalog->>'paylines')::INTEGER,
            v_catalog->>'thumbnail_url',
            v_catalog->>'background_url',
            v_catalog->>'logo_url',
            COALESCE((SELECT array_agg(x::VARCHAR(50)) FROM jsonb_array_elements_text(v_catalog->'features') x), '{}'),
            COALESCE((v_catalog->>'has_demo')::BOOLEAN, true),
            COALESCE((v_catalog->>'has_jackpot')::BOOLEAN, false),
            v_catalog->>'jackpot_type',
            COALESCE((v_catalog->>'has_bonus_buy')::BOOLEAN, false),
            COALESCE((v_catalog->>'is_mobile')::BOOLEAN, true),
            COALESCE((v_catalog->>'is_desktop')::BOOLEAN, true),
            COALESCE((v_overrides->>'display_order')::INTEGER, 0),
            COALESCE((v_overrides->>'is_visible')::BOOLEAN, true),
            COALESCE((v_overrides->>'is_enabled')::BOOLEAN, true),
            COALESCE((v_overrides->>'is_featured')::BOOLEAN, false),
            COALESCE((SELECT array_agg(x::CHAR(2)) FROM jsonb_array_elements_text(v_overrides->'blocked_countries') x), '{}'),
            COALESCE((SELECT array_agg(x::CHAR(2)) FROM jsonb_array_elements_text(v_overrides->'allowed_countries') x), '{}'),
            p_rollout_status,
            NOW(),
            NOW(),
            NOW()
        );
    END IF;
END;
$$;

COMMENT ON FUNCTION game.game_settings_sync IS 'Syncs game catalog data from Core to Tenant DB. On INSERT: applies catalog + tenant overrides. On UPDATE: only catalog fields updated, tenant overrides preserved. Auth-agnostic (cross-DB auth pattern).';
