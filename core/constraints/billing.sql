-- =============================================
-- Billing Schema Foreign Key Constraints
-- =============================================

-- CLIENT BILLING CONSTRAINTS

-- client_billing_periods.calculated_by -> users
ALTER TABLE billing.client_billing_periods
    DROP CONSTRAINT IF EXISTS fk_billing_periods_calculated_by;
ALTER TABLE billing.client_billing_periods
    ADD CONSTRAINT fk_billing_periods_calculated_by
    FOREIGN KEY (calculated_by) REFERENCES security.users(id);

-- client_billing_periods.closed_by -> users
ALTER TABLE billing.client_billing_periods
    DROP CONSTRAINT IF EXISTS fk_billing_periods_closed_by;
ALTER TABLE billing.client_billing_periods
    ADD CONSTRAINT fk_billing_periods_closed_by
    FOREIGN KEY (closed_by) REFERENCES security.users(id);

-- client_commission_rates.provider_id -> providers
ALTER TABLE billing.client_commission_rates
    DROP CONSTRAINT IF EXISTS fk_client_commission_rates_provider;
ALTER TABLE billing.client_commission_rates
    ADD CONSTRAINT fk_client_commission_rates_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- client_commission_rate_tiers.rate_id -> client_commission_rates
ALTER TABLE billing.client_commission_rate_tiers
    DROP CONSTRAINT IF EXISTS fk_client_commission_rate_tiers_rate;
ALTER TABLE billing.client_commission_rate_tiers
    ADD CONSTRAINT fk_client_commission_rate_tiers_rate
    FOREIGN KEY (rate_id) REFERENCES billing.client_commission_rates(id) ON DELETE CASCADE;

-- client_commission_plans.client_id -> clients
ALTER TABLE billing.client_commission_plans
    DROP CONSTRAINT IF EXISTS fk_client_commission_plans_client;
ALTER TABLE billing.client_commission_plans
    ADD CONSTRAINT fk_client_commission_plans_client
    FOREIGN KEY (client_id) REFERENCES core.clients(id);

-- client_commission_plans.provider_id -> providers
ALTER TABLE billing.client_commission_plans
    DROP CONSTRAINT IF EXISTS fk_client_commission_plans_provider;
ALTER TABLE billing.client_commission_plans
    ADD CONSTRAINT fk_client_commission_plans_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- client_commission_plans.source_rate_id -> client_commission_rates
ALTER TABLE billing.client_commission_plans
    DROP CONSTRAINT IF EXISTS fk_client_commission_plans_source_rate;
ALTER TABLE billing.client_commission_plans
    ADD CONSTRAINT fk_client_commission_plans_source_rate
    FOREIGN KEY (source_rate_id) REFERENCES billing.client_commission_rates(id);

-- client_commission_plans.created_by -> users
ALTER TABLE billing.client_commission_plans
    DROP CONSTRAINT IF EXISTS fk_client_commission_plans_created_by;
ALTER TABLE billing.client_commission_plans
    ADD CONSTRAINT fk_client_commission_plans_created_by
    FOREIGN KEY (created_by) REFERENCES security.users(id);

-- client_commission_plan_tiers.client_commission_plan_id -> client_commission_plans
ALTER TABLE billing.client_commission_plan_tiers
    DROP CONSTRAINT IF EXISTS fk_client_commission_plan_tiers_plan;
ALTER TABLE billing.client_commission_plan_tiers
    ADD CONSTRAINT fk_client_commission_plan_tiers_plan
    FOREIGN KEY (client_commission_plan_id) REFERENCES billing.client_commission_plans(id) ON DELETE CASCADE;

-- client_commission_aggregates.client_id -> clients
ALTER TABLE billing.client_commission_aggregates
    DROP CONSTRAINT IF EXISTS fk_client_commission_aggregates_client;
ALTER TABLE billing.client_commission_aggregates
    ADD CONSTRAINT fk_client_commission_aggregates_client
    FOREIGN KEY (client_id) REFERENCES core.clients(id);

-- client_commission_aggregates.provider_id -> providers
ALTER TABLE billing.client_commission_aggregates
    DROP CONSTRAINT IF EXISTS fk_client_commission_aggregates_provider;
ALTER TABLE billing.client_commission_aggregates
    ADD CONSTRAINT fk_client_commission_aggregates_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- client_commissions.client_id -> clients
ALTER TABLE billing.client_commissions
    DROP CONSTRAINT IF EXISTS fk_client_commissions_client;
ALTER TABLE billing.client_commissions
    ADD CONSTRAINT fk_client_commissions_client
    FOREIGN KEY (client_id) REFERENCES core.clients(id);

-- client_commissions.provider_id -> providers
ALTER TABLE billing.client_commissions
    DROP CONSTRAINT IF EXISTS fk_client_commissions_provider;
ALTER TABLE billing.client_commissions
    ADD CONSTRAINT fk_client_commissions_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- client_commissions.aggregate_id -> client_commission_aggregates
