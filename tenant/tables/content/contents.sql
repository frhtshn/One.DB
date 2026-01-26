DROP TABLE IF EXISTS content.contents CASCADE;

CREATE TABLE content.contents (
    id SERIAL PRIMARY KEY,
    content_type_id INTEGER NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    featured_image_url VARCHAR(500),
    version INTEGER NOT NULL DEFAULT 1,
    published_at TIMESTAMP WITHOUT TIME ZONE,
    expires_at TIMESTAMP WITHOUT TIME ZONE,
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);
