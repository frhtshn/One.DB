-- ============================================================================
-- SORTIS ONE - CORE STAGING DEPLOYMENT
-- ============================================================================
-- Staging/Development ortamı için tam deployment.
-- Tek dosyada: Core + Seed verileri
-- ============================================================================
-- Çalıştırma: psql -U postgres -d core -f deploy_core_staging.sql
-- ============================================================================
-- İÇERİK:
-- 1. Core Deployment (schemas, tables, functions, triggers, constraints)
-- 2. Menu Localization (key + values)
-- 3. Test Seed Data (companies, clients, users, settings, compliance)
-- 4. Permissions (UPSERT)
-- 5. Role-Permission Mappings (role bazlı permission atamaları)
-- 6. Presentation Seed (menu groups, menus, submenus, pages, tabs, contexts)
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
-- Diğer seed dosyalarından ÖNCE çalıştırılmalı (menüler localization'a bağlı)

\i core/data/staging_seed_menu_localization.sql

-- Frontend Content & Security Policy localization keys (seed_presentation'dan ÖNCE)
\i core/data/seed_menu_localization_content.sql

-- ============================================================================
-- 3. TEST SEED DATA
-- ============================================================================
-- Test şirketleri, client'lar, kullanıcılar, ayarlar, compliance

\i core/data/staging_seed.sql

-- ============================================================================
-- 4. PERMISSIONS
-- ============================================================================
-- Permission tanımları (UPSERT - güvenli tekrar çalıştırılabilir)

\i core/data/permissions_full.sql

-- ============================================================================
-- 5. ROLE-PERMISSION MAPPINGS
-- ============================================================================
-- Her rol için permission atamaları (roles ve permissions'dan sonra çalışmalı)

\i core/data/role_permissions_full.sql

-- ============================================================================
-- 5b. NOTIFICATION TEMPLATES SEED
-- ============================================================================
-- Platform bildirim şablonları (messaging tabloları ve constraints'den sonra)

\i core/data/notification_templates_seed.sql

-- ============================================================================
-- 6. PRESENTATION SEED
-- ============================================================================
-- Menu yapısı (localization + permissions'a depend — en son çalışmalı)

\i core/data/seed_presentation.sql

-- ============================================================================
-- DEPLOYMENT TAMAMLANDI
-- ============================================================================
-- Test kullanıcıları:
-- | Email                  | Role                    | Password |
-- |------------------------|-------------------------|----------|
-- | superadmin@sortisgaming.com   | superadmin              | deneme   |
-- | admin@sortisgaming.com        | admin                   | deneme   |
-- | eurobet@sortisgaming.com      | companyadmin            | deneme   |
-- | cyprus@sortisgaming.com       | companyadmin            | deneme   |
-- | turkbet@sortisgaming.com      | companyadmin            | deneme   |
-- | eurobet.eu@sortisgaming.com   | clientadmin@eurobet_eu  | deneme   |
-- | cyprus.admin@sortisgaming.com | clientadmin@cyprus_main | deneme   |
-- | turkbet.admin@sortisgaming.com| clientadmin@turkbet_tr  | deneme   |
-- | turkbet.mod@sortisgaming.com  | moderator@turkbet_tr    | deneme   |
-- | turkbet.edit@sortisgaming.com | editor@turkbet_tr       | deneme   |
-- | turkbet.op@sortisgaming.com   | operator@turkbet_tr     | deneme   |
-- | eurobet.user@sortisgaming.com | user@eurobet_eu         | deneme   |
-- ============================================================================
