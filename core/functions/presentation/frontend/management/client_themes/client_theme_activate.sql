-- ================================================================
-- CLIENT_THEME_ACTIVATE: Tema aktifleştir
-- ================================================================
-- Açıklama:
--   Belirtilen temayı aktif yapar, diğerlerini deaktif eder.
--   Tema daha önce yapılandırılmamışsa varsayılan ayarlarla oluşturur.
-- Erişim:
--   - Platform Admin: Tüm client'lar
--   - CompanyAdmin: Kendi company'sindeki client'lar
--   - ClientAdmin: user_allowed_clients'taki client'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.client_theme_activate(BIGINT, BIGINT, INT);

CREATE OR REPLACE FUNCTION presentation.client_theme_activate(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_theme_id INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = presentation, catalog, core, security, pg_temp
AS $$
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
    -- 5. MEVCUT AKTİF TEMAYI DEAKTİF ET
    -- ========================================
    UPDATE presentation.client_themes
    SET is_active = FALSE, updated_at = NOW()
    WHERE client_id = p_client_id AND is_active = TRUE;

    -- ========================================
    -- 6. YENİ TEMAYI AKTİF ET (yoksa oluştur)
    -- ========================================
    INSERT INTO presentation.client_themes (
        client_id,
        theme_id,
        config,
        is_active,
        created_at,
        updated_at
    )
    VALUES (
        p_client_id,
        p_theme_id,
        '{}'::jsonb,
        TRUE,
        NOW(),
        NOW()
    )
    ON CONFLICT (client_id, theme_id) DO UPDATE
    SET is_active = TRUE,
        updated_at = NOW();
END;
$$;

COMMENT ON FUNCTION presentation.client_theme_activate(BIGINT, BIGINT, INT) IS
'Activates a theme for the client.
Deactivates any currently active theme and activates the specified one.
If the theme was not configured before, creates it with default settings.
Access: Platform Admin (all), CompanyAdmin (own company), ClientAdmin (allowed clients).';
