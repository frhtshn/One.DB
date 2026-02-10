-- ================================================================
-- ADMIN_CAMPAIGN_CANCEL: Zamanlanmış kampanyayı iptal etme
-- Sadece draft veya scheduled durumundaki kampanyalar iptal edilebilir
-- Processing durumundaki kampanya iptal edilemez
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_campaign_cancel(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION messaging.admin_campaign_cancel(
    p_campaign_id       INTEGER,            -- Kampanya ID
    p_cancelled_by      INTEGER DEFAULT NULL -- İptal eden kullanıcı
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status VARCHAR(20);
BEGIN
    -- Kampanya varlık ve durum kontrolü
    SELECT status INTO v_current_status
    FROM messaging.message_campaigns
    WHERE id = p_campaign_id AND is_deleted = FALSE;

    IF v_current_status IS NULL THEN
        RAISE EXCEPTION 'error.messaging.campaign-not-found';
    END IF;

    IF v_current_status NOT IN ('draft', 'scheduled') THEN
        RAISE EXCEPTION 'error.messaging.campaign-not-cancellable';
    END IF;

    -- Durumu güncelle
    UPDATE messaging.message_campaigns SET
        status     = 'cancelled',
        updated_at = now(),
        updated_by = p_cancelled_by
    WHERE id = p_campaign_id;

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION messaging.admin_campaign_cancel(INTEGER, INTEGER) IS 'Cancel a draft or scheduled campaign. Processing campaigns cannot be cancelled.';
