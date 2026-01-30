-- =============================================
-- Tablo: performance.provider_global_daily
-- Açıklama: Tüm platform genelinde Provider performansı.
-- Hangi sağlayıcının (Pragmatic, Evolution vb.) globalde ne kadar hacim yarattığını gösterir.
-- =============================================

DROP TABLE IF EXISTS performance.provider_global_daily CASCADE;

CREATE TABLE performance.provider_global_daily (
    id bigserial PRIMARY KEY,
    report_date date NOT NULL,
    provider_id bigint NOT NULL,
    currency char(3) NOT NULL,

    total_bet numeric(18, 8) DEFAULT 0,
    total_win numeric(18, 8) DEFAULT 0,
    total_rounds bigint DEFAULT 0,                         -- Toplam oyun eli/spin sayısı

    active_tenants_count int DEFAULT 0,                    -- Bu provider'ı bugün kullanan tenant sayısı

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone
);

COMMENT ON TABLE performance.provider_global_daily IS 'Global aggregations per provider across all tenants';
