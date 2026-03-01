-- =============================================
-- Client Affiliate - Affiliate Schema Indexes
-- =============================================

-- affiliates
CREATE UNIQUE INDEX idx_affiliates_code ON affiliate.affiliates USING btree(code);
CREATE INDEX idx_affiliates_status ON affiliate.affiliates USING btree(status);
CREATE INDEX idx_affiliates_created ON affiliate.affiliates USING btree(created_at DESC);

-- affiliate_network
CREATE INDEX idx_affiliate_network_parent ON affiliate.affiliate_network USING btree(parent_affiliate_id) WHERE parent_affiliate_id IS NOT NULL;
CREATE INDEX idx_affiliate_network_level ON affiliate.affiliate_network USING btree(level);

-- affiliate_users
CREATE INDEX idx_affiliate_users_affiliate ON affiliate.affiliate_users USING btree(affiliate_id);
CREATE UNIQUE INDEX idx_affiliate_users_email ON affiliate.affiliate_users USING btree(email);
CREATE INDEX idx_affiliate_users_status ON affiliate.affiliate_users USING btree(status);
CREATE INDEX idx_affiliate_users_role ON affiliate.affiliate_users USING btree(affiliate_id, role);
CREATE INDEX idx_affiliate_users_last_login ON affiliate.affiliate_users USING btree(last_login_at DESC) WHERE last_login_at IS NOT NULL;
CREATE INDEX idx_affiliate_users_created_by ON affiliate.affiliate_users USING btree(created_by_affiliate_id) WHERE created_by_affiliate_id IS NOT NULL;
CREATE INDEX idx_affiliate_users_locked ON affiliate.affiliate_users USING btree(locked_until) WHERE locked_until IS NOT NULL;
CREATE INDEX idx_affiliate_users_active ON affiliate.affiliate_users USING btree(affiliate_id) WHERE status = 1;

-- affiliate_campaigns
CREATE INDEX idx_affiliate_campaigns_affiliate ON affiliate.affiliate_campaigns USING btree(affiliate_id);
CREATE INDEX idx_affiliate_campaigns_campaign ON affiliate.affiliate_campaigns USING btree(campaign_id);
CREATE INDEX idx_affiliate_campaigns_plan ON affiliate.affiliate_campaigns USING btree(commission_plan_id);
CREATE INDEX idx_affiliate_campaigns_active ON affiliate.affiliate_campaigns USING btree(affiliate_id, start_date, end_date);

-- network_commission_rules
CREATE UNIQUE INDEX idx_network_commission_rules_level ON affiliate.network_commission_rules USING btree(parent_level);
