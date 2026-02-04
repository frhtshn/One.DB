-- ============================================================================
-- NUCLEO PLATFORM - CORE STAGING DEPLOYMENT
-- ============================================================================
-- Staging/Development ortamı için tam deployment.
-- Tek dosyada: Core + Staging Seed verileri
-- ============================================================================
-- Çalıştırma: psql -U postgres -d nucleo -f deploy_core_staging.sql
-- ============================================================================
-- İÇERİK:
-- 1. Core Deployment (schemas, tables, functions, triggers, constraints)
-- 2. Menu Localization (key + values)
-- 3. Staging Seed Data (companies, tenants, users, menus)
-- 4. Permissions (UPSERT - 168 permissions)
-- 5. Role-Permission Mappings (role bazlı permission atamaları)
-- ============================================================================
-- UYARI: Bu dosya TÜM verileri siler ve yeniden oluşturur!
-- SADECE staging/dev ortamlarında kullanın - PRODUCTION'DA KULLANMAYIN!
-- ============================================================================

-- ============================================================================
-- 1. CORE DEPLOYMENT
-- ============================================================================
-- Schemas, tables, functions, triggers, constraints, base reference data

\i deploy_core.sql

-- ============================================================================
-- 2. MENU LOCALIZATION
-- ============================================================================
-- Menu localization key'leri ve çevirileri
-- staging_seed.sql'den ÖNCE çalıştırılmalı (menüler localization'a bağlı)

\i core/data/staging_seed_menu_localization.sql

-- ============================================================================
-- 3. STAGING SEED DATA
-- ============================================================================
-- Test şirketleri, tenant'lar, kullanıcılar ve menü yapısı

\i core/data/staging_seed.sql

-- ============================================================================
-- 4. PERMISSIONS
-- ============================================================================
-- 168 permission tanımı (UPSERT - güvenli tekrar çalıştırılabilir)

\i core/data/permissions_full.sql

-- ============================================================================
-- 5. ROLE-PERMISSION MAPPINGS
-- ============================================================================
-- Her rol için permission atamaları (roles ve permissions'dan sonra çalışmalı)

\i core/data/role_permissions_full.sql

-- ============================================================================
-- DEPLOYMENT TAMAMLANDI
-- ============================================================================
-- Test kullanıcıları:
-- | Email                  | Role                    | Password |
-- |------------------------|-------------------------|----------|
-- | superadmin@nucleo.io   | superadmin              | deneme   |
-- | admin@nucleo.io        | admin                   | deneme   |
-- | eurobet@nucleo.io      | companyadmin            | deneme   |
-- | cyprus@nucleo.io       | companyadmin            | deneme   |
-- | turkbet@nucleo.io      | companyadmin            | deneme   |
-- | eurobet.eu@nucleo.io   | tenantadmin@eurobet_eu  | deneme   |
-- | cyprus.admin@nucleo.io | tenantadmin@cyprus_main | deneme   |
-- | turkbet.admin@nucleo.io| tenantadmin@turkbet_tr  | deneme   |
-- | turkbet.mod@nucleo.io  | moderator@turkbet_tr    | deneme   |
-- | turkbet.edit@nucleo.io | editor@turkbet_tr       | deneme   |
-- | turkbet.op@nucleo.io   | operator@turkbet_tr     | deneme   |
-- | eurobet.user@nucleo.io | user@eurobet_eu         | deneme   |
-- ============================================================================
