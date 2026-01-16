SELECT
  'CREATE DATABASE core'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'core'
)
\gexec
