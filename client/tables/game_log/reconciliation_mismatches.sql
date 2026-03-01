-- =============================================
-- Tablo: game_log.reconciliation_mismatches
-- Açıklama: Round/transaction bazlı uyuşmazlık kayıtları
--           Reconciliation raporlarının detay tablosu
-- =============================================

CREATE TABLE game_log.reconciliation_mismatches (
    id                        BIGSERIAL       PRIMARY KEY,
    report_id                 BIGINT          NOT NULL,           -- FK → reconciliation_reports.id
    external_round_id         VARCHAR(100),                       -- Provider round ID
    external_transaction_id   VARCHAR(100),                       -- Provider transaction ID
    mismatch_type             VARCHAR(50)     NOT NULL,           -- missing_our_side, missing_provider, amount_diff, status_diff
    our_amount                DECIMAL(18,8),
    provider_amount           DECIMAL(18,8),
    our_status                VARCHAR(20),
    provider_status           VARCHAR(20),
    details                   JSONB,                              -- Ek detay bilgisi
    resolution_status         VARCHAR(20)     DEFAULT 'open',     -- open, resolved, ignored
    resolved_by               BIGINT,                             -- Çözen kullanıcı ID
    resolved_at               TIMESTAMPTZ,
    created_at                TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE game_log.reconciliation_mismatches IS 'Individual round/transaction level mismatches detected during reconciliation';
