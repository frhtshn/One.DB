DROP TABLE IF EXISTS catalog.localization_keys CASCADE;

CREATE TABLE catalog.localization_keys (
    id bigserial PRIMARY KEY,
    localization_key varchar(150) NOT NULL,
    domain varchar(50) NOT NULL,
    category varchar(30) NOT NULL,
    description varchar(255),
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
