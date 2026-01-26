-- ============================================================================
-- AUTH AUDIT LOG FUNCTIONS
-- ============================================================================

-- Save auth audit event - returns BIGINT ID
CREATE OR REPLACE FUNCTION backoffice.auth_audit_create(
    p_user_id BIGINT,
    p_company_id BIGINT,
    p_tenant_id BIGINT,
    p_event_type VARCHAR(50),
    p_event_data TEXT DEFAULT NULL,
    p_ip_address VARCHAR(50) DEFAULT NULL,
    p_user_agent VARCHAR(500) DEFAULT NULL,
    p_success BOOLEAN DEFAULT TRUE,
    p_error_message VARCHAR(500) DEFAULT NULL
)
RETURNS TABLE(id BIGINT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    INSERT INTO backoffice.auth_audit_log (
        user_id, company_id, tenant_id, event_type,
        event_data, ip_address, user_agent, success, error_message
    )
    VALUES (
        p_user_id, p_company_id, p_tenant_id, p_event_type,
        CASE WHEN p_event_data IS NOT NULL THEN p_event_data::JSONB ELSE NULL END,
        p_ip_address, p_user_agent, p_success, p_error_message
    )
    RETURNING backoffice.auth_audit_log.id INTO v_id;

    RETURN QUERY SELECT v_id;
END;
$$;

COMMENT ON FUNCTION backoffice.auth_audit_create IS 'Saves an auth audit event, returns BIGINT ID';
