-- ================================================================
-- TENANT_GAME_LIST: Tenant oyun listesi (BO admin)
-- ================================================================
-- Denormalize alanlardan sorgu, catalog.games JOIN YOK (cross-DB).
-- Provider filtresi + metin arama + sayfalama destekler.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_game_list(BIGINT, BIGINT, VARCHAR, VARCHAR, BOOLEAN, TEXT, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION core.tenant_game_list(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_provider_code VARCHAR(50) DEFAULT NULL,
    p_game_type VARCHAR(50) DEFAULT NULL,
    p_is_enabled BOOLEAN DEFAULT NULL,
    p_search TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_company_id BIGINT;
    v_total INTEGER;
    v_items JSONB;
BEGIN
    -- Tenant varlık kontrolü
    SELECT company_id INTO v_company_id
    FROM core.tenants WHERE id = p_tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_company_id);

    -- Toplam sayı
    SELECT COUNT(*) INTO v_total
    FROM core.tenant_games tg
    WHERE tg.tenant_id = p_tenant_id
      AND (p_provider_code IS NULL OR tg.provider_code = UPPER(TRIM(p_provider_code)))
      AND (p_game_type IS NULL OR tg.game_type = UPPER(TRIM(p_game_type)))
      AND (p_is_enabled IS NULL OR tg.is_enabled = p_is_enabled)
      AND (p_search IS NULL OR
           tg.game_name ILIKE '%' || p_search || '%' OR
           tg.game_code ILIKE '%' || p_search || '%' OR
           tg.custom_name ILIKE '%' || p_search || '%');

    -- Oyun listesi
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', tg.id,
            'gameId', tg.game_id,
            'gameName', tg.game_name,
            'gameCode', tg.game_code,
            'providerCode', tg.provider_code,
            'gameType', tg.game_type,
            'thumbnailUrl', tg.thumbnail_url,
            'isEnabled', tg.is_enabled,
            'isVisible', tg.is_visible,
            'isFeatured', tg.is_featured,
            'displayOrder', tg.display_order,
            'customName', tg.custom_name,
            'customThumbnailUrl', tg.custom_thumbnail_url,
            'customCategories', tg.custom_categories,
            'customTags', tg.custom_tags,
            'rtpVariant', tg.rtp_variant,
            'allowedPlatforms', tg.allowed_platforms,
            'blockedCountries', tg.blocked_countries,
            'allowedCountries', tg.allowed_countries,
            'availableFrom', tg.available_from,
            'availableUntil', tg.available_until,
            'syncStatus', tg.sync_status,
            'lastSyncedAt', tg.last_synced_at,
            'createdAt', tg.created_at,
            'updatedAt', tg.updated_at
        ) ORDER BY tg.display_order ASC, tg.id ASC
    ), '[]'::jsonb)
    INTO v_items
    FROM core.tenant_games tg
    WHERE tg.tenant_id = p_tenant_id
      AND (p_provider_code IS NULL OR tg.provider_code = UPPER(TRIM(p_provider_code)))
      AND (p_game_type IS NULL OR tg.game_type = UPPER(TRIM(p_game_type)))
      AND (p_is_enabled IS NULL OR tg.is_enabled = p_is_enabled)
      AND (p_search IS NULL OR
           tg.game_name ILIKE '%' || p_search || '%' OR
           tg.game_code ILIKE '%' || p_search || '%' OR
           tg.custom_name ILIKE '%' || p_search || '%')
    ORDER BY tg.display_order ASC, tg.id ASC
    LIMIT p_limit OFFSET p_offset;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total,
        'limit', p_limit,
        'offset', p_offset
    );
END;
$$;

COMMENT ON FUNCTION core.tenant_game_list IS 'Returns tenant game list for BO admin. Uses denormalized fields (no cross-DB JOIN). Supports provider, type, status filtering and text search. IDOR protected.';
