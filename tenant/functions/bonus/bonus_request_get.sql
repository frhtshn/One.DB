-- ================================================================
-- BONUS_REQUEST_GET: Tekil bonus talebi detayı
-- ================================================================
-- Talep bilgilerini aksiyon geçmişi ile birlikte döner.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_request_get(BIGINT);

CREATE OR REPLACE FUNCTION bonus.bonus_request_get(
    p_request_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result    JSONB;
    v_actions   JSONB;
BEGIN
    -- Talep bilgisi
    SELECT jsonb_build_object(
        'id', r.id,
        'playerId', r.player_id,
        'requestSource', r.request_source,
        'requestType', r.request_type,
        'requestedAmount', r.requested_amount,
        'currency', r.currency,
        'description', r.description,
        'supportingData', r.supporting_data,
        'status', r.status,
        'priority', r.priority,
        'assignedToId', r.assigned_to_id,
        'assignedAt', r.assigned_at,
        'reviewedById', r.reviewed_by_id,
        'reviewNote', r.review_note,
        'reviewedAt', r.reviewed_at,
        'approvedAmount', r.approved_amount,
        'approvedCurrency', r.approved_currency,
        'approvedBonusType', r.approved_bonus_type,
        'bonusRuleId', r.bonus_rule_id,
        'bonusAwardId', r.bonus_award_id,
        'requestedById', r.requested_by_id,
        'expiresAt', r.expires_at,
        'createdAt', r.created_at,
        'updatedAt', r.updated_at
    )
    INTO v_result
    FROM bonus.bonus_requests r
    WHERE r.id = p_request_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-request.not-found';
    END IF;

    -- Aksiyon geçmişi
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', a.id,
            'action', a.action,
            'performedById', a.performed_by_id,
            'performedByType', a.performed_by_type,
            'note', a.note,
            'actionData', a.action_data,
            'createdAt', a.created_at
        ) ORDER BY a.created_at
    ), '[]'::JSONB)
    INTO v_actions
    FROM bonus.bonus_request_actions a
    WHERE a.request_id = p_request_id;

    RETURN v_result || jsonb_build_object('actions', v_actions);
END;
$$;

COMMENT ON FUNCTION bonus.bonus_request_get IS 'Returns a single bonus request with full action history. Includes all request fields and ordered action log.';
