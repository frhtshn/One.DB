-- ================================================================
-- NUCLEO PLATFORM - MASTER PERMISSIONS SEED
-- ================================================================
-- Convention: PERMISSION_CONVENTION.md (source of truth)
-- Format: {scope}.{entity}.{action} — max 3 segment, tekil, kucuk harf
-- Bu dosya tek kaynak (single source of truth) olarak kullanilmalidir.
-- ================================================================
-- Calistirma: psql -U postgres -d nucleo -f core/data/permissions_full.sql
-- ================================================================
-- UPSERT: ON CONFLICT kullanir, siralama onemli degil.
-- Mevcut kayitlari gunceller, yenilerini ekler.
-- ================================================================

-- ================================================================
-- PERMISSIONS - FULL LIST (UPSERT)
-- ================================================================
-- Toplam: 131 permission (92 API/System + 39 Field)
-- Kategoriler (category kolonu bazinda):
--   platform (8), company (13), tenant (52), catalog (17),
--   audit (2), field (39)
-- ================================================================

INSERT INTO security.permissions (code, name, description, category, status) VALUES

-- ================================================================
-- PLATFORM SCOPE (7) — SuperAdmin only (bypass)
-- ================================================================
-- Platform yonetimi: rol, permission, presentation, localization, language, health
('platform.role.manage', 'Role Management', 'Role CRUD (list, get, create, update, delete)', 'platform', 1),
('platform.permission.manage', 'Permission Management', 'Permission CRUD (list, get, create, update)', 'platform', 1),
('platform.presentation.manage', 'Presentation Management', 'Menu group/menu/submenu/page/tab/context CRUD + reorder', 'platform', 1),
('platform.localization.manage', 'Localization Management', 'Localization key CRUD + translation + export/import', 'platform', 1),
('platform.language.manage', 'Language Management', 'Language admin CRUD (list, get, create, update, delete)', 'platform', 1),
('platform.health.view', 'Health Check', 'Dashboard, monitoring, error-logs, dead-letters menu/page visibility gate', 'platform', 1),

-- ================================================================
-- COMPANY SCOPE (7) — Admin+
-- ================================================================
('company.list', 'Company List', 'List all companies', 'company', 1),
('company.view', 'View Company', 'View company details', 'company', 1),
('company.create', 'Create Company', 'Create new company', 'company', 1),
('company.edit', 'Edit Company', 'Edit company information', 'company', 1),
('company.delete', 'Delete Company', 'Delete company (soft delete)', 'company', 1),
('company.password-policy.view', 'View Password Policy', 'View company password policy', 'company', 1),
('company.password-policy.edit', 'Edit Password Policy', 'Edit company password policy', 'company', 1),

-- ================================================================
-- COMPANY.USER (5) — Admin+
-- ================================================================
('company.user.list', 'Company User List', 'List company users', 'company', 1),
('company.user.view', 'View Company User', 'View company user details', 'company', 1),
('company.user.create', 'Create Company User', 'Add user to company', 'company', 1),
('company.user.edit', 'Edit Company User', 'Edit company user', 'company', 1),
('company.user.delete', 'Delete Company User', 'Delete company user (soft delete)', 'company', 1),

