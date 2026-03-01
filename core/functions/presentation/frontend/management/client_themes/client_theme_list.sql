-- ================================================================
-- CLIENT_THEME_LIST: Client tema listesi
-- ================================================================
-- Açıklama:
--   Client'ın yapılandırılmış temalarını listeler.
--   Catalog'daki tüm aktif temaları da gösterir (configured flag ile).
-- Erişim:
--   - Platform Admin: Tüm client'lar
--   - CompanyAdmin: Kendi company'sindeki client'lar
--   - ClientAdmin: user_allowed_clients'taki client'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.client_theme_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION presentation.client_theme_list(
    p_caller_id BIGINT,
    p_client_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = presentation, catalog, core, security, pg_temp
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- 1. Client varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM core.clients WHERE id = p_client_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- 2. Client erişim kontrolü
    PERFORM security.user_assert_access_client(p_caller_id, p_client_id);

    -- 3. Tema listesi (Catalog + Client Config)
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'themeId', t.id,
            'code', t.code,
            'name', t.name,
            'description', t.description,
            'version', t.version,
            'thumbnailUrl', t.thumbnail_url,
            'defaultConfig', t.default_config,
            'isPremium', t.is_premium,
            -- Client-specific fields
            'clientThemeId', tt.id,
            'isConfigured', (tt.id IS NOT NULL),
            'isActive', COALESCE(tt.is_active, FALSE),
            'clientConfig', tt.config,
            'customCss', tt.custom_css
        ) ORDER BY COALESCE(tt.is_active, FALSE) DESC, t.name
    ), '[]'::jsonb)
    INTO v_result
    FROM catalog.themes t
    LEFT JOIN presentation.client_themes tt ON tt.theme_id = t.id AND tt.client_id = p_client_id
    WHERE t.is_active = TRUE;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.client_theme_list(BIGINT, BIGINT) IS
'Lists all available themes with client configuration status.
Shows catalog themes with isConfigured and isActive flags based on client_themes.
Access: Platform Admin (all), CompanyAdmin (own company), ClientAdmin (allowed clients).';
