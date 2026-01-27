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

-- commissions -> affiliates (player affiliate - oyuncuyu getiren)
ALTER TABLE commission.commissions
    ADD CONSTRAINT fk_commissions_player_affiliate
    FOREIGN KEY (player_affiliate_id) REFERENCES affiliate.affiliates(id);

-- network_commission_splits -> commission_plans
ALTER TABLE commission.network_commission_splits
    ADD CONSTRAINT fk_network_splits_plan
    FOREIGN KEY (commission_plan_id) REFERENCES commission.commission_plans(id) ON DELETE CASCADE;

-- network_commission_splits unique constraint (plan + level)
ALTER TABLE commission.network_commission_splits
    ADD CONSTRAINT uq_network_splits_plan_level
    UNIQUE (commission_plan_id, network_level);

-- network_commission_distributions -> commission_plans
ALTER TABLE commission.network_commission_distributions
    ADD CONSTRAINT fk_network_dist_plan
    FOREIGN KEY (commission_plan_id) REFERENCES commission.commission_plans(id) ON DELETE CASCADE;

-- network_commission_distributions unique constraint (plan + level)
ALTER TABLE commission.network_commission_distributions
    ADD CONSTRAINT uq_network_dist_plan_level
    UNIQUE (commission_plan_id, level_from_player);

-- cost_allocation_settings -> commission_plans
ALTER TABLE commission.cost_allocation_settings
    ADD CONSTRAINT fk_cost_allocation_plan
    FOREIGN KEY (commission_plan_id) REFERENCES commission.commission_plans(id) ON DELETE CASCADE;

-- negative_balance_carryforward -> affiliates
ALTER TABLE commission.negative_balance_carryforward
    ADD CONSTRAINT fk_negative_carryforward_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id);