ALTER TABLE billing.client_commissions
    DROP CONSTRAINT IF EXISTS fk_client_commissions_aggregate;
ALTER TABLE billing.client_commissions
    ADD CONSTRAINT fk_client_commissions_aggregate
    FOREIGN KEY (aggregate_id) REFERENCES billing.client_commission_aggregates(id);

-- client_commissions.commission_plan_id -> client_commission_plans
ALTER TABLE billing.client_commissions
    DROP CONSTRAINT IF EXISTS fk_client_commissions_plan;
ALTER TABLE billing.client_commissions
    ADD CONSTRAINT fk_client_commissions_plan
    FOREIGN KEY (commission_plan_id) REFERENCES billing.client_commission_plans(id);

-- client_commissions.approved_by -> users
ALTER TABLE billing.client_commissions
    DROP CONSTRAINT IF EXISTS fk_client_commissions_approved_by;
ALTER TABLE billing.client_commissions
    ADD CONSTRAINT fk_client_commissions_approved_by
    FOREIGN KEY (approved_by) REFERENCES security.users(id);

-- client_commissions.invoice_id -> client_invoices
ALTER TABLE billing.client_commissions
    DROP CONSTRAINT IF EXISTS fk_client_commissions_invoice;
ALTER TABLE billing.client_commissions
    ADD CONSTRAINT fk_client_commissions_invoice
    FOREIGN KEY (invoice_id) REFERENCES billing.client_invoices(id);

-- client_commissions.invoice_item_id -> client_invoice_items
ALTER TABLE billing.client_commissions
    DROP CONSTRAINT IF EXISTS fk_client_commissions_invoice_item;
ALTER TABLE billing.client_commissions
    ADD CONSTRAINT fk_client_commissions_invoice_item
    FOREIGN KEY (invoice_item_id) REFERENCES billing.client_invoice_items(id);

-- client_invoices.client_id -> clients
ALTER TABLE billing.client_invoices
    DROP CONSTRAINT IF EXISTS fk_client_invoices_client;
ALTER TABLE billing.client_invoices
    ADD CONSTRAINT fk_client_invoices_client
    FOREIGN KEY (client_id) REFERENCES core.clients(id);

-- client_invoices.cancelled_by -> users
ALTER TABLE billing.client_invoices
    DROP CONSTRAINT IF EXISTS fk_client_invoices_cancelled_by;
ALTER TABLE billing.client_invoices
    ADD CONSTRAINT fk_client_invoices_cancelled_by
    FOREIGN KEY (cancelled_by) REFERENCES security.users(id);

-- client_invoices.created_by -> users
ALTER TABLE billing.client_invoices
    DROP CONSTRAINT IF EXISTS fk_client_invoices_created_by;
ALTER TABLE billing.client_invoices
    ADD CONSTRAINT fk_client_invoices_created_by
    FOREIGN KEY (created_by) REFERENCES security.users(id);

-- client_invoice_items.client_invoice_id -> client_invoices
ALTER TABLE billing.client_invoice_items
    DROP CONSTRAINT IF EXISTS fk_client_invoice_items_invoice;
ALTER TABLE billing.client_invoice_items
    ADD CONSTRAINT fk_client_invoice_items_invoice
    FOREIGN KEY (client_invoice_id) REFERENCES billing.client_invoices(id) ON DELETE CASCADE;

-- client_invoice_items.client_commission_id -> client_commissions
ALTER TABLE billing.client_invoice_items
    DROP CONSTRAINT IF EXISTS fk_client_invoice_items_commission;
ALTER TABLE billing.client_invoice_items
    ADD CONSTRAINT fk_client_invoice_items_commission
    FOREIGN KEY (client_commission_id) REFERENCES billing.client_commissions(id);

-- client_invoice_payments.client_invoice_id -> client_invoices
ALTER TABLE billing.client_invoice_payments
    DROP CONSTRAINT IF EXISTS fk_client_invoice_payments_invoice;
ALTER TABLE billing.client_invoice_payments
    ADD CONSTRAINT fk_client_invoice_payments_invoice
    FOREIGN KEY (client_invoice_id) REFERENCES billing.client_invoices(id);

-- client_invoice_payments.recorded_by -> users
ALTER TABLE billing.client_invoice_payments
    DROP CONSTRAINT IF EXISTS fk_client_invoice_payments_recorded_by;
ALTER TABLE billing.client_invoice_payments
    ADD CONSTRAINT fk_client_invoice_payments_recorded_by
    FOREIGN KEY (recorded_by) REFERENCES security.users(id);


-- PROVIDER BILLING CONSTRAINTS

-- provider_commission_rates.provider_id -> providers
ALTER TABLE billing.provider_commission_rates
    DROP CONSTRAINT IF EXISTS fk_provider_commission_rates_provider;
ALTER TABLE billing.provider_commission_rates
    ADD CONSTRAINT fk_provider_commission_rates_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- provider_commission_tiers.provider_commission_rate_id -> provider_commission_rates
ALTER TABLE billing.provider_commission_tiers
    DROP CONSTRAINT IF EXISTS fk_provider_commission_tiers_rate;
