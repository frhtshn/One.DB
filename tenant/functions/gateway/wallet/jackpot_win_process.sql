-- ================================================================
-- JACKPOT_WIN_PROCESS: Jackpot kazancı (thin wrapper)
-- ================================================================
-- PP jackpotWin endpoint'i için. Internal olarak win_process()
-- çağırır, transaction_type_id=70 ile. Auth-agnostic.
-- ================================================================

DROP FUNCTION IF EXISTS wallet.jackpot_win_process(BIGINT, VARCHAR, DECIMAL, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TEXT);

CREATE OR REPLACE FUNCTION wallet.jackpot_win_process(
    p_player_id BIGINT,
    p_currency_code VARCHAR(20),
    p_amount DECIMAL(18,8),
    p_idempotency_key VARCHAR(100),
    p_external_reference_id VARCHAR(100) DEFAULT NULL,
    p_game_code VARCHAR(100) DEFAULT NULL,
    p_provider_code VARCHAR(50) DEFAULT NULL,
    p_round_id VARCHAR(100) DEFAULT NULL,
    p_jackpot_id VARCHAR(100) DEFAULT NULL,
    p_metadata TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_merged_metadata JSONB;
BEGIN
    -- Metadata'ya jackpot bilgisi ekle
    v_merged_metadata := CASE WHEN p_metadata IS NOT NULL THEN p_metadata::JSONB ELSE '{}'::JSONB END;
    v_merged_metadata := v_merged_metadata || jsonb_build_object('jackpotId', p_jackpot_id);

    RETURN wallet.win_process(
        p_player_id, p_currency_code, p_amount, p_idempotency_key,
        p_external_reference_id, NULL,
        p_game_code, p_provider_code, p_round_id,
        70,
        v_merged_metadata::TEXT
    );
END;
$$;

COMMENT ON FUNCTION wallet.jackpot_win_process IS 'Thin wrapper over win_process for jackpot wins (transaction_type_id=70). Used by PP jackpotWin callback.';
