-- ================================================================
-- TIMEZONE_LIST: Timezone listesi (Combobox için)
-- catalog.timezones tablosundan veri döner.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.timezone_list();

CREATE OR REPLACE FUNCTION catalog.timezone_list()
RETURNS TABLE(name VARCHAR, utc_offset VARCHAR, display_name VARCHAR)
LANGUAGE sql
STABLE
AS $$
    SELECT
        name,
        utc_offset,
        display_name
    FROM catalog.timezones
    WHERE is_active = TRUE
    ORDER BY utc_offset DESC, name;
$$;

COMMENT ON FUNCTION catalog.timezone_list() IS 'Returns list of active timezones from catalog table.';