-- ================================================================
-- TENANT SCOPE (22) — Admin+ (sub-entity yazma Admin only)
-- ================================================================
('tenant.list', 'Tenant List', 'List tenants', 'tenant', 1),
('tenant.view', 'View Tenant', 'View tenant details', 'tenant', 1),
('tenant.create', 'Create Tenant', 'Create new tenant', 'tenant', 1),
('tenant.edit', 'Edit Tenant', 'Edit tenant information', 'tenant', 1),
('tenant.delete', 'Delete Tenant', 'Delete tenant (soft delete)', 'tenant', 1),
('tenant.setting.view', 'View Tenant Settings', 'View tenant configuration settings', 'tenant', 1),
('tenant.setting.edit', 'Edit Tenant Settings', 'Edit tenant configuration settings (all categories)', 'tenant', 1),
('tenant.currency.list', 'Tenant Currency List', 'View tenant currencies', 'tenant', 1),
('tenant.currency.edit', 'Edit Tenant Currency', 'Add/update tenant currencies', 'tenant', 1),
('tenant.language.list', 'Tenant Language List', 'View tenant languages', 'tenant', 1),
('tenant.language.edit', 'Edit Tenant Language', 'Add/update tenant languages', 'tenant', 1),
('tenant.cryptocurrency.list', 'Tenant Cryptocurrency List', 'View tenant cryptocurrencies', 'tenant', 1),
('tenant.cryptocurrency.edit', 'Edit Tenant Cryptocurrency', 'Add/update tenant cryptocurrencies', 'tenant', 1),
('tenant.presentation.manage', 'Manage Presentation', 'Manage tenant navigation, themes and layouts', 'tenant', 1),

-- ================================================================
-- TENANT.USER (5) — CompanyAdmin+
-- ================================================================
('tenant.user.list', 'Tenant User List', 'List tenant users', 'tenant', 1),
('tenant.user.view', 'View Tenant User', 'View tenant user details', 'tenant', 1),
('tenant.user.create', 'Create Tenant User', 'Add user to tenant', 'tenant', 1),
('tenant.user.edit', 'Edit Tenant User', 'Edit tenant user', 'tenant', 1),
('tenant.user.delete', 'Delete Tenant User', 'Delete tenant user (soft delete)', 'tenant', 1),

-- ================================================================
-- RBAC (3) — CompanyAdmin+
-- ================================================================
('tenant.user-role.assign', 'Assign Tenant Role', 'Assign/remove role to tenant user', 'tenant', 1),
('tenant.user-permission.grant', 'Grant Permission', 'Grant permission override to user', 'tenant', 1),
('tenant.user-permission.deny', 'Deny Permission', 'Deny permission override from user', 'tenant', 1),

-- ================================================================
-- TENANT.BONUS (3) — Bonus Award yönetimi
-- ================================================================
('tenant.bonus.list', 'Bonus Award List', 'List player bonus awards', 'tenant', 1),
('tenant.bonus.view', 'View Bonus Award', 'View bonus award details', 'tenant', 1),
('tenant.bonus.manage', 'Manage Bonus Awards', 'Cancel/manage player bonus awards', 'tenant', 1),

-- ================================================================
-- TENANT.BONUS-REQUEST (6) — Bonus Request yönetimi
-- ================================================================
('tenant.bonus-request.list', 'Bonus Request List', 'List bonus requests', 'tenant', 1),
('tenant.bonus-request.view', 'View Bonus Request', 'View bonus request details and action history', 'tenant', 1),
('tenant.bonus-request.create', 'Create Bonus Request', 'Create manual bonus requests for players', 'tenant', 1),
('tenant.bonus-request.review', 'Review Bonus Request', 'Approve or reject bonus requests', 'tenant', 1),
('tenant.bonus-request.assign', 'Assign Bonus Request', 'Assign bonus requests to operators', 'tenant', 1),
('tenant.bonus-request-settings.manage', 'Manage Bonus Request Settings', 'Configure requestable bonus types, cooldown periods, rules content and display names', 'tenant', 1),

-- ================================================================
-- TENANT.PROVISION (2) — Provisioning/Decommission
-- ================================================================
('tenant.provision.view', 'View Provisioning', 'View provisioning status and history', 'tenant', 1),
('tenant.provision.manage', 'Manage Provisioning', 'Start/complete provision and decommission', 'tenant', 1),

-- ================================================================
-- TENANT.SEGMENTATION (3) — Player Category/Group/Classification yönetimi
-- ================================================================
('tenant.player-category.manage', 'Manage Player Categories', 'Create, update, delete player VIP categories', 'tenant', 1),
('tenant.player-group.manage', 'Manage Player Groups', 'Create, update, delete player behavioral groups', 'tenant', 1),
('tenant.player-classification.manage', 'Manage Player Classification', 'Assign/remove player category and group memberships', 'tenant', 1),

