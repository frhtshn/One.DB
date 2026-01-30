-- =============================================
-- Billing Schema Indexes
-- FK indexes for optimal JOIN performance
-- =============================================

-- TENANT BILLING INDEXES

-- tenant_billing_periods
CREATE INDEX IF NOT EXISTS idx_billing_periods_status ON billing.tenant_billing_periods USING btree(status);
CREATE INDEX IF NOT EXISTS idx_billing_periods_period ON billing.tenant_billing_periods USING btree(period_start, period_end);

-- tenant_commission_rates
CREATE INDEX IF NOT EXISTS idx_tenant_commission_rates_provider ON billing.tenant_commission_rates USING btree(provider_id);
CREATE INDEX IF NOT EXISTS idx_tenant_commission_rates_active ON billing.tenant_commission_rates USING btree(provider_id, is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_tenant_commission_rates_lookup ON billing.tenant_commission_rates USING btree(provider_id, product_code, commission_type, is_active) WHERE is_active = true;

-- tenant_commission_rate_tiers
CREATE INDEX IF NOT EXISTS idx_tenant_commission_rate_tiers_rate ON billing.tenant_commission_rate_tiers USING btree(rate_id);
CREATE INDEX IF NOT EXISTS idx_tenant_commission_rate_tiers_order ON billing.tenant_commission_rate_tiers USING btree(rate_id, tier_order);

-- tenant_commission_plans
CREATE INDEX IF NOT EXISTS idx_tenant_commission_plans_tenant ON billing.tenant_commission_plans USING btree(tenant_id);
CREATE INDEX IF NOT EXISTS idx_tenant_commission_plans_provider ON billing.tenant_commission_plans USING btree(provider_id);
CREATE INDEX IF NOT EXISTS idx_tenant_commission_plans_active ON billing.tenant_commission_plans USING btree(tenant_id, provider_id, is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_tenant_commission_plans_lookup ON billing.tenant_commission_plans USING btree(tenant_id, provider_id, product_code, commission_type, is_active) WHERE is_active = true;
CREATE UNIQUE INDEX IF NOT EXISTS idx_tenant_commission_plans_unique ON billing.tenant_commission_plans USING btree(tenant_id, provider_id, product_code, commission_type, valid_from);

-- tenant_commission_plan_tiers
CREATE INDEX IF NOT EXISTS idx_tenant_commission_plan_tiers_plan ON billing.tenant_commission_plan_tiers USING btree(tenant_commission_plan_id);
CREATE INDEX IF NOT EXISTS idx_tenant_commission_plan_tiers_order ON billing.tenant_commission_plan_tiers USING btree(tenant_commission_plan_id, tier_order);

-- tenant_commission_aggregates
CREATE INDEX IF NOT EXISTS idx_tenant_commission_aggregates_tenant ON billing.tenant_commission_aggregates USING btree(tenant_id);
CREATE INDEX IF NOT EXISTS idx_tenant_commission_aggregates_provider ON billing.tenant_commission_aggregates USING btree(provider_id);
CREATE INDEX IF NOT EXISTS idx_tenant_commission_aggregates_period ON billing.tenant_commission_aggregates USING btree(period_key);
CREATE INDEX IF NOT EXISTS idx_tenant_commission_aggregates_lookup ON billing.tenant_commission_aggregates USING btree(tenant_id, provider_id, product_code, period_key);
CREATE UNIQUE INDEX IF NOT EXISTS idx_tenant_commission_aggregates_unique ON billing.tenant_commission_aggregates USING btree(tenant_id, provider_id, product_code, period_key, currency);

-- tenant_commissions
CREATE INDEX IF NOT EXISTS idx_tenant_commissions_tenant ON billing.tenant_commissions USING btree(tenant_id);
CREATE INDEX IF NOT EXISTS idx_tenant_commissions_provider ON billing.tenant_commissions USING btree(provider_id);
CREATE INDEX IF NOT EXISTS idx_tenant_commissions_period ON billing.tenant_commissions USING btree(period_key);
CREATE INDEX IF NOT EXISTS idx_tenant_commissions_status ON billing.tenant_commissions USING btree(status);
CREATE INDEX IF NOT EXISTS idx_tenant_commissions_invoice ON billing.tenant_commissions USING btree(invoice_id) WHERE invoice_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tenant_commissions_lookup ON billing.tenant_commissions USING btree(tenant_id, provider_id, period_key);
CREATE UNIQUE INDEX IF NOT EXISTS idx_tenant_commissions_unique ON billing.tenant_commissions USING btree(tenant_id, provider_id, product_code, commission_type, period_key, tier_order, currency);

-- tenant_invoices
CREATE INDEX IF NOT EXISTS idx_tenant_invoices_tenant ON billing.tenant_invoices USING btree(tenant_id);
CREATE INDEX IF NOT EXISTS idx_tenant_invoices_status ON billing.tenant_invoices USING btree(status);
CREATE INDEX IF NOT EXISTS idx_tenant_invoices_date ON billing.tenant_invoices USING btree(invoice_date);
CREATE INDEX IF NOT EXISTS idx_tenant_invoices_due ON billing.tenant_invoices USING btree(due_date);
CREATE INDEX IF NOT EXISTS idx_tenant_invoices_period ON billing.tenant_invoices USING btree(period_start, period_end);

-- tenant_invoice_items
CREATE INDEX IF NOT EXISTS idx_tenant_invoice_items_invoice ON billing.tenant_invoice_items USING btree(tenant_invoice_id);
CREATE INDEX IF NOT EXISTS idx_tenant_invoice_items_commission ON billing.tenant_invoice_items USING btree(tenant_commission_id) WHERE tenant_commission_id IS NOT NULL;

-- tenant_invoice_payments
CREATE INDEX IF NOT EXISTS idx_tenant_invoice_payments_invoice ON billing.tenant_invoice_payments USING btree(tenant_invoice_id);
CREATE INDEX IF NOT EXISTS idx_tenant_invoice_payments_date ON billing.tenant_invoice_payments USING btree(payment_date);


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

-- provider_settlement_tenants
CREATE INDEX IF NOT EXISTS idx_provider_settlement_tenants_settlement ON billing.provider_settlement_tenants USING btree(provider_settlement_id);
CREATE INDEX IF NOT EXISTS idx_provider_settlement_tenants_tenant ON billing.provider_settlement_tenants USING btree(tenant_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_provider_settlement_tenants_unique ON billing.provider_settlement_tenants USING btree(provider_settlement_id, tenant_id);

-- provider_invoices
CREATE INDEX IF NOT EXISTS idx_provider_invoices_provider ON billing.provider_invoices USING btree(provider_id);
CREATE INDEX IF NOT EXISTS idx_provider_invoices_status ON billing.provider_invoices USING btree(status);
CREATE INDEX IF NOT EXISTS idx_provider_invoices_date ON billing.provider_invoices USING btree(invoice_date);
CREATE INDEX IF NOT EXISTS idx_provider_invoices_due ON billing.provider_invoices USING btree(due_date);
CREATE INDEX IF NOT EXISTS idx_provider_invoices_settlement ON billing.provider_invoices USING btree(settlement_id) WHERE settlement_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_provider_invoices_unique ON billing.provider_invoices USING btree(provider_id, invoice_number);

-- provider_invoice_items
CREATE INDEX IF NOT EXISTS idx_provider_invoice_items_invoice ON billing.provider_invoice_items USING btree(provider_invoice_id);
CREATE INDEX IF NOT EXISTS idx_provider_invoice_items_tenant ON billing.provider_invoice_items USING btree(tenant_id) WHERE tenant_id IS NOT NULL;

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
