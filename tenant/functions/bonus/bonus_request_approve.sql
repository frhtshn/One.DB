-- ================================================================
-- BONUS_REQUEST_APPROVE: Bonus talebini onayla
-- ================================================================
-- in_progress durumundaki talebi onaylar ve atomik olarak
-- bonus_award_create() çağırarak bonus verir.
-- Çevrim şartı: operatör override > setting default > yok.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_request_approve(BIGINT, BIGINT, DECIMAL, VARCHAR, VARCHAR, BIGINT, TEXT, TEXT, INT, VARCHAR);

CREATE OR REPLACE FUNCTION bonus.bonus_request_approve(
    p_request_id        BIGINT,
    p_reviewed_by_id    BIGINT,
    p_approved_amount   DECIMAL(18,2),
    p_approved_currency VARCHAR(20),
    p_approved_bonus_type VARCHAR(50) DEFAULT NULL,
    p_bonus_rule_id     BIGINT DEFAULT NULL,
    p_usage_criteria    TEXT DEFAULT NULL,
    p_rule_snapshot     TEXT DEFAULT NULL,
    p_expires_in_days   INT DEFAULT NULL,
    p_review_note       VARCHAR(500) DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_request           RECORD;
    v_award_id          BIGINT;
    v_bonus_type        VARCHAR(50);
    v_usage_criteria    TEXT;
    v_default_criteria  JSONB;
    v_expires_at        TIMESTAMPTZ;
BEGIN
    -- Talep kontrolü
    SELECT * INTO v_request
    FROM bonus.bonus_requests
    WHERE id = p_request_id;

    IF v_request IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-request.not-found';
    END IF;

    IF v_request.status <> 'in_progress' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.invalid-status';
    END IF;

    -- Zorunlu alanlar
    IF p_approved_amount IS NULL OR p_approved_amount <= 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.amount-required';
    END IF;

    IF p_approved_currency IS NULL OR p_approved_currency = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.currency-required';
    END IF;

    -- Bonus tipi belirleme
    v_bonus_type := COALESCE(p_approved_bonus_type, v_request.request_type);

    -- Çevrim şartı belirleme: operatör override > setting default > yok
    v_usage_criteria := p_usage_criteria;

    IF v_usage_criteria IS NULL THEN
        SELECT s.default_usage_criteria INTO v_default_criteria
        FROM bonus.bonus_request_settings s
        WHERE s.bonus_type_code = v_request.request_type
          AND s.is_active = true;

        IF v_default_criteria IS NOT NULL THEN
            v_usage_criteria := v_default_criteria::TEXT;
        END IF;
    END IF;

    -- Bitiş tarihi
    v_expires_at := CASE
        WHEN p_expires_in_days IS NOT NULL THEN NOW() + (p_expires_in_days || ' days')::INTERVAL
        ELSE NULL
    END;

    -- Status → approved
    UPDATE bonus.bonus_requests SET
        status = 'approved',
        reviewed_by_id = p_reviewed_by_id,
        review_note = p_review_note,
        reviewed_at = NOW(),
        approved_amount = p_approved_amount,
        approved_currency = p_approved_currency,
        approved_bonus_type = v_bonus_type,
        bonus_rule_id = p_bonus_rule_id,
        updated_at = NOW()
    WHERE id = p_request_id;

    -- Aksiyon logu: APPROVED
    INSERT INTO bonus.bonus_request_actions (
        request_id, action, performed_by_id, performed_by_type, note,
        action_data, created_at
    ) VALUES (
        p_request_id, 'APPROVED', p_reviewed_by_id, 'BO_USER', p_review_note,
        jsonb_build_object(
            'approvedAmount', p_approved_amount,
            'approvedCurrency', p_approved_currency,
            'approvedBonusType', v_bonus_type
        ),
        NOW()
    );

    -- bonus_award_create() çağır
    v_award_id := bonus.bonus_award_create(
        p_player_id         := v_request.player_id,
        p_bonus_rule_id     := COALESCE(p_bonus_rule_id, 0),
        p_bonus_type_code   := v_bonus_type,
        p_bonus_amount      := p_approved_amount,
        p_currency          := p_approved_currency::CHAR(3),
        p_usage_criteria    := v_usage_criteria,
        p_rule_snapshot     := p_rule_snapshot,
        p_expires_at        := v_expires_at,
        p_awarded_by        := p_reviewed_by_id,
        p_bonus_request_id  := p_request_id
    );

    -- Status → completed + award bağla
    UPDATE bonus.bonus_requests SET
        status = 'completed',
        bonus_award_id = v_award_id,
        updated_at = NOW()
    WHERE id = p_request_id;

    -- Aksiyon logu: COMPLETED
    INSERT INTO bonus.bonus_request_actions (
        request_id, action, performed_by_id, performed_by_type,
        action_data, created_at
    ) VALUES (
        p_request_id, 'COMPLETED', NULL, 'SYSTEM',
        jsonb_build_object('bonusAwardId', v_award_id),
        NOW()
    );

    RETURN v_award_id;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_request_approve IS 'Approves a bonus request and atomically creates a bonus award. Usage criteria priority: operator override > setting default > none. Returns the created bonus_award_id.';
