-- =============================================
-- Tenant Bonus Schema Foreign Key Constraints
-- =============================================

-- bonus_awards -> players
ALTER TABLE bonus.bonus_awards
    ADD CONSTRAINT fk_bonus_awards_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;

-- bonus_awards -> transactions
ALTER TABLE bonus.bonus_awards
    ADD CONSTRAINT fk_bonus_awards_transaction
    FOREIGN KEY (tenant_transaction_id) REFERENCES transaction.transactions(id);

-- promo_redemptions -> players
ALTER TABLE bonus.promo_redemptions
    ADD CONSTRAINT fk_promo_redemptions_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;

-- promo_redemptions -> bonus_awards
ALTER TABLE bonus.promo_redemptions
    ADD CONSTRAINT fk_promo_redemptions_bonus
    FOREIGN KEY (bonus_award_id) REFERENCES bonus.bonus_awards(id);
