-- =============================================
-- Risk Schema Constraints
-- =============================================
-- FK yok — tablolar bağımsız, cross-DB erişim yok
-- CHECK constraints — veri bütünlüğü

-- risk_player_scores — risk seviyesi değer kontrolü
ALTER TABLE risk.risk_player_scores
    ADD CONSTRAINT chk_risk_player_scores_risk_level
    CHECK (risk_level IN ('low', 'medium', 'high'));

-- risk_player_scores — anomaly skoru 0-1 aralığında
ALTER TABLE risk.risk_player_scores
    ADD CONSTRAINT chk_risk_player_scores_anomaly_score
    CHECK (anomaly_score >= 0 AND anomaly_score <= 1);

-- risk_player_scores — sayaçlar negatif olamaz
ALTER TABLE risk.risk_player_scores
    ADD CONSTRAINT chk_risk_player_scores_counters
    CHECK (high_risk_count >= 0 AND evaluation_count >= 0);

-- risk_player_baselines — currency_count en az 1
ALTER TABLE risk.risk_player_baselines
    ADD CONSTRAINT chk_risk_player_baselines_currency_count
    CHECK (currency_count >= 1);
