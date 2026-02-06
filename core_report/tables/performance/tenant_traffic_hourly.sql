-- =============================================
-- Tablo: performance.tenant_traffic_hourly
-- Açıklama: Tenant bazlı saatlik trafik ve sağlık monitörü.
-- Sistem kaynak kullanımı ve Tier belirleme için kullanılır.
-- =============================================

DROP TABLE IF EXISTS performance.tenant_traffic_hourly CASCADE;

CREATE TABLE performance.tenant_traffic_hourly (
    id bigserial,
    period_hour timestamp with time zone NOT NULL,         -- İlgili saat

    company_id bigint NOT NULL,
    tenant_id bigint NOT NULL,

    -- Trafik Metrikleri
    total_requests bigint DEFAULT 0,                       -- Toplam API isteği
    total_logins int DEFAULT 0,                            -- Oturum açma sayısı
    concurrent_users_peak int DEFAULT 0,                   -- O saatteki en yüksek anlık kullanıcı

    -- Sağlık Metrikleri
    error_count int DEFAULT 0,                             -- 500/System Error sayısı
    avg_latency_ms int DEFAULT 0,                          -- Ortalama yanıt süresi (milisaniye)

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone,

    PRIMARY KEY (id, period_hour)
) PARTITION BY RANGE (period_hour);

CREATE TABLE performance.tenant_traffic_hourly_default PARTITION OF performance.tenant_traffic_hourly DEFAULT;

COMMENT ON TABLE performance.tenant_traffic_hourly IS 'Hourly traffic and system health indicators per tenant, partitioned monthly by period_hour';
