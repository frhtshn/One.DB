-- ================================================================
-- TENANT_SECRETS_GENERATE: Secret placeholder kayıtları oluştur
-- ================================================================
-- Provisioning sırasında (WRITE_CONFIG adımı) çağrılır.
-- JWT_SECRET, ENCRYPTION_KEY, API_KEY için placeholder oluşturur.
-- Gerçek değerler ProductionManager tarafından backend üzerinden yazılır.
-- Mevcut kayıt varsa atlanır (idempotent).
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_secrets_generate(BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION core.tenant_secrets_generate(
    p_tenant_id BIGINT,
    p_environment VARCHAR(20) DEFAULT 'production'
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_secret_types TEXT[] := ARRAY['JWT_SECRET', 'ENCRYPTION_KEY', 'API_KEY'];
    v_type TEXT;
BEGIN
    -- Tenant varlık kontrolü
    IF NOT EXISTS (SELECT 1 FROM core.tenants WHERE id = p_tenant_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- Parametre kontrolü
    IF p_environment NOT IN ('production', 'staging', 'shadow') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.secrets.invalid-environment';
    END IF;

    -- Her secret tipi için placeholder oluştur (mevcut varsa atla)
    FOREACH v_type IN ARRAY v_secret_types LOOP
        IF NOT EXISTS (
            SELECT 1 FROM security.secrets_tenant
            WHERE tenant_id = p_tenant_id
              AND secret_type = v_type
              AND environment = p_environment
        ) THEN
            INSERT INTO security.secrets_tenant (
                tenant_id, secret_type, secret_value, environment, is_active, created_at
            ) VALUES (
                p_tenant_id,
                v_type,
                'PLACEHOLDER_PENDING_GENERATION',
                p_environment,
                false,
                NOW()
            );
        END IF;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION core.tenant_secrets_generate(BIGINT, VARCHAR) IS 'Creates placeholder secret entries (JWT_SECRET, ENCRYPTION_KEY, API_KEY) for a tenant. Real values are generated and written by ProductionManager. Idempotent via NOT EXISTS check.';
