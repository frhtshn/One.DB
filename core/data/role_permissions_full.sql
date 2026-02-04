-- ================================================================
-- NUCLEO PLATFORM - ROLE PERMISSIONS MAPPING
-- ================================================================
-- Role-Permission ilişkilendirme dosyası.
-- permissions_full.sql'den SONRA çalıştırılmalı.
-- ================================================================
-- Çalıştırma: psql -U postgres -d nucleo -f core/data/role_permissions_full.sql
-- ================================================================
-- DELETE + INSERT: Mevcut mappingleri temizler, yeniden oluşturur.
-- ================================================================

-- ================================================================
-- 1. MEVCUT MAPPINGLERI TEMİZLE
-- ================================================================
DELETE FROM security.role_permissions;

-- ================================================================
-- 2. SUPERADMIN: TÜM PERMISSIONS (168)
-- ================================================================
-- Level 100 - Platform owner, full access

INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'superadmin';

-- ================================================================
-- 3. ADMIN: company.* + tenant.* + catalog.* + audit.* + report.*
-- ================================================================
-- Level 90 - System administrator
-- Platform.* HARİÇ tüm yetkiler

INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'admin'
  AND p.category IN ('company', 'tenant', 'catalog', 'audit', 'report');

-- ================================================================
-- 4. COMPANYADMIN: tenant.* + audit.* + report.* (kısıtlı)
-- ================================================================
-- Level 80 - Company manager
-- Kendi company'sindeki tenant işlemleri

INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'companyadmin'
  AND (
    p.category IN ('tenant', 'audit')
    OR p.code IN (
      'report.dashboard.view',
      'report.player.view',
      'report.game.view',
      'report.financial.view'
    )
  );

-- ================================================================
-- 5. TENANTADMIN: tenant.user.* + tenant.settings.* + player.* (kısıtlı) + audit.*
-- ================================================================
-- Level 70 - Tenant manager
-- Kendi tenant'ındaki tüm operasyonlar

INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'tenantadmin'
  AND (
    -- Tenant user management
    p.code LIKE 'tenant.user.%'
    OR p.code = 'tenant.settings.edit'
    OR p.code = 'tenant.content.list'
    OR p.code = 'tenant.content.manage'
    -- Player management (full)
    OR p.category = 'player'
    -- Game management (view + settings)
    OR p.code IN ('game.list', 'game.view', 'game.settings.edit', 'game.category.list')
    -- Finance (view + approve)
    OR p.code IN (
      'finance.transaction.list', 'finance.deposit.list', 'finance.deposit.view',
      'finance.withdrawal.list', 'finance.withdrawal.view',
      'finance.deposit.approve', 'finance.deposit.reject',
      'finance.withdrawal.approve', 'finance.withdrawal.reject'
    )
    -- Bonus (view)
    OR p.code IN ('bonus.list', 'bonus.view', 'bonus.campaign.list', 'bonus.campaign.view')
    -- Audit (full)
    OR p.category = 'audit'
    -- Reports (view)
    OR p.code IN ('report.dashboard.view', 'report.player.view', 'report.game.view')
  );

-- ================================================================
-- 6. MODERATOR: player.* (edit) + finance.* (view) + audit.list/view
-- ================================================================
-- Level 60 - Content moderator, player editing

INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'moderator'
  AND (
    -- Player management (most permissions)
    p.code IN (
      'player.list', 'player.view', 'player.edit', 'player.tags.manage',
      'player.block', 'player.unblock', 'player.password.reset',
      'player.wallet.view', 'player.kyc.list', 'player.kyc.view',
      'player.kyc.approve', 'player.kyc.reject', 'player.kyc.request',
      'player.transaction.view', 'player.gaming.view',
      'player.bonus.view', 'player.rg.view', 'player.limits.view',
      'player.communication.view', 'player.communication.send',
      'player.audit.view', 'player.action.view'
    )
    -- Finance (view only)
    OR p.code IN (
      'finance.transaction.list', 'finance.deposit.list', 'finance.deposit.view',
      'finance.withdrawal.list', 'finance.withdrawal.view',
      'finance.adjustment.list'
    )
    -- Affiliate (view)
    OR p.code IN ('affiliate.list', 'affiliate.view', 'affiliate.players.view')
    -- Audit (view)
    OR p.code IN ('audit.list', 'audit.view')
    -- Reports (player only)
    OR p.code = 'report.player.view'
  );

-- ================================================================
-- 7. EDITOR: game.* + bonus.* + tenant.content.* + audit.list
-- ================================================================
-- Level 50 - Content editor, banner/slider/game management

INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'editor'
  AND (
    -- Game management (full except risk)
    p.code IN (
      'game.provider.list', 'game.provider.view',
      'game.list', 'game.view', 'game.enable', 'game.disable',
      'game.settings.edit', 'game.stats.view', 'game.order.manage',
      'game.category.list', 'game.category.manage', 'game.lobby.manage'
    )
    -- Bonus management (full)
    OR p.category = 'bonus'
    -- Tenant content
    OR p.code IN ('tenant.content.list', 'tenant.content.manage')
    -- Audit (list only)
    OR p.code = 'audit.list'
  );

-- ================================================================
-- 8. OPERATOR: player.list/view + player.kyc.* + audit.list
-- ================================================================
-- Level 40 - Customer service, player viewing and KYC

INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'operator'
  AND p.code IN (
    -- Player (view + KYC)
    'player.list', 'player.view',
    'player.wallet.view', 'player.transaction.view',
    'player.kyc.list', 'player.kyc.view', 'player.kyc.request',
    'player.bonus.view', 'player.gaming.view',
    'player.communication.view', 'player.communication.send',
    'player.audit.view',
    -- Tenant user list (for internal reference)
    'tenant.user.list',
    -- Audit
    'audit.list'
  );

-- ================================================================
-- 9. USER: audit.list (minimum permission)
-- ================================================================
-- Level 10 - Standard user, view only

INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'user'
  AND p.code IN ('audit.list');

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
    RAISE NOTICE 'superadmin:   % permissions', v_superadmin;
    RAISE NOTICE 'admin:        % permissions', v_admin;
    RAISE NOTICE 'companyadmin: % permissions', v_companyadmin;
    RAISE NOTICE 'tenantadmin:  % permissions', v_tenantadmin;
    RAISE NOTICE 'moderator:    % permissions', v_moderator;
    RAISE NOTICE 'editor:       % permissions', v_editor;
    RAISE NOTICE 'operator:     % permissions', v_operator;
    RAISE NOTICE 'user:         % permissions', v_user;
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'TOTAL:        % mappings', v_total;
    RAISE NOTICE '================================================';
END $$;

-- Summary query
SELECT r.code as role, r.level, COUNT(rp.permission_id) as permission_count
FROM security.roles r
LEFT JOIN security.role_permissions rp ON r.id = rp.role_id
GROUP BY r.code, r.level, r.id
ORDER BY r.level DESC;