-- ================================================================
-- TENANT.SUPPORT (15) — Çağrı Merkezi & Müşteri Temsilcisi
-- ================================================================
-- Ticket (5)
('tenant.support-ticket.list', 'Support Ticket List', 'List support tickets', 'tenant', 1),
('tenant.support-ticket.view', 'View Support Ticket', 'View support ticket details and action history', 'tenant', 1),
('tenant.support-ticket.create', 'Create Support Ticket', 'Create support tickets on behalf of players', 'tenant', 1),
('tenant.support-ticket.assign', 'Assign Support Ticket', 'Assign support tickets to agents', 'tenant', 1),
('tenant.support-ticket.manage', 'Manage Support Ticket', 'Resolve, close, reopen, cancel tickets and manage priority/category', 'tenant', 1),
-- Player Note (2)
('tenant.support-player-note.list', 'Support Player Note List', 'List player notes', 'tenant', 1),
('tenant.support-player-note.manage', 'Manage Player Notes', 'Create, update, delete player notes', 'tenant', 1),
-- Representative (2)
('tenant.support-representative.view', 'View Player Representative', 'View assigned representative and assignment history', 'tenant', 1),
('tenant.support-representative.manage', 'Manage Player Representative', 'Assign or change player representative', 'tenant', 1),
-- Agent & Config (4)
('tenant.support-agent.manage', 'Manage Support Agents', 'Configure agent availability, capacity, and skills', 'tenant', 1),
('tenant.support-category.manage', 'Manage Ticket Categories', 'Create, update, delete ticket categories', 'tenant', 1),
('tenant.support-tag.manage', 'Manage Ticket Tags', 'Create, update ticket tags', 'tenant', 1),
('tenant.support-canned-response.manage', 'Manage Canned Responses', 'Create, update, delete canned response templates', 'tenant', 1),
-- Dashboard & Welcome Call (2)
('tenant.support-dashboard.view', 'Support Dashboard', 'View support dashboard statistics and queue', 'tenant', 1),
('tenant.support-welcome-call.manage', 'Manage Welcome Calls', 'View, assign, complete, reschedule welcome call tasks', 'tenant', 1),

-- ================================================================
-- CATALOG SCOPE (17) — Admin+
-- ================================================================
-- Provider (6)
('catalog.provider.list', 'Provider List', 'List providers and provider types', 'catalog', 1),
('catalog.provider.view', 'View Provider', 'View provider details', 'catalog', 1),
('catalog.provider.create', 'Create Provider', 'Create new provider', 'catalog', 1),
('catalog.provider.edit', 'Edit Provider', 'Edit provider information', 'catalog', 1),
('catalog.provider.delete', 'Delete Provider', 'Delete provider (soft delete)', 'catalog', 1),
('catalog.provider.manage', 'Provider Management', 'Provider type CUD + provider settings CRUD', 'catalog', 1),
-- Payment (3)
('catalog.payment.list', 'Payment Method List', 'List payment methods', 'catalog', 1),
('catalog.payment.view', 'View Payment Method', 'View payment method details', 'catalog', 1),
('catalog.payment.manage', 'Payment Method Management', 'Payment method POST/PUT/DELETE', 'catalog', 1),
-- Currency (2)
('catalog.currency.list', 'Currency List', 'List catalog currencies', 'catalog', 1),
('catalog.currency.manage', 'Currency Management', 'Currency CUD (POST/PUT/DELETE)', 'catalog', 1),
-- UIKit (2)
('catalog.uikit.list', 'UIKit List', 'List themes, widgets, nav templates', 'catalog', 1),
('catalog.uikit.manage', 'UIKit Management', 'Theme/Widget/Navigation CRUD', 'catalog', 1),
-- Compliance (2)
('catalog.compliance.list', 'Compliance List', 'List jurisdictions, KYC policies', 'catalog', 1),
('catalog.compliance.manage', 'Compliance Management', 'Jurisdiction/KYC policy CRUD', 'catalog', 1),
-- Bonus (2)
('catalog.bonus.list', 'Bonus Rule List', 'List bonus types, rules, campaigns, promo codes', 'catalog', 1),
('catalog.bonus.manage', 'Bonus Rule Management', 'Bonus type/rule/campaign/promo CRUD', 'catalog', 1),

