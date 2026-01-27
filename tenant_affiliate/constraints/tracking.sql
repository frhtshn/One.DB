-- =============================================
-- Tenant Affiliate - Tracking Schema Constraints
-- =============================================
-- NOT: player_id referansları cross-database (tenant DB) olduğu için FK yok
-- Sadece affiliate ve campaign referansları ekleniyor

-- player_affiliate_current -> affiliates
ALTER TABLE tracking.player_affiliate_current
    ADD CONSTRAINT fk_player_affiliate_current_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id);

-- player_affiliate_current -> campaigns
ALTER TABLE tracking.player_affiliate_current
    ADD CONSTRAINT fk_player_affiliate_current_campaign
    FOREIGN KEY (campaign_id) REFERENCES campaign.campaigns(id);

-- player_affiliate_history -> affiliates
ALTER TABLE tracking.player_affiliate_history
    ADD CONSTRAINT fk_player_affiliate_history_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id);

-- player_affiliate_history -> campaigns
ALTER TABLE tracking.player_affiliate_history
    ADD CONSTRAINT fk_player_affiliate_history_campaign
    FOREIGN KEY (campaign_id) REFERENCES campaign.campaigns(id);

-- transaction_events -> affiliates
ALTER TABLE tracking.transaction_events
    ADD CONSTRAINT fk_transaction_events_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id);

-- player_game_stats_daily -> affiliates
ALTER TABLE tracking.player_game_stats_daily
    ADD CONSTRAINT fk_player_game_stats_daily_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id);

-- player_stats_monthly -> affiliates
ALTER TABLE tracking.player_stats_monthly
    ADD CONSTRAINT fk_player_stats_monthly_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id);

-- affiliate_stats_daily -> affiliates
ALTER TABLE tracking.affiliate_stats_daily
    ADD CONSTRAINT fk_affiliate_stats_daily_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id);

-- affiliate_stats_monthly -> affiliates
ALTER TABLE tracking.affiliate_stats_monthly
    ADD CONSTRAINT fk_affiliate_stats_monthly_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id);

-- player_finance_stats_daily -> affiliates
ALTER TABLE tracking.player_finance_stats_daily
    ADD CONSTRAINT fk_player_finance_stats_daily_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id);
