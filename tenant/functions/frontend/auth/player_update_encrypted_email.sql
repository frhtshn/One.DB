-- ================================================================
-- PLAYER_UPDATE_ENCRYPTED_EMAIL: Sifreli email guncelleme
-- ================================================================
-- Re-encryption sonrasi yeni ciphertext'i yazar.
-- email_hash degismez (SHA-256, key'den bagimsiz).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_update_encrypted_email(BIGINT, BYTEA);

CREATE OR REPLACE FUNCTION auth.player_update_encrypted_email(
    p_player_id       BIGINT,
    p_email_encrypted BYTEA
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player.player-required';
    END IF;

    IF p_email_encrypted IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player.email-required';
    END IF;

    UPDATE auth.players
    SET email_encrypted = p_email_encrypted
    WHERE id = p_player_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION auth.player_update_encrypted_email IS 'Updates only email_encrypted column after re-encryption. Hash remains unchanged (SHA-256 is key-independent).';
