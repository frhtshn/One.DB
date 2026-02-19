-- ================================================================
-- ROUND_UPSERT: Round kaydı oluştur veya güncelle
-- ================================================================
-- Her bet/win callback'inde asenkron olarak çağrılır.
-- UPDATE-first pattern: mevcut round varsa kümülatif günceller,
-- yoksa yeni round oluşturur. round_closed=true ise otomatik
-- kapatır (Hub88 flag). Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS game_log.round_upsert(BIGINT, VARCHAR, VARCHAR, VARCHAR, TEXT);

CREATE OR REPLACE FUNCTION game_log.round_upsert(
    p_player_id BIGINT,
    p_game_code VARCHAR(100),
    p_provider_code VARCHAR(50),
    p_external_round_id VARCHAR(100),
    p_round_data TEXT
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_data JSONB;
    v_round_id BIGINT;
    v_round_created_at TIMESTAMP;
    v_round_started_at TIMESTAMPTZ;
    v_new_bet DECIMAL(18,8);
    v_new_win DECIMAL(18,8);
    v_new_jackpot DECIMAL(18,8);
    v_round_closed BOOLEAN;
    v_new_id BIGINT;
BEGIN
    -- JSONB parse
    v_data := p_round_data::JSONB;

    -- Değerleri çıkar
    v_new_bet := COALESCE((v_data->>'bet_amount')::DECIMAL, 0);
    v_new_win := COALESCE((v_data->>'win_amount')::DECIMAL, 0);
    v_new_jackpot := COALESCE((v_data->>'jackpot_amount')::DECIMAL, 0);
    v_round_closed := COALESCE((v_data->>'round_closed')::BOOLEAN, false);

    -- Mevcut round ara
    SELECT id, created_at, started_at
    INTO v_round_id, v_round_created_at, v_round_started_at
    FROM game_log.game_rounds
    WHERE external_round_id = p_external_round_id
      AND player_id = p_player_id
    ORDER BY created_at DESC
    LIMIT 1;

    IF v_round_id IS NOT NULL THEN
        -- Kümülatif güncelleme
        UPDATE game_log.game_rounds SET
            bet_amount = bet_amount + v_new_bet,
            win_amount = win_amount + v_new_win,
            jackpot_amount = jackpot_amount + v_new_jackpot,
            net_amount = (win_amount + v_new_win) - (bet_amount + v_new_bet),
            win_transaction_id = COALESCE((v_data->>'win_transaction_id')::BIGINT, win_transaction_id),
            round_detail = COALESCE(v_data->'round_detail', round_detail),
            round_status = CASE
                WHEN v_round_closed THEN 'closed'
                ELSE round_status
            END,
            ended_at = CASE
                WHEN v_round_closed THEN NOW()
                ELSE ended_at
            END,
            duration_ms = CASE
                WHEN v_round_closed THEN EXTRACT(EPOCH FROM (NOW() - v_round_started_at))::INTEGER * 1000
                ELSE duration_ms
            END
        WHERE id = v_round_id
          AND created_at = v_round_created_at;

        RETURN v_round_id;
    ELSE
        -- Yeni round oluştur
        INSERT INTO game_log.game_rounds (
            player_id, game_code, game_name, provider_code, game_type,
            external_round_id, external_session_id, parent_round_id,
            bet_amount, win_amount, net_amount, jackpot_amount,
            currency_code, round_status,
            is_free_round, is_bonus_round, bonus_award_id,
            round_detail,
            started_at,
            ended_at, duration_ms,
            bet_transaction_id, win_transaction_id,
            device_type, ip_address,
            created_at
        ) VALUES (
            p_player_id, p_game_code,
            v_data->>'game_name', p_provider_code, v_data->>'game_type',
            p_external_round_id, v_data->>'external_session_id', v_data->>'parent_round_id',
            v_new_bet, v_new_win, v_new_win - v_new_bet, v_new_jackpot,
            COALESCE(v_data->>'currency_code', 'TRY'),
            CASE WHEN v_round_closed THEN 'closed' ELSE 'open' END,
            COALESCE((v_data->>'is_free_round')::BOOLEAN, false),
            COALESCE((v_data->>'is_bonus_round')::BOOLEAN, false),
            (v_data->>'bonus_award_id')::BIGINT,
            v_data->'round_detail',
            NOW(),
            CASE WHEN v_round_closed THEN NOW() ELSE NULL END,
            CASE WHEN v_round_closed THEN 0 ELSE NULL END,
            (v_data->>'bet_transaction_id')::BIGINT,
            (v_data->>'win_transaction_id')::BIGINT,
            v_data->>'device_type',
            (v_data->>'ip_address')::INET,
            NOW()
        )
        RETURNING id INTO v_new_id;

        RETURN v_new_id;
    END IF;
END;
$$;

COMMENT ON FUNCTION game_log.round_upsert IS 'Creates or updates a game round with cumulative bet/win amounts. Auto-closes round when round_closed flag is true (Hub88). UPDATE-first pattern for existing rounds.';
