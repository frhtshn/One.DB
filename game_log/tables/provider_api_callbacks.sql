-- =============================================
-- Tablo: game_log.provider_api_callbacks
-- Açıklama: Provider'lardan gelen callback/webhook logları
-- Gateway seviyesi: Tüm tenant'lar için ortak
-- Provider'ın sisteme geri bildirdiği event'ler
-- GAME_LOG DB - 7 gün retention (daily partition)
-- =============================================

DROP TABLE IF EXISTS game_log.provider_api_callbacks CASCADE;

CREATE TABLE game_log.provider_api_callbacks (
    id bigserial,

    -- Bağlam bilgileri
    tenant_id BIGINT,                                    -- Çözümlenen tenant (NULL olabilir: parse hatası)
    player_id BIGINT,                                    -- Çözümlenen oyuncu (NULL olabilir)
    provider_code VARCHAR(50) NOT NULL,                  -- Provider kodu: PRAGMATIC, EVOLUTION, EGT
    game_code VARCHAR(100),                              -- Çözümlenen oyun kodu (varsa)

    -- Callback bilgileri
    callback_type VARCHAR(50) NOT NULL,                  -- bet, win, refund, rollback, jackpot, freespin, bonus, session_end
    callback_endpoint VARCHAR(500),                      -- Alınan endpoint (/api/callback/pragmatic/bet)
    raw_payload JSONB NOT NULL,                          -- Ham callback verisi (olduğu gibi)
    parsed_payload JSONB,                                -- Parse edilmiş ve normalize edilmiş veri

    -- İşlem durumu
    processing_status VARCHAR(20) NOT NULL DEFAULT 'received', -- received, processing, processed, failed, rejected, duplicate
    error_code VARCHAR(50),                              -- İşleme hata kodu
    error_message TEXT,                                  -- İşleme hata mesajı

    -- Performans
    processing_time_ms INTEGER,                          -- İşleme süresi (milisaniye)

    -- Provider referansları
    external_round_id VARCHAR(100),                      -- Provider round ID
    external_transaction_id VARCHAR(100),                 -- Provider transaction ID
    amount DECIMAL(18,8),                                -- İşlem tutarı
    currency_code VARCHAR(20),                           -- Para birimi

    -- Güvenlik
    signature_valid BOOLEAN,                             -- İmza doğrulama sonucu
    source_ip INET,                                      -- Kaynak IP adresi

    created_at TIMESTAMP NOT NULL DEFAULT now(),
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE game_log.provider_api_callbacks_default PARTITION OF game_log.provider_api_callbacks DEFAULT;

COMMENT ON TABLE game_log.provider_api_callbacks IS 'Inbound callback/webhook logs from game providers (bet, win, refund, rollback). Gateway-level shared across all tenants. Partitioned daily by created_at. Retention: 7 days.';
