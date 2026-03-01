-- ================================================================
-- JURISDICTION_UPDATE_GEO: Geo konum güncelle
-- ================================================================
-- Her giriş/işlemde IP bazlı konum güncellemesi.
-- VPN tespiti sayacı tutar.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.jurisdiction_update_geo(BIGINT, VARCHAR, CHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION kyc.jurisdiction_update_geo(
    p_player_id  BIGINT,
    p_ip_address VARCHAR(45),
    p_ip_country CHAR(2),
    p_is_vpn     BOOLEAN DEFAULT FALSE
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-jurisdiction.player-required';
    END IF;

    UPDATE kyc.player_jurisdiction SET
        last_ip_address = p_ip_address,
        last_ip_country = p_ip_country,
        last_geo_check_at = NOW(),
        vpn_detected = COALESCE(p_is_vpn, FALSE),
        vpn_detection_count = CASE
            WHEN p_is_vpn = TRUE THEN vpn_detection_count + 1
            ELSE vpn_detection_count
        END,
        last_vpn_detection_at = CASE
            WHEN p_is_vpn = TRUE THEN NOW()
            ELSE last_vpn_detection_at
        END,
        updated_at = NOW()
    WHERE player_id = p_player_id;
END;
$$;

COMMENT ON FUNCTION kyc.jurisdiction_update_geo IS 'Updates player geo location on every login/transaction. Tracks VPN detection count.';
