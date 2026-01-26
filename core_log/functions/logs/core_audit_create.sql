-- ============================================================================
-- CORE AUDIT LOG FUNCTIONS
-- ============================================================================

DROP FUNCTION IF EXISTS logs.core_audit_create(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TEXT, TEXT, VARCHAR, VARCHAR);

-- Save core audit log entry - returns UUID
CREATE OR REPLACE FUNCTION logs.core_audit_create(
    p_event_id VARCHAR(255),
    p_user_id VARCHAR(255) DEFAULT NULL,
    p_action VARCHAR(100) DEFAULT NULL,
    p_entity_type VARCHAR(100) DEFAULT NULL,
    p_entity_id VARCHAR(255) DEFAULT NULL,
    p_old_value TEXT DEFAULT NULL,
    p_new_value TEXT DEFAULT NULL,
    p_ip_address VARCHAR(50) DEFAULT NULL,
    p_correlation_id VARCHAR(255) DEFAULT NULL
)
RETURNS TABLE(id UUID)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id UUID;
BEGIN
    INSERT INTO logs.audit_logs (
        event_id, user_id, action, entity_type, entity_id,
        old_value, new_value, ip_address, correlation_id
    ) VALUES (
        p_event_id, p_user_id, p_action, p_entity_type, p_entity_id,
        CASE WHEN p_old_value IS NOT NULL THEN p_old_value::JSONB ELSE NULL END,
        CASE WHEN p_new_value IS NOT NULL THEN p_new_value::JSONB ELSE NULL END,
        p_ip_address, p_correlation_id
    )
    RETURNING logs.audit_logs.id INTO v_id;

    RETURN QUERY SELECT v_id;
END;
$$;

COMMENT ON FUNCTION logs.core_audit_create IS 'Saves a core audit log entry, returns UUID';
