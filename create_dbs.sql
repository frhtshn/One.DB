-- ============================================================
-- NUCLEO VERİTABANI OLUŞTURMA SCRIPTI
-- ============================================================
-- Bu script, Nucleo sisteminin ihtiyaç duyduğu tüm veritabanlarını
-- oluşturur. Veritabanları zaten mevcutsa tekrar oluşturulmaz.
-- ============================================================

-- ============================================================
-- CORE VERİTABANLARI (Merkezi/Paylaşılan)
-- ============================================================

-- Ana core veritabanı: Şirketler, kullanıcılar ve merkezi yapılandırma
SELECT
  'CREATE DATABASE core'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'core'
)
\gexec

-- Core log veritabanı: Sistem genelinde merkezi log kayıtları
-- SELECT
--   'CREATE DATABASE core_log'
-- WHERE NOT EXISTS (
--   SELECT 1 FROM pg_database WHERE datname = 'core_log'
-- )
-- \gexec

-- Core rapor veritabanı: Merkezi raporlama ve analitik verileri
-- SELECT
--   'CREATE DATABASE core_report'
-- WHERE NOT EXISTS (
--   SELECT 1 FROM pg_database WHERE datname = 'core_report'
-- )
-- \gexec

-- Finans veritabanı: Ödeme işlemleri, para transferleri ve finansal veriler
-- SELECT
--   'CREATE DATABASE finance'
-- WHERE NOT EXISTS (
--   SELECT 1 FROM pg_database WHERE datname = 'finance'
-- )
-- \gexec

-- Game veritabanı: Oyun katalogları, provider entegrasyonları ve oyun verileri
-- SELECT
--   'CREATE DATABASE game'
-- WHERE NOT EXISTS (
--   SELECT 1 FROM pg_database WHERE datname = 'game'
-- )
-- \gexec


-- ============================================================
-- TENANT VERİTABANLARI (Kiracıya Özel)
-- ============================================================

-- Ana tenant veritabanı: Oyuncular, cüzdanlar ve kiracıya özel veriler
-- Bu veritabanı her yeni tenant için klonlanarak kullanılır
SELECT
  'CREATE DATABASE tenant'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'tenant'
)
\gexec

-- Tenant log veritabanı: Kiracıya özel aktivite ve işlem logları
-- SELECT
--   'CREATE DATABASE tenant_log'
-- WHERE NOT EXISTS (
--   SELECT 1 FROM pg_database WHERE datname = 'tenant_log'
-- )
-- \gexec

-- Tenant rapor veritabanı: Kiracıya özel raporlar ve istatistikler
-- SELECT
--   'CREATE DATABASE tenant_report'
-- WHERE NOT EXISTS (
--   SELECT 1 FROM pg_database WHERE datname = 'tenant_report'
-- )
-- \gexec
