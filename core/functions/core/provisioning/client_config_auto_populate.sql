-- ================================================================
-- CLIENT_CONFIG_AUTO_POPULATE: Otomatik yapılandırma oluştur
-- ================================================================
-- Provisioning sırasında (WRITE_CONFIG adımı) çağrılır.
-- Client server bilgilerinden tek DB connection string oluşturur.
-- Varsayılan güvenlik ayarlarını yazar.
-- Doğrudan INSERT — sistem fonksiyonu, IDOR kontrolü yok.
-- ================================================================

DROP FUNCTION IF EXISTS core.client_config_auto_populate(BIGINT);

CREATE OR REPLACE FUNCTION core.client_config_auto_populate(
    p_client_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_client RECORD;
    v_primary_host VARCHAR;
    v_replica_host VARCHAR;
    v_conn_json JSONB;
BEGIN
    -- Client varlık kontrolü
    SELECT id, client_code
    INTO v_client
    FROM core.clients
    WHERE id = p_client_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- DB Primary sunucu host bilgisi
    SELECT s.host
    INTO v_primary_host
    FROM core.client_servers ts
    JOIN core.infrastructure_servers s ON s.id = ts.server_id
    WHERE ts.client_id = p_client_id AND ts.server_role = 'db_primary';

    IF v_primary_host IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.db-primary-not-assigned';
    END IF;

    -- DB Replica sunucu host bilgisi (opsiyonel)
    SELECT s.host
    INTO v_replica_host
    FROM core.client_servers ts
    JOIN core.infrastructure_servers s ON s.id = ts.server_id
    WHERE ts.client_id = p_client_id AND ts.server_role = 'db_replica';

    -- Tek DB connection string oluştur (tüm schema'lar tek DB'de)
    v_conn_json := jsonb_build_object(
        'host', v_primary_host,
        'port', 5432,
        'database', 'client_' || p_client_id,
        'username', 'so_client_' || p_client_id,
        'password', 'auto_generated',
        'ssl_mode', 'require',
        'min_pool_size', 5,
        'max_pool_size', 50,
        'replica_enabled', v_replica_host IS NOT NULL,
        'replica_host', COALESCE(v_replica_host, ''),
        'replica_port', 5432
    );

    INSERT INTO core.client_settings (
        client_id, category, setting_key, setting_value, description, created_at, updated_at
    ) VALUES (
        p_client_id,
        'Database',
        'connection_client',
        v_conn_json,
        'Auto-generated connection string for unified client database',
        NOW(), NOW()
    )
    ON CONFLICT (client_id, setting_key)
    DO UPDATE SET
        setting_value = EXCLUDED.setting_value,
        updated_at = NOW();

    -- Varsayılan güvenlik ayarları
    INSERT INTO core.client_settings (client_id, category, setting_key, setting_value, description, created_at, updated_at)
    VALUES
        (p_client_id, 'Security', 'password_expiry_days', '30'::jsonb, 'Password expiry period in days', NOW(), NOW()),
        (p_client_id, 'Security', 'password_history_count', '3'::jsonb, 'Number of previous passwords to remember', NOW(), NOW()),
        (p_client_id, 'Security', 'password_min_length', '8'::jsonb, 'Minimum password length', NOW(), NOW())
    ON CONFLICT (client_id, setting_key)
    DO UPDATE SET
        setting_value = EXCLUDED.setting_value,
        updated_at = NOW();
END;
$$;

COMMENT ON FUNCTION core.client_config_auto_populate(BIGINT) IS 'Auto-generates client configuration during provisioning. Creates single DB connection string (unified client database with 30 schemas) from server assignments and default security settings. Idempotent via UPSERT.';
