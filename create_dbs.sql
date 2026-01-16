-- core database
SELECT
  'CREATE DATABASE core'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'core'
)
\gexec

-- tenant database
SELECT
  'CREATE DATABASE tenant'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'tenant'
)
\gexec
