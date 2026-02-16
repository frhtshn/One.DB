-- ================================================================
-- INFRASTRUCTURE_SERVER_CREATE: Yeni sunucu envantere ekle
-- ================================================================
-- Platform Admin (SUPER_ADMIN) tarafından kullanılır.
-- server_code UNIQUE olmalıdır.
-- Kapasite ve bağlantı bilgilerini kayıt eder.
-- ================================================================

DROP FUNCTION IF EXISTS core.infrastructure_server_create(
    BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, BOOLEAN,
    VARCHAR, VARCHAR, VARCHAR,
    VARCHAR, VARCHAR, JSONB, INTEGER
);

CREATE OR REPLACE FUNCTION core.infrastructure_server_create(
    p_caller_id BIGINT,
    p_server_code VARCHAR(50),
    p_server_name VARCHAR(255) DEFAULT NULL,
    p_host VARCHAR(255) DEFAULT NULL,
    p_docker_host VARCHAR(255) DEFAULT NULL,
    p_docker_tls_verify BOOLEAN DEFAULT true,
    p_region VARCHAR(50) DEFAULT NULL,
    p_cloud_provider VARCHAR(50) DEFAULT NULL,
    p_availability_zone VARCHAR(50) DEFAULT NULL,
    p_server_type VARCHAR(30) DEFAULT 'shared',
    p_server_purpose VARCHAR(30) DEFAULT 'all',
    p_specs JSONB DEFAULT '{}',
    p_max_tenants INTEGER DEFAULT 10
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_role_level INTEGER;
    v_new_id BIGINT;
BEGIN
    -- SUPER_ADMIN kontrolü (role_level >= 100)
    SELECT al.role_level INTO v_role_level
    FROM security.user_get_access_level(p_caller_id) al;

    IF v_role_level IS NULL OR v_role_level < 100 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.auth.super-admin-required';
    END IF;

    -- server_code zorunlu
    IF p_server_code IS NULL OR TRIM(p_server_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.server.code-required';
    END IF;

    -- host zorunlu
    IF p_host IS NULL OR TRIM(p_host) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.server.host-required';
    END IF;

    -- server_code unique kontrolü
    IF EXISTS(SELECT 1 FROM core.infrastructure_servers WHERE server_code = LOWER(TRIM(p_server_code))) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.server.code-exists';
    END IF;

    -- server_type validasyon
    IF p_server_type NOT IN ('dedicated', 'shared') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.server.invalid-type';
    END IF;

    -- server_purpose validasyon
    IF p_server_purpose NOT IN ('all', 'db_only', 'app_only') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.server.invalid-purpose';
    END IF;

    INSERT INTO core.infrastructure_servers (
        server_code, server_name, host, docker_host, docker_tls_verify,
        region, cloud_provider, availability_zone,
        server_type, server_purpose, specs, max_tenants,
        status, health_status,
        created_at, updated_at, created_by
    ) VALUES (
        LOWER(TRIM(p_server_code)),
        TRIM(p_server_name),
        TRIM(p_host),
        TRIM(p_docker_host),
        p_docker_tls_verify,
        TRIM(p_region),
        TRIM(p_cloud_provider),
        TRIM(p_availability_zone),
        p_server_type,
        p_server_purpose,
        COALESCE(p_specs, '{}'),
        COALESCE(p_max_tenants, 10),
        'active',
        'unknown',
        NOW(),
        NOW(),
        p_caller_id
    )
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION core.infrastructure_server_create IS 'Creates a new infrastructure server entry. Requires SUPER_ADMIN role (level >= 100). Server code must be unique.';
