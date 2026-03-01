-- =============================================
-- Tablo: game_log.reconciliation_reports
-- Açıklama: Günlük uzlaştırma raporları
--           Provider data feed'leri ile karşılaştırma
-- =============================================

CREATE TABLE game_log.reconciliation_reports (
    id                      BIGSERIAL       PRIMARY KEY,
    provider_code           VARCHAR(50)     NOT NULL,
    report_date             DATE            NOT NULL,
    currency_code           VARCHAR(20)     NOT NULL,
    our_total_bet           DECIMAL(18,8)   DEFAULT 0,
    our_total_win           DECIMAL(18,8)   DEFAULT 0,
    our_total_rounds        BIGINT          DEFAULT 0,
    provider_total_bet      DECIMAL(18,8)   DEFAULT 0,
    provider_total_win      DECIMAL(18,8)   DEFAULT 0,
    provider_total_rounds   BIGINT          DEFAULT 0,
    bet_diff                DECIMAL(18,8)   GENERATED ALWAYS AS (our_total_bet - provider_total_bet) STORED,
    win_diff                DECIMAL(18,8)   GENERATED ALWAYS AS (our_total_win - provider_total_win) STORED,
    status                  VARCHAR(20)     NOT NULL DEFAULT 'pending', -- pending, matched, mismatched, resolved
    mismatch_details        JSONB,                             -- Özet fark bilgisi
    resolved_by             BIGINT,                            -- Çözen kullanıcı ID (Core DB referans)
    resolved_at             TIMESTAMPTZ,
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE game_log.reconciliation_reports IS 'Daily reconciliation reports comparing internal game rounds with provider data feeds';
