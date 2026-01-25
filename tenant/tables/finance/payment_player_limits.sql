DROP TABLE IF EXISTS finance.payment_player_limits CASCADE;

CREATE TABLE finance.payment_player_limits (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,

    -- Denormalize edilmiş alanlar
    payment_method_id bigint NOT NULL,
    payment_method_code varchar(100) NOT NULL,

    -- Para yatırma limitleri (player specific)
    min_deposit decimal(18,2),
    max_deposit decimal(18,2),

    -- Para çekme limitleri (player specific)
    min_withdrawal decimal(18,2),
    max_withdrawal decimal(18,2),

    -- Periyodik limitler
    daily_deposit_limit decimal(18,2),
    daily_withdrawal_limit decimal(18,2),
    monthly_deposit_limit decimal(18,2),
    monthly_withdrawal_limit decimal(18,2),

    -- Limit tipi (self-imposed, responsible gaming, admin-imposed)
    limit_type varchar(50),

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
