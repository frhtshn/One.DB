-- =============================================
-- Client Affiliate - Campaign Schema Constraints
-- =============================================

-- campaigns -> traffic_sources
ALTER TABLE campaign.campaigns
    ADD CONSTRAINT fk_campaigns_traffic_source
    FOREIGN KEY (traffic_source_id) REFERENCES campaign.traffic_sources(id);
