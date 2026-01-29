DROP TABLE IF EXISTS content.faq_categories CASCADE;

CREATE TABLE content.faq_categories (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL,
    icon VARCHAR(100),
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.faq_categories IS 'FAQ category definitions for organizing frequently asked questions';
