-- =============================================
-- Client Bonus Schema Foreign Key Constraints
-- =============================================

-- bonus_awards -> players
ALTER TABLE bonus.bonus_awards
    ADD CONSTRAINT fk_bonus_awards_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;

-- NOTE: bonus_awards -> transactions (partitioned tablo, FK uygulanamaz, app-level kontrol)

-- promo_redemptions -> players
ALTER TABLE bonus.promo_redemptions
    ADD CONSTRAINT fk_promo_redemptions_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;

-- promo_redemptions -> bonus_awards
ALTER TABLE bonus.promo_redemptions
    ADD CONSTRAINT fk_promo_redemptions_bonus
    FOREIGN KEY (bonus_award_id) REFERENCES bonus.bonus_awards(id);

-- provider_bonus_mappings -> bonus_awards
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_provider_bonus_mappings_award') THEN
        ALTER TABLE bonus.provider_bonus_mappings
            ADD CONSTRAINT fk_provider_bonus_mappings_award
            FOREIGN KEY (bonus_award_id) REFERENCES bonus.bonus_awards(id);
    END IF;
END $$;

-- provider_bonus_mappings — durum kontrolü
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_provider_bonus_mappings_status') THEN
        ALTER TABLE bonus.provider_bonus_mappings
            ADD CONSTRAINT chk_provider_bonus_mappings_status
            CHECK (status IN ('active', 'completed', 'cancelled', 'expired'));
    END IF;
END $$;
