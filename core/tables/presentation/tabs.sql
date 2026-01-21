DROP TABLE IF EXISTS presentation.tabs CASCADE;

CREATE TABLE presentation.tabs (
    id BIGSERIAL PRIMARY KEY,
    page_id BIGINT NOT NULL
        REFERENCES presentation.pages(id) ON DELETE CASCADE,
    code VARCHAR(50) NOT NULL,                        -- WALLET
    title_localization_key VARCHAR(150) NOT NULL,
    order_index INT NOT NULL,
    required_permission VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    UNIQUE (page_id, code)
);

