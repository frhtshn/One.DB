-- =============================================
-- Tenant Transaction Schema Indexes
-- =============================================

-- transactions (high-volume table - optimized indexes)
CREATE INDEX idx_transactions_player ON transaction.transactions USING btree(player_id);
CREATE INDEX idx_transactions_wallet ON transaction.transactions USING btree(wallet_id);
CREATE INDEX idx_transactions_type ON transaction.transactions USING btree(transaction_type_id);
CREATE INDEX idx_transactions_source ON transaction.transactions USING btree(source);
CREATE INDEX idx_transactions_created ON transaction.transactions USING btree(created_at DESC);
CREATE INDEX idx_transactions_player_date ON transaction.transactions USING btree(player_id, created_at DESC);
CREATE UNIQUE INDEX idx_transactions_idempotency ON transaction.transactions USING btree(idempotency_key) WHERE idempotency_key IS NOT NULL;
CREATE INDEX idx_transactions_related ON transaction.transactions USING btree(related_transaction_id) WHERE related_transaction_id IS NOT NULL;

-- transaction_workflows
CREATE UNIQUE INDEX idx_transaction_workflows_transaction ON transaction.transaction_workflows USING btree(transaction_id);
CREATE INDEX idx_transaction_workflows_status ON transaction.transaction_workflows USING btree(status);
CREATE INDEX idx_transaction_workflows_type ON transaction.transaction_workflows USING btree(workflow_type);
CREATE INDEX idx_transaction_workflows_pending ON transaction.transaction_workflows USING btree(status, created_at) WHERE status = 'PENDING';
CREATE INDEX idx_transaction_workflows_assigned ON transaction.transaction_workflows USING btree(assigned_to_id) WHERE assigned_to_id IS NOT NULL;

-- transaction_workflow_actions
CREATE INDEX idx_workflow_actions_workflow ON transaction.transaction_workflow_actions USING btree(workflow_id);
CREATE INDEX idx_workflow_actions_created ON transaction.transaction_workflow_actions USING btree(created_at DESC);
