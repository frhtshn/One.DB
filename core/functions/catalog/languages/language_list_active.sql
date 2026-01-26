-- ============================================================================
-- LANGUAGE FUNCTIONS (Dil CRUD)
-- ============================================================================

DROP FUNCTION IF EXISTS catalog.language_list_active();

-- Aktif dilleri listeler (public API icin)
CREATE OR REPLACE FUNCTION catalog.language_list_active()
RETURNS TABLE(language_code CHAR(2), language_name VARCHAR(50))
LANGUAGE sql
STABLE
AS $$
    SELECT l.language_code, l.language_name
    FROM catalog.languages l
    WHERE l.is_active = TRUE
    ORDER BY l.language_code;
$$;

COMMENT ON FUNCTION catalog.language_list_active IS 'Lists all active languages (for public API usage)';
