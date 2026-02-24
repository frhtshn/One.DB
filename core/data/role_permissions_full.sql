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
-- 3. ADMIN (Level 90) — 92 API + 13 field(edit) = 105
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
    'company.permission-template.manage', 'tenant.permission-template.assign',
    -- segmentation (3)
    'tenant.player-category.manage', 'tenant.player-group.manage', 'tenant.player-classification.manage',
    -- bonus-request (6)
    'tenant.bonus-request.list', 'tenant.bonus-request.view', 'tenant.bonus-request.create',
    'tenant.bonus-request.review', 'tenant.bonus-request.assign', 'tenant.bonus-request-settings.manage',
    -- content (4)
    'tenant.content.manage', 'tenant.site-settings.manage',
    'tenant.operator-license.view', 'tenant.operator-license.manage',
    -- support (15)
    'tenant.support-ticket.list', 'tenant.support-ticket.view', 'tenant.support-ticket.create',
    'tenant.support-ticket.assign', 'tenant.support-ticket.manage',
    'tenant.support-player-note.list', 'tenant.support-player-note.manage',
    'tenant.support-representative.view', 'tenant.support-representative.manage',
    'tenant.support-agent.manage', 'tenant.support-category.manage',
    'tenant.support-tag.manage', 'tenant.support-canned-response.manage',
    'tenant.support-dashboard.view', 'tenant.support-welcome-call.manage',
    -- messaging (12)
    'messaging.draft.create', 'messaging.draft.read', 'messaging.draft.update', 'messaging.draft.delete',
    'messaging.draft.cancel', 'messaging.draft.unschedule', 'messaging.draft.publish', 'messaging.draft.recall',
    'messaging.send',
    'messaging.inbox.read', 'messaging.inbox.read-all', 'messaging.inbox.delete',
    -- notification templates (3)
    'platform.notification-template.view',
    'tenant.notification-template.manage', 'tenant.notification-template.view'
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
-- 4. COMPANYADMIN (Level 80) — 44 API + 13 field(edit) = 57
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
    -- content (1 — sadece lisans okuma)
    'tenant.operator-license.view',
    -- tenant.user (5)
    'tenant.user.list', 'tenant.user.view', 'tenant.user.create', 'tenant.user.edit', 'tenant.user.delete',
    -- RBAC (3)
    'tenant.user-role.assign', 'tenant.user-permission.grant', 'tenant.user-permission.deny',
    -- audit (2)
    'audit.list', 'audit.view',
    -- template (2)
    'company.permission-template.manage', 'tenant.permission-template.assign',
    -- bonus-request (6)
    'tenant.bonus-request.list', 'tenant.bonus-request.view', 'tenant.bonus-request.create',
    'tenant.bonus-request.review', 'tenant.bonus-request.assign', 'tenant.bonus-request-settings.manage',
    -- support (15)
    'tenant.support-ticket.list', 'tenant.support-ticket.view', 'tenant.support-ticket.create',
    'tenant.support-ticket.assign', 'tenant.support-ticket.manage',
    'tenant.support-player-note.list', 'tenant.support-player-note.manage',
    'tenant.support-representative.view', 'tenant.support-representative.manage',
    'tenant.support-agent.manage', 'tenant.support-category.manage',
    'tenant.support-tag.manage', 'tenant.support-canned-response.manage',
    'tenant.support-dashboard.view', 'tenant.support-welcome-call.manage',
    -- messaging inbox (3)
    'messaging.inbox.read', 'messaging.inbox.read-all', 'messaging.inbox.delete',
    -- notification templates (2)
    'tenant.notification-template.manage', 'tenant.notification-template.view'
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
-- 5. TENANTADMIN (Level 70) — 41 API + 13 field(view) = 54
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
    -- content (3 — site settings + içerik yönetimi + lisans okuma)
    'tenant.content.manage', 'tenant.site-settings.manage', 'tenant.operator-license.view',
    -- tenant.user (5)
    'tenant.user.list', 'tenant.user.view', 'tenant.user.create', 'tenant.user.edit', 'tenant.user.delete',
    -- RBAC (3)
    'tenant.user-role.assign', 'tenant.user-permission.grant', 'tenant.user-permission.deny',
    -- audit (2)
    'audit.list', 'audit.view',
    -- template (1)
    'tenant.permission-template.assign',
    -- segmentation (3)
    'tenant.player-category.manage', 'tenant.player-group.manage', 'tenant.player-classification.manage',
    -- bonus-request (6)
    'tenant.bonus-request.list', 'tenant.bonus-request.view', 'tenant.bonus-request.create',
    'tenant.bonus-request.review', 'tenant.bonus-request.assign', 'tenant.bonus-request-settings.manage',
    -- support (15)
    'tenant.support-ticket.list', 'tenant.support-ticket.view', 'tenant.support-ticket.create',
    'tenant.support-ticket.assign', 'tenant.support-ticket.manage',
    'tenant.support-player-note.list', 'tenant.support-player-note.manage',
    'tenant.support-representative.view', 'tenant.support-representative.manage',
    'tenant.support-agent.manage', 'tenant.support-category.manage',
    'tenant.support-tag.manage', 'tenant.support-canned-response.manage',
    'tenant.support-dashboard.view', 'tenant.support-welcome-call.manage',
    -- messaging inbox (3)
    'messaging.inbox.read', 'messaging.inbox.read-all', 'messaging.inbox.delete',
    -- notification templates (2)
    'tenant.notification-template.manage', 'tenant.notification-template.view'
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
-- 6. MODERATOR (Level 60) — 20 API + 13 field(view) = 33
-- ================================================================
-- Audit erisimi. Player/finance API endpoint'leri eklendikce genisleyecek.

INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'moderator'
  AND p.code IN (
    -- audit (2)
    'audit.list', 'audit.view',
    -- segmentation (1)
    'tenant.player-classification.manage',
    -- bonus-request (4 — review ve settings yok)
    'tenant.bonus-request.list', 'tenant.bonus-request.view', 'tenant.bonus-request.create',
    'tenant.bonus-request.assign',
    -- support (10 — config yok, rep.manage yok)
    'tenant.support-ticket.list', 'tenant.support-ticket.view', 'tenant.support-ticket.create',
    'tenant.support-ticket.assign', 'tenant.support-ticket.manage',
    'tenant.support-player-note.list', 'tenant.support-player-note.manage',
    'tenant.support-representative.view',
    'tenant.support-dashboard.view', 'tenant.support-welcome-call.manage',
    -- messaging inbox (3)
    'messaging.inbox.read', 'messaging.inbox.read-all', 'messaging.inbox.delete'
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
-- 7. EDITOR (Level 50) — 4 API + 13 field(mask) = 17
-- ================================================================
-- Presentation yonetimi. Game/bonus/content API endpoint'leri eklendikce genisleyecek.

INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'editor'
  AND p.code IN (
    -- tenant presentation (1)
    'tenant.presentation.manage',
    -- content (1 — içerik yönetimi, site-settings ve lisans YOK)
    'tenant.content.manage',
    -- messaging inbox (3)
    'messaging.inbox.read', 'messaging.inbox.read-all', 'messaging.inbox.delete'
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
-- 8. OPERATOR (Level 40) — 13 API + 13 field(mask) = 26
-- ================================================================
-- Bonus request list/view/create. Review ve settings yok.

INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'operator'
  AND p.code IN (
    -- bonus-request (3 — review, assign, settings yok)
    'tenant.bonus-request.list', 'tenant.bonus-request.view', 'tenant.bonus-request.create',
    -- support (7 — assign/manage/config yok)
    'tenant.support-ticket.list', 'tenant.support-ticket.view', 'tenant.support-ticket.create',
    'tenant.support-player-note.list', 'tenant.support-player-note.manage',
    'tenant.support-representative.view',
    'tenant.support-welcome-call.manage',
    -- messaging inbox (3)
    'messaging.inbox.read', 'messaging.inbox.read-all', 'messaging.inbox.delete'
  );

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
    RAISE NOTICE 'admin:        % (expected: 105 = 92 API + 13 field)', v_admin;
    RAISE NOTICE 'companyadmin: % (expected: 57 = 44 API + 13 field)', v_companyadmin;
    RAISE NOTICE 'tenantadmin:  % (expected: 54 = 41 API + 13 field)', v_tenantadmin;
    RAISE NOTICE 'moderator:    % (expected: 33 = 20 API + 13 field)', v_moderator;
    RAISE NOTICE 'editor:       % (expected: 17 = 4 API + 13 field)', v_editor;
    RAISE NOTICE 'operator:     % (expected: 26 = 13 API + 13 field)', v_operator;
    RAISE NOTICE 'user:         % (expected: 0)', v_user;
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'TOTAL:        % (expected: 292)', v_total;
    RAISE NOTICE '================================================';

    -- Strict validation
    IF v_superadmin != 0 THEN
        RAISE WARNING 'SuperAdmin permission atamasi olmamali! Gercek: %', v_superadmin;
    END IF;
    IF v_admin != 105 THEN
        RAISE WARNING 'Admin permission sayisi hatali! Beklenen: 105, Gercek: %', v_admin;
    END IF;
    IF v_companyadmin != 57 THEN
        RAISE WARNING 'CompanyAdmin permission sayisi hatali! Beklenen: 57, Gercek: %', v_companyadmin;
    END IF;
    IF v_tenantadmin != 54 THEN
        RAISE WARNING 'TenantAdmin permission sayisi hatali! Beklenen: 54, Gercek: %', v_tenantadmin;
    END IF;
    IF v_moderator != 33 THEN
        RAISE WARNING 'Moderator permission sayisi hatali! Beklenen: 33, Gercek: %', v_moderator;
    END IF;
    IF v_editor != 17 THEN
        RAISE WARNING 'Editor permission sayisi hatali! Beklenen: 17, Gercek: %', v_editor;
    END IF;
    IF v_operator != 26 THEN
        RAISE WARNING 'Operator permission sayisi hatali! Beklenen: 26, Gercek: %', v_operator;
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
