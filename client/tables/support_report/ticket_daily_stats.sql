-- =============================================
-- Tablo: support_report.ticket_daily_stats
-- Açıklama: Günlük ticket istatistikleri.
--           Dashboard ve raporlama için.
--           Kategori, kanal ve temsilci bazlı
--           kırılımlar.
-- CLIENT_REPORT DB - Süresiz retention
-- Aylık partition (report_date)
-- =============================================

DROP TABLE IF EXISTS support_report.ticket_daily_stats CASCADE;

CREATE TABLE support_report.ticket_daily_stats (
    id                          BIGSERIAL,
    report_date                 DATE            NOT NULL,               -- Rapor tarihi

    -- Kırılım boyutları (NULL = genel toplam)
    category_id                 BIGINT,                                 -- Kategori (NULL = genel toplam)
    channel                     VARCHAR(20),                            -- Kanal (NULL = genel toplam)
    representative_id           BIGINT,                                 -- Temsilci (NULL = genel toplam)

    -- Ticket metrikleri
    tickets_opened              INT             NOT NULL DEFAULT 0,     -- Açılan ticket sayısı
    tickets_closed              INT             NOT NULL DEFAULT 0,     -- Kapatılan
    tickets_resolved            INT             NOT NULL DEFAULT 0,     -- Çözülen
    tickets_cancelled           INT             NOT NULL DEFAULT 0,     -- İptal edilen
    tickets_reopened            INT             NOT NULL DEFAULT 0,     -- Tekrar açılan
    avg_resolution_minutes      INT,                                    -- Ortalama çözüm süresi (dakika)

    -- Hoşgeldin araması metrikleri
    welcome_calls_completed     INT             NOT NULL DEFAULT 0,     -- Tamamlanan hoşgeldin araması
    welcome_calls_failed        INT             NOT NULL DEFAULT 0,     -- Başarısız hoşgeldin araması

    -- Temsilci atama metrikleri
    representatives_assigned    INT             NOT NULL DEFAULT 0,     -- Atanan temsilci sayısı

    created_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id, report_date)                                       -- Partition key PK'ya dahil
) PARTITION BY RANGE (report_date);

CREATE TABLE support_report.ticket_daily_stats_default PARTITION OF support_report.ticket_daily_stats DEFAULT;

COMMENT ON TABLE support_report.ticket_daily_stats IS 'Monthly-partitioned daily ticket statistics for dashboard and reporting. Aggregated by category, channel, and representative.';
