DROP TABLE IF EXISTS presentation.tabs CASCADE;

CREATE TABLE presentation.tabs (
    id BIGSERIAL PRIMARY KEY,

    page_id BIGINT NOT NULL,
        --REFERENCES presentation.pages(id)
        --ON DELETE CASCADE,

    code VARCHAR(50) NOT NULL,
    title VARCHAR(100) NOT NULL,

    display_order INT NOT NULL,

    is_active BOOLEAN NOT NULL DEFAULT true,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    UNIQUE (page_id, code)
);
