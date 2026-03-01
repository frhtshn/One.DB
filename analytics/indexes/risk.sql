-- =============================================
-- Risk Schema Indexes
-- =============================================

-- risk_player_scores — BO Operator dashboard filtresi
CREATE INDEX IF NOT EXISTS idx_risk_player_scores_risk_level
    ON risk.risk_player_scores USING btree(client_id, risk_level);
