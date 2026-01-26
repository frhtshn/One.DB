-- =============================================
-- Tenant Affiliate - Payout Schema Constraints
-- =============================================

-- payout_requests -> affiliates
ALTER TABLE payout.payout_requests
    ADD CONSTRAINT fk_payout_requests_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id);

-- payouts -> affiliates
ALTER TABLE payout.payouts
    ADD CONSTRAINT fk_payouts_affiliate
    FOREIGN KEY (affiliate_id) REFERENCES affiliate.affiliates(id);
