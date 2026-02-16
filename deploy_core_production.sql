-- ============================================================================
-- NUCLEO PLATFORM - CORE PRODUCTION DEPLOYMENT
-- ============================================================================
-- Production environment full deployment script.
-- Combined: Core Schema + Production Seed Data
-- ============================================================================
-- Usage: psql -U postgres -d nucleo -f deploy_core_production.sql
-- ============================================================================
-- CONTENT:
-- 1. Core Deployment (schemas, tables, functions, triggers, constraints)
--    - Includes lookup data (Countries, Currencies, Timezones, Languages)
--    - Includes localization data
-- 2. Production Seed Data
--    - Overwrites generic Security/Company data with Production constraints
--    - Sets up Roles and the Nucleo Company with SuperAdmin user
-- 3. Permissions (UPSERT - 99 permissions)
-- 4. Role-Permission Mappings (role bazlı permission atamaları)
-- ============================================================================
-- WARNING: This script TRUNCATES critical tables (Users, Companies, Roles)!
-- Use only for initial setup or full reset of a PRODUCTION environment.
-- ============================================================================

-- ============================================================================
-- 1. CORE DEPLOYMENT
-- ============================================================================
-- Schemas, tables, functions, triggers, constraints, base reference data
-- Note: This will load default companies.sql and security_seed.sql,
-- but they will be overwritten by step 2.

\i deploy_core.sql

-- ============================================================================
-- 2. PRODUCTION SEED DATA
-- ============================================================================
-- Truncates Security and Tenant/Company tables.
-- Inserts defined Roles, Permissions, and the SuperAdmin user.

\i core/data/production_seed.sql

-- ============================================================================
-- 3. PERMISSIONS
-- ============================================================================
-- 168 permission tanımı (UPSERT - güvenli tekrar çalıştırılabilir)

\i core/data/permissions_full.sql

-- ============================================================================
-- 4. ROLE-PERMISSION MAPPINGS
-- ============================================================================
-- Her rol için permission atamaları (roles ve permissions'dan sonra çalışmalı)

\i core/data/role_permissions_full.sql

-- ============================================================================
-- DEPLOYMENT COMPLETE
-- ============================================================================
-- SuperAdmin User: superadmin@nucleo.io
-- Change the default password immediately!
-- ============================================================================
