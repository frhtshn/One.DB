-- =============================================
-- Tablo: affiliate_log.report_generations
-- Açıklama: Rapor oluşturma logları
-- Affiliate panelden oluşturulan raporlar
-- Kaynak kullanımı ve audit için
-- =============================================

DROP TABLE IF EXISTS affiliate_log.report_generations CASCADE;

CREATE TABLE affiliate_log.report_generations (
    id bigserial,                                          -- Benzersiz kayıt kimliği
    affiliate_id bigint NOT NULL,                          -- Affiliate ID
    user_id bigint NOT NULL,                               -- Raporu oluşturan kullanıcı
    report_type varchar(50) NOT NULL,                      -- Rapor tipi: COMMISSION, PLAYER, TRAFFIC, CONVERSION, etc.
    report_format varchar(20) NOT NULL,                    -- Format: WEB, CSV, EXCEL, PDF
    date_from date,                                        -- Rapor başlangıç tarihi
    date_to date,                                          -- Rapor bitiş tarihi
    filters jsonb,                                         -- Uygulanan filtreler
    row_count int,                                         -- Dönen satır sayısı
    file_size_bytes bigint,                                -- Dosya boyutu (export ise)
    generation_time_ms int,                                -- Oluşturma süresi (ms)
    ip_address inet,                                       -- IP adresi
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Oluşturma zamanı
    PRIMARY KEY (id, created_at)                               -- Partition key PK'ya dahil
) PARTITION BY RANGE (created_at);

CREATE TABLE affiliate_log.report_generations_default PARTITION OF affiliate_log.report_generations DEFAULT;

COMMENT ON TABLE affiliate_log.report_generations IS 'Report generation logs for affiliate panel - resource usage tracking and audit. Partitioned daily by created_at.';
