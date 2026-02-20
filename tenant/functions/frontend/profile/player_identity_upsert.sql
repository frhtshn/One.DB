-- ================================================================
-- PLAYER_IDENTITY_UPSERT: Kimlik bilgisi ekle/güncelle
-- ================================================================
-- Kimlik numarası (TC/Pasaport) şifreli olarak saklanır.
-- Mevcut kayıt varsa günceller, yoksa oluşturur.
-- Güncelleme durumunda doğrulama sıfırlanır.
-- ================================================================

DROP FUNCTION IF EXISTS profile.player_identity_upsert(BIGINT, BYTEA, BYTEA);

CREATE OR REPLACE FUNCTION profile.player_identity_upsert(
    p_player_id       BIGINT,
    p_identity_no      BYTEA,
    p_identity_no_hash BYTEA
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-identity.player-required';
    END IF;

    IF p_identity_no IS NULL OR p_identity_no_hash IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-identity.identity-required';
    END IF;

    -- Oyuncu kontrolü
    IF NOT EXISTS (SELECT 1 FROM auth.players WHERE id = p_player_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-identity.player-not-found';
    END IF;

    -- Mevcut kayıt var mı?
    SELECT id INTO v_id
    FROM profile.player_identity
    WHERE player_id = p_player_id;

    IF FOUND THEN
        -- Güncelle, doğrulama sıfırla
        UPDATE profile.player_identity
        SET identity_no = p_identity_no,
            identity_no_hash = p_identity_no_hash,
            identity_confirmed = FALSE,
            verified_at = NULL
        WHERE id = v_id;
    ELSE
        -- Yeni kayıt
        INSERT INTO profile.player_identity (
            player_id, identity_no, identity_no_hash
        ) VALUES (
            p_player_id, p_identity_no, p_identity_no_hash
        )
        RETURNING id INTO v_id;
    END IF;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION profile.player_identity_upsert IS 'Creates or updates player identity (ID/passport) with encrypted storage. Resets verification status on update.';
