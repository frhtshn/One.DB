-- =============================================
-- Tenant Affiliate - Payout Schema Indexes
-- =============================================

-- payout_requests
CREATE INDEX idx_payout_requests_affiliate ON payout.payout_requests USING btree(affiliate_id);
CREATE INDEX idx_payout_requests_status ON payout.payout_requests USING btree(status);
CREATE INDEX idx_payout_requests_requested ON payout.payout_requests USING btree(requested_at DESC);
CREATE INDEX idx_payout_requests_pending ON payout.payout_requests USING btree(status, requested_at) WHERE status = 0;

-- payouts
CREATE INDEX idx_payouts_affiliate ON payout.payouts USING btree(affiliate_id);
CREATE INDEX idx_payouts_status ON payout.payouts USING btree(status);
CREATE INDEX idx_payouts_date ON payout.payouts USING btree(payout_date DESC) WHERE payout_date IS NOT NULL;
CREATE INDEX idx_payouts_affiliate_date ON payout.payouts USING btree(affiliate_id, payout_date DESC);
