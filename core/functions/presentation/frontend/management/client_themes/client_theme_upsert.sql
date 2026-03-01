-- ================================================================
-- CLIENT_THEME_UPSERT: Client tema yapılandırması oluştur/güncelle
-- ================================================================
-- Açıklama:
--   Client için tema yapılandırması oluşturur veya günceller.
--   Config parametresi default_config'i override eder (merge edilir FE'de).
-- Erişim:
--   - Platform Admin: Tüm client'lar
--   - CompanyAdmin: Kendi company'sindeki client'lar
--   - ClientAdmin: user_allowed_clients'taki client'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.client_theme_upsert(BIGINT, BIGINT, INT, TEXT, TEXT, BOOLEAN);

CREATE OR REPLACE FUNCTION presentation.client_theme_upsert(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_theme_id INT,
    p_config TEXT DEFAULT '{}',
    p_custom_css TEXT DEFAULT NULL,
    p_set_active BOOLEAN DEFAULT FALSE
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = presentation, catalog, core, security, pg_temp
AS $$
DECLARE
    v_client_theme_id BIGINT;
BEGIN
    -- 1. Client varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM core.clients WHERE id = p_client_id AND status = 1) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- 2. Client erişim kontrolü
    PERFORM security.user_assert_access_client(p_caller_id, p_client_id);

    -- 3. Tema varlık kontrolü
    IF NOT EXISTS (SELECT 1 FROM catalog.themes WHERE id = p_theme_id AND is_active = TRUE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.theme.not-found';
    END IF;

    -- ========================================
    -- 5. AKTİF TEMA DEĞİŞİKLİĞİ
    -- ========================================
    IF p_set_active THEN
        -- Diğer temaları deaktif et
        UPDATE presentation.client_themes
        SET is_active = FALSE, updated_at = NOW()
        WHERE client_id = p_client_id AND is_active = TRUE;
    END IF;

    -- ========================================
    -- 6. UPSERT
    -- ========================================
    INSERT INTO presentation.client_themes (
        client_id,
        theme_id,
        config,
        custom_css,
        is_active,
        created_at,
        updated_at
    )
    VALUES (
        p_client_id,
        p_theme_id,
        p_config::jsonb,
        p_custom_css,
        p_set_active,
        NOW(),
        NOW()
    )
    ON CONFLICT (client_id, theme_id) DO UPDATE
    SET config = EXCLUDED.config,
        custom_css = EXCLUDED.custom_css,
        is_active = CASE WHEN p_set_active THEN TRUE ELSE presentation.client_themes.is_active END,
        updated_at = NOW()
    RETURNING id INTO v_client_theme_id;

    RETURN v_client_theme_id;
END;
$$;

COMMENT ON FUNCTION presentation.client_theme_upsert(BIGINT, BIGINT, INT, TEXT, TEXT, BOOLEAN) IS
'Creates or updates client theme configuration.
If p_set_active is TRUE, deactivates other themes and sets this one as active.
Access: Platform Admin (all), CompanyAdmin (own company), ClientAdmin (allowed clients).';
