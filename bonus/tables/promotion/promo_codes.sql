DROP TABLE IF EXISTS promotion.promo_codes CASCADE;

CREATE TABLE promotion.promo_codes (
    id bigserial PRIMARY KEY,
    client_id bigint,  -- NULL = platform seviyesi, değer = client'a ait
    code varchar(50) NOT NULL,
    promo_name varchar(255) NOT NULL,
    bonus_rule_id bigint NOT NULL,

    -- Kullanım limitleri
    max_redemptions int,
    max_per_player int DEFAULT 1,
    current_redemptions int DEFAULT 0,

    -- Geçerlilik
    valid_from timestamp without time zone NOT NULL,
    valid_until timestamp without time zone NOT NULL,

    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);

COMMENT ON TABLE promotion.promo_codes IS 'Promotional codes that players can redeem for bonuses, with redemption limits and validity periods';
