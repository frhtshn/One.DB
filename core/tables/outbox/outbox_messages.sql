-- ================================================================
-- OUTBOX_MESSAGES - Transactional Outbox Pattern
-- ================================================================
-- Cache invalidation ve event publishing için outbox tablosu.
-- Aynı DB transaction'da yazılır, ayrı process tarafından işlenir.
-- ================================================================

DROP TABLE IF EXISTS outbox.messages CASCADE;

CREATE TABLE outbox.messages (
    -- Primary Key
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Message Type
    action_type varchar(50) NOT NULL,           -- 'cache_invalidate', 'event_publish'
    aggregate_type varchar(100) NOT NULL,       -- 'user_permission', 'role', 'tenant'
    aggregate_id varchar(100) NOT NULL,         -- İlgili entity ID

    -- Payload
    payload jsonb NOT NULL,                     -- İşlenecek data

    -- Context
    tenant_id bigint,                           -- Opsiyonel tenant context
    correlation_id uuid DEFAULT gen_random_uuid(),

    -- Processing State
    status varchar(20) NOT NULL DEFAULT 'pending',  -- 'pending', 'processing', 'completed', 'failed'
    retry_count int NOT NULL DEFAULT 0,
    max_retries int NOT NULL DEFAULT 5,
    next_retry_at timestamptz,
    last_error text,

    -- Ordering
    sequence_number bigserial NOT NULL,

    -- Timestamps
    created_at timestamptz NOT NULL DEFAULT now(),
    processed_at timestamptz
);

-- Table comment
COMMENT ON TABLE outbox.messages IS 'Transactional outbox pattern için mesaj tablosu. Cache invalidation ve event publishing.';
