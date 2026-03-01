-- ================================================================
-- ADMIN_MESSAGE_DRAFT_GET: Draft detayını döner
-- Published ise okunma istatistikleri dahil
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_draft_get(INTEGER);

CREATE OR REPLACE FUNCTION messaging.admin_message_draft_get(
    p_draft_id INTEGER  -- Draft ID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_draft_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.draft-id-required' USING ERRCODE = 'P0400';
    END IF;

    SELECT jsonb_build_object(
        'id', d.id,
        'sender_id', d.sender_id,
        'sender_name', u.first_name || ' ' || u.last_name,
        'subject', d.subject,
        'body', d.body,
        'message_type', d.message_type,
        'priority', d.priority,
        'company_id', d.company_id,
        'client_ids', d.client_ids,
        'department_id', d.department_id,
        'role_id', d.role_id,
        'status', d.status,
        'scheduled_at', d.scheduled_at,
        'published_at', d.published_at,
        'expires_at', d.expires_at,
        'total_recipients', d.total_recipients,
        'read_count', CASE WHEN d.status = 'published' THEN (
            SELECT COUNT(*) FROM messaging.user_messages m
            WHERE m.draft_id = d.id AND m.is_read = TRUE
        ) ELSE 0 END,
        'read_rate', CASE WHEN d.status = 'published' AND d.total_recipients > 0 THEN
            ROUND((
                SELECT COUNT(*)::NUMERIC FROM messaging.user_messages m
                WHERE m.draft_id = d.id AND m.is_read = TRUE
            ) / d.total_recipients * 100, 1)
        ELSE 0 END,
        'created_at', d.created_at,
        'updated_at', d.updated_at
    ) INTO v_result
    FROM messaging.user_message_drafts d
    LEFT JOIN security.users u ON u.id = d.sender_id
    WHERE d.id = p_draft_id
      AND d.is_deleted = FALSE;

    IF v_result IS NULL THEN
        RAISE EXCEPTION 'error.messaging.draft-not-found' USING ERRCODE = 'P0404';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_draft_get(INTEGER) IS 'Get draft details by ID. Includes dynamic read stats (read_count, read_rate) for published drafts.';
