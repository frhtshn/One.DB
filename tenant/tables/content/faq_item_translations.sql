DROP TABLE IF EXISTS content.faq_item_translations CASCADE;

CREATE TABLE content.faq_item_translations (
    id SERIAL PRIMARY KEY,
    faq_item_id INTEGER NOT NULL,
    language_id INTEGER NOT NULL,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);
