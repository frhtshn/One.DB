-- =============================================
-- Tenant Log - Game Log Schema Constraints
-- =============================================
-- Cross-DB referanslar (player_id → tenant.auth.players) uygulama
-- katmanında kontrol edilir. Partitioned tablo olduğu için
-- FK tanımlanamaz.
-- =============================================

-- game_rounds — round durum kontrolü
ALTER TABLE game_log.game_rounds
    ADD CONSTRAINT chk_game_rounds_status
    CHECK (round_status IN ('open', 'closed', 'cancelled', 'refunded'));

-- game_rounds — finansal alan kontrolleri
ALTER TABLE game_log.game_rounds
    ADD CONSTRAINT chk_game_rounds_bet_amount
    CHECK (bet_amount >= 0);

ALTER TABLE game_log.game_rounds
    ADD CONSTRAINT chk_game_rounds_win_amount
    CHECK (win_amount >= 0);

ALTER TABLE game_log.game_rounds
    ADD CONSTRAINT chk_game_rounds_jackpot_amount
    CHECK (jackpot_amount >= 0);

-- game_rounds — performans alan kontrolü
ALTER TABLE game_log.game_rounds
    ADD CONSTRAINT chk_game_rounds_duration
    CHECK (duration_ms IS NULL OR duration_ms >= 0);

-- =============================================
-- Reconciliation Constraints
-- =============================================

-- reconciliation_mismatches -> reconciliation_reports
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_reconciliation_mismatches_report') THEN
        ALTER TABLE game_log.reconciliation_mismatches
            ADD CONSTRAINT fk_reconciliation_mismatches_report
            FOREIGN KEY (report_id) REFERENCES game_log.reconciliation_reports(id);
    END IF;
END $$;

-- reconciliation_reports — durum kontrolü
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_reconciliation_reports_status') THEN
        ALTER TABLE game_log.reconciliation_reports
            ADD CONSTRAINT chk_reconciliation_reports_status
            CHECK (status IN ('pending', 'matched', 'mismatched', 'resolved'));
    END IF;
END $$;

-- reconciliation_mismatches — uyuşmazlık tipi kontrolü
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_reconciliation_mismatches_type') THEN
        ALTER TABLE game_log.reconciliation_mismatches
            ADD CONSTRAINT chk_reconciliation_mismatches_type
            CHECK (mismatch_type IN ('missing_our_side', 'missing_provider', 'amount_diff', 'status_diff'));
    END IF;
END $$;

-- reconciliation_mismatches — çözüm durumu kontrolü
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_reconciliation_mismatches_resolution') THEN
        ALTER TABLE game_log.reconciliation_mismatches
            ADD CONSTRAINT chk_reconciliation_mismatches_resolution
            CHECK (resolution_status IN ('open', 'resolved', 'ignored'));
    END IF;
END $$;
