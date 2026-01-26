-- =============================================
-- Tenant Affiliate - Commission Schema Constraints
-- =============================================

-- commission_tiers -> commission_plans
ALTER TABLE commission.commission_tiers
    ADD CONSTRAINT fk_commission_tiers_plan
    FOREIGN KEY (commission_plan_id) REFERENCES commission.commission_plans(id) ON DELETE CASCADE;

-- commissions -> affiliates
ALTER TABLE commission.commissions
    ADD CONSTRAINT fk_commissions_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id);

-- commissions -> affiliates (source - network)
ALTER TABLE commission.commissions
    ADD CONSTRAINT fk_commissions_source_affiliate
    FOREIGN KEY (source_affiliate_id) REFERENCES affiliate.affiliates(id);
