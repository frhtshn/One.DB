-- ================================================================
-- CLIENT_THEME_GET: Client tema detayı
-- ================================================================
-- Açıklama:
--   Belirtilen tema için client yapılandırmasını getirir.
--   Eğer theme_id NULL ise aktif temayı getirir.
--   Merged config (default + override) döner.
-- Erişim:
--   - Platform Admin: Tüm client'lar
--   - CompanyAdmin: Kendi company'sindeki client'lar
--   - ClientAdmin: user_allowed_clients'taki client'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.client_theme_get(BIGINT, BIGINT, INT);

CREATE OR REPLACE FUNCTION presentation.client_theme_get(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_theme_id INT DEFAULT NULL
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

    -- 3. Tema getir
    IF p_theme_id IS NULL THEN
        -- Aktif temayı getir
        SELECT jsonb_build_object(
            'clientThemeId', tt.id,
            'themeId', t.id,
            'code', t.code,
            'name', t.name,
            'description', t.description,
            'version', t.version,
            'thumbnailUrl', t.thumbnail_url,
            'defaultConfig', t.default_config,
            'clientConfig', tt.config,
            'mergedConfig', COALESCE(t.default_config, '{}'::jsonb) || COALESCE(tt.config, '{}'::jsonb),
            'customCss', tt.custom_css,
            'isActive', tt.is_active,
            'isPremium', t.is_premium,
            'createdAt', tt.created_at,
            'updatedAt', tt.updated_at
        )
        INTO v_result
        FROM presentation.client_themes tt
        JOIN catalog.themes t ON t.id = tt.theme_id
        WHERE tt.client_id = p_client_id AND tt.is_active = TRUE;

        IF v_result IS NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client-theme.no-active-theme';
        END IF;
    ELSE
        -- Belirli temayı getir
        SELECT jsonb_build_object(
            'clientThemeId', tt.id,
            'themeId', t.id,
            'code', t.code,
            'name', t.name,
            'description', t.description,
            'version', t.version,
            'thumbnailUrl', t.thumbnail_url,
            'defaultConfig', t.default_config,
            'clientConfig', COALESCE(tt.config, '{}'::jsonb),
            'mergedConfig', COALESCE(t.default_config, '{}'::jsonb) || COALESCE(tt.config, '{}'::jsonb),
            'customCss', tt.custom_css,
            'isActive', COALESCE(tt.is_active, FALSE),
            'isConfigured', (tt.id IS NOT NULL),
            'isPremium', t.is_premium,
            'createdAt', tt.created_at,
            'updatedAt', tt.updated_at
        )
        INTO v_result
        FROM catalog.themes t
        LEFT JOIN presentation.client_themes tt ON tt.theme_id = t.id AND tt.client_id = p_client_id
        WHERE t.id = p_theme_id AND t.is_active = TRUE;

        IF v_result IS NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.theme.not-found';
        END IF;
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.client_theme_get(BIGINT, BIGINT, INT) IS
'Gets client theme configuration.
If p_theme_id is NULL, returns the active theme.
Returns merged config (default_config + client override).
Access: Platform Admin (all), CompanyAdmin (own company), ClientAdmin (allowed clients).';
