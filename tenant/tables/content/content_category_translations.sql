DROP TABLE IF EXISTS content.content_category_translations CASCADE;

CREATE TABLE content.content_category_translations (
    id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL,
    language_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.content_category_translations IS 'Multilingual translations for content category names and descriptions';
