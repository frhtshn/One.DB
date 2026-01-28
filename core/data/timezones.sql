-- ============================================================================
-- TIMEZONE SEED DATA (Dynamic from pg_timezone_names)
-- Tüm dünyadaki timezone'ları veritabanı kataloğundan çeker.
-- ============================================================================

TRUNCATE TABLE catalog.timezones CASCADE;

INSERT INTO catalog.timezones (name, utc_offset, display_name)
SELECT
    name,
    -- Format: +03:00 or -05:00
    (CASE WHEN extract(epoch from utc_offset) >= 0 THEN '+' ELSE '-' END) ||
    LPAD(ABS(extract(hour from utc_offset))::text, 2, '0') || ':' ||
    LPAD(ABS(extract(minute from utc_offset))::text, 2, '0'),

    -- Format: (UTC+03:00) Europe/Istanbul
    '(UTC' ||
    (CASE WHEN extract(epoch from utc_offset) >= 0 THEN '+' ELSE '-' END) ||
    LPAD(ABS(extract(hour from utc_offset))::text, 2, '0') || ':' ||
    LPAD(ABS(extract(minute from utc_offset))::text, 2, '0') || ') ' || name

FROM pg_timezone_names
WHERE name NOT LIKE 'posix/%'
  AND name NOT LIKE 'SystemV/%'
  AND name NOT LIKE 'Etc/%'
  AND name NOT LIKE 'Mideast/%'
ORDER BY name
ON CONFLICT (name) DO NOTHING;
