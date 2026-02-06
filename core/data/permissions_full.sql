-- ================================================================
-- NUCLEO PLATFORM - MASTER PERMISSIONS SEED
-- ================================================================
-- Tüm BO menü yapısı için MASTER permission dosyası.
-- Bu dosya tek kaynak (single source of truth) olarak kullanılmalıdır.
-- ================================================================
-- Çalıştırma: psql -U postgres -d nucleo -f core/data/permissions_full.sql
-- ================================================================
-- UPSERT: ON CONFLICT kullanır, sıralama önemli değil.
-- Mevcut kayıtları günceller, yenilerini ekler.
-- ================================================================

-- ================================================================
-- PERMISSIONS - FULL LIST (UPSERT)
-- ================================================================
-- Toplam: 168 permission
-- Kategoriler:
--   platform (6), company (13), tenant (21), catalog (9),
--   player (32), game (16), finance (21), bonus (22),
--   affiliate (12), report (7), audit (9)
-- ================================================================

INSERT INTO security.permissions (code, name, description, category, status) VALUES

-- ================================================================
-- PLATFORM SCOPE (6) - SuperAdmin only
-- ================================================================
('platform.menu.manage', 'Menu Management', 'Menu/Submenu/Page/Tab/Context CRUD operations', 'platform', 1),
('platform.permission.manage', 'Permission Management', 'Define and edit permissions', 'platform', 1),
('platform.role.manage', 'Role Management', 'Define and edit roles', 'platform', 1),
('platform.system.settings', 'System Settings', 'Platform global settings management', 'platform', 1),
('platform.logs.view', 'View System Logs', 'View system and security logs', 'platform', 1),
('platform.health.view', 'Health Check', 'System health and gateway status monitoring', 'platform', 1),

-- ================================================================
-- COMPANY SCOPE (13) - Admin + SuperAdmin
-- ================================================================
('company.list', 'Company List', 'List all companies', 'company', 1),
('company.view', 'View Company', 'View company details', 'company', 1),
('company.create', 'Create Company', 'Create new company', 'company', 1),
('company.edit', 'Edit Company', 'Edit company information', 'company', 1),
('company.delete', 'Delete Company', 'Delete company (soft delete)', 'company', 1),
('company.user.list', 'Company User List', 'List company users', 'company', 1),
('company.user.create', 'Create Company User', 'Add user to company', 'company', 1),
('company.user.edit', 'Edit Company User', 'Edit company user', 'company', 1),
('company.user.view', 'View Company User', 'View company user details', 'company', 1),
('company.tenant.create', 'Create Tenant', 'Create new tenant under company', 'company', 1),
('company.tenant.edit', 'Edit Tenant', 'Edit tenant information', 'company', 1),
('company.billing.view', 'View Company Billing', 'View invoices, contracts, commission rates', 'company', 1),
('company.limits.view', 'View Company Limits', 'View risk profile and limits', 'company', 1),

-- ================================================================
-- TENANT SCOPE (21) - CompanyAdmin + Admin + SuperAdmin
-- ================================================================
('tenant.list', 'Tenant List', 'List tenants (filtered by company)', 'tenant', 1),
('tenant.view', 'View Tenant', 'View tenant details', 'tenant', 1),
('tenant.edit', 'Edit Tenant', 'Edit tenant information', 'tenant', 1),
('tenant.user.list', 'Tenant User List', 'List tenant users', 'tenant', 1),
('tenant.user.view', 'View Tenant User', 'View tenant user details', 'tenant', 1),
('tenant.user.create', 'Create Tenant User', 'Add user to tenant', 'tenant', 1),
('tenant.user.edit', 'Edit Tenant User', 'Edit tenant user', 'tenant', 1),
('tenant.user.delete', 'Delete Tenant User', 'Delete tenant user (soft delete)', 'tenant', 1),
('tenant.user.role.assign', 'Assign Tenant Role', 'Assign role to tenant user', 'tenant', 1),
('tenant.user.permission.grant', 'Grant Permission', 'Grant permission override to user', 'tenant', 1),
('tenant.user.permission.deny', 'Deny Permission', 'Deny permission override from user', 'tenant', 1),
('tenant.settings.edit', 'Edit Tenant Settings', 'Edit tenant configuration settings', 'tenant', 1),
('tenant.currency.list', 'Tenant Currency List', 'View tenant currencies', 'tenant', 1),
('tenant.currency.manage', 'Manage Tenant Currencies', 'Add/remove tenant currencies', 'tenant', 1),
('tenant.language.list', 'Tenant Language List', 'View tenant languages', 'tenant', 1),
('tenant.language.manage', 'Manage Tenant Languages', 'Add/remove tenant languages', 'tenant', 1),
('tenant.compliance.view', 'View Tenant Compliance', 'View jurisdiction and KYC settings', 'tenant', 1),
('tenant.integration.view', 'View Integrations', 'View callback URLs, webhooks, IP whitelist', 'tenant', 1),
('tenant.integration.manage', 'Manage Integrations', 'Edit callback URLs, webhooks, IP whitelist', 'tenant', 1),
('tenant.content.list', 'Tenant Content List', 'View CMS, sliders, popups, FAQ', 'tenant', 1),
('tenant.content.manage', 'Manage Tenant Content', 'Edit CMS, sliders, popups, FAQ', 'tenant', 1),
('tenant.presentation.manage', 'Manage Presentation', 'Manage tenant navigation, themes and layouts', 'tenant', 1),

