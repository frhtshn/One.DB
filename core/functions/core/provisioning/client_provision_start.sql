-- ================================================================
-- CLIENT_PROVISION_START: Provisioning başlat
-- ================================================================
-- Client'ın provisioning sürecini başlatır.
-- provisioning_status 'draft' veya 'failed' olmalı.
-- Ön koşulları doğrular: domain, sunucu atamaları, base_currency.
-- 11 adımlık log kaydı oluşturur ve UUID run_id döner.
-- ProductionManager tarafından çağrılır (system caller).
-- ================================================================

DROP FUNCTION IF EXISTS core.client_provision_start(BIGINT);

CREATE OR REPLACE FUNCTION core.client_provision_start(
    p_client_id BIGINT
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_client RECORD;
    v_run_id UUID;
    v_server_roles TEXT[];
    v_steps TEXT[] := ARRAY[
        'VALIDATE', 'DB_PROVISION', 'DB_CREATE', 'DB_MIGRATE', 'DB_SEED',
        'WRITE_CONFIG', 'BACKEND_DEPLOY', 'CALLBACK_DEPLOY', 'FRONTEND_DEPLOY',
        'HEALTH_CHECK', 'ACTIVATE'
    ];
    v_i INTEGER;
BEGIN
    -- Client varlık ve durum kontrolü
    SELECT id, client_code, provisioning_status, domain, base_currency, hosting_mode
    INTO v_client
    FROM core.clients
    WHERE id = p_client_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    IF v_client.provisioning_status NOT IN ('draft', 'failed') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.invalid-status';
    END IF;

    -- Ön koşul: domain tanımlı olmalı
    IF v_client.domain IS NULL OR v_client.domain = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.domain-required';
    END IF;

    -- Ön koşul: base_currency tanımlı olmalı
    IF v_client.base_currency IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.base-currency-required';
    END IF;

    -- Ön koşul: en az db_primary + backend + frontend sunucu ataması yapılmış olmalı
    SELECT ARRAY_AGG(DISTINCT ts.server_role)
    INTO v_server_roles
    FROM core.client_servers ts
    WHERE ts.client_id = p_client_id;

    IF v_server_roles IS NULL
       OR NOT ('db_primary' = ANY(v_server_roles))
       OR NOT ('backend' = ANY(v_server_roles))
       OR NOT ('frontend' = ANY(v_server_roles)) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provision.missing-server-assignments';
    END IF;

    -- Provisioning başlat
    v_run_id := gen_random_uuid();

    UPDATE core.clients SET
        provisioning_status = 'provisioning',
        provisioning_step = 'VALIDATE',
        updated_at = NOW()
    WHERE id = p_client_id;

    -- 11 adım kaydı oluştur
    FOR v_i IN 1..array_length(v_steps, 1) LOOP
        INSERT INTO core.client_provisioning_log (
            client_id, provision_run_id, step_name, step_order, status, created_at
        ) VALUES (
            p_client_id, v_run_id, v_steps[v_i], v_i, 'pending', NOW()
        );
    END LOOP;

    RETURN v_run_id;
END;
$$;

COMMENT ON FUNCTION core.client_provision_start(BIGINT) IS 'Starts client provisioning process. Validates prerequisites (domain, servers, currency), creates 11 step entries in provisioning log, returns UUID run_id. Called by ProductionManager.';
