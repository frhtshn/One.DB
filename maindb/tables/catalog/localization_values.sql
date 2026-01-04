DROP TABLE IF EXISTS catalog.localization_values CASCADE;

CREATE TABLE catalog.localization_values (
    id bigserial PRIMARY KEY,
    localization_key_id bigint NOT NULL,
    language_code character(2) NOT NULL,
    localized_text text NOT NULL,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
