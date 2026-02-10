-- ================================================================
-- LOGIN_SESSION_CREATE: Oyuncu oturumu başlatır
-- Başarılı giriş sonrası çağrılır
-- GeoIP bilgileri ip-api.com'dan çözümlenmiş olarak gelir
-- ================================================================

DROP FUNCTION IF EXISTS player_audit.login_session_create(UUID,BIGINT,INET,VARCHAR,VARCHAR,CHAR,VARCHAR,VARCHAR,BOOLEAN,BOOLEAN,BOOLEAN);

CREATE OR REPLACE FUNCTION player_audit.login_session_create(
    p_session_token     UUID,                    -- Oturum token'ı
    p_player_id         BIGINT,                  -- Player ID
    p_ip_address        INET,                    -- IP adresi
    p_user_agent        VARCHAR(500) DEFAULT NULL,   -- Tarayıcı bilgisi
    p_device_fingerprint VARCHAR(64) DEFAULT NULL,   -- Cihaz parmak izi
    p_country_code      CHAR(2) DEFAULT NULL,    -- GeoIP ülke kodu
    p_region            VARCHAR(100) DEFAULT NULL,   -- GeoIP bölge
    p_city              VARCHAR(200) DEFAULT NULL,   -- GeoIP şehir
    p_is_proxy          BOOLEAN DEFAULT FALSE,   -- VPN/Proxy bayrağı
    p_is_hosting        BOOLEAN DEFAULT FALSE,   -- Datacenter bayrağı
    p_is_mobile         BOOLEAN DEFAULT FALSE    -- Mobil bağlantı bayrağı
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    INSERT INTO player_audit.login_sessions (
        session_token, player_id, ip_address, user_agent, device_fingerprint,
        country_code, region, city, is_proxy, is_hosting, is_mobile
    )
    VALUES (
        p_session_token, p_player_id, p_ip_address, p_user_agent, p_device_fingerprint,
        p_country_code, p_region, p_city,
        COALESCE(p_is_proxy, FALSE), COALESCE(p_is_hosting, FALSE), COALESCE(p_is_mobile, FALSE)
    )
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION player_audit.login_session_create IS 'Creates a new player login session with GeoIP data. Returns session ID.';
