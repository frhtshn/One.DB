-- Get paginated entity audit logs
CREATE OR REPLACE FUNCTION backoffice_log.audit_list(
    p_client_id VARCHAR(100) DEFAULT NULL,
    p_user_id VARCHAR(255) DEFAULT NULL,
    p_action VARCHAR(100) DEFAULT NULL,
    p_entity_type VARCHAR(100) DEFAULT NULL,
    p_entity_id VARCHAR(255) DEFAULT NULL,
    p_from_date TIMESTAMPTZ DEFAULT NULL,
    p_to_date TIMESTAMPTZ DEFAULT NULL,
    p_page INT DEFAULT 1,
    p_page_size INT DEFAULT 20
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
    v_offset INT;
    v_total INT;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    SELECT COUNT(*) INTO v_total
    FROM backoffice_log.audit_logs a
    WHERE (p_client_id IS NULL OR a.client_id = p_client_id)
      AND (p_user_id IS NULL OR a.user_id = p_user_id)
      AND (p_action IS NULL OR a.action = p_action)
      AND (p_entity_type IS NULL OR a.entity_type = p_entity_type)
      AND (p_entity_id IS NULL OR a.entity_id = p_entity_id)
      AND (p_from_date IS NULL OR a.created_at >= p_from_date)
      AND (p_to_date IS NULL OR a.created_at <= p_to_date);

    SELECT jsonb_build_object(
        'items', COALESCE(
            (SELECT jsonb_agg(
                jsonb_build_object(
                    'id', a.id,
                    'eventId', a.event_id,
                    'originalEventId', a.original_event_id,
                    'clientId', a.client_id,
                    'userId', a.user_id,
                    'action', a.action,
                    'entityType', a.entity_type,
                    'entityId', a.entity_id,
                    'oldValue', a.old_value,
                    'newValue', a.new_value,
                    'ipAddress', a.ip_address,
                    'correlationId', a.correlation_id,
                    'forwardedAt', a.forwarded_at,
                    'createdAt', a.created_at
                )
                ORDER BY a.created_at DESC
            )
            FROM backoffice_log.audit_logs a
            WHERE (p_client_id IS NULL OR a.client_id = p_client_id)
              AND (p_user_id IS NULL OR a.user_id = p_user_id)
              AND (p_action IS NULL OR a.action = p_action)
              AND (p_entity_type IS NULL OR a.entity_type = p_entity_type)
              AND (p_entity_id IS NULL OR a.entity_id = p_entity_id)
              AND (p_from_date IS NULL OR a.created_at >= p_from_date)
              AND (p_to_date IS NULL OR a.created_at <= p_to_date)
            LIMIT p_page_size
            OFFSET v_offset),
            '[]'::JSONB
        ),
        'totalCount', v_total
    ) INTO v_result;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION backoffice_log.audit_list IS 'Retrieves paginated entity audit logs as JSONB';
