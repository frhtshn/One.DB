-- ================================================================
-- TENANT_PROVISION_START: Provisioning başlat
-- ================================================================
-- Tenant'ın provisioning sürecini başlatır.
-- provisioning_status 'draft' veya 'failed' olmalı.
-- Ön koşulları doğrular: domain, sunucu atamaları, base_currency.
-- 11 adımlık log kaydı oluşturur ve UUID run_id döner.
-- ProductionManager tarafından çağrılır (system caller).
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_provision_start(BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_provision_start(
    p_tenant_id BIGINT
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_tenant RECORD;
    v_run_id UUID;
    v_server_roles TEXT[];
    v_steps TEXT[] := ARRAY[
        'VALIDATE', 'DB_PROVISION', 'DB_CREATE', 'DB_MIGRATE', 'DB_SEED',
        'WRITE_CONFIG', 'BACKEND_DEPLOY', 'CALLBACK_DEPLOY', 'FRONTEND_DEPLOY',
        'HEALTH_CHECK', 'ACTIVATE'
    ];
    v_i INTEGER;
BEGIN
    -- Tenant varlık ve durum kontrolü
    SELECT id, tenant_code, provisioning_status, domain, base_currency, hosting_mode
    INTO v_tenant
    FROM core.tenants
    WHERE id = p_tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    IF v_tenant.provisioning_status NOT IN ('draft', 'failed') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.invalid-status';
    END IF;

    -- Ön koşul: domain tanımlı olmalı
    IF v_tenant.domain IS NULL OR v_tenant.domain = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.domain-required';
    END IF;

    -- Ön koşul: base_currency tanımlı olmalı
    IF v_tenant.base_currency IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.base-currency-required';
    END IF;

    -- Ön koşul: en az db_primary + backend + frontend sunucu ataması yapılmış olmalı
    SELECT ARRAY_AGG(DISTINCT ts.server_role)
    INTO v_server_roles
    FROM core.tenant_servers ts
    WHERE ts.tenant_id = p_tenant_id;

    IF v_server_roles IS NULL
       OR NOT ('db_primary' = ANY(v_server_roles))
       OR NOT ('backend' = ANY(v_server_roles))
       OR NOT ('frontend' = ANY(v_server_roles)) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.missing-server-assignments';
    END IF;

    -- Provisioning başlat
    v_run_id := gen_random_uuid();

    UPDATE core.tenants SET
        provisioning_status = 'provisioning',
        provisioning_step = 'VALIDATE',
        updated_at = NOW()
    WHERE id = p_tenant_id;

    -- 11 adım kaydı oluştur
    FOR v_i IN 1..array_length(v_steps, 1) LOOP
        INSERT INTO core.tenant_provisioning_log (
            tenant_id, provision_run_id, step_name, step_order, status, created_at
        ) VALUES (
            p_tenant_id, v_run_id, v_steps[v_i], v_i, 'pending', NOW()
        );
    END LOOP;

    RETURN v_run_id;
END;
$$;

COMMENT ON FUNCTION core.tenant_provision_start(BIGINT) IS 'Starts tenant provisioning process. Validates prerequisites (domain, servers, currency), creates 11 step entries in provisioning log, returns UUID run_id. Called by ProductionManager.';
