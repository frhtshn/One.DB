-- ================================================================
-- SORTIS ONE - MASTER PERMISSIONS SEED
-- ================================================================
-- Convention: PERMISSION_CONVENTION.md (source of truth)
-- Format: {scope}.{entity}.{action} — max 3 segment, tekil, kucuk harf
-- Bu dosya tek kaynak (single source of truth) olarak kullanilmalidir.
-- ================================================================
-- Calistirma: psql -U postgres -d core -f core/data/permissions_full.sql
-- ================================================================
-- UPSERT: ON CONFLICT kullanir, siralama onemli degil.
-- Mevcut kayitlari gunceller, yenilerini ekler.
-- ================================================================

-- ================================================================
-- PERMISSIONS - FULL LIST (UPSERT)
-- ================================================================
-- Toplam: 151 permission (112 API/System + 39 Field)
-- Kategoriler (category kolonu bazinda):
--   platform (10), company (25), client (58), catalog (17),
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
-- CLIENT SCOPE (22) — Admin+ (sub-entity yazma Admin only)
-- ================================================================
('client.list', 'Client List', 'List clients', 'client', 1),
('client.view', 'View Client', 'View client details', 'client', 1),
('client.create', 'Create Client', 'Create new client', 'client', 1),
('client.edit', 'Edit Client', 'Edit client information', 'client', 1),
('client.delete', 'Delete Client', 'Delete client (soft delete)', 'client', 1),
('client.setting.view', 'View Client Settings', 'View client configuration settings', 'client', 1),
('client.setting.edit', 'Edit Client Settings', 'Edit client configuration settings (all categories)', 'client', 1),
('client.currency.list', 'Client Currency List', 'View client currencies', 'client', 1),
('client.currency.edit', 'Edit Client Currency', 'Add/update client currencies', 'client', 1),
('client.language.list', 'Client Language List', 'View client languages', 'client', 1),
('client.language.edit', 'Edit Client Language', 'Add/update client languages', 'client', 1),
('client.cryptocurrency.list', 'Client Cryptocurrency List', 'View client cryptocurrencies', 'client', 1),
('client.cryptocurrency.edit', 'Edit Client Cryptocurrency', 'Add/update client cryptocurrencies', 'client', 1),
('client.presentation.manage', 'Manage Presentation', 'Manage client navigation, themes and layouts', 'client', 1),

-- ================================================================
-- CLIENT.USER (5) — CompanyAdmin+
-- ================================================================
('client.user.list', 'Client User List', 'List client users', 'client', 1),
('client.user.view', 'View Client User', 'View client user details', 'client', 1),
('client.user.create', 'Create Client User', 'Add user to client', 'client', 1),
('client.user.edit', 'Edit Client User', 'Edit client user', 'client', 1),
('client.user.delete', 'Delete Client User', 'Delete client user (soft delete)', 'client', 1),

-- ================================================================
-- RBAC (3) — CompanyAdmin+
-- ================================================================
('client.user-role.assign', 'Assign Client Role', 'Assign/remove role to client user', 'client', 1),
('client.user-permission.grant', 'Grant Permission', 'Grant permission override to user', 'client', 1),
('client.user-permission.deny', 'Deny Permission', 'Deny permission override from user', 'client', 1),

-- ================================================================
-- CLIENT.BONUS (3) — Bonus Award yönetimi
-- ================================================================
('client.bonus.list', 'Bonus Award List', 'List player bonus awards', 'client', 1),
('client.bonus.view', 'View Bonus Award', 'View bonus award details', 'client', 1),
('client.bonus.manage', 'Manage Bonus Awards', 'Cancel/manage player bonus awards', 'client', 1),

