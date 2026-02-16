-- ================================================================
-- TENANT_CONFIG_AUTO_POPULATE: Otomatik yapılandırma oluştur
-- ================================================================
-- Provisioning sırasında (WRITE_CONFIG adımı) çağrılır.
-- Tenant server bilgilerinden DB connection string'leri oluşturur.
-- Varsayılan güvenlik ayarlarını yazar.
-- Doğrudan INSERT — sistem fonksiyonu, IDOR kontrolü yok.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_config_auto_populate(BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_config_auto_populate(
    p_tenant_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_tenant RECORD;
    v_primary_host VARCHAR;
    v_replica_host VARCHAR;
    v_db_names TEXT[] := ARRAY['tenant', 'tenant_audit', 'tenant_log', 'tenant_report', 'tenant_affiliate'];
    v_db_name TEXT;
    v_conn_json JSONB;
BEGIN
    -- Tenant varlık kontrolü
    SELECT id, tenant_code
    INTO v_tenant
    FROM core.tenants
    WHERE id = p_tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- DB Primary sunucu host bilgisi
    SELECT s.host
    INTO v_primary_host
    FROM core.tenant_servers ts
    JOIN core.infrastructure_servers s ON s.id = ts.server_id
    WHERE ts.tenant_id = p_tenant_id AND ts.server_role = 'db_primary';

    IF v_primary_host IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.db-primary-not-assigned';
    END IF;

    -- DB Replica sunucu host bilgisi (opsiyonel)
    SELECT s.host
    INTO v_replica_host
    FROM core.tenant_servers ts
    JOIN core.infrastructure_servers s ON s.id = ts.server_id
    WHERE ts.tenant_id = p_tenant_id AND ts.server_role = 'db_replica';

    -- 5 DB connection string oluştur
    FOREACH v_db_name IN ARRAY v_db_names LOOP
        v_conn_json := jsonb_build_object(
            'host', v_primary_host,
            'port', 5432,
            'database', v_db_name || '_' || p_tenant_id,
            'username', 'nucleo_' || v_db_name || '_' || p_tenant_id,
            'password', 'auto_generated',
            'ssl_mode', 'require',
            'min_pool_size', 5,
            'max_pool_size', 50,
            'replica_enabled', v_replica_host IS NOT NULL,
            'replica_host', COALESCE(v_replica_host, ''),
            'replica_port', 5432
        );

        INSERT INTO core.tenant_settings (
            tenant_id, category, setting_key, setting_value, description, created_at, updated_at
        ) VALUES (
            p_tenant_id,
            'Database',
            'connection_' || v_db_name,
            v_conn_json,
            'Auto-generated connection string for ' || v_db_name || ' database',
            NOW(), NOW()
        )
        ON CONFLICT (tenant_id, setting_key)
        DO UPDATE SET
            setting_value = EXCLUDED.setting_value,
            updated_at = NOW();
    END LOOP;

    -- Varsayılan güvenlik ayarları
    INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description, created_at, updated_at)
    VALUES
        (p_tenant_id, 'Security', 'password_expiry_days', '30'::jsonb, 'Password expiry period in days', NOW(), NOW()),
        (p_tenant_id, 'Security', 'password_history_count', '3'::jsonb, 'Number of previous passwords to remember', NOW(), NOW()),
        (p_tenant_id, 'Security', 'password_min_length', '8'::jsonb, 'Minimum password length', NOW(), NOW())
    ON CONFLICT (tenant_id, setting_key)
    DO UPDATE SET
        setting_value = EXCLUDED.setting_value,
        updated_at = NOW();
END;
$$;

COMMENT ON FUNCTION core.tenant_config_auto_populate(BIGINT) IS 'Auto-generates tenant configuration during provisioning. Creates 5 DB connection strings from server assignments and default security settings. Idempotent via UPSERT.';
