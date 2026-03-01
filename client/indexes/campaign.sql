-- =============================================
-- Client Affiliate - Campaign Schema Indexes
-- =============================================

-- traffic_sources
CREATE UNIQUE INDEX idx_traffic_sources_code ON campaign.traffic_sources USING btree(code);

-- campaigns
CREATE INDEX idx_campaigns_traffic_source ON campaign.campaigns USING btree(traffic_source_id);
CREATE INDEX idx_campaigns_status ON campaign.campaigns USING btree(status);
CREATE INDEX idx_campaigns_dates ON campaign.campaigns USING btree(start_date, end_date);
CREATE INDEX idx_campaigns_active ON campaign.campaigns USING btree(status) WHERE status = 1;

-- attribution_models
CREATE UNIQUE INDEX idx_attribution_models_code ON campaign.attribution_models USING btree(code);
