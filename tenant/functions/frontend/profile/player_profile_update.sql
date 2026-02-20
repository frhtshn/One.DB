-- ================================================================
-- PLAYER_PROFILE_UPDATE: Oyuncu profil güncelleme
-- ================================================================
-- Partial update: sadece gönderilen alanlar güncellenir.
-- COALESCE ile mevcut değerler korunur.
-- ================================================================

DROP FUNCTION IF EXISTS profile.player_profile_update(BIGINT, BYTEA, BYTEA, BYTEA, BYTEA, BYTEA, DATE, BYTEA, BYTEA, BYTEA, BYTEA, BYTEA, CHAR, VARCHAR, SMALLINT);

CREATE OR REPLACE FUNCTION profile.player_profile_update(
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
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-profile.player-required';
    END IF;

    UPDATE profile.player_profile SET
        first_name      = COALESCE(p_first_name, first_name),
        first_name_hash = COALESCE(p_first_name_hash, first_name_hash),
        middle_name     = COALESCE(p_middle_name, middle_name),
        last_name       = COALESCE(p_last_name, last_name),
        last_name_hash  = COALESCE(p_last_name_hash, last_name_hash),
        birth_date      = COALESCE(p_birth_date, birth_date),
        address         = COALESCE(p_address, address),
        phone           = COALESCE(p_phone, phone),
        phone_hash      = COALESCE(p_phone_hash, phone_hash),
        gsm             = COALESCE(p_gsm, gsm),
        gsm_hash        = COALESCE(p_gsm_hash, gsm_hash),
        country_code    = COALESCE(p_country_code, country_code),
        city            = COALESCE(p_city, city),
        gender          = COALESCE(p_gender, gender),
        updated_at      = NOW()
    WHERE player_id = p_player_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-profile.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION profile.player_profile_update IS 'Updates player profile using partial update pattern. Only non-NULL parameters are applied.';
