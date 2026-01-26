DROP TABLE IF EXISTS content.content_translations CASCADE;

CREATE TABLE content.content_translations (
    id SERIAL PRIMARY KEY,
    content_id INTEGER NOT NULL,
    language_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    subtitle VARCHAR(500),
    summary TEXT,
    body TEXT,
    meta_title VARCHAR(255),
    meta_description VARCHAR(500),
    meta_keywords VARCHAR(500),
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    translated_at TIMESTAMP WITHOUT TIME ZONE,
    translated_by INTEGER,
    reviewed_at TIMESTAMP WITHOUT TIME ZONE,
    reviewed_by INTEGER,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);
