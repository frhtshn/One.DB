-- =============================================
-- Payment Method Limits (Ödeme Yöntemi Limitleri)
-- Tenant seviyesinde ödeme limitleri
-- Core DB limitlerini override edebilir
-- =============================================

DROP TABLE IF EXISTS finance.payment_method_limits CASCADE;

CREATE TABLE finance.payment_method_limits (
    id bigserial PRIMARY KEY,

    -- Denormalize edilmiş alanlar
    payment_method_id bigint NOT NULL,            -- Ödeme yöntemi ID
    payment_method_code varchar(100) NOT NULL,    -- Yöntem kodu

    -- Para yatırma limitleri (tenant override)
    min_deposit decimal(18,2),                    -- Minimum para yatırma
    max_deposit decimal(18,2),                    -- Maksimum para yatırma

    -- Para çekme limitleri (tenant override)
    min_withdrawal decimal(18,2),                 -- Minimum para çekme
    max_withdrawal decimal(18,2),                 -- Maksimum para çekme

    -- Periyodik limitler
    daily_deposit_limit decimal(18,2),            -- Günlük para yatırma limiti
    daily_withdrawal_limit decimal(18,2),         -- Günlük para çekme limiti
    monthly_deposit_limit decimal(18,2),          -- Aylık para yatırma limiti
    monthly_withdrawal_limit decimal(18,2),       -- Aylık para çekme limiti

    -- Ücret yapılandırması
    processing_fee_percentage decimal(5,2),       -- Yüzdesel komisyon
    processing_fee_fixed decimal(18,2),           -- Sabit komisyon

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
