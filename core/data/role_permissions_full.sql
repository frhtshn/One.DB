-- ================================================================
-- NUCLEO PLATFORM - ROLE PERMISSIONS MAPPING
-- ================================================================
-- Convention: PERMISSION_CONVENTION.md Section 10 (source of truth)
-- Role-Permission iliskilendirme dosyasi.
-- permissions_full.sql'den SONRA calistirilmalidir.
-- ================================================================
-- Calistirma: psql -U postgres -d nucleo -f core/data/role_permissions_full.sql
-- ================================================================
-- DELETE + INSERT: Mevcut mappingleri temizler, yeniden olusturur.
-- ================================================================

-- ================================================================
-- 1. MEVCUT MAPPINGLERI TEMIZLE
-- ================================================================
DELETE FROM security.role_permissions;

-- ================================================================
-- 2. SUPERADMIN (Level 100) — BYPASS
-- ================================================================
-- Permission atamasi YAPILMAZ. Kod tarafinda otomatik gecis:
-- PolicyEvaluator: if (context.IsSuperAdmin) return PolicyResult.Allow();
-- role_permissions tablosunda 0 satir.

-- ================================================================
-- 3. ADMIN (Level 90) — 53 API + 13 field(edit) = 66
-- ================================================================
-- Platform haric TUM scope'lara erisim. Tenant sub-entity yazma dahil.

INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'admin'
  AND p.code IN (
    -- company (7)
    'company.list', 'company.view', 'company.create', 'company.edit', 'company.delete',
    'company.password-policy.view', 'company.password-policy.edit',
    -- company.user (5)
    'company.user.list', 'company.user.view', 'company.user.create', 'company.user.edit', 'company.user.delete',
    -- tenant (14)
    'tenant.list', 'tenant.view', 'tenant.create', 'tenant.edit', 'tenant.delete',
    'tenant.setting.view', 'tenant.setting.edit',
    'tenant.currency.list', 'tenant.currency.edit',
    'tenant.cryptocurrency.list', 'tenant.cryptocurrency.edit',
    'tenant.language.list', 'tenant.language.edit',
    'tenant.presentation.manage',
    -- tenant.user (5)
    'tenant.user.list', 'tenant.user.view', 'tenant.user.create', 'tenant.user.edit', 'tenant.user.delete',
    -- RBAC (3)
    'tenant.user-role.assign', 'tenant.user-permission.grant', 'tenant.user-permission.deny',
    -- catalog (15)
    'catalog.provider.list', 'catalog.provider.view', 'catalog.provider.create',
    'catalog.provider.edit', 'catalog.provider.delete', 'catalog.provider.manage',
    'catalog.payment.list', 'catalog.payment.view', 'catalog.payment.manage',
    'catalog.currency.list', 'catalog.currency.manage',
    'catalog.uikit.list', 'catalog.uikit.manage',
    'catalog.compliance.list', 'catalog.compliance.manage',
    -- audit (2)
    'audit.list', 'audit.view',
    -- template (2)
    'company.permission-template.manage', 'tenant.permission-template.assign'
  );

-- ADMIN: Field protection (edit level — tam erisim, 13 alan)
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'admin'
  AND p.category = 'field'
  AND p.code LIKE 'field.%.edit';

-- ================================================================
-- 4. COMPANYADMIN (Level 80) — 18 API + 13 field(edit) = 31
-- ================================================================
-- Tenant okuma + sub-entity okuma + user yonetimi + RBAC + audit + template.
-- Tenant CRUD (create/edit/delete) YAPAMAZ. Sub-entity yazma YAPAMAZ.

INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'companyadmin'
  AND p.code IN (
    -- tenant okuma (2)
    'tenant.list', 'tenant.view',
    -- tenant sub-entity okuma (4)
    'tenant.setting.view',
    'tenant.currency.list',
    'tenant.cryptocurrency.list',
    'tenant.language.list',
    -- tenant.user (5)
    'tenant.user.list', 'tenant.user.view', 'tenant.user.create', 'tenant.user.edit', 'tenant.user.delete',
    -- RBAC (3)
    'tenant.user-role.assign', 'tenant.user-permission.grant', 'tenant.user-permission.deny',
    -- audit (2)
    'audit.list', 'audit.view',
    -- template (2)
    'company.permission-template.manage', 'tenant.permission-template.assign'
  );

-- COMPANYADMIN: Field protection (edit level — tam erisim, 13 alan)
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'companyadmin'
  AND p.category = 'field'
  AND p.code LIKE 'field.%.edit';

-- ================================================================
-- 5. TENANTADMIN (Level 70) — 12 API + 13 field(view) = 25
-- ================================================================
-- User yonetimi + RBAC + presentation + audit + template atama.
-- Tenant list/view YOK. Sub-entity okuma YOK.

INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'tenantadmin'
  AND p.code IN (
    -- tenant presentation (1)
    'tenant.presentation.manage',
    -- tenant.user (5)
    'tenant.user.list', 'tenant.user.view', 'tenant.user.create', 'tenant.user.edit', 'tenant.user.delete',
    -- RBAC (3)
    'tenant.user-role.assign', 'tenant.user-permission.grant', 'tenant.user-permission.deny',
    -- audit (2)
    'audit.list', 'audit.view',
    -- template (1)
    'tenant.permission-template.assign'
  );

-- TENANTADMIN: Field protection (view level — acik okuma, 13 alan)
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'tenantadmin'
  AND p.category = 'field'
  AND p.code LIKE 'field.%.view';

-- ================================================================
-- 6. MODERATOR (Level 60) — 2 API + 13 field(view) = 15
-- ================================================================
-- Audit erisimi. Player/finance API endpoint'leri eklendikce genisleyecek.

INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'moderator'
  AND p.code IN (
    -- audit (2)
    'audit.list', 'audit.view'
  );

-- MODERATOR: Field protection (view level — acik okuma, 13 alan)
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'moderator'
  AND p.category = 'field'
  AND p.code LIKE 'field.%.view';

-- ================================================================
-- 7. EDITOR (Level 50) — 1 API + 13 field(mask) = 14
-- ================================================================
-- Presentation yonetimi. Game/bonus/content API endpoint'leri eklendikce genisleyecek.

INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'editor'
  AND p.code IN (
    -- tenant presentation (1)
    'tenant.presentation.manage'
  );

-- EDITOR: Field protection (mask level — maskeli okuma, 13 alan)
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'editor'
  AND p.category = 'field'
  AND p.code LIKE 'field.%.mask';

-- ================================================================
-- 8. OPERATOR (Level 40) — 0 API + 13 field(mask) = 13
-- ================================================================
-- Player API endpoint'leri eklendikce genisleyecek.

-- OPERATOR: Field protection (mask level — maskeli okuma, 13 alan)
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'operator'
  AND p.category = 'field'
  AND p.code LIKE 'field.%.mask';

-- ================================================================
-- 9. USER (Level 10) — 0 permission
-- ================================================================
-- Minimum erisim. Sadece login olabilir.
-- role_permissions tablosunda 0 satir.

-- ================================================================
-- VALIDATION
-- ================================================================
DO $$
DECLARE
    v_total INT;
    v_superadmin INT;
    v_admin INT;
    v_companyadmin INT;
    v_tenantadmin INT;
    v_moderator INT;
    v_editor INT;
    v_operator INT;
    v_user INT;
