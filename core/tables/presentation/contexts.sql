DROP TABLE IF EXISTS presentation.contexts CASCADE;

CREATE TABLE presentation.contexts (
    id BIGSERIAL PRIMARY KEY,
    page_id BIGINT NOT NULL,
    code VARCHAR(100) NOT NULL,                       -- player.phone
    context_type VARCHAR(20) NOT NULL CHECK (
        context_type IN ('field','action','section','button')
    ),
    label_localization_key VARCHAR(150),              -- bo.field.player.phone
    required_permission VARCHAR(100) NOT NULL,
    behavior VARCHAR(20) NOT NULL DEFAULT 'hide'
        CHECK (behavior IN ('hide','mask','readonly','edit')),
    UNIQUE (page_id, code)
);
