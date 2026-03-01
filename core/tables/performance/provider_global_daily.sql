-- =============================================
-- Tablo: performance.provider_global_daily
-- Açıklama: Tüm platform genelinde Provider performansı.
-- Hangi sağlayıcının (Pragmatic, Evolution vb.) globalde ne kadar hacim yarattığını gösterir.
-- =============================================

DROP TABLE IF EXISTS performance.provider_global_daily CASCADE;

CREATE TABLE performance.provider_global_daily (
    id bigserial,
    report_date date NOT NULL,
    provider_id bigint NOT NULL,
    currency varchar(20) NOT NULL,                          -- Para birimi (Fiat: TRY, Crypto: BTC)

    total_bet numeric(18, 8) DEFAULT 0,
    total_win numeric(18, 8) DEFAULT 0,
    total_rounds bigint DEFAULT 0,                         -- Toplam oyun eli/spin sayısı

    active_clients_count int DEFAULT 0,                    -- Bu provider'ı bugün kullanan client sayısı

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone,

    PRIMARY KEY (id, report_date)
) PARTITION BY RANGE (report_date);

CREATE TABLE performance.provider_global_daily_default PARTITION OF performance.provider_global_daily DEFAULT;

COMMENT ON TABLE performance.provider_global_daily IS 'Global aggregations per provider across all clients, partitioned monthly by report_date';
