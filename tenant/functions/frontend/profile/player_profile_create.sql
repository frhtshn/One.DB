-- ================================================================
-- PLAYER_PROFILE_CREATE: Oyuncu profili oluştur
-- ================================================================
-- Kayıt sonrası profil bilgilerini kaydeder.
-- Şifreli alanlar backend'den gelir (BYTEA + hash).
-- Bir oyuncunun sadece bir profili olabilir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS profile.player_profile_create(BIGINT, BYTEA, BYTEA, BYTEA, BYTEA, BYTEA, DATE, BYTEA, BYTEA, BYTEA, BYTEA, BYTEA, CHAR, VARCHAR, SMALLINT);

CREATE OR REPLACE FUNCTION profile.player_profile_create(
    p_player_id       BIGINT,
    p_first_name      BYTEA DEFAULT NULL,
    p_first_name_hash BYTEA DEFAULT NULL,
    p_middle_name     BYTEA DEFAULT NULL,
    p_last_name       BYTEA DEFAULT NULL,
    p_last_name_hash  BYTEA DEFAULT NULL,
    p_birth_date      DATE DEFAULT NULL,
    p_address         BYTEA DEFAULT NULL,
    p_phone           BYTEA DEFAULT NULL,
    p_phone_hash      BYTEA DEFAULT NULL,
    p_gsm             BYTEA DEFAULT NULL,
    p_gsm_hash        BYTEA DEFAULT NULL,
    p_country_code    CHAR(2) DEFAULT NULL,
    p_city            VARCHAR(100) DEFAULT NULL,
    p_gender          SMALLINT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id BIGINT;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-profile.player-required';
    END IF;

    -- Oyuncu kontrolü
    IF NOT EXISTS (SELECT 1 FROM auth.players WHERE id = p_player_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-profile.player-not-found';
    END IF;

    -- Tekrar kontrolü
    IF EXISTS (SELECT 1 FROM profile.player_profile WHERE player_id = p_player_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.player-profile.already-exists';
    END IF;

    INSERT INTO profile.player_profile (
        player_id, first_name, first_name_hash, middle_name,
        last_name, last_name_hash, birth_date, address,
        phone, phone_hash, gsm, gsm_hash,
        country_code, city, gender
    ) VALUES (
        p_player_id, p_first_name, p_first_name_hash, p_middle_name,
        p_last_name, p_last_name_hash, p_birth_date, p_address,
        p_phone, p_phone_hash, p_gsm, p_gsm_hash,
        p_country_code, p_city, p_gender
    )
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION profile.player_profile_create IS 'Creates player profile with encrypted PII fields. All fields optional except player_id. One profile per player.';
