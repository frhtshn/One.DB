-- ================================================================
-- PLAYER_SCORE_GET: Tekil oyuncu risk skoru sorgulama
-- ================================================================
-- BO Cluster tarafından çağrılır. Redis miss durumunda tek
-- oyuncunun güncel risk skorunu döner (PK lookup).
-- ================================================================

DROP FUNCTION IF EXISTS risk.player_score_get(INT, BIGINT);

CREATE OR REPLACE FUNCTION risk.player_score_get(
    p_tenant_id INT,
    p_player_id BIGINT
)
RETURNS TABLE (
    tenant_id          INT,
    player_id          BIGINT,
    anomaly_score      NUMERIC(5,4),
    risk_level         VARCHAR(10),
    pattern_deviations JSONB,
    zscore_details     JSONB,
    model_version      VARCHAR(50),
    high_risk_count    INT,
    evaluation_count   INT,
    evaluated_at       TIMESTAMPTZ,
    first_evaluated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        rps.tenant_id, rps.player_id,
        rps.anomaly_score, rps.risk_level,
        rps.pattern_deviations, rps.zscore_details,
        rps.model_version, rps.high_risk_count, rps.evaluation_count,
        rps.evaluated_at, rps.first_evaluated_at
    FROM risk.risk_player_scores rps
    WHERE rps.tenant_id = p_tenant_id
      AND rps.player_id = p_player_id;
END;
$$;

COMMENT ON FUNCTION risk.player_score_get(INT, BIGINT) IS
'Returns a single player risk score by PK lookup. Called by BO Cluster as Redis miss fallback.
Access: Backoffice Cluster (EXECUTE).
Returns: Single row or empty if player has no score.';
