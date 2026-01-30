-- =============================================
-- Tablo: performance.payment_global_daily
-- Açıklama: Tüm platform genelinde Ödeme Metodu performansı.
-- Hangi metodun (Papara, CC, Crypto) globalde ne kadar hacim yarattığını ve başarı oranlarını gösterir.
-- =============================================

DROP TABLE IF EXISTS performance.payment_global_daily CASCADE;

CREATE TABLE performance.payment_global_daily (
    id bigserial PRIMARY KEY,
    report_date date NOT NULL,

    -- Metod Bilgisi
    method_id bigint NOT NULL,                             -- Ödeme Metodu ID (core.catalog)
    currency char(3) NOT NULL,

    -- Hacimler
    deposit_volume numeric(18, 8) DEFAULT 0,
    withdraw_volume numeric(18, 8) DEFAULT 0,

    -- Adetler ve Başarı Oranları (Success Rate Monitörü)
    deposit_callees int DEFAULT 0,                         -- Toplam deneme
    deposit_success int DEFAULT 0,                         -- Başarılı işlem
    deposit_success_rate numeric(5, 2) GENERATED ALWAYS AS (
        CASE WHEN deposit_callees > 0 THEN (deposit_success::numeric / deposit_callees::numeric) * 100 ELSE 0 END
    ) STORED,

    withdraw_callees int DEFAULT 0,
    withdraw_success int DEFAULT 0,

    active_tenants_count int DEFAULT 0,                    -- Bu metodu bugün kullanan tenant sayısı

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone
);

COMMENT ON TABLE performance.payment_global_daily IS 'Global aggregations per payment method across all tenants';
