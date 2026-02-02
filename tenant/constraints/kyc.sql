-- =============================================
-- Tenant KYC Schema Foreign Key Constraints
-- Using IF NOT EXISTS pattern for idempotent deploys
-- =============================================

-- player_kyc_cases -> players
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_kyc_cases_player') THEN
        ALTER TABLE kyc.player_kyc_cases ADD CONSTRAINT fk_kyc_cases_player
            FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;
    END IF;
END $$;

-- player_kyc_workflows -> player_kyc_cases
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_kyc_workflows_case') THEN
        ALTER TABLE kyc.player_kyc_workflows ADD CONSTRAINT fk_kyc_workflows_case
            FOREIGN KEY (kyc_case_id) REFERENCES kyc.player_kyc_cases(id) ON DELETE CASCADE;
    END IF;
END $$;

-- player_documents -> players
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_player_documents_player') THEN
        ALTER TABLE kyc.player_documents ADD CONSTRAINT fk_player_documents_player
            FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;
    END IF;
END $$;

-- player_documents -> player_kyc_cases
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_player_documents_case') THEN
        ALTER TABLE kyc.player_documents ADD CONSTRAINT fk_player_documents_case
            FOREIGN KEY (kyc_case_id) REFERENCES kyc.player_kyc_cases(id) ON DELETE SET NULL;
    END IF;
END $$;

-- player_kyc_provider_logs -> player_kyc_cases
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_kyc_provider_logs_case') THEN
        ALTER TABLE kyc.player_kyc_provider_logs ADD CONSTRAINT fk_kyc_provider_logs_case
            FOREIGN KEY (kyc_case_id) REFERENCES kyc.player_kyc_cases(id) ON DELETE CASCADE;
    END IF;
END $$;

-- player_limits -> players
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_player_limits_player') THEN
        ALTER TABLE kyc.player_limits ADD CONSTRAINT fk_player_limits_player
            FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;
    END IF;
END $$;

-- player_restrictions -> players
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_player_restrictions_player') THEN
        ALTER TABLE kyc.player_restrictions ADD CONSTRAINT fk_player_restrictions_player
            FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;
    END IF;
END $$;

-- player_limit_history -> players
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_player_limit_history_player') THEN
        ALTER TABLE kyc.player_limit_history ADD CONSTRAINT fk_player_limit_history_player
            FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;
    END IF;
END $$;

-- =============================================
-- New KYC Tables Constraints (Jurisdiction, AML)
-- NOTE: player_screening_results, player_risk_assessments -> tenant_audit DB (no cross-DB FK)
-- NOTE: player_kyc_provider_logs -> tenant_log DB (no cross-DB FK)
-- =============================================

-- player_jurisdiction -> players
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_player_jurisdiction_player') THEN
        ALTER TABLE kyc.player_jurisdiction ADD CONSTRAINT fk_player_jurisdiction_player
            FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;
    END IF;
END $$;

-- player_aml_flags -> players
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_player_aml_flags_player') THEN
        ALTER TABLE kyc.player_aml_flags ADD CONSTRAINT fk_player_aml_flags_player
            FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;
    END IF;
END $$;