-- ================================================================
-- CLIENT.BONUS-REQUEST (6) — Bonus Request yönetimi
-- ================================================================
('client.bonus-request.list', 'Bonus Request List', 'List bonus requests', 'client', 1),
('client.bonus-request.view', 'View Bonus Request', 'View bonus request details and action history', 'client', 1),
('client.bonus-request.create', 'Create Bonus Request', 'Create manual bonus requests for players', 'client', 1),
('client.bonus-request.review', 'Review Bonus Request', 'Approve or reject bonus requests', 'client', 1),
('client.bonus-request.assign', 'Assign Bonus Request', 'Assign bonus requests to operators', 'client', 1),
('client.bonus-request-settings.manage', 'Manage Bonus Request Settings', 'Configure requestable bonus types, cooldown periods, rules content and display names', 'client', 1),

-- ================================================================
-- CLIENT.PROVISION (2) — Provisioning/Decommission
-- ================================================================
('client.provision.view', 'View Provisioning', 'View provisioning status and history', 'client', 1),
('client.provision.manage', 'Manage Provisioning', 'Start/complete provision and decommission', 'client', 1),

-- ================================================================
-- CLIENT.SEGMENTATION (3) — Player Category/Group/Classification yönetimi
-- ================================================================
('client.player-category.manage', 'Manage Player Categories', 'Create, update, delete player VIP categories', 'client', 1),
('client.player-group.manage', 'Manage Player Groups', 'Create, update, delete player behavioral groups', 'client', 1),
('client.player-classification.manage', 'Manage Player Classification', 'Assign/remove player category and group memberships', 'client', 1),

-- ================================================================
-- CLIENT.CONTENT (4) — Frontend İçerik Yönetimi
-- ================================================================
('client.content.manage', 'Manage Client Content', 'Manage trust logos, game lobby sections, game labels, SEO redirects', 'client', 1),
('client.site-settings.manage', 'Manage Site Settings', 'Manage site settings: analytics config, cookie consent, age gate, live chat', 'client', 1),
('client.operator-license.view', 'View Operator Licenses', 'View operator licenses (read-only)', 'client', 1),
('client.operator-license.manage', 'Manage Operator Licenses', 'Full CRUD for operator licenses', 'client', 1),

-- ================================================================
-- CLIENT.SUPPORT (15) — Çağrı Merkezi & Müşteri Temsilcisi
-- ================================================================
-- Ticket (5)
('client.support-ticket.list', 'Support Ticket List', 'List support tickets', 'client', 1),
('client.support-ticket.view', 'View Support Ticket', 'View support ticket details and action history', 'client', 1),
('client.support-ticket.create', 'Create Support Ticket', 'Create support tickets on behalf of players', 'client', 1),
('client.support-ticket.assign', 'Assign Support Ticket', 'Assign support tickets to agents', 'client', 1),
('client.support-ticket.manage', 'Manage Support Ticket', 'Resolve, close, reopen, cancel tickets and manage priority/category', 'client', 1),
-- Player Note (2)
('client.support-player-note.list', 'Support Player Note List', 'List player notes', 'client', 1),
('client.support-player-note.manage', 'Manage Player Notes', 'Create, update, delete player notes', 'client', 1),
-- Representative (2)
('client.support-representative.view', 'View Player Representative', 'View assigned representative and assignment history', 'client', 1),
('client.support-representative.manage', 'Manage Player Representative', 'Assign or change player representative', 'client', 1),
-- Agent & Config (4)
('client.support-agent.manage', 'Manage Support Agents', 'Configure agent availability, capacity, and skills', 'client', 1),
('client.support-category.manage', 'Manage Ticket Categories', 'Create, update, delete ticket categories', 'client', 1),
('client.support-tag.manage', 'Manage Ticket Tags', 'Create, update ticket tags', 'client', 1),
('client.support-canned-response.manage', 'Manage Canned Responses', 'Create, update, delete canned response templates', 'client', 1),
-- Dashboard & Welcome Call (2)
('client.support-dashboard.view', 'Support Dashboard', 'View support dashboard statistics and queue', 'client', 1),
('client.support-welcome-call.manage', 'Manage Welcome Calls', 'View, assign, complete, reschedule welcome call tasks', 'client', 1),

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
-- MESSAGING (12) — Admin+
-- ================================================================
-- Draft Management (8)
('messaging.draft.create', 'Create Draft', 'Create message drafts', 'company', 1),
('messaging.draft.read', 'Read Draft', 'List and view message drafts', 'company', 1),
('messaging.draft.update', 'Update Draft', 'Update message drafts', 'company', 1),
('messaging.draft.delete', 'Delete Draft', 'Delete message drafts', 'company', 1),
('messaging.draft.cancel', 'Cancel Draft', 'Cancel draft or scheduled messages', 'company', 1),
('messaging.draft.unschedule', 'Unschedule Draft', 'Remove scheduling from a draft', 'company', 1),
('messaging.draft.publish', 'Publish Draft', 'Publish message drafts to recipients', 'company', 1),
('messaging.draft.recall', 'Recall Message', 'Recall published messages', 'company', 1),
-- Direct Messaging (1)
('messaging.send', 'Send Direct Message', 'Send direct messages to users', 'company', 1),
-- Inbox (3)
('messaging.inbox.read', 'Read Inbox', 'Access user inbox messages', 'company', 1),
('messaging.inbox.read-all', 'Mark All Read', 'Mark all inbox messages as read', 'company', 1),
('messaging.inbox.delete', 'Delete Inbox Message', 'Delete inbox messages', 'company', 1),

