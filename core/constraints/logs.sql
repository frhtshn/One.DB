-- =============================================
-- Core Log - Logs Schema Constraints
-- =============================================

-- dead_letter_messages -> status check
DO $$ BEGIN
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_dead_letter_status') THEN
        ALTER TABLE logs.dead_letter_messages DROP CONSTRAINT chk_dead_letter_status;
    END IF;
END $$;

ALTER TABLE logs.dead_letter_messages ADD CONSTRAINT chk_dead_letter_status
    CHECK (status IN (
        'pending', 'retrying', 'resolved', 'failed',
        'validation_failed', 'max_retry_exceeded', 'archived', 'ignored'
    ));

-- dead_letter_messages -> failure_category check
DO $$ BEGIN
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_dead_letter_failure_category') THEN
        ALTER TABLE logs.dead_letter_messages DROP CONSTRAINT chk_dead_letter_failure_category;
    END IF;
END $$;

ALTER TABLE logs.dead_letter_messages ADD CONSTRAINT chk_dead_letter_failure_category
    CHECK (failure_category IS NULL OR failure_category IN (
        'validation', 'timeout', 'database', 'network',
        'serialization', 'authorization', 'business_rule',
        'dependency', 'unknown'
    ));
