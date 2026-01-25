# Nucleo Platform - Veritabanı Envanteri

## 1. MainDB (CoreDB)

- **core:** companies, clients, client_settings, client_providers, client_games, client_currencies.
- **catalog:** providers, provider_types, games, currencies, currency_rates, countries, transaction_types, operation_types.
- **routing:** callback_routes, provider_callbacks, provider_endpoints.
- **security:** client_secrets, provider_secrets.

## 2. ClientDB (TenantDB)

- **auth:** users, external_provider_users, active_sessions.
- **wallet:** wallets, wallet_balances.
- **transaction:** transactions (Ledger), transaction_items, idempotency_keys.
- **betting:** bets, rounds, bet_items.
- **idempotency:** processed_requests.
- **system:** migrations.

## 3. PluginDB

- **bonus:** bonuses, bonus_rules, bonus_assignments, bonus_progress, bonus_events.
- **affiliate:** affiliates, campaigns, clicks, registrations, conversions, rewards.
- **campaign/crm:** campaigns, campaign_rules, campaign_targets, campaign_events, player_segments, segment_users, provider_campaigns.
- **notification:** notifications, notification_targets.
- **plugin_internal:** idempotency_keys, outbox_events, migrations.
