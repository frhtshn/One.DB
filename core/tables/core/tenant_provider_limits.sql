DROP TABLE IF EXISTS core.tenant_provider_limits CASCADE;

CREATE TABLE core.tenant_provider_limits (
    id bigserial PRIMARY KEY,
    tenant_id bigint NOT NULL,
    provider_id bigint NOT NULL,
    payment_method_id bigint NOT NULL,

    -- Para yatırma limitleri
    min_deposit decimal(18,2),
    max_deposit decimal(18,2),

    -- Para çekme limitleri
    min_withdrawal decimal(18,2),
    max_withdrawal decimal(18,2),

    -- Periyodik limitler (opsiyonel)
    daily_deposit_limit decimal(18,2),
    daily_withdrawal_limit decimal(18,2),
    monthly_deposit_limit decimal(18,2),
    monthly_withdrawal_limit decimal(18,2),

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
