-- =============================================
-- Tenant Affiliate - Commission Schema Indexes
-- =============================================

-- commission_plans
CREATE UNIQUE INDEX idx_commission_plans_code ON commission.commission_plans USING btree(code);
CREATE INDEX idx_commission_plans_model ON commission.commission_plans USING btree(model);
CREATE INDEX idx_commission_plans_active ON commission.commission_plans USING btree(model) WHERE is_active = true;
CREATE INDEX idx_commission_plans_metric ON commission.commission_plans USING btree(revshare_metric) WHERE revshare_enabled = true;

-- commission_tiers
CREATE INDEX idx_commission_tiers_plan ON commission.commission_tiers USING btree(commission_plan_id);
CREATE INDEX idx_commission_tiers_type ON commission.commission_tiers USING btree(tier_type);
CREATE INDEX idx_commission_tiers_metric ON commission.commission_tiers USING btree(metric);
CREATE INDEX idx_commission_tiers_range ON commission.commission_tiers USING btree(commission_plan_id, metric, range_from, range_to);
CREATE INDEX idx_commission_tiers_active ON commission.commission_tiers USING btree(commission_plan_id, tier_type, metric) WHERE is_active = true;

-- commissions
CREATE INDEX idx_commissions_affiliate ON commission.commissions USING btree(affiliate_id);
CREATE INDEX idx_commissions_plan ON commission.commissions USING btree(commission_plan_id);
CREATE INDEX idx_commissions_source ON commission.commissions USING btree(source_affiliate_id) WHERE source_affiliate_id IS NOT NULL;
CREATE INDEX idx_commissions_player_affiliate ON commission.commissions USING btree(player_affiliate_id) WHERE player_affiliate_id IS NOT NULL;
CREATE INDEX idx_commissions_type ON commission.commissions USING btree(commission_type);
CREATE INDEX idx_commissions_model ON commission.commissions USING btree(commission_model);
CREATE INDEX idx_commissions_network_level ON commission.commissions USING btree(network_level);
CREATE INDEX idx_commissions_period ON commission.commissions USING btree(period_start, period_end);
CREATE INDEX idx_commissions_status ON commission.commissions USING btree(status);
CREATE INDEX idx_commissions_affiliate_period ON commission.commissions USING btree(affiliate_id, period_start DESC);
CREATE INDEX idx_commissions_pending ON commission.commissions USING btree(status, created_at) WHERE status IN (0, 1);
CREATE INDEX idx_commissions_batch ON commission.commissions USING btree(batch_id) WHERE batch_id IS NOT NULL;
CREATE INDEX idx_commissions_network_trace ON commission.commissions USING btree(player_affiliate_id, network_level, period_start);
CREATE INDEX idx_commissions_revshare_metric ON commission.commissions USING btree(revshare_metric) WHERE revshare_amount > 0;
CREATE INDEX idx_commissions_cpa ON commission.commissions USING btree(affiliate_id, period_start) WHERE cpa_amount > 0;

-- network_commission_splits (iki seviyeli basit dağılım)
CREATE INDEX idx_network_commission_splits_plan ON commission.network_commission_splits USING btree(commission_plan_id);
CREATE INDEX idx_network_commission_splits_active ON commission.network_commission_splits USING btree(commission_plan_id, network_level) WHERE is_active = true;

-- network_commission_distributions (çok katmanlı dağılım)
CREATE INDEX idx_network_commission_dist_plan ON commission.network_commission_distributions USING btree(commission_plan_id);
CREATE INDEX idx_network_commission_dist_level ON commission.network_commission_distributions USING btree(commission_plan_id, level_from_player) WHERE is_active = true;
CREATE INDEX idx_network_commission_dist_active ON commission.network_commission_distributions USING btree(commission_plan_id) WHERE is_active = true;

-- cost_allocation_settings
CREATE INDEX idx_cost_allocation_plan ON commission.cost_allocation_settings USING btree(commission_plan_id);
CREATE INDEX idx_cost_allocation_active ON commission.cost_allocation_settings USING btree(commission_plan_id) WHERE is_active = true;

-- negative_balance_carryforward
CREATE INDEX idx_negative_carryforward_affiliate ON commission.negative_balance_carryforward USING btree(affiliate_id);
CREATE INDEX idx_negative_carryforward_active ON commission.negative_balance_carryforward USING btree(affiliate_id, currency) WHERE status = 0;
CREATE INDEX idx_negative_carryforward_expires ON commission.negative_balance_carryforward USING btree(expires_at) WHERE status = 0 AND expires_at IS NOT NULL;
CREATE INDEX idx_negative_carryforward_source ON commission.negative_balance_carryforward USING btree(source_year DESC, source_month DESC);