-- ================================================================
-- CATALOG SCOPE (9) - SuperAdmin + Platform Admin
-- ================================================================
('catalog.provider.list', 'Provider List', 'List providers and provider types', 'catalog', 1),
('catalog.provider.manage', 'Provider Management', 'Provider CRUD operations', 'catalog', 1),
('catalog.payment.list', 'Payment Method List', 'List payment methods', 'catalog', 1),
('catalog.payment.manage', 'Payment Method Management', 'Payment method CRUD operations', 'catalog', 1),
('catalog.compliance.list', 'Compliance List', 'List jurisdictions, KYC policies', 'catalog', 1),
('catalog.compliance.manage', 'Compliance Management', 'Jurisdiction/KYC policy CRUD operations', 'catalog', 1),
('catalog.uikit.list', 'UIKit List', 'List themes, widgets, nav templates', 'catalog', 1),
('catalog.uikit.manage', 'UIKit Management', 'Theme/Widget/Navigation CRUD operations', 'catalog', 1),
('catalog.reference.list', 'Reference Data List', 'List countries, currencies, languages, timezones', 'catalog', 1),

-- ================================================================
-- PLAYER SCOPE (32) - Operator+
-- ================================================================
-- Player Management
('player.list', 'Player List', 'List and search players', 'player', 1),
('player.view', 'View Player', 'View player profile and details', 'player', 1),
('player.create', 'Create Player', 'Create new player account', 'player', 1),
('player.edit', 'Edit Player', 'Edit player profile information', 'player', 1),
('player.tags.manage', 'Manage Player Tags', 'Add/remove player tags and categories', 'player', 1),

-- Player Actions
('player.block', 'Block Player', 'Block player account', 'player', 1),
('player.unblock', 'Unblock Player', 'Unblock player account', 'player', 1),
('player.password.reset', 'Reset Player Password', 'Reset player password', 'player', 1),
('player.force.logout', 'Force Logout', 'Force player logout from all sessions', 'player', 1),
('player.action.view', 'View Player Actions', 'View block/password reset history', 'player', 1),

-- Player Wallet
('player.wallet.view', 'View Player Wallet', 'View wallet balances and transactions', 'player', 1),
('player.wallet.adjust', 'Adjust Player Wallet', 'Manual wallet credit/debit', 'player', 1),

-- Player KYC
('player.kyc.list', 'KYC Queue List', 'View KYC pending/review queue', 'player', 1),
('player.kyc.view', 'View Player KYC', 'View KYC status and documents', 'player', 1),
('player.kyc.approve', 'Approve KYC', 'Approve KYC documents', 'player', 1),
('player.kyc.reject', 'Reject KYC', 'Reject KYC documents', 'player', 1),
('player.kyc.request', 'Request KYC Document', 'Request additional documents from player', 'player', 1),

-- Player Transactions & Gaming
('player.transaction.view', 'View Player Transactions', 'View deposit/withdrawal/adjustment history', 'player', 1),
('player.gaming.view', 'View Player Gaming', 'View game history, sessions, favorites', 'player', 1),

-- Player Bonuses
('player.bonus.view', 'View Player Bonuses', 'View active bonuses and history', 'player', 1),
('player.bonus.award', 'Award Bonus', 'Award bonus to player', 'player', 1),
('player.bonus.cancel', 'Cancel Bonus', 'Cancel active bonus', 'player', 1),

