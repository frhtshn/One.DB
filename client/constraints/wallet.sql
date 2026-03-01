-- =============================================
-- Client Wallet Schema Foreign Key Constraints
-- =============================================

-- wallets -> players
ALTER TABLE wallet.wallets
    ADD CONSTRAINT fk_wallets_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;

-- wallet_snapshots -> wallets
ALTER TABLE wallet.wallet_snapshots
    ADD CONSTRAINT fk_wallet_snapshots_wallet
    FOREIGN KEY (wallet_id) REFERENCES wallet.wallets(id) ON DELETE CASCADE;
