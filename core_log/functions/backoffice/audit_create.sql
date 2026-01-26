-- ============================================================================
-- ENTITY AUDIT LOG FUNCTIONS
-- ============================================================================

-- Save entity audit log entry - returns UUID
CREATE OR REPLACE FUNCTION backoffice.audit_create(
    p_event_id VARCHAR(255) DEFAULT NULL,
    p_original_event_id VARCHAR(255) DEFAULT NULL,
    p_tenant_id VARCHAR(100) DEFAULT NULL,
    p_user_id VARCHAR(255) DEFAULT NULL,
    p_action VARCHAR(100) DEFAULT NULL,
    p_entity_type VARCHAR(100) DEFAULT NULL,
    p_entity_id VARCHAR(255) DEFAULT NULL,
    p_old_value TEXT DEFAULT NULL,
    p_new_value TEXT DEFAULT NULL,
    p_ip_address VARCHAR(50) DEFAULT NULL,
    p_correlation_id VARCHAR(255) DEFAULT NULL,
    p_forwarded_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS TABLE(id UUID)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id UUID;
BEGIN
    INSERT INTO backoffice.audit_logs (
        event_id, original_event_id, tenant_id, user_id,
        action, entity_type, entity_id,
        old_value, new_value, ip_address,
        correlation_id, forwarded_at
    ) VALUES (
        p_event_id, p_original_event_id, p_tenant_id, p_user_id,
        p_action, p_entity_type, p_entity_id,
        CASE WHEN p_old_value IS NOT NULL THEN p_old_value::JSONB ELSE NULL END,
        CASE WHEN p_new_value IS NOT NULL THEN p_new_value::JSONB ELSE NULL END,
        p_ip_address, p_correlation_id, COALESCE(p_forwarded_at, NOW())
    )
    RETURNING backoffice.audit_logs.id INTO v_id;

    RETURN QUERY SELECT v_id;
END;
$$;

COMMENT ON FUNCTION backoffice.audit_create IS 'Saves an entity audit log entry, returns UUID';
