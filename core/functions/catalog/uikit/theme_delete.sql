-- ================================================================
-- THEME_DELETE: Tema siler
-- Tenant tarafından kullanılıyorsa silme engellenir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.theme_delete(INT);

CREATE OR REPLACE FUNCTION catalog.theme_delete(
    p_id INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.theme.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.themes t WHERE t.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.theme.not-found';
    END IF;

    -- NOT: Tenant kullanım kontrolü core.tenant_settings veya benzeri tablo varsa eklenebilir
    -- IF EXISTS(SELECT 1 FROM core.tenant_settings ts WHERE ts.theme_id = p_id) THEN
    --     RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.theme.in-use';
    -- END IF;

    -- Sil
    DELETE FROM catalog.themes WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.theme_delete IS 'Deletes a theme.';
