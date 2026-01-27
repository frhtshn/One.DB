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

-- payouts -> payout_requests
ALTER TABLE payout.payouts
    ADD CONSTRAINT fk_payouts_request
    FOREIGN KEY (payout_request_id) REFERENCES payout.payout_requests(id);

-- payout_commissions -> payouts
ALTER TABLE payout.payout_commissions
    ADD CONSTRAINT fk_payout_commissions_payout
    FOREIGN KEY (payout_id) REFERENCES payout.payouts(id) ON DELETE CASCADE;

-- payout_commissions -> commissions
ALTER TABLE payout.payout_commissions
    ADD CONSTRAINT fk_payout_commissions_commission
    FOREIGN KEY (commission_id) REFERENCES commission.commissions(id);
