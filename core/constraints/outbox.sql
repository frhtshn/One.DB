-- =============================================
-- Outbox Schema Constraints
-- Using IF NOT EXISTS pattern for idempotent deploys
-- =============================================

-- Status check constraint
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_outbox_status') THEN
        ALTER TABLE outbox.messages ADD CONSTRAINT chk_outbox_status
            CHECK (status IN ('pending', 'processing', 'completed', 'failed'));
    END IF;
END $$;

-- Action type check constraint
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_outbox_action_type') THEN
        ALTER TABLE outbox.messages ADD CONSTRAINT chk_outbox_action_type
            CHECK (action_type IN ('cache_invalidate', 'event_publish'));
    END IF;
END $$;

-- Retry count must be non-negative
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_outbox_retry_count') THEN
        ALTER TABLE outbox.messages ADD CONSTRAINT chk_outbox_retry_count
            CHECK (retry_count >= 0 AND retry_count <= max_retries);
    END IF;
END $$;