-- ================================================================
-- NOTIFICATION TEMPLATES (4) — Platform + Client
-- ================================================================
-- Platform (2)
('platform.notification-template.manage', 'Manage Notification Templates', 'Create, update, delete platform notification templates', 'platform', 1),
('platform.notification-template.view', 'View Notification Templates', 'View platform notification templates', 'platform', 1),
-- Client (2)
('client.notification-template.manage', 'Manage Notification Templates', 'Create, update, delete client notification templates', 'client', 1),
('client.notification-template.view', 'View Notification Templates', 'View client notification templates', 'client', 1),

-- ================================================================
-- PLATFORM.INFRASTRUCTURE (1) — SuperAdmin
-- ================================================================
('platform.infrastructure.manage', 'Infrastructure Management', 'Infrastructure server CRUD and client server assignment', 'platform', 1),

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
('client.permission-template.assign', 'Template Assignment', 'Template assign/unassign/list', 'client', 1),

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
    v_client INT;
    v_catalog INT;
    v_audit INT;
    v_field INT;
BEGIN
    SELECT COUNT(*) INTO v_total FROM security.permissions;
    SELECT COUNT(*) INTO v_platform FROM security.permissions WHERE category = 'platform';
    SELECT COUNT(*) INTO v_company FROM security.permissions WHERE category = 'company';
    SELECT COUNT(*) INTO v_client FROM security.permissions WHERE category = 'client';
    SELECT COUNT(*) INTO v_catalog FROM security.permissions WHERE category = 'catalog';
    SELECT COUNT(*) INTO v_audit FROM security.permissions WHERE category = 'audit';
    SELECT COUNT(*) INTO v_field FROM security.permissions WHERE category = 'field';

    RAISE NOTICE '================================================';
    RAISE NOTICE 'PERMISSIONS SEED COMPLETED';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Platform:     % (expected: 10)', v_platform;
    RAISE NOTICE 'Company:      % (expected: 13)', v_company;
    RAISE NOTICE 'Client:       % (expected: 54)', v_client;
    RAISE NOTICE 'Catalog:      % (expected: 17)', v_catalog;
    RAISE NOTICE 'Audit:        % (expected: 2)', v_audit;
    RAISE NOTICE 'Field:        % (expected: 39)', v_field;
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'TOTAL:        % (expected: 135)', v_total;
    RAISE NOTICE '================================================';

    -- Strict validation: convention'daki 107 permission kontrol
    IF v_platform < 10 THEN
        RAISE WARNING 'Platform permission eksik! Beklenen: 10, Gercek: %', v_platform;
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
