-- =============================================
-- Tenant Log KYC Schema Constraints
-- Using IF NOT EXISTS pattern for idempotent deploys
-- =============================================
-- NOTE: Cross-DB foreign keys are not possible in PostgreSQL.
-- player_id and kyc_case_id references are documented but not enforced at DB level.
-- Application layer must ensure referential integrity.
-- =============================================

-- player_kyc_provider_logs indexes for query performance
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_kyc_provider_logs_player') THEN
        CREATE INDEX idx_kyc_provider_logs_player ON kyc_log.player_kyc_provider_logs(player_id);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_kyc_provider_logs_case') THEN
        CREATE INDEX idx_kyc_provider_logs_case ON kyc_log.player_kyc_provider_logs(kyc_case_id);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_kyc_provider_logs_provider') THEN
        CREATE INDEX idx_kyc_provider_logs_provider ON kyc_log.player_kyc_provider_logs(provider_code, created_at DESC);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_kyc_provider_logs_status') THEN
        CREATE INDEX idx_kyc_provider_logs_status ON kyc_log.player_kyc_provider_logs(status)
        WHERE status = 'failed';
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_kyc_provider_logs_created') THEN
        CREATE INDEX idx_kyc_provider_logs_created ON kyc_log.player_kyc_provider_logs(created_at DESC);
    END IF;
END $$;