-- Responsible Gaming
('player.rg.view', 'View Responsible Gaming', 'View player limits and exclusion status', 'player', 1),
('player.limits.view', 'View Player Limits', 'View deposit/loss/wager/session limits', 'player', 1),
('player.limits.edit', 'Edit Player Limits', 'Edit player limits', 'player', 1),
('player.exclusion.view', 'View Self-Exclusion', 'View self-exclusion status', 'player', 1),
('player.exclusion.manage', 'Manage Self-Exclusion', 'Set/remove self-exclusion', 'player', 1),
('player.cooloff.view', 'View Cooling Off', 'View cooling off status', 'player', 1),
('player.cooloff.manage', 'Manage Cooling Off', 'Set/remove cooling off period', 'player', 1),

-- Player Communication & Audit
('player.communication.view', 'View Player Messages', 'View message history', 'player', 1),
('player.communication.send', 'Send Player Message', 'Send message to player', 'player', 1),
('player.audit.view', 'View Player Audit', 'View login/action/IP/device history', 'player', 1),

-- ================================================================
-- GAME SCOPE (16) - Editor+
-- ================================================================
-- Game Providers
('game.provider.list', 'Game Provider List', 'List game providers', 'game', 1),
('game.provider.view', 'View Game Provider', 'View provider details', 'game', 1),
('game.provider.settings', 'Provider Settings', 'Edit provider configuration', 'game', 1),
('game.provider.logs', 'Provider Logs', 'View provider API logs', 'game', 1),

-- Games
('game.list', 'Game List', 'List all games', 'game', 1),
('game.view', 'View Game', 'View game details', 'game', 1),
('game.enable', 'Enable Game', 'Enable game for tenant', 'game', 1),
('game.disable', 'Disable Game', 'Disable game for tenant', 'game', 1),
('game.settings.edit', 'Edit Game Settings', 'Edit RTP override, bet limits', 'game', 1),
('game.stats.view', 'View Game Stats', 'View game statistics', 'game', 1),
('game.order.manage', 'Manage Game Order', 'Change game display order', 'game', 1),

-- Categories & Lobby
('game.category.list', 'Game Category List', 'List game categories', 'game', 1),
('game.category.manage', 'Manage Game Categories', 'Create/edit game categories', 'game', 1),
('game.lobby.manage', 'Manage Game Lobby', 'Featured games, category ordering', 'game', 1),

-- Risk
('game.risk.view', 'View Game Risk', 'View RTP profiles and risk config', 'game', 1),
('game.risk.manage', 'Manage Game Risk', 'Edit RTP profiles and risk config', 'game', 1),

-- ================================================================
-- FINANCE SCOPE (21) - Moderator+ / Finance Role
-- ================================================================
-- Transactions
('finance.transaction.list', 'Transaction List', 'List all transactions', 'finance', 1),
('finance.deposit.list', 'Deposit List', 'List deposits', 'finance', 1),
('finance.deposit.view', 'View Deposit', 'View deposit details', 'finance', 1),
('finance.deposit.approve', 'Approve Deposit', 'Approve pending deposit', 'finance', 1),
('finance.deposit.reject', 'Reject Deposit', 'Reject pending deposit', 'finance', 1),
('finance.withdrawal.list', 'Withdrawal List', 'List withdrawals', 'finance', 1),
('finance.withdrawal.view', 'View Withdrawal', 'View withdrawal details', 'finance', 1),
('finance.withdrawal.approve', 'Approve Withdrawal', 'Approve pending withdrawal', 'finance', 1),
('finance.withdrawal.reject', 'Reject Withdrawal', 'Reject pending withdrawal', 'finance', 1),
('finance.adjustment.list', 'Adjustment List', 'List adjustments', 'finance', 1),
('finance.adjustment.create', 'Create Adjustment', 'Create manual adjustment', 'finance', 1),

-- Payment Providers
('finance.provider.list', 'Payment Provider List', 'List payment providers', 'finance', 1),
('finance.provider.view', 'View Payment Provider', 'View provider details', 'finance', 1),
('finance.provider.settings', 'Provider Settings', 'Edit provider configuration', 'finance', 1),
('finance.provider.limits', 'Provider Limits', 'Edit provider limits and fees', 'finance', 1),
('finance.provider.logs', 'Provider Logs', 'View provider transaction logs', 'finance', 1),

