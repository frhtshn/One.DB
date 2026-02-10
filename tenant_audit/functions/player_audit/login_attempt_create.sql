-- ================================================================
-- LOGIN_ATTEMPT_CREATE: Oyuncu giriş denemesi kaydı oluşturur
-- Başarılı ve başarısız tüm giriş denemelerini loglar
-- GeoIP bilgileri ip-api.com'dan çözümlenmiş olarak gelir
-- ================================================================

DROP FUNCTION IF EXISTS player_audit.login_attempt_create(BIGINT,VARCHAR,INET,VARCHAR,BOOLEAN,CHAR,VARCHAR,BOOLEAN,BOOLEAN,BOOLEAN,VARCHAR);

CREATE OR REPLACE FUNCTION player_audit.login_attempt_create(
    p_player_id      BIGINT,                 -- Player ID (başarılıysa, NULL olabilir)
    p_identifier     VARCHAR(300),            -- Denenen email/username (encrypted)
    p_ip_address     INET,                    -- IP adresi
    p_user_agent     VARCHAR(500),            -- Tarayıcı bilgisi
    p_is_successful  BOOLEAN,                 -- Başarılı mı?
    p_country_code   CHAR(2) DEFAULT NULL,    -- GeoIP ülke kodu
    p_city           VARCHAR(200) DEFAULT NULL,  -- GeoIP şehir
    p_is_proxy       BOOLEAN DEFAULT FALSE,   -- VPN/Proxy bayrağı
    p_is_hosting     BOOLEAN DEFAULT FALSE,   -- Datacenter bayrağı
    p_is_mobile      BOOLEAN DEFAULT FALSE,   -- Mobil bağlantı bayrağı
    p_failure_reason VARCHAR(50) DEFAULT NULL  -- Başarısızlık sebebi
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    INSERT INTO player_audit.login_attempts (
        player_id, identifier, ip_address, user_agent,
        country_code, city, is_proxy, is_hosting, is_mobile,
        is_successful, failure_reason
    )
    VALUES (
        p_player_id, p_identifier, p_ip_address, p_user_agent,
        p_country_code, p_city,
        COALESCE(p_is_proxy, FALSE), COALESCE(p_is_hosting, FALSE), COALESCE(p_is_mobile, FALSE),
        p_is_successful, p_failure_reason
    )
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION player_audit.login_attempt_create IS 'Creates a player login attempt record with GeoIP data. Returns attempt ID.';
