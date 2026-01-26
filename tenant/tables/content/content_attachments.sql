DROP TABLE IF EXISTS content.content_attachments CASCADE;

CREATE TABLE content.content_attachments (
    id SERIAL PRIMARY KEY,
    content_id INTEGER NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(100),
    file_size INTEGER,
    alt_text VARCHAR(255),
    caption VARCHAR(500),
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER
);

COMMENT ON TABLE content.content_attachments IS 'File attachments for content items including images, documents, and media files';
