DROP TABLE IF EXISTS content.content_versions CASCADE;

CREATE TABLE content.content_versions (
    id SERIAL PRIMARY KEY,
    content_id INTEGER NOT NULL,
    language_id INTEGER NOT NULL,
    version INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    subtitle VARCHAR(500),
    summary TEXT,
    body TEXT,
    meta_title VARCHAR(255),
    meta_description VARCHAR(500),
    meta_keywords VARCHAR(500),
    change_note TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER
);

COMMENT ON TABLE content.content_versions IS 'Content version history for auditing and rollback capabilities with change notes';
