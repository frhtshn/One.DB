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
