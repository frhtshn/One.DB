-- ================================================================
-- JURISDICTION_GET: Yetki alanı bilgilerini getir
-- ================================================================
-- Oyuncunun tüm jurisdiction ve geo bilgilerini döner.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.jurisdiction_get(BIGINT);

CREATE OR REPLACE FUNCTION kyc.jurisdiction_get(
    p_player_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-jurisdiction.player-required';
    END IF;

    SELECT jsonb_build_object(
        'id', j.id,
        'playerId', j.player_id,
        'registrationCountryCode', j.registration_country_code,
        'registrationIpCountry', j.registration_ip_country,
        'declaredCountryCode', j.declared_country_code,
        'verifiedCountryCode', j.verified_country_code,
        'verifiedAt', j.verified_at,
        'jurisdictionId', j.jurisdiction_id,
        'jurisdictionAssignedAt', j.jurisdiction_assigned_at,
        'jurisdictionAssignedBy', j.jurisdiction_assigned_by,
        'previousJurisdictionId', j.previous_jurisdiction_id,
        'jurisdictionChangedAt', j.jurisdiction_changed_at,
        'jurisdictionChangeReason', j.jurisdiction_change_reason,
        'geoStatus', j.geo_status,
        'geoBlockReason', j.geo_block_reason,
        'geoReviewedAt', j.geo_reviewed_at,
        'geoReviewedBy', j.geo_reviewed_by,
        'lastIpAddress', j.last_ip_address,
        'lastIpCountry', j.last_ip_country,
        'lastGeoCheckAt', j.last_geo_check_at,
        'vpnDetected', j.vpn_detected,
        'vpnDetectionCount', j.vpn_detection_count,
        'lastVpnDetectionAt', j.last_vpn_detection_at,
        'createdAt', j.created_at,
        'updatedAt', j.updated_at
    )
    INTO v_result
    FROM kyc.player_jurisdiction j
    WHERE j.player_id = p_player_id;

    -- NULL döner, hata değil (jurisdiction henüz atanmamış olabilir)
    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION kyc.jurisdiction_get IS 'Returns player jurisdiction and geo information. Returns NULL if not yet assigned.';
