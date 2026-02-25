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

-- NOTE: player_kyc_provider_logs -> tenant_log DB (cross-DB FK uygulanamaz, app-level kontrol)

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

-- =============================================
-- IDManager Document Analysis & Decisions
-- =============================================

-- player_kyc_cases -> player_documents (selfie)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_kyc_cases_selfie') THEN
        ALTER TABLE kyc.player_kyc_cases ADD CONSTRAINT fk_kyc_cases_selfie
            FOREIGN KEY (selfie_document_id) REFERENCES kyc.player_documents(id) ON DELETE SET NULL;
    END IF;
END $$;

-- document_analysis -> players
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_document_analysis_player') THEN
        ALTER TABLE kyc.document_analysis ADD CONSTRAINT fk_document_analysis_player
            FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;
    END IF;
END $$;

-- document_analysis -> player_kyc_cases
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_document_analysis_case') THEN
        ALTER TABLE kyc.document_analysis ADD CONSTRAINT fk_document_analysis_case
            FOREIGN KEY (kyc_case_id) REFERENCES kyc.player_kyc_cases(id) ON DELETE CASCADE;
    END IF;
END $$;

-- document_analysis -> player_documents
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_document_analysis_document') THEN
        ALTER TABLE kyc.document_analysis ADD CONSTRAINT fk_document_analysis_document
            FOREIGN KEY (document_id) REFERENCES kyc.player_documents(id) ON DELETE CASCADE;
    END IF;
END $$;

-- document_decisions -> players
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_document_decisions_player') THEN
        ALTER TABLE kyc.document_decisions ADD CONSTRAINT fk_document_decisions_player
            FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;
    END IF;
END $$;

-- document_decisions -> player_kyc_cases
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_document_decisions_case') THEN
        ALTER TABLE kyc.document_decisions ADD CONSTRAINT fk_document_decisions_case
            FOREIGN KEY (kyc_case_id) REFERENCES kyc.player_kyc_cases(id) ON DELETE CASCADE;
    END IF;
END $$;

-- document_decisions -> player_documents
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_document_decisions_document') THEN
        ALTER TABLE kyc.document_decisions ADD CONSTRAINT fk_document_decisions_document
            FOREIGN KEY (document_id) REFERENCES kyc.player_documents(id) ON DELETE CASCADE;
    END IF;
END $$;

-- document_decisions -> document_analysis (opsiyonel bağlantı)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_document_decisions_analysis') THEN
        ALTER TABLE kyc.document_decisions ADD CONSTRAINT fk_document_decisions_analysis
            FOREIGN KEY (analysis_id) REFERENCES kyc.document_analysis(id) ON DELETE SET NULL;
    END IF;
END $$;
