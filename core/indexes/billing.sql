-- =============================================
-- Billing Schema Indexes
-- FK indexes for optimal JOIN performance
-- =============================================

-- CLIENT BILLING INDEXES

-- client_billing_periods
CREATE INDEX IF NOT EXISTS idx_billing_periods_status ON billing.client_billing_periods USING btree(status);
CREATE INDEX IF NOT EXISTS idx_billing_periods_period ON billing.client_billing_periods USING btree(period_start, period_end);

-- client_commission_rates
CREATE INDEX IF NOT EXISTS idx_client_commission_rates_provider ON billing.client_commission_rates USING btree(provider_id);
CREATE INDEX IF NOT EXISTS idx_client_commission_rates_active ON billing.client_commission_rates USING btree(provider_id, is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_client_commission_rates_lookup ON billing.client_commission_rates USING btree(provider_id, product_code, commission_type, is_active) WHERE is_active = true;

-- client_commission_rate_tiers
CREATE INDEX IF NOT EXISTS idx_client_commission_rate_tiers_rate ON billing.client_commission_rate_tiers USING btree(rate_id);
CREATE INDEX IF NOT EXISTS idx_client_commission_rate_tiers_order ON billing.client_commission_rate_tiers USING btree(rate_id, tier_order);

-- client_commission_plans
CREATE INDEX IF NOT EXISTS idx_client_commission_plans_client ON billing.client_commission_plans USING btree(client_id);
CREATE INDEX IF NOT EXISTS idx_client_commission_plans_provider ON billing.client_commission_plans USING btree(provider_id);
CREATE INDEX IF NOT EXISTS idx_client_commission_plans_active ON billing.client_commission_plans USING btree(client_id, provider_id, is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_client_commission_plans_lookup ON billing.client_commission_plans USING btree(client_id, provider_id, product_code, commission_type, is_active) WHERE is_active = true;
CREATE UNIQUE INDEX IF NOT EXISTS idx_client_commission_plans_unique ON billing.client_commission_plans USING btree(client_id, provider_id, product_code, commission_type, valid_from);

-- client_commission_plan_tiers
CREATE INDEX IF NOT EXISTS idx_client_commission_plan_tiers_plan ON billing.client_commission_plan_tiers USING btree(client_commission_plan_id);
CREATE INDEX IF NOT EXISTS idx_client_commission_plan_tiers_order ON billing.client_commission_plan_tiers USING btree(client_commission_plan_id, tier_order);

-- client_commission_aggregates
CREATE INDEX IF NOT EXISTS idx_client_commission_aggregates_client ON billing.client_commission_aggregates USING btree(client_id);
CREATE INDEX IF NOT EXISTS idx_client_commission_aggregates_provider ON billing.client_commission_aggregates USING btree(provider_id);
CREATE INDEX IF NOT EXISTS idx_client_commission_aggregates_period ON billing.client_commission_aggregates USING btree(period_key);
CREATE INDEX IF NOT EXISTS idx_client_commission_aggregates_lookup ON billing.client_commission_aggregates USING btree(client_id, provider_id, product_code, period_key);
CREATE UNIQUE INDEX IF NOT EXISTS idx_client_commission_aggregates_unique ON billing.client_commission_aggregates USING btree(client_id, provider_id, product_code, period_key, currency);

-- client_commissions
CREATE INDEX IF NOT EXISTS idx_client_commissions_client ON billing.client_commissions USING btree(client_id);
CREATE INDEX IF NOT EXISTS idx_client_commissions_provider ON billing.client_commissions USING btree(provider_id);
CREATE INDEX IF NOT EXISTS idx_client_commissions_period ON billing.client_commissions USING btree(period_key);
CREATE INDEX IF NOT EXISTS idx_client_commissions_status ON billing.client_commissions USING btree(status);
CREATE INDEX IF NOT EXISTS idx_client_commissions_invoice ON billing.client_commissions USING btree(invoice_id) WHERE invoice_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_client_commissions_lookup ON billing.client_commissions USING btree(client_id, provider_id, period_key);
CREATE UNIQUE INDEX IF NOT EXISTS idx_client_commissions_unique ON billing.client_commissions USING btree(client_id, provider_id, product_code, commission_type, period_key, tier_order, currency);

-- client_invoices
CREATE INDEX IF NOT EXISTS idx_client_invoices_client ON billing.client_invoices USING btree(client_id);
CREATE INDEX IF NOT EXISTS idx_client_invoices_status ON billing.client_invoices USING btree(status);
CREATE INDEX IF NOT EXISTS idx_client_invoices_date ON billing.client_invoices USING btree(invoice_date);
CREATE INDEX IF NOT EXISTS idx_client_invoices_due ON billing.client_invoices USING btree(due_date);
CREATE INDEX IF NOT EXISTS idx_client_invoices_period ON billing.client_invoices USING btree(period_start, period_end);

-- client_invoice_items
CREATE INDEX IF NOT EXISTS idx_client_invoice_items_invoice ON billing.client_invoice_items USING btree(client_invoice_id);
CREATE INDEX IF NOT EXISTS idx_client_invoice_items_commission ON billing.client_invoice_items USING btree(client_commission_id) WHERE client_commission_id IS NOT NULL;

-- client_invoice_payments
CREATE INDEX IF NOT EXISTS idx_client_invoice_payments_invoice ON billing.client_invoice_payments USING btree(client_invoice_id);
CREATE INDEX IF NOT EXISTS idx_client_invoice_payments_date ON billing.client_invoice_payments USING btree(payment_date);


-- PROVIDER BILLING INDEXES

-- provider_commission_rates
CREATE INDEX IF NOT EXISTS idx_provider_commission_rates_provider ON billing.provider_commission_rates USING btree(provider_id);
CREATE INDEX IF NOT EXISTS idx_provider_commission_rates_active ON billing.provider_commission_rates USING btree(provider_id, is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_provider_commission_rates_lookup ON billing.provider_commission_rates USING btree(provider_id, product_code, commission_type, is_active) WHERE is_active = true;

-- provider_commission_tiers
CREATE INDEX IF NOT EXISTS idx_provider_commission_tiers_rate ON billing.provider_commission_tiers USING btree(provider_commission_rate_id);
CREATE INDEX IF NOT EXISTS idx_provider_commission_tiers_order ON billing.provider_commission_tiers USING btree(provider_commission_rate_id, tier_order);

-- provider_settlements
CREATE INDEX IF NOT EXISTS idx_provider_settlements_provider ON billing.provider_settlements USING btree(provider_id);
CREATE INDEX IF NOT EXISTS idx_provider_settlements_period ON billing.provider_settlements USING btree(period_key);
CREATE INDEX IF NOT EXISTS idx_provider_settlements_status ON billing.provider_settlements USING btree(status);
CREATE UNIQUE INDEX IF NOT EXISTS idx_provider_settlements_unique ON billing.provider_settlements USING btree(provider_id, period_key);

-- provider_settlement_clients
CREATE INDEX IF NOT EXISTS idx_provider_settlement_clients_settlement ON billing.provider_settlement_clients USING btree(provider_settlement_id);
CREATE INDEX IF NOT EXISTS idx_provider_settlement_clients_client ON billing.provider_settlement_clients USING btree(client_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_provider_settlement_clients_unique ON billing.provider_settlement_clients USING btree(provider_settlement_id, client_id);

-- provider_invoices
CREATE INDEX IF NOT EXISTS idx_provider_invoices_provider ON billing.provider_invoices USING btree(provider_id);
CREATE INDEX IF NOT EXISTS idx_provider_invoices_status ON billing.provider_invoices USING btree(status);
CREATE INDEX IF NOT EXISTS idx_provider_invoices_date ON billing.provider_invoices USING btree(invoice_date);
CREATE INDEX IF NOT EXISTS idx_provider_invoices_due ON billing.provider_invoices USING btree(due_date);
CREATE INDEX IF NOT EXISTS idx_provider_invoices_settlement ON billing.provider_invoices USING btree(settlement_id) WHERE settlement_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_provider_invoices_unique ON billing.provider_invoices USING btree(provider_id, invoice_number);

-- provider_invoice_items
CREATE INDEX IF NOT EXISTS idx_provider_invoice_items_invoice ON billing.provider_invoice_items USING btree(provider_invoice_id);
CREATE INDEX IF NOT EXISTS idx_provider_invoice_items_client ON billing.provider_invoice_items USING btree(client_id) WHERE client_id IS NOT NULL;

-- provider_payments
CREATE INDEX IF NOT EXISTS idx_provider_payments_provider ON billing.provider_payments USING btree(provider_id);
CREATE INDEX IF NOT EXISTS idx_provider_payments_invoice ON billing.provider_payments USING btree(provider_invoice_id) WHERE provider_invoice_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_provider_payments_date ON billing.provider_payments USING btree(payment_date);
CREATE INDEX IF NOT EXISTS idx_provider_payments_status ON billing.provider_payments USING btree(status);

-- =========================================================================================
-- GIN Indexes for JSONB Columns
-- =========================================================================================

-- billing.provider_payments (netting_details)
CREATE INDEX IF NOT EXISTS idx_provider_payments_netting_gin ON billing.provider_payments USING gin(netting_details);
