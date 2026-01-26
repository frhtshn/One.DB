-- =============================================
-- Tenant Wallet Schema Indexes
-- =============================================

-- wallets
CREATE INDEX idx_wallets_player ON wallet.wallets USING btree(player_id);
CREATE INDEX idx_wallets_currency ON wallet.wallets USING btree(currency_code);
CREATE INDEX idx_wallets_type ON wallet.wallets USING btree(wallet_type);
CREATE INDEX idx_wallets_default ON wallet.wallets USING btree(player_id, is_default) WHERE is_default = true;
CREATE UNIQUE INDEX idx_wallets_player_type_currency ON wallet.wallets USING btree(player_id, wallet_type, currency_code);

-- wallet_snapshots
CREATE INDEX idx_wallet_snapshots_wallet ON wallet.wallet_snapshots USING btree(wallet_id);
CREATE INDEX idx_wallet_snapshots_date ON wallet.wallet_snapshots USING btree(snapshot_date DESC);
CREATE UNIQUE INDEX idx_wallet_snapshots_wallet_date ON wallet.wallet_snapshots USING btree(wallet_id, snapshot_date);
