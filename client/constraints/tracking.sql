-- =============================================
-- Client Affiliate - Tracking Schema Constraints
-- =============================================
-- NOT: player_id referansları cross-database (client DB) olduğu için FK yok
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

-- =============================================
-- Tracking Links, Clicks, Registrations, Promo Codes Constraints
-- =============================================

-- tracking_links -> affiliates
ALTER TABLE tracking.tracking_links
    ADD CONSTRAINT fk_tracking_links_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id);

-- tracking_links -> campaigns
ALTER TABLE tracking.tracking_links
    ADD CONSTRAINT fk_tracking_links_campaign
    FOREIGN KEY (campaign_id) REFERENCES campaign.campaigns(id);

-- link_clicks -> tracking_links
ALTER TABLE tracking.link_clicks
    ADD CONSTRAINT fk_link_clicks_tracking_link
    FOREIGN KEY (tracking_link_id) REFERENCES tracking.tracking_links(id);

-- link_clicks -> affiliates
ALTER TABLE tracking.link_clicks
    ADD CONSTRAINT fk_link_clicks_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id);

-- player_registrations -> affiliates
ALTER TABLE tracking.player_registrations
    ADD CONSTRAINT fk_player_registrations_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id);

-- player_registrations -> campaigns
ALTER TABLE tracking.player_registrations
    ADD CONSTRAINT fk_player_registrations_campaign
    FOREIGN KEY (campaign_id) REFERENCES campaign.campaigns(id);

-- player_registrations -> tracking_links
ALTER TABLE tracking.player_registrations
    ADD CONSTRAINT fk_player_registrations_tracking_link
    FOREIGN KEY (tracking_link_id) REFERENCES tracking.tracking_links(id);

-- player_registrations -> promo_codes
ALTER TABLE tracking.player_registrations
    ADD CONSTRAINT fk_player_registrations_promo_code
    FOREIGN KEY (promo_code_id) REFERENCES tracking.promo_codes(id);

-- promo_codes -> affiliates
ALTER TABLE tracking.promo_codes
    ADD CONSTRAINT fk_promo_codes_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id);

-- promo_codes -> campaigns
ALTER TABLE tracking.promo_codes
    ADD CONSTRAINT fk_promo_codes_campaign
    FOREIGN KEY (campaign_id) REFERENCES campaign.campaigns(id);
