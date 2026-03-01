-- =============================================
-- Client Affiliate - Affiliate Schema Constraints
-- =============================================

-- affiliate_network -> affiliates (self)
ALTER TABLE affiliate.affiliate_network
    ADD CONSTRAINT fk_affiliate_network_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id) ON DELETE CASCADE;

-- affiliate_network -> affiliates (parent)
ALTER TABLE affiliate.affiliate_network
    ADD CONSTRAINT fk_affiliate_network_parent
    FOREIGN KEY (parent_affiliate_id) REFERENCES affiliate.affiliates(id) ON DELETE SET NULL;

-- affiliate_users -> affiliates
ALTER TABLE affiliate.affiliate_users
    ADD CONSTRAINT fk_affiliate_users_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id) ON DELETE CASCADE;

-- affiliate_users -> affiliate_users (created by)
ALTER TABLE affiliate.affiliate_users
    ADD CONSTRAINT fk_affiliate_users_created_by
    FOREIGN KEY (created_by_user_id) REFERENCES affiliate.affiliate_users(id) ON DELETE SET NULL;

-- affiliate_users -> affiliates (created by affiliate - üst affiliate)
ALTER TABLE affiliate.affiliate_users
    ADD CONSTRAINT fk_affiliate_users_created_by_affiliate
    FOREIGN KEY (created_by_affiliate_id) REFERENCES affiliate.affiliates(id) ON DELETE SET NULL;

-- affiliate_campaigns -> affiliates
ALTER TABLE affiliate.affiliate_campaigns
    ADD CONSTRAINT fk_affiliate_campaigns_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id) ON DELETE CASCADE;

-- affiliate_campaigns -> campaigns
ALTER TABLE affiliate.affiliate_campaigns
    ADD CONSTRAINT fk_affiliate_campaigns_campaign
    FOREIGN KEY (campaign_id) REFERENCES campaign.campaigns(id) ON DELETE CASCADE;

-- affiliate_campaigns -> commission_plans
ALTER TABLE affiliate.affiliate_campaigns
    ADD CONSTRAINT fk_affiliate_campaigns_plan
    FOREIGN KEY (commission_plan_id) REFERENCES commission.commission_plans(id);
