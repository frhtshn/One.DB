-- =============================================
-- Tablo: affiliate_log.commission_calculations
-- Açıklama: Komisyon hesaplama logları
-- Batch hesaplama süreçlerinin kaydı
-- Network dağılım detayları dahil
-- =============================================

DROP TABLE IF EXISTS affiliate_log.commission_calculations CASCADE;

CREATE TABLE affiliate_log.commission_calculations (
    id bigserial,                                          -- Benzersiz kayıt kimliği
    batch_id uuid NOT NULL,                                -- Hesaplama batch ID
    period_start date NOT NULL,                            -- Dönem başlangıç
    period_end date NOT NULL,                              -- Dönem bitiş
    calculation_type varchar(30) NOT NULL,                 -- Tip: SCHEDULED, MANUAL, RERUN
    total_affiliates int NOT NULL DEFAULT 0,               -- Hesaplanan affiliate sayısı
    total_commissions int NOT NULL DEFAULT 0,              -- Oluşturulan komisyon sayısı
    total_direct_amount numeric(18,2) NOT NULL DEFAULT 0,  -- Toplam direkt komisyon
    total_network_amount numeric(18,2) NOT NULL DEFAULT 0, -- Toplam network komisyon
    base_currency varchar(20) NOT NULL,                     -- Hesaplama para birimi (Fiat: TRY, Crypto: BTC)
    calculation_started_at timestamp without time zone NOT NULL, -- Başlangıç zamanı
    calculation_ended_at timestamp without time zone,      -- Bitiş zamanı
    duration_seconds int,                                  -- Süre (saniye)
    status varchar(20) NOT NULL,                           -- Durum: RUNNING, COMPLETED, FAILED
    error_message text,                                    -- Hata mesajı (varsa)
    triggered_by varchar(50),                              -- Tetikleyen: CRON, USER:xxx
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    PRIMARY KEY (id, created_at)                               -- Partition key PK'ya dahil
) PARTITION BY RANGE (created_at);

CREATE TABLE affiliate_log.commission_calculations_default PARTITION OF affiliate_log.commission_calculations DEFAULT;

COMMENT ON TABLE affiliate_log.commission_calculations IS 'Commission batch calculation logs with network distribution details. Partitioned daily by created_at.';

-- =============================================
-- Örnek Log:
--
-- batch_id: 550e8400-e29b-41d4-a716-446655440000
-- period: 2026-01-01 to 2026-01-31
-- calculation_type: SCHEDULED
--
-- total_affiliates: 150
-- total_commissions: 450 (her seviye için ayrı kayıt)
-- total_direct_amount: $45,000
-- total_network_amount: $12,000
--
-- duration_seconds: 23
-- status: COMPLETED
-- =============================================
