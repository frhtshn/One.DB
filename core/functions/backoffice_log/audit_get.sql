-- Get entity audit log by ID
CREATE OR REPLACE FUNCTION backoffice_log.audit_get(
    p_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
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
    ) INTO v_result
    FROM backoffice_log.audit_logs a
    WHERE a.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.logs.auditnotfound';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION backoffice_log.audit_get IS 'Gets an entity audit log entry by ID as JSONB';
