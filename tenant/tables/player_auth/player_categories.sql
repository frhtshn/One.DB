DROP TABLE IF EXISTS auth.player_categories CASCADE;

CREATE TABLE auth.player_categories (
    id bigserial PRIMARY KEY,
    category_code varchar(50) NOT NULL,
    category_name varchar(100) NOT NULL,
    description varchar(255),
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