BEGIN
    SELECT COUNT(*) INTO v_total FROM security.role_permissions;

    SELECT COUNT(*) INTO v_superadmin FROM security.role_permissions rp
    JOIN security.roles r ON rp.role_id = r.id WHERE r.code = 'superadmin';

    SELECT COUNT(*) INTO v_admin FROM security.role_permissions rp
    JOIN security.roles r ON rp.role_id = r.id WHERE r.code = 'admin';

    SELECT COUNT(*) INTO v_companyadmin FROM security.role_permissions rp
    JOIN security.roles r ON rp.role_id = r.id WHERE r.code = 'companyadmin';

    SELECT COUNT(*) INTO v_tenantadmin FROM security.role_permissions rp
    JOIN security.roles r ON rp.role_id = r.id WHERE r.code = 'tenantadmin';

    SELECT COUNT(*) INTO v_moderator FROM security.role_permissions rp
    JOIN security.roles r ON rp.role_id = r.id WHERE r.code = 'moderator';

    SELECT COUNT(*) INTO v_editor FROM security.role_permissions rp
    JOIN security.roles r ON rp.role_id = r.id WHERE r.code = 'editor';

    SELECT COUNT(*) INTO v_operator FROM security.role_permissions rp
    JOIN security.roles r ON rp.role_id = r.id WHERE r.code = 'operator';

    SELECT COUNT(*) INTO v_user FROM security.role_permissions rp
    JOIN security.roles r ON rp.role_id = r.id WHERE r.code = 'user';

    RAISE NOTICE '================================================';
    RAISE NOTICE 'ROLE-PERMISSION MAPPING COMPLETED';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'superadmin:   % (expected: 0 — bypass)', v_superadmin;
    RAISE NOTICE 'admin:        % (expected: 66 = 53 API + 13 field)', v_admin;
    RAISE NOTICE 'companyadmin: % (expected: 31 = 18 API + 13 field)', v_companyadmin;
    RAISE NOTICE 'tenantadmin:  % (expected: 25 = 12 API + 13 field)', v_tenantadmin;
    RAISE NOTICE 'moderator:    % (expected: 15 = 2 API + 13 field)', v_moderator;
    RAISE NOTICE 'editor:       % (expected: 14 = 1 API + 13 field)', v_editor;
    RAISE NOTICE 'operator:     % (expected: 13 = 0 API + 13 field)', v_operator;
    RAISE NOTICE 'user:         % (expected: 0)', v_user;
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'TOTAL:        % (expected: 164)', v_total;
    RAISE NOTICE '================================================';

    -- Strict validation
    IF v_superadmin != 0 THEN
        RAISE WARNING 'SuperAdmin permission atamasi olmamali! Gercek: %', v_superadmin;
    END IF;
    IF v_admin != 66 THEN
        RAISE WARNING 'Admin permission sayisi hatali! Beklenen: 66, Gercek: %', v_admin;
    END IF;
    IF v_companyadmin != 31 THEN
        RAISE WARNING 'CompanyAdmin permission sayisi hatali! Beklenen: 31, Gercek: %', v_companyadmin;
    END IF;
    IF v_tenantadmin != 25 THEN
        RAISE WARNING 'TenantAdmin permission sayisi hatali! Beklenen: 25, Gercek: %', v_tenantadmin;
    END IF;
    IF v_moderator != 15 THEN
        RAISE WARNING 'Moderator permission sayisi hatali! Beklenen: 15, Gercek: %', v_moderator;
    END IF;
    IF v_editor != 14 THEN
        RAISE WARNING 'Editor permission sayisi hatali! Beklenen: 14, Gercek: %', v_editor;
    END IF;
    IF v_operator != 13 THEN
        RAISE WARNING 'Operator permission sayisi hatali! Beklenen: 13, Gercek: %', v_operator;
    END IF;
    IF v_user != 0 THEN
        RAISE WARNING 'User permission atamasi olmamali! Gercek: %', v_user;
    END IF;
END $$;

-- Summary query
SELECT r.code as role, r.level, COUNT(rp.permission_id) as permission_count
FROM security.roles r
LEFT JOIN security.role_permissions rp ON r.id = rp.role_id
GROUP BY r.code, r.level, r.id
ORDER BY r.level DESC;
