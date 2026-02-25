-- ================================================================
-- PLAYER_IDENTITY_UPDATE_ENCRYPTED: Sifreli kimlik guncelleme
-- ================================================================
-- Re-encryption sonrasi identity_no ve hash'i gunceller.
-- identity_confirmed ve verified_at'e DOKUNMAZ.
-- Mevcut player_identity_upsert dogrulama sifirliyor — bu fonksiyon
-- sadece encryption key degisikliginde kullanilir.
-- ================================================================

DROP FUNCTION IF EXISTS profile.player_identity_update_encrypted(BIGINT, BYTEA, BYTEA);

CREATE OR REPLACE FUNCTION profile.player_identity_update_encrypted(
    p_player_id       BIGINT,
    p_identity_no      BYTEA,
    p_identity_no_hash BYTEA
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-identity.player-required';
    END IF;

    IF p_identity_no IS NULL OR p_identity_no_hash IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-identity.identity-required';
    END IF;

    UPDATE profile.player_identity
    SET identity_no = p_identity_no,
        identity_no_hash = p_identity_no_hash
    WHERE player_id = p_player_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-identity.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION profile.player_identity_update_encrypted IS 'Updates only identity_no and hash after re-encryption. Does NOT reset identity_confirmed or verified_at. Use player_identity_upsert for normal identity changes.';
