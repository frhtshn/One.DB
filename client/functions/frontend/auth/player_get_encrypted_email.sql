-- ================================================================
-- PLAYER_GET_ENCRYPTED_EMAIL: Oyuncunun sifreli emailini doner
-- ================================================================
-- Re-encryption icin tek kolonu doner (BYTEA).
-- Mevcut player_get cok agir (6 sorgu) — bu hafif alternatif.
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_get_encrypted_email(BIGINT);

CREATE OR REPLACE FUNCTION auth.player_get_encrypted_email(
    p_player_id BIGINT
)
RETURNS BYTEA
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_email_encrypted BYTEA;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player.player-required';
    END IF;

    SELECT p.email_encrypted
    INTO v_email_encrypted
    FROM auth.players p
    WHERE p.id = p_player_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player.not-found';
    END IF;

    RETURN v_email_encrypted;
END;
$$;

COMMENT ON FUNCTION auth.player_get_encrypted_email IS 'Returns raw email_encrypted BYTEA for a player. Lightweight alternative to player_get for re-encryption batch processing.';