-- ================================================================
-- PLATFORM.INFRASTRUCTURE (1) — SuperAdmin
-- ================================================================
('platform.infrastructure.manage', 'Infrastructure Management', 'Infrastructure server CRUD and tenant server assignment', 'platform', 1),

-- ================================================================
-- AUDIT SCOPE (2) — Moderator+
-- ================================================================
('audit.list', 'Audit Log List', 'List audit logs', 'audit', 1),
('audit.view', 'View Audit Log', 'View audit log details + auth audit (user/type/failed)', 'audit', 1),

-- ================================================================
-- PERMISSION TEMPLATE (3) — Faz 3
-- ================================================================
('platform.permission-template.manage', 'Platform Template Management', 'Template CRUD + toggle + clone + from-user (platform scope)', 'platform', 1),
('company.permission-template.manage', 'Company Template Management', 'Template CRUD + toggle + clone + from-user (company scope)', 'company', 1),
('tenant.permission-template.assign', 'Template Assignment', 'Template assign/unassign/list', 'tenant', 1),

-- ================================================================
-- FIELD PROTECTION — BackOffice User (12)
-- ================================================================
-- Format: field.user-{alan}.{seviye} — Seviyeler: edit > view > mask > (yok = gizli)
-- User Email
('field.user-email.edit', 'User Email Edit', 'Edit user email field', 'field', 1),
('field.user-email.view', 'User Email View', 'View user email unmasked', 'field', 1),
('field.user-email.mask', 'User Email Mask', 'View user email masked', 'field', 1),
-- User Username
('field.user-username.edit', 'User Username Edit', 'Edit username field', 'field', 1),
('field.user-username.view', 'User Username View', 'View username unmasked', 'field', 1),
('field.user-username.mask', 'User Username Mask', 'View username masked', 'field', 1),
-- User FirstName
('field.user-firstname.edit', 'User FirstName Edit', 'Edit user first name field', 'field', 1),
('field.user-firstname.view', 'User FirstName View', 'View user first name unmasked', 'field', 1),
('field.user-firstname.mask', 'User FirstName Mask', 'View user first name masked', 'field', 1),
-- User LastName
('field.user-lastname.edit', 'User LastName Edit', 'Edit user last name field', 'field', 1),
('field.user-lastname.view', 'User LastName View', 'View user last name unmasked', 'field', 1),
('field.user-lastname.mask', 'User LastName Mask', 'View user last name masked', 'field', 1),

