-- =============================================
-- Tenant Audit KYC Schema Constraints
-- Using IF NOT EXISTS pattern for idempotent deploys
-- =============================================
-- NOTE: Cross-DB foreign keys are not possible in PostgreSQL.
-- player_id references are documented but not enforced at DB level.
-- Application layer must ensure referential integrity.
-- =============================================

-- player_screening_results indexes for query performance
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_screening_player') THEN
        CREATE INDEX idx_screening_player ON kyc_audit.player_screening_results(player_id);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_screening_type_status') THEN
        CREATE INDEX idx_screening_type_status ON kyc_audit.player_screening_results(screening_type, result_status);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_screening_review_pending') THEN
        CREATE INDEX idx_screening_review_pending ON kyc_audit.player_screening_results(review_status)
        WHERE review_status = 'pending';
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_screening_provider') THEN
        CREATE INDEX idx_screening_provider ON kyc_audit.player_screening_results(provider_code, screened_at);
    END IF;
END $$;

-- player_risk_assessments indexes for query performance
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_risk_player') THEN
        CREATE INDEX idx_risk_player ON kyc_audit.player_risk_assessments(player_id);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_risk_level') THEN
        CREATE INDEX idx_risk_level ON kyc_audit.player_risk_assessments(risk_level);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_risk_type_created') THEN
        CREATE INDEX idx_risk_type_created ON kyc_audit.player_risk_assessments(assessment_type, created_at DESC);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_risk_high_critical') THEN
        CREATE INDEX idx_risk_high_critical ON kyc_audit.player_risk_assessments(risk_level, requires_approval)
        WHERE risk_level IN ('high', 'critical');
    END IF;
END $$;

-- Unique constraint: Only one valid assessment per player at a time
-- (superseded_by IS NULL means it's the current valid assessment)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_risk_current_valid') THEN
        CREATE UNIQUE INDEX idx_risk_current_valid ON kyc_audit.player_risk_assessments(player_id)
        WHERE superseded_by IS NULL;
    END IF;
END $$;
