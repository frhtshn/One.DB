
-- ================================================================
-- AUDIT_CREATE: Varlık denetim log kaydı ekler
-- Bu fonksiyon bir varlık denetim logu oluşturur ve UUID döner
-- ================================================================

DROP FUNCTION IF EXISTS backoffice_log.audit_create(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TIMESTAMPTZ);

CREATE OR REPLACE FUNCTION backoffice_log.audit_create(
    p_event_id VARCHAR(255) DEFAULT NULL,
    p_original_event_id VARCHAR(255) DEFAULT NULL,
    p_client_id VARCHAR(100) DEFAULT NULL,
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
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_id UUID; -- Oluşturulan varlık denetim logunun UUID'si
BEGIN
    INSERT INTO backoffice_log.audit_logs (
        event_id, original_event_id, client_id, user_id,
        action, entity_type, entity_id,
        old_value, new_value, ip_address,
        correlation_id, forwarded_at
    ) VALUES (
        p_event_id, p_original_event_id, p_client_id, p_user_id,
        p_action, p_entity_type, p_entity_id,
        CASE WHEN p_old_value IS NOT NULL THEN p_old_value::JSONB ELSE NULL END,
        CASE WHEN p_new_value IS NOT NULL THEN p_new_value::JSONB ELSE NULL END,
        p_ip_address, p_correlation_id, COALESCE(p_forwarded_at, NOW())
    )
    RETURNING backoffice_log.audit_logs.id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION backoffice_log.audit_create IS 'Adds an entity audit log entry. Returns UUID.';
