-- ================================================================
-- USER_BROADCAST_GET: Broadcast detayını döner
-- İstatistiklerle birlikte (total_recipients, read_count, read_rate)
-- ================================================================

DROP FUNCTION IF EXISTS messaging.user_broadcast_get(INTEGER);

CREATE OR REPLACE FUNCTION messaging.user_broadcast_get(
    p_broadcast_id INTEGER  -- Broadcast ID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_broadcast_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.broadcast-id-required';
    END IF;

    SELECT jsonb_build_object(
        'id', b.id,
        'sender_id', b.sender_id,
        'sender_name', u.first_name || ' ' || u.last_name,
        'subject', b.subject,
        'body', b.body,
        'message_type', b.message_type,
        'priority', b.priority,
        'company_id', b.company_id,
        'tenant_id', b.tenant_id,
        'department_id', b.department_id,
        'role_id', b.role_id,
        'expires_at', b.expires_at,
        'total_recipients', b.total_recipients,
        'read_count', b.read_count,
        'read_rate', CASE
            WHEN b.total_recipients > 0
            THEN ROUND((b.read_count::NUMERIC / b.total_recipients) * 100, 1)
            ELSE 0
        END,
        'is_deleted', b.is_deleted,
        'created_at', b.created_at
    ) INTO v_result
    FROM messaging.user_message_broadcasts b
    LEFT JOIN security.users u ON u.id = b.sender_id
    WHERE b.id = p_broadcast_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION 'error.messaging.broadcast-not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION messaging.user_broadcast_get(INTEGER) IS 'Get broadcast details with sender info and read statistics as a single JSON response.';
