DROP TABLE IF EXISTS bonus.bonus_types CASCADE;

CREATE TABLE bonus.bonus_types (
    id bigserial PRIMARY KEY,
    client_id bigint,  -- NULL = platform seviyesi, değer = client'a ait
    type_code varchar(50) NOT NULL,
    type_name varchar(255) NOT NULL,
    description text,

    -- Bonus tipi: deposit_match, free_spin, free_bet, cashback, loyalty
    category varchar(50) NOT NULL,

    -- Değer tipi: percentage, fixed_amount, free_spins_count
    value_type varchar(30) NOT NULL,

    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);

COMMENT ON TABLE bonus.bonus_types IS 'Lookup table for bonus type definitions including deposit match, free spins, free bets, cashback, and loyalty rewards';
