-- =============================================
-- Outbox Schema Indexes
-- Using IF NOT EXISTS pattern for idempotent deploys
-- =============================================

-- Primary index: Pending messages for processing (most critical)
-- Worker polls this: WHERE status = 'pending' ORDER BY sequence_number
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_outbox_pending') THEN
        CREATE INDEX idx_outbox_pending ON outbox.messages (sequence_number)
        WHERE status = 'pending';
    END IF;
END $$;

-- Retry index: Messages ready for retry
-- Worker polls: WHERE status = 'failed' AND next_retry_at <= now() AND retry_count < max_retries
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_outbox_retry') THEN
        CREATE INDEX idx_outbox_retry ON outbox.messages (next_retry_at)
        WHERE status = 'failed' AND retry_count < max_retries;
    END IF;
END $$;

-- Action type index: For filtering by action type
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_outbox_action_type') THEN
        CREATE INDEX idx_outbox_action_type ON outbox.messages (action_type, status);
    END IF;
END $$;

-- Aggregate lookup: Find messages for specific entity
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_outbox_aggregate') THEN
        CREATE INDEX idx_outbox_aggregate ON outbox.messages (aggregate_type, aggregate_id);
    END IF;
END $$;

-- Client index: For client-specific queries
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_outbox_client') THEN
        CREATE INDEX idx_outbox_client ON outbox.messages (client_id)
        WHERE client_id IS NOT NULL;
    END IF;
END $$;

-- Correlation ID: For distributed tracing
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_outbox_correlation') THEN
        CREATE INDEX idx_outbox_correlation ON outbox.messages (correlation_id);
    END IF;
END $$;

-- Cleanup index: For archiving/deleting old completed messages
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_outbox_cleanup') THEN
        CREATE INDEX idx_outbox_cleanup ON outbox.messages (processed_at)
        WHERE status = 'completed';
    END IF;
END $$;
