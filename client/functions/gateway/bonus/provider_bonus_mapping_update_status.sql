-- ================================================================
-- PROVIDER_BONUS_MAPPING_UPDATE_STATUS: Eşleme durumunu güncelle
-- ================================================================
-- Bonus tamamlandığında, iptal edildiğinde veya süre dolduğunda
-- provider mapping durumunu günceller.
-- ================================================================

DROP FUNCTION IF EXISTS bonus.provider_bonus_mapping_update_status(BIGINT, VARCHAR(20));

CREATE OR REPLACE FUNCTION bonus.provider_bonus_mapping_update_status(
    p_id     BIGINT,
    p_status VARCHAR(20)
)
RETURNS VOID
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    -- ------------------------------------------------
    -- Status doğrulama
    -- ------------------------------------------------
    IF p_status IS NULL OR p_status NOT IN ('active', 'completed', 'cancelled', 'expired') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = format('error.bonus-mapping.invalid-status');
    END IF;

    -- ------------------------------------------------
    -- UPDATE
    -- ------------------------------------------------
    UPDATE bonus.provider_bonus_mappings
    SET status     = p_status,
        updated_at = NOW()
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = format('error.bonus-mapping.not-found');
    END IF;
END;
$$;

COMMENT ON FUNCTION bonus.provider_bonus_mapping_update_status(BIGINT, VARCHAR(20))
    IS 'Update provider bonus mapping status (active, completed, cancelled, expired)';
