-- ================================================================
-- GET_ACTIVE_THEME: Frontend için aktif tema verisi
-- ================================================================
-- Açıklama:
--   Frontend uygulamasının aktif tema yapılandırmasını çekmesi için.
--   Merged config (default + tenant override) döner.
--   Custom CSS dahil edilir.
-- Kullanım:
--   Website/App frontend tarafından çağrılır.
--   Sayfa yüklenirken tema stillerini uygulamak için.
-- ================================================================

DROP FUNCTION IF EXISTS presentation.get_active_theme(BIGINT);

CREATE OR REPLACE FUNCTION presentation.get_active_theme(
    p_tenant_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = presentation, catalog, pg_temp
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- ========================================
    -- 1. TENANT VARLIK KONTROLÜ
    -- ========================================
    IF NOT EXISTS (SELECT 1 FROM core.tenants WHERE id = p_tenant_id AND status = 1) THEN
        RETURN NULL;
    END IF;

    -- ========================================
    -- 2. AKTİF TEMA VERİSİ
    -- ========================================
    SELECT jsonb_build_object(
        'themeId', t.id,
        'code', t.code,
        'name', t.name,
        'version', t.version,
        'config', COALESCE(t.default_config, '{}'::jsonb) || COALESCE(tt.config, '{}'::jsonb),
        'customCss', tt.custom_css
    )
    INTO v_result
    FROM presentation.tenant_themes tt
    JOIN catalog.themes t ON t.id = tt.theme_id AND t.is_active = TRUE
    WHERE tt.tenant_id = p_tenant_id
      AND tt.is_active = TRUE;

    -- Aktif tema yoksa varsayılan tema dön
    IF v_result IS NULL THEN
        SELECT jsonb_build_object(
            'themeId', t.id,
            'code', t.code,
            'name', t.name,
            'version', t.version,
            'config', COALESCE(t.default_config, '{}'::jsonb),
            'customCss', NULL
        )
        INTO v_result
        FROM catalog.themes t
        WHERE t.is_active = TRUE
        ORDER BY t.id
        LIMIT 1;
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.get_active_theme(BIGINT) IS
'Returns active theme configuration for frontend rendering.
Returns merged config (default_config + tenant override).
If no active theme configured, returns first available theme with defaults.
Usage: Called by website/app frontend for theming.';
