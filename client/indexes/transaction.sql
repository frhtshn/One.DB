-- =============================================
-- Client Transaction Schema Indexes
-- =============================================

-- operation_types
CREATE UNIQUE INDEX IF NOT EXISTS idx_operation_types_code ON transaction.operation_types USING btree(code);

-- transaction_types
CREATE UNIQUE INDEX IF NOT EXISTS idx_transaction_types_code ON transaction.transaction_types USING btree(code);

-- transactions (high-volume table - optimized indexes)
CREATE INDEX IF NOT EXISTS idx_transactions_player ON transaction.transactions USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_transactions_wallet ON transaction.transactions USING btree(wallet_id);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transaction.transactions USING btree(transaction_type_id);
CREATE INDEX IF NOT EXISTS idx_transactions_source ON transaction.transactions USING btree(source);
CREATE INDEX IF NOT EXISTS idx_transactions_created ON transaction.transactions USING btree(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_player_date ON transaction.transactions USING btree(player_id, created_at DESC);
CREATE UNIQUE INDEX IF NOT EXISTS idx_transactions_idempotency ON transaction.transactions USING btree(idempotency_key, created_at) WHERE idempotency_key IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_transactions_related ON transaction.transactions USING btree(related_transaction_id) WHERE related_transaction_id IS NOT NULL;

-- Yeni alanlar için indexler
CREATE INDEX IF NOT EXISTS idx_transactions_external_ref ON transaction.transactions USING btree(external_reference_id) WHERE external_reference_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_transactions_confirmed_at ON transaction.transactions USING btree(confirmed_at DESC);

-- Bonus award referansı (per-bonus harcama takibi)
CREATE INDEX IF NOT EXISTS idx_transactions_bonus_award ON transaction.transactions USING btree(bonus_award_id, created_at) WHERE bonus_award_id IS NOT NULL;

-- GIN Index (metadata)
CREATE INDEX IF NOT EXISTS idx_transactions_metadata_gin ON transaction.transactions USING gin(metadata);

-- transaction_workflows
CREATE UNIQUE INDEX IF NOT EXISTS idx_transaction_workflows_transaction ON transaction.transaction_workflows USING btree(transaction_id) WHERE transaction_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_transaction_workflows_status ON transaction.transaction_workflows USING btree(status);
CREATE INDEX IF NOT EXISTS idx_transaction_workflows_type ON transaction.transaction_workflows USING btree(workflow_type);
CREATE INDEX IF NOT EXISTS idx_transaction_workflows_pending ON transaction.transaction_workflows USING btree(status, created_at) WHERE status = 'PENDING';
CREATE INDEX IF NOT EXISTS idx_transaction_workflows_assigned ON transaction.transaction_workflows USING btree(assigned_to_id) WHERE assigned_to_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_transaction_workflows_creator ON transaction.transaction_workflows USING btree(created_by_id) WHERE created_by_id IS NOT NULL;

-- transaction_workflow_actions
CREATE INDEX IF NOT EXISTS idx_workflow_actions_workflow ON transaction.transaction_workflow_actions USING btree(workflow_id);
CREATE INDEX IF NOT EXISTS idx_workflow_actions_created ON transaction.transaction_workflow_actions USING btree(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_workflow_actions_actor ON transaction.transaction_workflow_actions USING btree(performed_by_id) WHERE performed_by_id IS NOT NULL;

-- payment_sessions
CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_sessions_token ON transaction.payment_sessions USING btree(session_token);
CREATE INDEX IF NOT EXISTS idx_payment_sessions_player ON transaction.payment_sessions USING btree(player_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_payment_sessions_active ON transaction.payment_sessions USING btree(status, created_at DESC) WHERE status IN ('created', 'processing', 'redirected', 'pending_approval');
CREATE INDEX IF NOT EXISTS idx_payment_sessions_expires ON transaction.payment_sessions USING btree(expires_at) WHERE status IN ('created', 'processing', 'redirected', 'pending_approval');
CREATE INDEX IF NOT EXISTS idx_payment_sessions_idempotency ON transaction.payment_sessions USING btree(idempotency_key, created_at) WHERE idempotency_key IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_payment_sessions_method_status ON transaction.payment_sessions USING btree(payment_method_id, status) WHERE payment_method_id IS NOT NULL;

-- transaction_adjustments
CREATE INDEX IF NOT EXISTS idx_tx_adjustments_player ON transaction.transaction_adjustments USING btree(player_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tx_adjustments_status ON transaction.transaction_adjustments USING btree(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tx_adjustments_pending ON transaction.transaction_adjustments USING btree(status) WHERE status = 'PENDING';
CREATE INDEX IF NOT EXISTS idx_tx_adjustments_workflow ON transaction.transaction_adjustments USING btree(workflow_id) WHERE workflow_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tx_adjustments_creator ON transaction.transaction_adjustments USING btree(created_by_id);
CREATE INDEX IF NOT EXISTS idx_tx_adjustments_type ON transaction.transaction_adjustments USING btree(adjustment_type);
CREATE INDEX IF NOT EXISTS idx_tx_adjustments_provider ON transaction.transaction_adjustments USING btree(provider_id) WHERE provider_id IS NOT NULL;
