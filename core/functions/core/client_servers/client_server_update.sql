-- ================================================================
-- CLIENT_SERVER_UPDATE: Container bilgisi güncelle
-- ================================================================
-- ProductionManager tarafından provisioning sırasında çağrılır.
-- Container ID, durum ve sağlık bilgilerini günceller.
-- p_caller_id = -1 (SystemCallerId) olabilir.
-- ================================================================

DROP FUNCTION IF EXISTS core.client_server_update(BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, JSONB, JSONB);

CREATE OR REPLACE FUNCTION core.client_server_update(
    p_client_id BIGINT,
    p_server_role VARCHAR(30),
    p_container_id VARCHAR(100) DEFAULT NULL,
    p_container_name VARCHAR(150) DEFAULT NULL,
    p_container_image VARCHAR(255) DEFAULT NULL,
    p_status VARCHAR(20) DEFAULT NULL,
    p_health_status VARCHAR(20) DEFAULT NULL,
    p_environment_vars JSONB DEFAULT NULL,
    p_metadata JSONB DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF p_client_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.client.id-required';
    END IF;

    IF p_server_role IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.server.role-required';
    END IF;

    -- status validasyon
    IF p_status IS NOT NULL AND p_status NOT IN ('pending', 'creating', 'running', 'stopped', 'error', 'removed') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.server.invalid-container-status';
    END IF;

    UPDATE core.client_servers SET
        container_id = COALESCE(p_container_id, container_id),
        container_name = COALESCE(p_container_name, container_name),
        container_image = COALESCE(p_container_image, container_image),
        status = COALESCE(p_status, status),
        health_status = COALESCE(p_health_status, health_status),
        last_health_at = CASE WHEN p_health_status IS NOT NULL THEN NOW() ELSE last_health_at END,
        environment_vars = COALESCE(p_environment_vars, environment_vars),
        metadata = COALESCE(p_metadata, metadata),
        updated_at = NOW()
    WHERE client_id = p_client_id AND server_role = p_server_role;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client-server.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION core.client_server_update IS 'Updates client server container info during provisioning. Called by ProductionManager (system caller). COALESCE pattern preserves existing values.';
