-- ================================================================
-- CLIENT_GAME_REMOVE: Client oyun kapatma (soft delete)
-- ================================================================
-- is_enabled=false + disabled_reason ayarlar.
-- sync_status='pending' ile client DB'ye de yansıtılır.
-- ================================================================

DROP FUNCTION IF EXISTS core.client_game_remove(BIGINT, BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION core.client_game_remove(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_game_id BIGINT,
    p_disabled_reason VARCHAR(255) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_company_id BIGINT;
BEGIN
    -- Client varlık kontrolü
    SELECT company_id INTO v_company_id
    FROM core.clients WHERE id = p_client_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_company_id);

    -- game_id zorunlu
    IF p_game_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.id-required';
    END IF;

    -- Kayıt kontrolü + güncelleme
    UPDATE core.client_games SET
        is_enabled = false,
        disabled_at = NOW(),
        disabled_reason = COALESCE(p_disabled_reason, 'disabled_by_admin'),
        sync_status = 'pending',
        updated_at = NOW(),
        updated_by = p_caller_id
    WHERE client_id = p_client_id AND game_id = p_game_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client-game.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION core.client_game_remove IS 'Soft-disables a client game (is_enabled=false) with optional reason. Sets sync_status=pending for client DB propagation. IDOR protected.';
