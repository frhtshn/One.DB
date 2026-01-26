-- =============================================
-- Tenant Affiliate - Commission Schema Indexes
-- =============================================

-- commission_plans
CREATE UNIQUE INDEX idx_commission_plans_code ON commission.commission_plans USING btree(code);
CREATE INDEX idx_commission_plans_model ON commission.commission_plans USING btree(model);

-- commission_tiers
CREATE INDEX idx_commission_tiers_plan ON commission.commission_tiers USING btree(commission_plan_id);
CREATE INDEX idx_commission_tiers_metric ON commission.commission_tiers USING btree(metric);
CREATE INDEX idx_commission_tiers_range ON commission.commission_tiers USING btree(commission_plan_id, metric, range_from, range_to);

-- commissions
CREATE INDEX idx_commissions_affiliate ON commission.commissions USING btree(affiliate_id);
CREATE INDEX idx_commissions_source ON commission.commissions USING btree(source_affiliate_id) WHERE source_affiliate_id IS NOT NULL;
CREATE INDEX idx_commissions_type ON commission.commissions USING btree(commission_type);
CREATE INDEX idx_commissions_period ON commission.commissions USING btree(period_start, period_end);
CREATE INDEX idx_commissions_status ON commission.commissions USING btree(status);
CREATE INDEX idx_commissions_affiliate_period ON commission.commissions USING btree(affiliate_id, period_start DESC);
CREATE INDEX idx_commissions_pending ON commission.commissions USING btree(status, created_at) WHERE status IN (0, 1);
