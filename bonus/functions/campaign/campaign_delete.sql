-- ================================================================
-- CAMPAIGN_DELETE: Kampanya sonlandır (soft delete)
-- ================================================================
-- status = 'ended' yapar. Aktif award'lar etkilenmez.
-- ================================================================

DROP FUNCTION IF EXISTS campaign.campaign_delete(BIGINT);

CREATE OR REPLACE FUNCTION campaign.campaign_delete(
    p_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.campaign.id-required';
    END IF;

    UPDATE campaign.campaigns SET
        status = 'ended',
        updated_at = NOW()
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.campaign.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION campaign.campaign_delete(BIGINT) IS 'Soft-deletes a campaign by setting status=ended. Active awards linked to this campaign are not affected.';
