-- ============================================================
-- SORTIS ONE VERİTABANI OLUŞTURMA SCRIPTI
-- ============================================================
-- Bu script, Sortis One sisteminin ihtiyaç duyduğu tüm veritabanlarını
-- oluşturur. Veritabanları zaten mevcutsa tekrar oluşturulmaz.
-- ============================================================

-- ============================================================
-- CORE VERİTABANLARI (Merkezi/Paylaşılan)
-- ============================================================

-- Ana core veritabanı: Birleşik — şirketler, kullanıcılar, yapılandırma + log + audit + report
SELECT
  'CREATE DATABASE core'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'core'
)
\gexec

COMMENT ON DATABASE core IS 'Unified core database: Companies, users, central configuration, logs, audit, reports';

-- Finans veritabanı: Birleşik — ödeme kataloğu + provider API logları
SELECT
  'CREATE DATABASE finance'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'finance'
)
\gexec
COMMENT ON DATABASE finance IS 'Unified finance database: Payment catalog + provider API logs';

-- Game veritabanı: Birleşik — oyun kataloğu + provider API logları
SELECT
  'CREATE DATABASE game'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'game'
)
\gexec
COMMENT ON DATABASE game IS 'Unified game database: Game catalog + provider API logs';

-- Bonus veritabanı: Bonus, promosyon ve kampanya yönetimi (Plugin)
SELECT
  'CREATE DATABASE bonus'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'bonus'
)
\gexec
COMMENT ON DATABASE bonus IS 'Bonus, promotion and campaign management (Plugin)';

-- Analytics veritabanı: Risk analiz, oyuncu skorlama ve fraud tespiti
SELECT
  'CREATE DATABASE analytics'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'analytics'
)
\gexec
COMMENT ON DATABASE analytics IS 'Risk analytics, player scoring and fraud detection data';


-- ============================================================
-- CLIENT VERİTABANLARI (Client'a Özel)
-- ============================================================

-- Ana client veritabanı: Oyuncular, cüzdanlar ve client'a özel tüm veriler
-- Tek DB: core business + log + audit + report + affiliate schema'ları içerir
-- Bu veritabanı her yeni client için klonlanarak kullanılır
SELECT
  'CREATE DATABASE client'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'client'
)
\gexec

COMMENT ON DATABASE client IS 'Unified client database template: Players, wallets, logs, audit, reports, affiliate - all in one DB with 30 schemas';
