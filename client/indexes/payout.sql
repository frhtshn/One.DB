-- =============================================
-- Tenant Affiliate - Payout Schema Indexes
-- =============================================

-- payout_requests
CREATE INDEX IF NOT EXISTS idx_payout_requests_affiliate ON payout.payout_requests USING btree(affiliate_id);
CREATE INDEX IF NOT EXISTS idx_payout_requests_status ON payout.payout_requests USING btree(status);
CREATE INDEX IF NOT EXISTS idx_payout_requests_requested ON payout.payout_requests USING btree(requested_at DESC);
CREATE INDEX IF NOT EXISTS idx_payout_requests_pending ON payout.payout_requests USING btree(status, requested_at) WHERE status = 0;

-- payouts
CREATE INDEX IF NOT EXISTS idx_payouts_affiliate ON payout.payouts USING btree(affiliate_id);
CREATE INDEX IF NOT EXISTS idx_payouts_request ON payout.payouts USING btree(payout_request_id) WHERE payout_request_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_payouts_status ON payout.payouts USING btree(status);
CREATE INDEX IF NOT EXISTS idx_payouts_date ON payout.payouts USING btree(payout_date DESC) WHERE payout_date IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_payouts_affiliate_date ON payout.payouts USING btree(affiliate_id, payout_date DESC);
CREATE INDEX IF NOT EXISTS idx_payouts_period ON payout.payouts USING btree(period_start, period_end);
CREATE INDEX IF NOT EXISTS idx_payouts_pending ON payout.payouts USING btree(status, created_at) WHERE status IN (0, 1, 2);
CREATE INDEX IF NOT EXISTS idx_payouts_processed_by ON payout.payouts USING btree(processed_by) WHERE processed_by IS NOT NULL;

-- payout_commissions (junction table)
CREATE INDEX IF NOT EXISTS idx_payout_commissions_payout ON payout.payout_commissions USING btree(payout_id);
CREATE INDEX IF NOT EXISTS idx_payout_commissions_commission ON payout.payout_commissions USING btree(commission_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_payout_commissions_unique ON payout.payout_commissions USING btree(payout_id, commission_id);
