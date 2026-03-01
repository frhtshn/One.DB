-- ================================================================
-- JURISDICTION_UPDATE: Yetki alanı güncelle
-- ================================================================
-- Doğrulanmış ülke, jurisdiction değişikliği veya geo durumu.
-- Partial update: sadece gönderilen alanlar güncellenir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.jurisdiction_update(BIGINT, CHAR, INT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION kyc.jurisdiction_update(
    p_player_id            BIGINT,
    p_verified_country_code CHAR(2) DEFAULT NULL,
    p_jurisdiction_id      INT DEFAULT NULL,
    p_assigned_by          VARCHAR(20) DEFAULT NULL,
    p_change_reason        VARCHAR(255) DEFAULT NULL,
    p_geo_status           VARCHAR(20) DEFAULT NULL,
    p_geo_block_reason     VARCHAR(255) DEFAULT NULL,
    p_geo_reviewed_by      BIGINT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_jurisdiction_id INT;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-jurisdiction.player-required';
    END IF;

    -- Mevcut kayıt kontrolü
    SELECT jurisdiction_id INTO v_old_jurisdiction_id
    FROM kyc.player_jurisdiction
    WHERE player_id = p_player_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-jurisdiction.not-found';
    END IF;

    UPDATE kyc.player_jurisdiction SET
        verified_country_code = COALESCE(p_verified_country_code, verified_country_code),
        verified_at = CASE WHEN p_verified_country_code IS NOT NULL THEN NOW() ELSE verified_at END,
        jurisdiction_id = COALESCE(p_jurisdiction_id, jurisdiction_id),
        jurisdiction_assigned_by = COALESCE(p_assigned_by, jurisdiction_assigned_by),
        previous_jurisdiction_id = CASE
            WHEN p_jurisdiction_id IS NOT NULL AND p_jurisdiction_id != v_old_jurisdiction_id
            THEN v_old_jurisdiction_id
            ELSE previous_jurisdiction_id
        END,
        jurisdiction_changed_at = CASE
            WHEN p_jurisdiction_id IS NOT NULL AND p_jurisdiction_id != v_old_jurisdiction_id
            THEN NOW()
            ELSE jurisdiction_changed_at
        END,
        jurisdiction_change_reason = COALESCE(p_change_reason, jurisdiction_change_reason),
        geo_status = COALESCE(p_geo_status, geo_status),
        geo_block_reason = COALESCE(p_geo_block_reason, geo_block_reason),
        geo_reviewed_at = CASE WHEN p_geo_reviewed_by IS NOT NULL THEN NOW() ELSE geo_reviewed_at END,
        geo_reviewed_by = COALESCE(p_geo_reviewed_by, geo_reviewed_by),
        updated_at = NOW()
    WHERE player_id = p_player_id;
END;
$$;

COMMENT ON FUNCTION kyc.jurisdiction_update IS 'Updates player jurisdiction with partial update. Tracks jurisdiction changes with previous_jurisdiction_id.';
