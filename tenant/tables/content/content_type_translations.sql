DROP TABLE IF EXISTS content.content_type_translations CASCADE;

CREATE TABLE content.content_type_translations (
    id SERIAL PRIMARY KEY,
    content_type_id INTEGER NOT NULL,
    language_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);