-- ================================================================
-- FIELD PROTECTION — Player (27)
-- ================================================================
-- Format: field.player-{alan}.{seviye} — Player PII alanlari (DB'de encrypted)
-- Player Email
('field.player-email.edit', 'Player Email Edit', 'Edit player email field', 'field', 1),
('field.player-email.view', 'Player Email View', 'View player email unmasked', 'field', 1),
('field.player-email.mask', 'Player Email Mask', 'View player email masked', 'field', 1),
-- Player Username
('field.player-username.edit', 'Player Username Edit', 'Edit player username field', 'field', 1),
('field.player-username.view', 'Player Username View', 'View player username unmasked', 'field', 1),
('field.player-username.mask', 'Player Username Mask', 'View player username masked', 'field', 1),
-- Player FirstName
('field.player-firstname.edit', 'Player FirstName Edit', 'Edit player first name field', 'field', 1),
('field.player-firstname.view', 'Player FirstName View', 'View player first name unmasked', 'field', 1),
('field.player-firstname.mask', 'Player FirstName Mask', 'View player first name masked', 'field', 1),
-- Player LastName
('field.player-lastname.edit', 'Player LastName Edit', 'Edit player last name field', 'field', 1),
('field.player-lastname.view', 'Player LastName View', 'View player last name unmasked', 'field', 1),
('field.player-lastname.mask', 'Player LastName Mask', 'View player last name masked', 'field', 1),
-- Player Birthdate
('field.player-birthdate.edit', 'Player Birthdate Edit', 'Edit player birth date field', 'field', 1),
('field.player-birthdate.view', 'Player Birthdate View', 'View player birth date unmasked', 'field', 1),
('field.player-birthdate.mask', 'Player Birthdate Mask', 'View player birth date masked', 'field', 1),
-- Player Phone
('field.player-phone.edit', 'Player Phone Edit', 'Edit player phone field', 'field', 1),
('field.player-phone.view', 'Player Phone View', 'View player phone unmasked', 'field', 1),
('field.player-phone.mask', 'Player Phone Mask', 'View player phone masked', 'field', 1),
-- Player GSM
('field.player-gsm.edit', 'Player GSM Edit', 'Edit player GSM field', 'field', 1),
('field.player-gsm.view', 'Player GSM View', 'View player GSM unmasked', 'field', 1),
('field.player-gsm.mask', 'Player GSM Mask', 'View player GSM masked', 'field', 1),
-- Player Address
('field.player-address.edit', 'Player Address Edit', 'Edit player address field', 'field', 1),
('field.player-address.view', 'Player Address View', 'View player address unmasked', 'field', 1),
('field.player-address.mask', 'Player Address Mask', 'View player address masked', 'field', 1),
-- Player Identity
('field.player-identity.edit', 'Player Identity Edit', 'Edit player TC/passport field', 'field', 1),
('field.player-identity.view', 'Player Identity View', 'View player TC/passport unmasked', 'field', 1),
('field.player-identity.mask', 'Player Identity Mask', 'View player TC/passport masked', 'field', 1)

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
    v_audit INT;
    v_field INT;
BEGIN
    SELECT COUNT(*) INTO v_total FROM security.permissions;
    SELECT COUNT(*) INTO v_platform FROM security.permissions WHERE category = 'platform';
    SELECT COUNT(*) INTO v_company FROM security.permissions WHERE category = 'company';
    SELECT COUNT(*) INTO v_tenant FROM security.permissions WHERE category = 'tenant';
    SELECT COUNT(*) INTO v_catalog FROM security.permissions WHERE category = 'catalog';
    SELECT COUNT(*) INTO v_audit FROM security.permissions WHERE category = 'audit';
    SELECT COUNT(*) INTO v_field FROM security.permissions WHERE category = 'field';

    RAISE NOTICE '================================================';
    RAISE NOTICE 'PERMISSIONS SEED COMPLETED';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Platform:     % (expected: 8)', v_platform;
    RAISE NOTICE 'Company:      % (expected: 13)', v_company;
    RAISE NOTICE 'Tenant:       % (expected: 52)', v_tenant;
    RAISE NOTICE 'Catalog:      % (expected: 17)', v_catalog;
    RAISE NOTICE 'Audit:        % (expected: 2)', v_audit;
    RAISE NOTICE 'Field:        % (expected: 39)', v_field;
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'TOTAL:        % (expected: 131)', v_total;
    RAISE NOTICE '================================================';

    -- Strict validation: convention'daki 107 permission kontrol
    IF v_platform < 8 THEN
        RAISE WARNING 'Platform permission eksik! Beklenen: 8, Gercek: %', v_platform;
    END IF;
    IF v_field < 39 THEN
        RAISE WARNING 'Field permission eksik! Beklenen: 39, Gercek: %', v_field;
    END IF;
END $$;

-- Permission summary by category
SELECT category, COUNT(*) as count
FROM security.permissions
GROUP BY category
ORDER BY count DESC;
