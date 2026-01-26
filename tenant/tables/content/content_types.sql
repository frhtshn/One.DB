DROP TABLE IF EXISTS content.content_types CASCADE;

CREATE TABLE content.content_types (
    id SERIAL PRIMARY KEY,
    category_id INTEGER,
    code VARCHAR(50) NOT NULL UNIQUE,
    template_key VARCHAR(100),
    icon VARCHAR(100),
    requires_acceptance BOOLEAN NOT NULL DEFAULT FALSE,
    show_in_footer BOOLEAN NOT NULL DEFAULT FALSE,
    show_in_menu BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.content_types IS 'Content type definitions such as terms, privacy policy, about us with display settings';
