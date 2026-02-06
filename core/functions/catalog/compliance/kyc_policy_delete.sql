-- ================================================================
-- KYC_POLICY_DELETE: KYC policy pasife alır (soft delete)
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

    -- Soft delete
    UPDATE catalog.kyc_policies SET
        is_active = FALSE,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.kyc_policy_delete IS 'Soft-deletes a KYC policy by setting is_active to false.';
