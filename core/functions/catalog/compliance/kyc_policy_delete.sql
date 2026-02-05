-- ================================================================
-- KYC_POLICY_DELETE: KYC policy siler
-- ================================================================

DROP FUNCTION IF EXISTS catalog.kyc_policy_delete(INT);

CREATE OR REPLACE FUNCTION catalog.kyc_policy_delete(
    p_id INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-policy.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.kyc_policies kp WHERE kp.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-policy.not-found';
    END IF;

    -- NOT: Aktif tenant kullanımı kontrolü eklenebilir
    -- IF EXISTS(SELECT 1 FROM tenant.player_jurisdiction pj WHERE pj.jurisdiction_id = ...) THEN
    --     RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.kyc-policy.in-use';
    -- END IF;

    -- Sil
    DELETE FROM catalog.kyc_policies WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.kyc_policy_delete IS 'Deletes a KYC policy.';
