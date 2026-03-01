-- ================================================================
-- THEME_ACTIVATE: Aktif temayı değiştir
-- Diğer tüm temaları pasifler, seçileni aktifler
-- Aynı anda sadece 1 tema aktif olabilir
-- ================================================================

DROP FUNCTION IF EXISTS presentation.theme_activate(BIGINT);

CREATE OR REPLACE FUNCTION presentation.theme_activate(
    p_id                BIGINT              -- Tenant theme kayıt ID
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Parametre doğrulama
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.theme.id-required';
    END IF;

    -- Kayıt kontrolü
    IF NOT EXISTS (SELECT 1 FROM presentation.themes WHERE id = p_id) THEN
        RAISE EXCEPTION 'error.theme.not-found';
    END IF;

    -- Tüm temaları pasifle
    UPDATE presentation.themes
    SET is_active = FALSE, updated_at = NOW()
    WHERE is_active = TRUE;

    -- Seçileni aktifle
    UPDATE presentation.themes
    SET is_active = TRUE, updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION presentation.theme_activate(BIGINT) IS 'Activate a specific theme. Deactivates all other themes first to ensure single active theme.';
