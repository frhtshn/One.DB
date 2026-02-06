-- =============================================
-- Tablo: tracking.transaction_events
-- Açıklama: Transaction event queue tablosu
-- Her transaction insert sonrası trigger ile kayıt oluşur
-- Worker bu tabloyu okuyarak istatistikleri günceller
-- =============================================

DROP TABLE IF EXISTS tracking.transaction_events CASCADE;

CREATE TABLE tracking.transaction_events (
    id bigserial,                              -- Benzersiz event kimliği
    transaction_id bigint NOT NULL,                        -- Transaction ID
    player_id bigint NOT NULL,                             -- Oyuncu ID
    affiliate_id bigint,                                   -- Oyuncunun affiliate'i (snapshot)

    -- Transaction Detayları
    transaction_type varchar(30) NOT NULL,                 -- BET, WIN, DEPOSIT, WITHDRAWAL, BONUS, etc.
    amount numeric(18,2) NOT NULL,                         -- İşlem tutarı
    currency char(3) NOT NULL,                             -- Para birimi

    -- Oyun Bilgisi (BET/WIN için)
    game_id bigint,                                        -- Oyun ID
    provider_id bigint,                                    -- Provider ID
    round_id varchar(100),                                 -- Oyun round ID

    -- Bonus Bilgisi (BONUS için)
    bonus_id bigint,                                       -- Bonus ID
    bonus_type varchar(30),                                -- FREESPIN, DEPOSIT_MATCH, CASHBACK, etc.

    -- İşleme Durumu
    status smallint NOT NULL DEFAULT 0,                    -- 0=Pending, 1=Processing, 2=Processed, 3=Failed
    processed_at timestamp without time zone,              -- İşlenme zamanı
    retry_count smallint NOT NULL DEFAULT 0,               -- Yeniden deneme sayısı
    error_message text,                                    -- Hata mesajı (varsa)

    -- Meta
    transaction_created_at timestamp without time zone NOT NULL, -- Orijinal transaction zamanı
    created_at timestamp without time zone NOT NULL DEFAULT now(),

    PRIMARY KEY (id, created_at)                                 -- Partition key PK'ya dahil
) PARTITION BY RANGE (created_at);

CREATE TABLE tracking.transaction_events_default PARTITION OF tracking.transaction_events DEFAULT;

COMMENT ON TABLE tracking.transaction_events IS 'Transaction event queue. Partitioned monthly by created_at. Worker processes these to update player/affiliate stats.';

-- =============================================
-- Worker Akışı:
--
-- 1. Transaction INSERT → Trigger → transaction_events INSERT
-- 2. Worker her X saniyede pending kayıtları alır
-- 3. Her event için:
--    a. player_game_stats_daily güncelle/oluştur
--    b. GGR hesapla (BET - WIN)
--    c. Affiliate ilişkisini kontrol et
-- 4. Event'i processed olarak işaretle
--
-- Batch işleme için worker her 5-10 saniyede çalışır
-- Real-time değil, near real-time (acceptable latency)
-- =============================================
