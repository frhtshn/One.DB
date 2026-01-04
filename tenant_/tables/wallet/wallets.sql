DROP TABLE IF EXISTS wallet.wallets CASCADE;

CREATE TABLE wallet.wallets (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,
    wallet_type varchar(20) NOT NULL,
    currency_code character(3) NOT NULL,
    status smallint NOT NULL DEFAULT 1,
    is_default boolean NOT NULL DEFAULT false,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
