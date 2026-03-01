-- ================================================================
-- BONUS_REQUEST_CREATE: Bonus talebi oluştur
-- ================================================================
-- Oyuncu veya BO operatör tarafından bonus talebi oluşturur.
-- Operatör talebi: amount + currency zorunlu.
-- Oyuncu talebi: amount/currency NULL (operatör belirler).
-- Cooldown ve uygunluk kontrolü bu fonksiyonda YOK —
-- player_bonus_request_create() sarmalayıcısında yapılır.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_request_create(BIGINT, VARCHAR, VARCHAR, TEXT, DECIMAL, VARCHAR, TEXT, SMALLINT, BIGINT, INT);

CREATE OR REPLACE FUNCTION bonus.bonus_request_create(
    p_player_id         BIGINT,
    p_request_source    VARCHAR(20),
    p_request_type      VARCHAR(50),
    p_description       TEXT,
    p_requested_amount  DECIMAL(18,2) DEFAULT NULL,
    p_currency          VARCHAR(20) DEFAULT NULL,
    p_supporting_data   TEXT DEFAULT NULL,
    p_priority          SMALLINT DEFAULT 0,
    p_requested_by_id   BIGINT DEFAULT NULL,
    p_expires_in_hours  INT DEFAULT 72
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_request_id    BIGINT;
    v_supporting    JSONB;
    v_performed_by_type VARCHAR(20);
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.player-required';
    END IF;

    IF p_request_source IS NULL OR p_request_source NOT IN ('player', 'operator') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.invalid-source';
    END IF;

    IF p_request_type IS NULL OR p_request_type = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.type-required';
    END IF;

    IF p_description IS NULL OR p_description = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.description-required';
    END IF;

    -- Operatör talebi: amount + currency zorunlu
    IF p_request_source = 'operator' THEN
        IF p_requested_amount IS NULL OR p_requested_amount <= 0 THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.amount-required';
        END IF;

        IF p_currency IS NULL OR p_currency = '' THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.currency-required';
        END IF;
    END IF;

    -- Supporting data parse
    IF p_supporting_data IS NOT NULL AND p_supporting_data <> '' THEN
        BEGIN
            v_supporting := p_supporting_data::JSONB;
        EXCEPTION WHEN OTHERS THEN
            v_supporting := NULL;
        END;
    END IF;

    -- Talep oluştur
    INSERT INTO bonus.bonus_requests (
        player_id, request_source, request_type,
        requested_amount, currency, description,
        supporting_data, status, priority,
        requested_by_id, expires_at,
        created_at, updated_at
    ) VALUES (
        p_player_id, p_request_source, p_request_type,
        p_requested_amount, p_currency, p_description,
        v_supporting, 'pending', p_priority,
        p_requested_by_id,
        CASE WHEN p_expires_in_hours > 0 THEN NOW() + (p_expires_in_hours || ' hours')::INTERVAL ELSE NULL END,
        NOW(), NOW()
    )
    RETURNING id INTO v_request_id;

    -- Aksiyon logu
    v_performed_by_type := CASE
        WHEN p_request_source = 'player' THEN 'PLAYER'
        ELSE 'BO_USER'
    END;

    INSERT INTO bonus.bonus_request_actions (
        request_id, action, performed_by_id, performed_by_type, note, created_at
    ) VALUES (
        v_request_id, 'CREATED',
        COALESCE(p_requested_by_id, p_player_id),
        v_performed_by_type,
        LEFT(p_description, 500),
        NOW()
    );

    RETURN v_request_id;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_request_create IS 'Creates a bonus request from player or BO operator. Operator requests require amount and currency. Cooldown/eligibility checks are handled by player_bonus_request_create wrapper.';
