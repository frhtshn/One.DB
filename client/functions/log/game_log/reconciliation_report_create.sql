-- ================================================================
-- RECONCILIATION_REPORT_CREATE: Uzlaştırma raporu oluştur/güncelle
-- ================================================================
-- Günlük reconciliation job'ı tarafından çağrılır.
-- game_rounds'tan our_ alanlarını aggregate eder.
-- Provider data feed'i opsiyonel olarak eklenebilir.
-- İdempotent: aynı provider+tarih+currency tekrar çalıştırılırsa günceller.
-- ================================================================

DROP FUNCTION IF EXISTS game_log.reconciliation_report_create(VARCHAR(50), DATE, VARCHAR(20), TEXT);

CREATE OR REPLACE FUNCTION game_log.reconciliation_report_create(
    p_provider_code   VARCHAR(50),
    p_report_date     DATE,
    p_currency_code   VARCHAR(20),
    p_provider_data   TEXT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    v_id                   BIGINT;
    v_our_bet              DECIMAL(18,8);
    v_our_win              DECIMAL(18,8);
    v_our_rounds           BIGINT;
    v_provider_data        JSONB;
    v_provider_bet         DECIMAL(18,8) := 0;
    v_provider_win         DECIMAL(18,8) := 0;
    v_provider_rounds      BIGINT := 0;
    v_status               VARCHAR(20);
    v_existing_id          BIGINT;
BEGIN
    -- ------------------------------------------------
    -- Zorunlu alan kontrolleri
    -- ------------------------------------------------
    IF p_provider_code IS NULL OR TRIM(p_provider_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = format('error.reconciliation.provider-required');
    END IF;

    IF p_report_date IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = format('error.reconciliation.date-required');
    END IF;

    IF p_currency_code IS NULL OR TRIM(p_currency_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = format('error.reconciliation.date-required');
    END IF;

    -- ------------------------------------------------
    -- game_rounds'tan our_ alanlarını aggregate et
    -- Daily partition pruning: created_at >= date AND < date + 1
    -- ------------------------------------------------
    SELECT
        COALESCE(SUM(gr.bet_amount), 0),
        COALESCE(SUM(gr.win_amount), 0),
        COUNT(*)
    INTO v_our_bet, v_our_win, v_our_rounds
    FROM game_log.game_rounds gr
    WHERE gr.provider_code = p_provider_code
      AND gr.created_at >= p_report_date::TIMESTAMPTZ
      AND gr.created_at < (p_report_date + 1)::TIMESTAMPTZ
      AND gr.currency_code = p_currency_code
      AND gr.round_status IN ('closed', 'open');

    -- ------------------------------------------------
    -- Provider data parse (opsiyonel)
    -- ------------------------------------------------
    IF p_provider_data IS NOT NULL AND TRIM(p_provider_data) <> '' THEN
        v_provider_data := p_provider_data::JSONB;
        v_provider_bet    := COALESCE((v_provider_data->>'totalBet')::DECIMAL(18,8), 0);
        v_provider_win    := COALESCE((v_provider_data->>'totalWin')::DECIMAL(18,8), 0);
        v_provider_rounds := COALESCE((v_provider_data->>'totalRounds')::BIGINT, 0);
    END IF;

    -- ------------------------------------------------
    -- Status belirleme
    -- ------------------------------------------------
    IF p_provider_data IS NULL OR TRIM(p_provider_data) = '' THEN
        v_status := 'pending';
    ELSIF (v_our_bet - v_provider_bet) = 0 AND (v_our_win - v_provider_win) = 0 THEN
        v_status := 'matched';
    ELSE
        v_status := 'mismatched';
    END IF;

    -- ------------------------------------------------
    -- İdempotent: mevcut rapor varsa güncelle, yoksa oluştur
    -- ------------------------------------------------
    SELECT id INTO v_existing_id
    FROM game_log.reconciliation_reports
    WHERE provider_code = p_provider_code
      AND report_date = p_report_date
      AND currency_code = p_currency_code;

    IF v_existing_id IS NOT NULL THEN
        UPDATE game_log.reconciliation_reports
        SET our_total_bet       = v_our_bet,
            our_total_win       = v_our_win,
            our_total_rounds    = v_our_rounds,
            provider_total_bet  = v_provider_bet,
            provider_total_win  = v_provider_win,
            provider_total_rounds = v_provider_rounds,
            status              = v_status,
            updated_at          = NOW()
        WHERE id = v_existing_id;

        v_id := v_existing_id;
    ELSE
        INSERT INTO game_log.reconciliation_reports (
            provider_code,
            report_date,
            currency_code,
            our_total_bet,
            our_total_win,
            our_total_rounds,
            provider_total_bet,
            provider_total_win,
            provider_total_rounds,
            status,
            created_at,
            updated_at
        ) VALUES (
            TRIM(p_provider_code),
            p_report_date,
            TRIM(p_currency_code),
            v_our_bet,
            v_our_win,
            v_our_rounds,
            v_provider_bet,
            v_provider_win,
            v_provider_rounds,
            v_status,
            NOW(),
            NOW()
        )
        RETURNING id INTO v_id;
    END IF;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION game_log.reconciliation_report_create(VARCHAR(50), DATE, VARCHAR(20), TEXT)
    IS 'Create or update daily reconciliation report with aggregated game round data and optional provider feed data';
