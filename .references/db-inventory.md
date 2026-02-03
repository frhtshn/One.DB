# Nucleo Platform - Veritabanı Envanteri

## 1. MainDB (CoreDB)

- **billing:**
    - **provider:** provider_commission_rates, provider_commission_tiers, provider_invoice_items, provider_invoices, provider_payments, provider_settlement_tenants, provider_settlements.
    - **tenant:** tenant_billing_periods, tenant_commission_aggregates, tenant_commission_plan_tiers, tenant_commission_plans, tenant_commission_rate_tiers, tenant_commission_rates, tenant_commissions, tenant_invoice_items, tenant_invoice_payments, tenant_invoices.
- **catalog:**
    - **compliance:** jurisdictions, kyc_document_requirements, kyc_level_requirements, kyc_policies, responsible_gaming_policies.
    - **game:** games.
    - **localization:** localization_keys, localization_values.
    - **payment:** payment_methods.
    - **provider:** provider_settings, provider_types, providers.
    - **reference:** countries, currencies, languages, timezones.
    - **transaction:** operation_types, transaction_types.
    - **uikit:** navigation_template_items, navigation_templates, themes, ui_positions, widgets.
- **core:**
    - **configuration:** tenant_currencies, tenant_data_policies, tenant_jurisdictions, tenant_languages, tenant_settings.
    - **integration:** tenant_games, tenant_payment_methods, tenant_provider_limits, tenant_providers.
    - **organization:** companies, tenants.
- **outbox:** outbox_messages.
- **presentation:**
    - **backoffice:** contexts, menu_groups, menus, pages, submenus, tabs.
    - **frontend:** tenant_layouts, tenant_navigation, tenant_themes.
- **routing:** callback_routes, provider_callbacks, provider_endpoints.
- **security:**
    - **identity:** user_sessions, users.
    - **rbac:** permissions, role_permissions, roles, user_allowed_tenants, user_permission_overrides, user_roles.
    - **secrets:** secrets_provider, secrets_tenant.

## 2. ClientDB (TenantDB)

- **bonus:** bonus_awards, promo_redemptions.
- **content:**
    - **cms:** content_attachments, content_categories, content_category_translations, content_translations, content_type_translations, content_types, content_versions, contents.
    - **faq:** faq_categories, faq_category_translations, faq_item_translations, faq_items.
    - **popup:** popup_images, popup_schedules, popup_translations, popup_type_translations, popup_types, popups.
    - **promotion:** promotion_banners, promotion_display_locations, promotion_games, promotion_segments, promotion_translations, promotions.
    - **slide:** slide_categories, slide_category_translations, slide_images, slide_placements, slide_schedules, slide_translations, slides.
- **finance:** currency_rates, currency_rates_latest, operation_types, payment_method_limits, payment_method_settings, payment_player_limits, transaction_types.
- **game:** game_limits, game_settings.
- **kyc:** player_aml_flags, player_documents, player_jurisdiction, player_kyc_cases, player_kyc_workflows, player_limit_history, player_limits, player_restrictions.
- **player_auth:** player_categories, player_classification, player_credentials, player_groups, players.
- **player_profile:** player_identity, player_profile.
- **transaction:** transaction_workflow_actions, transaction_workflows, transactions.
- **wallet:** wallet_snapshots, wallets.

## 3. PluginDB (BonusDB)

- **bonus:** bonus_rules, bonus_triggers, bonus_types.
- **campaign:** campaigns.
- **promotion:** promo_codes.
