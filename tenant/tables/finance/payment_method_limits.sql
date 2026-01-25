DROP TABLE IF EXISTS finance.payment_method_limits CASCADE;

CREATE TABLE finance.payment_method_limits (
    id bigserial PRIMARY KEY,

    -- Denormalize edilmiş alanlar
    payment_method_id bigint NOT NULL,
    payment_method_code varchar(100) NOT NULL,

    -- Para yatırma limitleri (tenant override)
    min_deposit decimal(18,2),
    max_deposit decimal(18,2),

    -- Para çekme limitleri (tenant override)
    min_withdrawal decimal(18,2),
    max_withdrawal decimal(18,2),

    -- Periyodik limitler
    daily_deposit_limit decimal(18,2),
    daily_withdrawal_limit decimal(18,2),
    monthly_deposit_limit decimal(18,2),
    monthly_withdrawal_limit decimal(18,2),

    -- Ücret yapılandırması
    processing_fee_percentage decimal(5,2),
    processing_fee_fixed decimal(18,2),

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
