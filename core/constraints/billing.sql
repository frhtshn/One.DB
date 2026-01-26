-- =============================================
-- Billing Schema Foreign Key Constraints
-- =============================================

-- TENANT BILLING CONSTRAINTS

-- tenant_billing_periods.calculated_by -> users
ALTER TABLE billing.tenant_billing_periods
    ADD CONSTRAINT fk_billing_periods_calculated_by
    FOREIGN KEY (calculated_by) REFERENCES security.users(id);

-- tenant_billing_periods.closed_by -> users
ALTER TABLE billing.tenant_billing_periods
    ADD CONSTRAINT fk_billing_periods_closed_by
    FOREIGN KEY (closed_by) REFERENCES security.users(id);

-- tenant_commission_rates.provider_id -> providers
ALTER TABLE billing.tenant_commission_rates
    ADD CONSTRAINT fk_tenant_commission_rates_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- tenant_commission_rate_tiers.rate_id -> tenant_commission_rates
ALTER TABLE billing.tenant_commission_rate_tiers
    ADD CONSTRAINT fk_tenant_commission_rate_tiers_rate
    FOREIGN KEY (rate_id) REFERENCES billing.tenant_commission_rates(id) ON DELETE CASCADE;

-- tenant_commission_plans.tenant_id -> tenants
ALTER TABLE billing.tenant_commission_plans
    ADD CONSTRAINT fk_tenant_commission_plans_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- tenant_commission_plans.provider_id -> providers
ALTER TABLE billing.tenant_commission_plans
    ADD CONSTRAINT fk_tenant_commission_plans_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- tenant_commission_plans.source_rate_id -> tenant_commission_rates
ALTER TABLE billing.tenant_commission_plans
    ADD CONSTRAINT fk_tenant_commission_plans_source_rate
    FOREIGN KEY (source_rate_id) REFERENCES billing.tenant_commission_rates(id);

-- tenant_commission_plans.created_by -> users
ALTER TABLE billing.tenant_commission_plans
    ADD CONSTRAINT fk_tenant_commission_plans_created_by
    FOREIGN KEY (created_by) REFERENCES security.users(id);

-- tenant_commission_plan_tiers.tenant_commission_plan_id -> tenant_commission_plans
ALTER TABLE billing.tenant_commission_plan_tiers
    ADD CONSTRAINT fk_tenant_commission_plan_tiers_plan
    FOREIGN KEY (tenant_commission_plan_id) REFERENCES billing.tenant_commission_plans(id) ON DELETE CASCADE;

-- tenant_commission_aggregates.tenant_id -> tenants
ALTER TABLE billing.tenant_commission_aggregates
    ADD CONSTRAINT fk_tenant_commission_aggregates_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- tenant_commission_aggregates.provider_id -> providers
ALTER TABLE billing.tenant_commission_aggregates
    ADD CONSTRAINT fk_tenant_commission_aggregates_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- tenant_commissions.tenant_id -> tenants
ALTER TABLE billing.tenant_commissions
    ADD CONSTRAINT fk_tenant_commissions_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- tenant_commissions.provider_id -> providers
ALTER TABLE billing.tenant_commissions
    ADD CONSTRAINT fk_tenant_commissions_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- tenant_commissions.aggregate_id -> tenant_commission_aggregates
ALTER TABLE billing.tenant_commissions
    ADD CONSTRAINT fk_tenant_commissions_aggregate
    FOREIGN KEY (aggregate_id) REFERENCES billing.tenant_commission_aggregates(id);

-- tenant_commissions.commission_plan_id -> tenant_commission_plans
ALTER TABLE billing.tenant_commissions
    ADD CONSTRAINT fk_tenant_commissions_plan
    FOREIGN KEY (commission_plan_id) REFERENCES billing.tenant_commission_plans(id);

-- tenant_commissions.approved_by -> users
ALTER TABLE billing.tenant_commissions
    ADD CONSTRAINT fk_tenant_commissions_approved_by
    FOREIGN KEY (approved_by) REFERENCES security.users(id);

-- tenant_commissions.invoice_id -> tenant_invoices
ALTER TABLE billing.tenant_commissions
    ADD CONSTRAINT fk_tenant_commissions_invoice
    FOREIGN KEY (invoice_id) REFERENCES billing.tenant_invoices(id);

-- tenant_commissions.invoice_item_id -> tenant_invoice_items
ALTER TABLE billing.tenant_commissions
    ADD CONSTRAINT fk_tenant_commissions_invoice_item
    FOREIGN KEY (invoice_item_id) REFERENCES billing.tenant_invoice_items(id);

-- tenant_invoices.tenant_id -> tenants
ALTER TABLE billing.tenant_invoices
    ADD CONSTRAINT fk_tenant_invoices_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- tenant_invoices.cancelled_by -> users
ALTER TABLE billing.tenant_invoices
    ADD CONSTRAINT fk_tenant_invoices_cancelled_by
    FOREIGN KEY (cancelled_by) REFERENCES security.users(id);