ALTER TABLE billing.provider_commission_tiers
    ADD CONSTRAINT fk_provider_commission_tiers_rate
    FOREIGN KEY (provider_commission_rate_id) REFERENCES billing.provider_commission_rates(id) ON DELETE CASCADE;

-- provider_settlements.provider_id -> providers
ALTER TABLE billing.provider_settlements
    DROP CONSTRAINT IF EXISTS fk_provider_settlements_provider;
ALTER TABLE billing.provider_settlements
    ADD CONSTRAINT fk_provider_settlements_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- provider_settlements.reconciled_by -> users
ALTER TABLE billing.provider_settlements
    DROP CONSTRAINT IF EXISTS fk_provider_settlements_reconciled_by;
ALTER TABLE billing.provider_settlements
    ADD CONSTRAINT fk_provider_settlements_reconciled_by
    FOREIGN KEY (reconciled_by) REFERENCES security.users(id);

-- provider_settlement_clients.provider_settlement_id -> provider_settlements
ALTER TABLE billing.provider_settlement_clients
    DROP CONSTRAINT IF EXISTS fk_provider_settlement_clients_settlement;
ALTER TABLE billing.provider_settlement_clients
    ADD CONSTRAINT fk_provider_settlement_clients_settlement
    FOREIGN KEY (provider_settlement_id) REFERENCES billing.provider_settlements(id) ON DELETE CASCADE;

-- provider_settlement_clients.client_id -> clients
ALTER TABLE billing.provider_settlement_clients
    DROP CONSTRAINT IF EXISTS fk_provider_settlement_clients_client;
ALTER TABLE billing.provider_settlement_clients
    ADD CONSTRAINT fk_provider_settlement_clients_client
    FOREIGN KEY (client_id) REFERENCES core.clients(id);

-- provider_invoices.provider_id -> providers
ALTER TABLE billing.provider_invoices
    DROP CONSTRAINT IF EXISTS fk_provider_invoices_provider;
ALTER TABLE billing.provider_invoices
    ADD CONSTRAINT fk_provider_invoices_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- provider_invoices.settlement_id -> provider_settlements
ALTER TABLE billing.provider_invoices
    DROP CONSTRAINT IF EXISTS fk_provider_invoices_settlement;
ALTER TABLE billing.provider_invoices
    ADD CONSTRAINT fk_provider_invoices_settlement
    FOREIGN KEY (settlement_id) REFERENCES billing.provider_settlements(id);

-- provider_invoices.approved_by -> users
ALTER TABLE billing.provider_invoices
    DROP CONSTRAINT IF EXISTS fk_provider_invoices_approved_by;
ALTER TABLE billing.provider_invoices
    ADD CONSTRAINT fk_provider_invoices_approved_by
    FOREIGN KEY (approved_by) REFERENCES security.users(id);

-- provider_invoice_items.provider_invoice_id -> provider_invoices
ALTER TABLE billing.provider_invoice_items
    DROP CONSTRAINT IF EXISTS fk_provider_invoice_items_invoice;
ALTER TABLE billing.provider_invoice_items
    ADD CONSTRAINT fk_provider_invoice_items_invoice
    FOREIGN KEY (provider_invoice_id) REFERENCES billing.provider_invoices(id) ON DELETE CASCADE;

-- provider_invoice_items.client_id -> clients
ALTER TABLE billing.provider_invoice_items
    DROP CONSTRAINT IF EXISTS fk_provider_invoice_items_client;
ALTER TABLE billing.provider_invoice_items
    ADD CONSTRAINT fk_provider_invoice_items_client
    FOREIGN KEY (client_id) REFERENCES core.clients(id);

-- provider_payments.provider_id -> providers
ALTER TABLE billing.provider_payments
    DROP CONSTRAINT IF EXISTS fk_provider_payments_provider;
ALTER TABLE billing.provider_payments
    ADD CONSTRAINT fk_provider_payments_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- provider_payments.provider_invoice_id -> provider_invoices
ALTER TABLE billing.provider_payments
    DROP CONSTRAINT IF EXISTS fk_provider_payments_invoice;
ALTER TABLE billing.provider_payments
    ADD CONSTRAINT fk_provider_payments_invoice
    FOREIGN KEY (provider_invoice_id) REFERENCES billing.provider_invoices(id);

-- provider_payments.approved_by -> users
ALTER TABLE billing.provider_payments
    DROP CONSTRAINT IF EXISTS fk_provider_payments_approved_by;
ALTER TABLE billing.provider_payments
    ADD CONSTRAINT fk_provider_payments_approved_by
    FOREIGN KEY (approved_by) REFERENCES security.users(id);

-- provider_payments.created_by -> users
ALTER TABLE billing.provider_payments
    DROP CONSTRAINT IF EXISTS fk_provider_payments_created_by;
ALTER TABLE billing.provider_payments
    ADD CONSTRAINT fk_provider_payments_created_by
    FOREIGN KEY (created_by) REFERENCES security.users(id);
