-- =============================================
-- Tenant Log Bonus Log Schema Indexes
-- =============================================

-- bonus_evaluation_logs — oyuncu bazlı sorgulama
CREATE INDEX IF NOT EXISTS idx_bonus_eval_logs_player ON bonus_log.bonus_evaluation_logs USING btree(player_id, created_at);

-- bonus_evaluation_logs — kural bazlı sorgulama
CREATE INDEX IF NOT EXISTS idx_bonus_eval_logs_rule ON bonus_log.bonus_evaluation_logs USING btree(bonus_rule_id, created_at);

-- bonus_evaluation_logs — sonuç bazlı filtreleme (awarded/rejected/error analizi)
CREATE INDEX IF NOT EXISTS idx_bonus_eval_logs_result ON bonus_log.bonus_evaluation_logs USING btree(evaluation_result, created_at);

-- bonus_evaluation_logs — event tipi bazlı sorgulama
CREATE INDEX IF NOT EXISTS idx_bonus_eval_logs_trigger ON bonus_log.bonus_evaluation_logs USING btree(trigger_event, created_at);