-- Manual Operations
('finance.manual.credit', 'Manual Credit', 'Manual credit to player wallet', 'finance', 1),
('finance.manual.debit', 'Manual Debit', 'Manual debit from player wallet', 'finance', 1),

-- Reconciliation & Currency
('finance.reconciliation.view', 'View Reconciliation', 'View daily settlement and provider reconciliation', 'finance', 1),
('finance.currency.view', 'View Currency Rates', 'View exchange rates', 'finance', 1),
('finance.currency.manage', 'Manage Currency Rates', 'Edit exchange rates', 'finance', 1),

-- ================================================================
-- BONUS SCOPE (22) - Editor+ / Marketing
-- ================================================================
-- Bonus Management
('bonus.list', 'Bonus List', 'List bonus definitions', 'bonus', 1),
('bonus.view', 'View Bonus', 'View bonus details', 'bonus', 1),
('bonus.create', 'Create Bonus', 'Create new bonus', 'bonus', 1),
('bonus.edit', 'Edit Bonus', 'Edit bonus configuration', 'bonus', 1),
('bonus.activate', 'Activate Bonus', 'Activate bonus', 'bonus', 1),
('bonus.deactivate', 'Deactivate Bonus', 'Deactivate bonus', 'bonus', 1),
('bonus.triggers.view', 'View Bonus Triggers', 'View bonus trigger rules', 'bonus', 1),
('bonus.triggers.manage', 'Manage Bonus Triggers', 'Edit bonus trigger rules', 'bonus', 1),
('bonus.players.view', 'View Bonus Players', 'View players with bonus', 'bonus', 1),
('bonus.stats.view', 'View Bonus Stats', 'View bonus statistics', 'bonus', 1),

-- Campaigns
('bonus.campaign.list', 'Campaign List', 'List campaigns', 'bonus', 1),
('bonus.campaign.view', 'View Campaign', 'View campaign details', 'bonus', 1),
('bonus.campaign.create', 'Create Campaign', 'Create new campaign', 'bonus', 1),
('bonus.campaign.edit', 'Edit Campaign', 'Edit campaign configuration', 'bonus', 1),

-- Promo Codes
('bonus.promo.list', 'Promo Code List', 'List promo codes', 'bonus', 1),
('bonus.promo.view', 'View Promo Code', 'View promo code details', 'bonus', 1),
('bonus.promo.create', 'Create Promo Code', 'Create new promo code', 'bonus', 1),
('bonus.promo.manage', 'Manage Promo Codes', 'Edit/deactivate promo codes', 'bonus', 1),

-- Free Spins
('bonus.freespin.list', 'Free Spin List', 'List free spin awards', 'bonus', 1),
('bonus.freespin.award', 'Award Free Spins', 'Award free spins to player', 'bonus', 1),

-- Loyalty
('bonus.loyalty.view', 'View Loyalty Program', 'View VIP levels and point system', 'bonus', 1),
('bonus.loyalty.manage', 'Manage Loyalty Program', 'Edit VIP levels and point system', 'bonus', 1),

-- ================================================================
-- AFFILIATE SCOPE (12) - Moderator+
-- ================================================================
('affiliate.list', 'Affiliate List', 'List affiliates', 'affiliate', 1),
('affiliate.view', 'View Affiliate', 'View affiliate details', 'affiliate', 1),
('affiliate.create', 'Create Affiliate', 'Create new affiliate', 'affiliate', 1),
('affiliate.edit', 'Edit Affiliate', 'Edit affiliate information', 'affiliate', 1),
('affiliate.players.view', 'View Affiliate Players', 'View players referred by affiliate', 'affiliate', 1),
('affiliate.stats.view', 'View Affiliate Stats', 'View affiliate statistics', 'affiliate', 1),
('affiliate.hierarchy.view', 'View Affiliate Hierarchy', 'View affiliate tree structure', 'affiliate', 1),
('affiliate.commission.view', 'View Commissions', 'View commission calculations', 'affiliate', 1),
('affiliate.commission.manage', 'Manage Commission Rules', 'Edit commission rules', 'affiliate', 1),
('affiliate.payout.view', 'View Payouts', 'View affiliate payouts', 'affiliate', 1),
('affiliate.payout.approve', 'Approve Payout', 'Approve affiliate payout', 'affiliate', 1),
('affiliate.report.view', 'View Affiliate Reports', 'View affiliate performance reports', 'affiliate', 1),

