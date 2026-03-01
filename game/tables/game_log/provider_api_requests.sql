-- =============================================
-- Tablo: game_log.provider_api_requests
-- Açıklama: Game provider'lara yapılan API çağrı logları
-- Gateway seviyesi: Tüm client'lar için ortak
-- Game launch, bet, win, balance vb. istekler
-- GAME_LOG DB - 7 gün retention (daily partition)
-- =============================================

DROP TABLE IF EXISTS game_log.provider_api_requests CASCADE;

CREATE TABLE game_log.provider_api_requests (
    id bigserial,

    -- Bağlam bilgileri
    client_id BIGINT NOT NULL,                           -- Hangi client adına çağrı yapıldı
    player_id BIGINT,                                    -- İlgili oyuncu (varsa)
    provider_code VARCHAR(50) NOT NULL,                  -- Provider kodu: PRAGMATIC, EVOLUTION, EGT
    game_code VARCHAR(100),                              -- İlgili oyun kodu (varsa)

    -- İstek bilgileri
    request_id UUID DEFAULT gen_random_uuid(),           -- Korelasyon ID (distributed tracing)
    action_type VARCHAR(50) NOT NULL,                    -- game_launch, bet, win, balance, refund, rollback, session_check
    api_endpoint VARCHAR(500) NOT NULL,                  -- Çağrılan endpoint URL
    api_method VARCHAR(10) NOT NULL DEFAULT 'POST',      -- HTTP method (GET, POST, PUT)
    request_headers JSONB,                               -- İstek header'ları (hassas bilgiler maskelenmeli)
    request_payload JSONB,                               -- İstek gövdesi

    -- Yanıt bilgileri
    response_payload JSONB,                              -- Yanıt gövdesi
    http_status_code SMALLINT,                           -- HTTP durum kodu (200, 400, 500, vb.)
    status VARCHAR(20) NOT NULL DEFAULT 'pending',       -- pending, success, failed, timeout, error
    error_code VARCHAR(50),                              -- Provider hata kodu
    error_message TEXT,                                  -- Hata mesajı

    -- Performans
    response_time_ms INTEGER,                            -- Yanıt süresi (milisaniye)

    -- Finansal bağlam (debug amaçlı)
    external_round_id VARCHAR(100),                      -- Provider round ID
    external_transaction_id VARCHAR(100),                 -- Provider transaction ID
    amount DECIMAL(18,8),                                -- İşlem tutarı (varsa)
    currency_code VARCHAR(20),                           -- Para birimi

    created_at TIMESTAMP NOT NULL DEFAULT now(),
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE game_log.provider_api_requests_default PARTITION OF game_log.provider_api_requests DEFAULT;

COMMENT ON TABLE game_log.provider_api_requests IS 'Outbound API call logs to game providers (launch, bet, win, balance, refund). Gateway-level shared across all clients. Partitioned daily by created_at. Retention: 7 days.';
