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
