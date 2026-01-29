-- =============================================
-- Tenant KYC Schema Foreign Key Constraints
-- =============================================

-- player_kyc_cases -> players
ALTER TABLE kyc.player_kyc_cases
    ADD CONSTRAINT fk_kyc_cases_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;

-- player_kyc_workflows -> player_kyc_cases
ALTER TABLE kyc.player_kyc_workflows
    ADD CONSTRAINT fk_kyc_workflows_case
    FOREIGN KEY (kyc_case_id) REFERENCES kyc.player_kyc_cases(id) ON DELETE CASCADE;

-- player_documents -> players
ALTER TABLE kyc.player_documents
    ADD CONSTRAINT fk_player_documents_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;

-- player_documents -> player_kyc_cases
ALTER TABLE kyc.player_documents
    ADD CONSTRAINT fk_player_documents_case
    FOREIGN KEY (kyc_case_id) REFERENCES kyc.player_kyc_cases(id) ON DELETE SET NULL;

-- player_kyc_provider_logs -> player_kyc_cases
ALTER TABLE kyc.player_kyc_provider_logs
    ADD CONSTRAINT fk_kyc_provider_logs_case
    FOREIGN KEY (kyc_case_id) REFERENCES kyc.player_kyc_cases(id) ON DELETE CASCADE;

-- player_limits -> players
ALTER TABLE kyc.player_limits
    ADD CONSTRAINT fk_player_limits_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;

-- player_restrictions -> players
ALTER TABLE kyc.player_restrictions
    ADD CONSTRAINT fk_player_restrictions_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;

-- player_limit_history -> players
ALTER TABLE kyc.player_limit_history
    ADD CONSTRAINT fk_player_limit_history_player
    FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE;
