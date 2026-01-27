
-- ================================================================
-- CORE_AUDIT_CREATE: Çekirdek denetim log kaydı ekler
-- Bu fonksiyon bir denetim logu oluşturur ve UUID döner
-- ================================================================

DROP FUNCTION IF EXISTS logs.core_audit_create(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TEXT, TEXT, VARCHAR, VARCHAR);

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
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_id UUID; -- Oluşturulan log kaydının UUID'si
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

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION logs.core_audit_create IS 'Adds a core audit log entry. Returns UUID.';
