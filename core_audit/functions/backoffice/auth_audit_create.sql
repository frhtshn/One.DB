-- ================================================================
-- AUTH_AUDIT_CREATE: Kimlik denetim log kaydı ekler
-- Bu fonksiyon bir kimlik denetim logu oluşturur ve BIGINT döner
-- GeoIP bilgileri ip-api.com'dan çözümlenmiş olarak gelir
-- Partitioned tablo: created_at üzerinden otomatik partition pruning
-- ================================================================

DROP FUNCTION IF EXISTS backoffice.auth_audit_create(BIGINT,BIGINT,BIGINT,VARCHAR,TEXT,VARCHAR,VARCHAR,CHAR,VARCHAR,BOOLEAN,BOOLEAN,BOOLEAN,BOOLEAN,VARCHAR);

CREATE OR REPLACE FUNCTION backoffice.auth_audit_create(
    p_user_id BIGINT,
    p_company_id BIGINT,
    p_tenant_id BIGINT,
    p_event_type VARCHAR(50),
    p_event_data TEXT DEFAULT NULL,
    p_ip_address VARCHAR(50) DEFAULT NULL,
    p_user_agent VARCHAR(500) DEFAULT NULL,
    p_country_code CHAR(2) DEFAULT NULL,             -- GeoIP ülke kodu
    p_city VARCHAR(200) DEFAULT NULL,                -- GeoIP şehir
    p_is_proxy BOOLEAN DEFAULT FALSE,                -- VPN/Proxy bayrağı
    p_is_hosting BOOLEAN DEFAULT FALSE,              -- Datacenter bayrağı
    p_is_mobile BOOLEAN DEFAULT FALSE,               -- Mobil bağlantı bayrağı
    p_success BOOLEAN DEFAULT TRUE,
    p_error_message VARCHAR(500) DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT; -- Oluşturulan kimlik denetim logunun ID'si
BEGIN
    INSERT INTO backoffice.auth_audit_log (
        user_id, company_id, tenant_id, event_type,
        event_data, ip_address, user_agent,
        country_code, city, is_proxy, is_hosting, is_mobile,
        success, error_message
    )
    VALUES (
        p_user_id, p_company_id, p_tenant_id, p_event_type,
        CASE WHEN p_event_data IS NOT NULL THEN p_event_data::JSONB ELSE NULL END,
        p_ip_address, p_user_agent,
        p_country_code, p_city,
        COALESCE(p_is_proxy, FALSE), COALESCE(p_is_hosting, FALSE), COALESCE(p_is_mobile, FALSE),
        p_success, p_error_message
    )
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION backoffice.auth_audit_create IS 'Adds an auth audit log entry with GeoIP data. Returns BIGINT.';
