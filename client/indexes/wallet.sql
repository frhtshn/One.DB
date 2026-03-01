-- =============================================
-- Tenant Wallet Schema Indexes
-- =============================================

-- wallets
CREATE INDEX IF NOT EXISTS idx_wallets_player ON wallet.wallets USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_wallets_currency ON wallet.wallets USING btree(currency_code);
CREATE INDEX IF NOT EXISTS idx_wallets_type ON wallet.wallets USING btree(wallet_type);
CREATE INDEX IF NOT EXISTS idx_wallets_currency_type ON wallet.wallets USING btree(currency_type);
CREATE INDEX IF NOT EXISTS idx_wallets_default ON wallet.wallets USING btree(player_id, is_default) WHERE is_default = true;
CREATE UNIQUE INDEX IF NOT EXISTS idx_wallets_player_type_currency ON wallet.wallets USING btree(player_id, wallet_type, currency_code);

-- wallet_snapshots (wallet_id is PK, just add updated_at index)
CREATE INDEX IF NOT EXISTS idx_wallet_snapshots_updated ON wallet.wallet_snapshots USING btree(updated_at DESC);
