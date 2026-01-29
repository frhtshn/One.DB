-- =============================================
-- Core Log - Logs Schema Constraints
-- =============================================

-- logs.dead_letter_messages -> status check
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_dead_letter_status') THEN
        ALTER TABLE logs.dead_letter_messages ADD CONSTRAINT chk_dead_letter_status
            CHECK (status IN ('pending', 'retrying', 'resolved', 'failed'));
    END IF;
END $$;