-- tenant_invoices.created_by -> users
ALTER TABLE billing.tenant_invoices
    ADD CONSTRAINT fk_tenant_invoices_created_by
    FOREIGN KEY (created_by) REFERENCES security.users(id);

-- tenant_invoice_items.tenant_invoice_id -> tenant_invoices
ALTER TABLE billing.tenant_invoice_items
    ADD CONSTRAINT fk_tenant_invoice_items_invoice
    FOREIGN KEY (tenant_invoice_id) REFERENCES billing.tenant_invoices(id) ON DELETE CASCADE;

-- tenant_invoice_items.tenant_commission_id -> tenant_commissions
ALTER TABLE billing.tenant_invoice_items
    ADD CONSTRAINT fk_tenant_invoice_items_commission
    FOREIGN KEY (tenant_commission_id) REFERENCES billing.tenant_commissions(id);

-- tenant_invoice_payments.tenant_invoice_id -> tenant_invoices
ALTER TABLE billing.tenant_invoice_payments
    ADD CONSTRAINT fk_tenant_invoice_payments_invoice
    FOREIGN KEY (tenant_invoice_id) REFERENCES billing.tenant_invoices(id);

-- tenant_invoice_payments.recorded_by -> users
ALTER TABLE billing.tenant_invoice_payments
    ADD CONSTRAINT fk_tenant_invoice_payments_recorded_by
    FOREIGN KEY (recorded_by) REFERENCES security.users(id);


-- PROVIDER BILLING CONSTRAINTS

-- provider_commission_rates.provider_id -> providers
ALTER TABLE billing.provider_commission_rates
    ADD CONSTRAINT fk_provider_commission_rates_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- provider_commission_tiers.provider_commission_rate_id -> provider_commission_rates
ALTER TABLE billing.provider_commission_tiers
    ADD CONSTRAINT fk_provider_commission_tiers_rate
    FOREIGN KEY (provider_commission_rate_id) REFERENCES billing.provider_commission_rates(id) ON DELETE CASCADE;

-- provider_settlements.provider_id -> providers
ALTER TABLE billing.provider_settlements
    ADD CONSTRAINT fk_provider_settlements_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- provider_settlements.reconciled_by -> users
ALTER TABLE billing.provider_settlements
    ADD CONSTRAINT fk_provider_settlements_reconciled_by
    FOREIGN KEY (reconciled_by) REFERENCES security.users(id);

-- provider_settlement_tenants.provider_settlement_id -> provider_settlements
ALTER TABLE billing.provider_settlement_tenants
    ADD CONSTRAINT fk_provider_settlement_tenants_settlement
    FOREIGN KEY (provider_settlement_id) REFERENCES billing.provider_settlements(id) ON DELETE CASCADE;

-- provider_settlement_tenants.tenant_id -> tenants
ALTER TABLE billing.provider_settlement_tenants
    ADD CONSTRAINT fk_provider_settlement_tenants_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- provider_invoices.provider_id -> providers
ALTER TABLE billing.provider_invoices
    ADD CONSTRAINT fk_provider_invoices_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- provider_invoices.settlement_id -> provider_settlements
ALTER TABLE billing.provider_invoices
    ADD CONSTRAINT fk_provider_invoices_settlement
    FOREIGN KEY (settlement_id) REFERENCES billing.provider_settlements(id);

-- provider_invoices.approved_by -> users
ALTER TABLE billing.provider_invoices
    ADD CONSTRAINT fk_provider_invoices_approved_by
    FOREIGN KEY (approved_by) REFERENCES security.users(id);

-- provider_invoice_items.provider_invoice_id -> provider_invoices
ALTER TABLE billing.provider_invoice_items
    ADD CONSTRAINT fk_provider_invoice_items_invoice
    FOREIGN KEY (provider_invoice_id) REFERENCES billing.provider_invoices(id) ON DELETE CASCADE;

-- provider_invoice_items.tenant_id -> tenants
ALTER TABLE billing.provider_invoice_items
    ADD CONSTRAINT fk_provider_invoice_items_tenant
    FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);

-- provider_payments.provider_id -> providers
ALTER TABLE billing.provider_payments
    ADD CONSTRAINT fk_provider_payments_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- provider_payments.provider_invoice_id -> provider_invoices
ALTER TABLE billing.provider_payments
    ADD CONSTRAINT fk_provider_payments_invoice
    FOREIGN KEY (provider_invoice_id) REFERENCES billing.provider_invoices(id);

-- provider_payments.approved_by -> users
ALTER TABLE billing.provider_payments
    ADD CONSTRAINT fk_provider_payments_approved_by
    FOREIGN KEY (approved_by) REFERENCES security.users(id);

-- provider_payments.created_by -> users
ALTER TABLE billing.provider_payments
    ADD CONSTRAINT fk_provider_payments_created_by
    FOREIGN KEY (created_by) REFERENCES security.users(id);
