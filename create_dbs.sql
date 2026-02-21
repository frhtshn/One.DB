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

COMMENT ON DATABASE core IS 'Main core database: Companies, users and central configuration';

-- Core log veritabanı: Sistem genelinde merkezi log kayıtları
SELECT
  'CREATE DATABASE core_log'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'core_log'
)
\gexec

COMMENT ON DATABASE core_log IS 'Core log database: System-wide central log records';

-- Core audit veritabanı: Merkezi denetim ve uyumluluk kayıtları
SELECT
  'CREATE DATABASE core_audit'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'core_audit'
)
\gexec

COMMENT ON DATABASE core_audit IS 'Core audit database: Central audit and compliance records';

-- Core rapor veritabanı: Merkezi raporlama ve analitik verileri
SELECT
  'CREATE DATABASE core_report'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'core_report'
)
\gexec
COMMENT ON DATABASE core_report IS 'Central reporting and analytics data';

-- Finans veritabanı: Ödeme işlemleri, para transferleri ve finansal veriler
SELECT
  'CREATE DATABASE finance'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'finance'
)
\gexec
COMMENT ON DATABASE finance IS 'Financial operations, money transfers and financial data';

-- Finans Log veritabanı: Finansal işlem logları ve tarihçesi
SELECT
  'CREATE DATABASE finance_log'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'finance_log'
)
\gexec
COMMENT ON DATABASE finance_log IS 'Financial transaction logs and history';

-- Game veritabanı: Oyun katalogları, provider entegrasyonları ve oyun verileri
SELECT
  'CREATE DATABASE game'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'game'
)
\gexec
COMMENT ON DATABASE game IS 'Game catalogs, provider integrations and game data';

-- Game Log veritabanı: Oyun tur logları ve detaylı oyun geçmişi
SELECT
  'CREATE DATABASE game_log'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'game_log'
)
\gexec
COMMENT ON DATABASE game_log IS 'Game round logs and detailed game history';

-- Bonus veritabanı: Bonus, promosyon ve kampanya yönetimi (Plugin)
SELECT
  'CREATE DATABASE bonus'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'bonus'
)
\gexec
COMMENT ON DATABASE bonus IS 'Bonus, promotion and campaign management (Plugin)';


-- ============================================================
-- INFRASTRUCTURE VERİTABANLARI
-- ============================================================

-- Orleans veritabanı: Orleans Clustering, Persistence ve Reminders (ADO.NET provider)
SELECT
  'CREATE DATABASE orleans'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'orleans'
)
\gexec
COMMENT ON DATABASE orleans IS 'Orleans clustering, persistence and reminders (ADO.NET PostgreSQL provider)';


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

COMMENT ON DATABASE tenant IS 'Base tenant database template: Players, wallets and tenant-specific data';

-- Tenant log veritabanı: Kiracıya özel aktivite ve işlem logları
SELECT
  'CREATE DATABASE tenant_log'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'tenant_log'
)
\gexec
COMMENT ON DATABASE tenant_log IS 'Tenant-specific activity and transaction logs';

-- Tenant audit veritabanı: Kiracıya özel denetim logları
SELECT
  'CREATE DATABASE tenant_audit'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'tenant_audit'
)
\gexec
COMMENT ON DATABASE tenant_audit IS 'Tenant-specific audit logs';

-- Tenant rapor veritabanı: Kiracıya özel raporlar ve istatistikler
SELECT
  'CREATE DATABASE tenant_report'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'tenant_report'
)
\gexec
COMMENT ON DATABASE tenant_report IS 'Tenant-specific reports and statistics';

-- Tenant Affiliate veritabanı: Kiracıya özel affiliate plugin veritabanı
-- Her yeni tenant için 'tenant_affiliate_<CODE>' formatında oluşturulur
SELECT
  'CREATE DATABASE tenant_affiliate'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_database WHERE datname = 'tenant_affiliate'
)
\gexec
COMMENT ON DATABASE tenant_affiliate IS 'Tenant-specific affiliate plugin database';
