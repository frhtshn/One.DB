INSERT INTO presentation.menu_groups
(code, title_localization_key, order_index)
VALUES
('HOME',        'bo.menu_group.home',        1),
('OPERATIONS',  'bo.menu_group.operations',  2),
('DOCUMENTS',   'bo.menu_group.documents',   3);


INSERT INTO presentation.menus
(menu_group_id, code, title_localization_key, icon, order_index, required_permission)
VALUES
-- HOME
(
  (SELECT id FROM presentation.menu_groups WHERE code = 'HOME'),
  'DASHBOARD',
  'bo.menu.dashboard',
  'dashboard',
  1,
  'dashboard.view'
),

-- OPERATIONS
(
  (SELECT id FROM presentation.menu_groups WHERE code = 'OPERATIONS'),
  'PLAYERS',
  'bo.menu.players',
  'users',
  1,
  'players.view'
),
(
  (SELECT id FROM presentation.menu_groups WHERE code = 'OPERATIONS'),
  'DEPOSITS',
  'bo.menu.deposits',
  'credit-card',
  2,
  'deposits.view'
),

-- DOCUMENTS
(
  (SELECT id FROM presentation.menu_groups WHERE code = 'DOCUMENTS'),
  'REPORTS',
  'bo.menu.reports',
  'file',
  1,
  'reports.view'
);

INSERT INTO presentation.submenus
(menu_id, code, title_localization_key, route, order_index, required_permission)
VALUES
-- PLAYERS
(
  (SELECT id FROM presentation.menus WHERE code = 'PLAYERS'),
  'PLAYER_LIST',
  'bo.submenu.players.list',
  '/players/list',
  1,
  'players.view'
),

-- DEPOSITS
(
  (SELECT id FROM presentation.menus WHERE code = 'DEPOSITS'),
  'DEPOSIT_LIST',
  'bo.submenu.deposits.list',
  '/deposits',
  1,
  'deposits.view'
);

INSERT INTO presentation.pages
(submenu_id, code, route, title_localization_key, required_permission)
VALUES
-- PLAYERS LIST
(
  (SELECT id FROM presentation.submenus WHERE code = 'PLAYER_LIST'),
  'PLAYER_LIST',
  '/players/list',
  'bo.page.players.list',
  'players.view'
),

-- DEPOSITS LIST
(
  (SELECT id FROM presentation.submenus WHERE code = 'DEPOSIT_LIST'),
  'DEPOSIT_LIST',
  '/deposits',
  'bo.page.deposits.list',
  'deposits.view'
);

INSERT INTO presentation.tabs
(page_id, code, title_localization_key, order_index, required_permission)
VALUES
-- PLAYER LIST TABS
(
  (SELECT id FROM presentation.pages WHERE code = 'PLAYER_LIST'),
  'OVERVIEW',
  'bo.tab.player.overview',
  1,
  'players.view'
),
(
  (SELECT id FROM presentation.pages WHERE code = 'PLAYER_LIST'),
  'WALLET',
  'bo.tab.player.wallet',
  2,
  'wallet.view'
),
(
  (SELECT id FROM presentation.pages WHERE code = 'PLAYER_LIST'),
  'KYC',
  'bo.tab.player.kyc',
  3,
  'players.kyc.view'
);
INSERT INTO presentation.contexts
(page_id, code, context_type, label_localization_key, required_permission, behavior)
VALUES
-- PLAYER LIST FIELDS
(
  (SELECT id FROM presentation.pages WHERE code = 'PLAYER_LIST'),
  'player.phone',
  'FIELD',
  'bo.field.player.phone',
  'players.pii.view',
  'MASK'
),
(
  (SELECT id FROM presentation.pages WHERE code = 'PLAYER_LIST'),
  'player.email',
  'FIELD',
  'bo.field.player.email',
  'players.pii.view',
  'MASK'
),

-- ACTIONS
(
  (SELECT id FROM presentation.pages WHERE code = 'PLAYER_LIST'),
  'player.edit',
  'BUTTON',
  'bo.button.player.edit',
  'players.edit',
  'EDIT'
),
(
  (SELECT id FROM presentation.pages WHERE code = 'PLAYER_LIST'),
  'player.export',
  'BUTTON',
  'bo.button.player.export',
  'players.export',
  'EDIT'
),

-- DEPOSIT PAGE ACTION
(
  (SELECT id FROM presentation.pages WHERE code = 'DEPOSIT_LIST'),
  'deposit.export',
  'BUTTON',
  'bo.button.deposit.export',
  'deposits.export',
  'EDIT'
);
