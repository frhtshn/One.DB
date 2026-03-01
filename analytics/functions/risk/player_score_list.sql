-- ================================================================
-- PLAYER_SCORE_LIST: Oyuncu risk skoru listesi (dashboard)
-- ================================================================
-- BO Cluster tarafından çağrılır. Dashboard'da risk seviyesine
-- göre filtrelenmiş oyuncu listesi döner. anomaly_score DESC
-- sıralı.
-- ================================================================

DROP FUNCTION IF EXISTS risk.player_score_list(INT, VARCHAR);

CREATE OR REPLACE FUNCTION risk.player_score_list(
    p_client_id  INT,
    p_risk_level VARCHAR(10) DEFAULT NULL
)
RETURNS TABLE (
    client_id          INT,
    player_id          BIGINT,
    anomaly_score      NUMERIC(5,4),
    risk_level         VARCHAR(10),
    pattern_deviations JSONB,
    model_version      VARCHAR(50),
    high_risk_count    INT,
    evaluation_count   INT,
    evaluated_at       TIMESTAMPTZ
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        rps.client_id, rps.player_id,
        rps.anomaly_score, rps.risk_level,
        rps.pattern_deviations, rps.model_version,
        rps.high_risk_count, rps.evaluation_count,
        rps.evaluated_at
    FROM risk.risk_player_scores rps
    WHERE rps.client_id = p_client_id
      AND (p_risk_level IS NULL OR rps.risk_level = p_risk_level)
    ORDER BY rps.anomaly_score DESC;
END;
$$;

COMMENT ON FUNCTION risk.player_score_list(INT, VARCHAR) IS
'Returns player risk scores for a client, optionally filtered by risk level. Ordered by anomaly_score descending. Used by BO Cluster operator dashboard.
Access: Backoffice Cluster (EXECUTE).
Returns: Filtered list of player scores.';
