-- ================================================================
-- JURISDICTION_CREATE: Oyuncu yetki alanı oluştur
-- ================================================================
-- Kayıt sırasında oyuncunun yetki alanını belirler.
-- Ülke kodu ve IP ülkesi ile jurisdiction ataması yapar.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.jurisdiction_create(BIGINT, CHAR, CHAR, CHAR, INT, VARCHAR);

CREATE OR REPLACE FUNCTION kyc.jurisdiction_create(
    p_player_id                 BIGINT,
    p_registration_country_code CHAR(2),
    p_registration_ip_country   CHAR(2) DEFAULT NULL,
    p_declared_country_code     CHAR(2) DEFAULT NULL,
    p_jurisdiction_id           INT DEFAULT NULL,
    p_assigned_by               VARCHAR(20) DEFAULT 'system'
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-jurisdiction.player-required';
    END IF;

    IF p_registration_country_code IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-jurisdiction.country-required';
    END IF;

    -- Oyuncu kontrolü
    IF NOT EXISTS (SELECT 1 FROM auth.players WHERE id = p_player_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-jurisdiction.player-not-found';
    END IF;

    -- Tekrar kontrolü (UNIQUE player_id)
    IF EXISTS (SELECT 1 FROM kyc.player_jurisdiction WHERE player_id = p_player_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.kyc-jurisdiction.already-exists';
    END IF;

    INSERT INTO kyc.player_jurisdiction (
        player_id, registration_country_code, registration_ip_country,
        declared_country_code, jurisdiction_id, jurisdiction_assigned_by
    ) VALUES (
        p_player_id, p_registration_country_code, p_registration_ip_country,
        p_declared_country_code, COALESCE(p_jurisdiction_id, 0),
        COALESCE(p_assigned_by, 'system')
    )
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION kyc.jurisdiction_create IS 'Creates player jurisdiction record with registration country and IP country. One per player (UNIQUE).';
