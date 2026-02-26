-- ================================================================
-- PLAYER_SCORE_UPSERT: Oyuncu risk skoru yazma/güncelleme
-- ================================================================
-- Oyuncu risk skorunu yazar veya günceller. high_risk_count ve
-- evaluation_count atomik olarak artırılır.
-- first_evaluated_at sadece ilk INSERT'te set edilir.
-- ================================================================

DROP FUNCTION IF EXISTS risk.player_score_upsert(INT, BIGINT, NUMERIC, VARCHAR, JSONB, JSONB, VARCHAR, TIMESTAMPTZ);

CREATE OR REPLACE FUNCTION risk.player_score_upsert(
    p_tenant_id          INT,
    p_player_id          BIGINT,
    p_anomaly_score      NUMERIC(5,4),
    p_risk_level         VARCHAR(10),
    p_pattern_deviations JSONB,
    p_zscore_details     JSONB,
    p_model_version      VARCHAR(50),
    p_evaluated_at       TIMESTAMPTZ
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO risk.risk_player_scores (
        tenant_id, player_id,
        anomaly_score, risk_level, pattern_deviations, zscore_details,
        model_version, high_risk_count, evaluation_count,
        evaluated_at, first_evaluated_at
    ) VALUES (
        p_tenant_id, p_player_id,
        p_anomaly_score, p_risk_level, p_pattern_deviations, p_zscore_details,
        p_model_version,
        CASE WHEN p_risk_level = 'high' THEN 1 ELSE 0 END,
        1,
        p_evaluated_at, p_evaluated_at
    )
    ON CONFLICT (tenant_id, player_id) DO UPDATE SET
        anomaly_score      = EXCLUDED.anomaly_score,
        risk_level         = EXCLUDED.risk_level,
        pattern_deviations = EXCLUDED.pattern_deviations,
        zscore_details     = EXCLUDED.zscore_details,
        model_version      = EXCLUDED.model_version,
        high_risk_count    = risk.risk_player_scores.high_risk_count
                             + CASE WHEN EXCLUDED.risk_level = 'high' THEN 1 ELSE 0 END,
        evaluation_count   = risk.risk_player_scores.evaluation_count + 1,
        evaluated_at       = EXCLUDED.evaluated_at;
END;
$$;

COMMENT ON FUNCTION risk.player_score_upsert(INT, BIGINT, NUMERIC, VARCHAR, JSONB, JSONB, VARCHAR, TIMESTAMPTZ) IS
'Upserts a player risk score. Atomically increments high_risk_count (when HIGH) and evaluation_count. first_evaluated_at is set only on initial insert.
Access: RiskManager (EXECUTE).
Returns: void.';
