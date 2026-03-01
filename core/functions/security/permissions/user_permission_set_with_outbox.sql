-- ================================================================
-- USER_PERMISSION_SET_WITH_OUTBOX - Permission Grant/Deny + Outbox
-- ================================================================
-- user_permission_set ile aynı mantık, ek olarak outbox mesajları oluşturur.
-- DB transaction ile cache invalidation ve event publish atomik garanti.
-- ================================================================

DROP FUNCTION IF EXISTS security.user_permission_set_with_outbox(BIGINT, VARCHAR, BOOLEAN, BIGINT, VARCHAR, BIGINT, TIMESTAMPTZ, TEXT);
DROP FUNCTION IF EXISTS security.user_permission_set_with_outbox(BIGINT, VARCHAR, BOOLEAN, BIGINT, VARCHAR, BIGINT, TIMESTAMPTZ, BIGINT, TEXT);

CREATE OR REPLACE FUNCTION security.user_permission_set_with_outbox(
    p_user_id BIGINT,
    p_permission_code VARCHAR(100),
    p_is_granted BOOLEAN,
    p_client_id BIGINT DEFAULT NULL,
    p_reason VARCHAR(500) DEFAULT NULL,
    p_assigned_by BIGINT DEFAULT NULL,
    p_expires_at TIMESTAMPTZ DEFAULT NULL,
    p_context_id BIGINT DEFAULT NULL,
    p_outbox_messages TEXT DEFAULT '[]'  -- Dapper text olarak gönderir, içerde JSONB'ye cast edilir
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSONB;
    v_correlation_id UUID;
    v_outbox_json JSONB;
BEGIN
    -- Text'i JSONB'ye cast et
    v_outbox_json := p_outbox_messages::JSONB;

    -- 1. Permission set işlemini yap (mevcut fonksiyonu çağır)
    v_result := security.user_permission_set(
        p_user_id,
        p_permission_code,
        p_is_granted,
        p_client_id,
        p_reason,
        p_assigned_by,
        p_expires_at,
        p_context_id
    );

    -- 2. Outbox mesajlarını ekle (aynı transaction'da)
    IF v_outbox_json IS NOT NULL AND jsonb_array_length(v_outbox_json) > 0 THEN
        -- Correlation ID üret (tüm mesajlar için aynı)
        v_correlation_id := gen_random_uuid();

        INSERT INTO outbox.messages (
            action_type,
            aggregate_type,
            aggregate_id,
            payload,
            client_id,
            correlation_id,
            max_retries,
            status,
            created_at
        )
        SELECT
            msg->>'action_type',
            msg->>'aggregate_type',
            msg->>'aggregate_id',
            (msg->>'payload')::JSONB,  -- payload da JSONB olarak saklanmalı
            COALESCE((msg->>'client_id')::BIGINT, p_client_id),
            COALESCE((msg->>'correlation_id')::UUID, v_correlation_id),
            COALESCE((msg->>'max_retries')::INT, 5),
            'pending',
            NOW()
        FROM jsonb_array_elements(v_outbox_json) AS msg;

        -- Outbox mesaj sayısını sonuca ekle
        v_result := v_result || jsonb_build_object('outbox_count', jsonb_array_length(v_outbox_json));
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION security.user_permission_set_with_outbox IS
'Grants/Denies permission with transactional outbox pattern.
Creates outbox messages for cache invalidation and event publishing in same transaction.
Guarantees atomicity between DB changes and external system calls.
Supports context-scoped overrides via p_context_id (NULL = global).';
