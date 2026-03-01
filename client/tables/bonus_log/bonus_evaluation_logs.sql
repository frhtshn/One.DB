-- =============================================
-- Tablo: bonus_log.bonus_evaluation_logs
-- Açıklama: Bonus Worker değerlendirme sonuçları
--           Her kural değerlendirmesinin audit trail'i
--           Red sebebi, event verisi ve hesaplama detayı
-- =============================================

DROP TABLE IF EXISTS bonus_log.bonus_evaluation_logs CASCADE;

CREATE TABLE bonus_log.bonus_evaluation_logs (
    id BIGSERIAL,                                      -- Benzersiz kayıt kimliği
    client_id BIGINT NOT NULL,                         -- Client ID
    player_id BIGINT NOT NULL,                         -- Oyuncu ID

    -- Değerlendirilen kural bilgisi
    bonus_rule_id BIGINT NOT NULL,                     -- Değerlendirilen kural ID
    bonus_rule_code VARCHAR(100) NOT NULL,             -- Rule code snapshot

    -- Sonuç
    evaluation_result VARCHAR(20) NOT NULL,            -- awarded, rejected, error, skipped
    rejection_reason VARCHAR(100),                     -- Red sebebi kodu
    rejection_details JSONB,                           -- Detaylı red bilgisi

    -- Tetikleyen event
    trigger_event VARCHAR(50) NOT NULL,                -- Tetikleyen event tipi
    event_data JSONB,                                  -- Event snapshot

    -- Hesaplama sonucu (başarılı durumda)
    reward_amount DECIMAL(18,2),                       -- Hesaplanan tutar
    bonus_award_id BIGINT,                             -- Oluşturulan award ID

    -- Zamanlama
    evaluated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),   -- Değerlendirme zamanı
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),     -- Kayıt zamanı

    PRIMARY KEY (id, created_at)                       -- Partition key PK'ya dahil
) PARTITION BY RANGE (created_at);

CREATE TABLE bonus_log.bonus_evaluation_logs_default PARTITION OF bonus_log.bonus_evaluation_logs DEFAULT;

COMMENT ON TABLE bonus_log.bonus_evaluation_logs IS 'Bonus engine evaluation audit trail - records every rule evaluation result including rejections and error details. Partitioned daily by created_at with 90-day retention.';
