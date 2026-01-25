DROP TABLE IF EXISTS bonus.promo_redemptions CASCADE;

CREATE TABLE bonus.promo_redemptions (
    id bigserial PRIMARY KEY,

    -- Denormalize edilmiş bilgiler
    player_id bigint NOT NULL,

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
