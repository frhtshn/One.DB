DROP TABLE IF EXISTS execution.promo_redemptions CASCADE;

CREATE TABLE execution.promo_redemptions (
    id bigserial PRIMARY KEY,

    -- Denormalize edilmiş bilgiler
    tenant_id bigint NOT NULL,
    tenant_code varchar(50) NOT NULL,
    player_id bigint NOT NULL,
    player_username varchar(150),

    -- Promosyon bilgileri
    promo_code_id bigint NOT NULL,
    promo_code varchar(50) NOT NULL,
    bonus_award_id bigint,

    -- Durum
    status varchar(20) NOT NULL DEFAULT 'success',  -- success, failed, expired
    failure_reason varchar(255),

    redeemed_at timestamp without time zone NOT NULL DEFAULT now(),
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