-- ================================================================
-- REPORT SCOPE (7) - Moderator+ / Management
-- ================================================================
('report.dashboard.view', 'View Dashboard', 'View KPI dashboard', 'report', 1),
('report.realtime.view', 'View Realtime', 'View realtime metrics', 'report', 1),
('report.player.view', 'View Player Reports', 'View player activity, retention, LTV reports', 'report', 1),
('report.game.view', 'View Game Reports', 'View GGR/NGR, game performance reports', 'report', 1),
('report.financial.view', 'View Financial Reports', 'View financial summary, payment, revenue reports', 'report', 1),
('report.risk.view', 'View Risk Reports', 'View fraud alerts, suspicious activity reports', 'report', 1),
('report.export', 'Export Reports', 'Export reports to file', 'report', 1),

-- ================================================================
-- AUDIT SCOPE (9) - TenantAdmin+
-- ================================================================
('audit.list', 'Audit Log List', 'List audit logs', 'audit', 1),
('audit.view', 'View Audit Log', 'View audit log details', 'audit', 1),
('audit.export', 'Export Audit Log', 'Export audit logs', 'audit', 1),
('audit.kyc.view', 'View KYC Audit', 'View KYC audit trail and document audit', 'audit', 1),
('audit.aml.view', 'View AML Alerts', 'View AML alerts, SAR reports, PEP/sanctions', 'audit', 1),
('audit.aml.manage', 'Manage AML', 'Manage AML cases and SAR reports', 'audit', 1),
('audit.fraud.view', 'View Fraud Events', 'View fraud events and alerts', 'audit', 1),
('audit.fraud.manage', 'Manage Fraud Rules', 'Edit fraud detection rules', 'audit', 1),
('audit.report.view', 'View Compliance Reports', 'View compliance reports', 'audit', 1)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    category = EXCLUDED.category,
    status = EXCLUDED.status;

-- ================================================================
-- VALIDATION
-- ================================================================
DO $$
DECLARE
    v_total INT;
    v_platform INT;
    v_company INT;
    v_tenant INT;
    v_catalog INT;
    v_player INT;
    v_game INT;
    v_finance INT;
    v_bonus INT;
    v_affiliate INT;
    v_report INT;
    v_audit INT;
BEGIN
    SELECT COUNT(*) INTO v_total FROM security.permissions;
    SELECT COUNT(*) INTO v_platform FROM security.permissions WHERE category = 'platform';
    SELECT COUNT(*) INTO v_company FROM security.permissions WHERE category = 'company';
    SELECT COUNT(*) INTO v_tenant FROM security.permissions WHERE category = 'tenant';
    SELECT COUNT(*) INTO v_catalog FROM security.permissions WHERE category = 'catalog';
    SELECT COUNT(*) INTO v_player FROM security.permissions WHERE category = 'player';
    SELECT COUNT(*) INTO v_game FROM security.permissions WHERE category = 'game';
    SELECT COUNT(*) INTO v_finance FROM security.permissions WHERE category = 'finance';
    SELECT COUNT(*) INTO v_bonus FROM security.permissions WHERE category = 'bonus';
    SELECT COUNT(*) INTO v_affiliate FROM security.permissions WHERE category = 'affiliate';
    SELECT COUNT(*) INTO v_report FROM security.permissions WHERE category = 'report';
    SELECT COUNT(*) INTO v_audit FROM security.permissions WHERE category = 'audit';

    RAISE NOTICE '================================================';
    RAISE NOTICE 'PERMISSIONS SEED COMPLETED';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Platform:   %', v_platform;
    RAISE NOTICE 'Company:    %', v_company;
    RAISE NOTICE 'Tenant:     %', v_tenant;
    RAISE NOTICE 'Catalog:    %', v_catalog;
    RAISE NOTICE 'Player:     %', v_player;
    RAISE NOTICE 'Game:       %', v_game;
    RAISE NOTICE 'Finance:    %', v_finance;
    RAISE NOTICE 'Bonus:      %', v_bonus;
    RAISE NOTICE 'Affiliate:  %', v_affiliate;
    RAISE NOTICE 'Report:     %', v_report;
    RAISE NOTICE 'Audit:      %', v_audit;
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'TOTAL:      %', v_total;
    RAISE NOTICE '================================================';
END $$;

-- Permission summary by category
SELECT category, COUNT(*) as count
FROM security.permissions
GROUP BY category
ORDER BY count DESC;
