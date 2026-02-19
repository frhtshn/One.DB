-- ================================================================
-- ADMIN_CAMPAIGN_PUBLISH: Kampanyayı yayınlama
-- Draft veya scheduled durumundan scheduled/processing'e geçirir
-- scheduled_at varsa scheduled, yoksa processing durumuna alır
-- Backend bu fonksiyon sonrası RabbitMQ'ya iş bırakır
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_campaign_publish(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION messaging.admin_campaign_publish(
    p_campaign_id       INTEGER,            -- Kampanya ID
    p_published_by      INTEGER DEFAULT NULL -- Yayınlayan kullanıcı
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status VARCHAR(20);
    v_scheduled_at   TIMESTAMP WITHOUT TIME ZONE;
    v_new_status     VARCHAR(20);
BEGIN
    -- Kampanya varlık ve durum kontrolü
    SELECT status, scheduled_at
    INTO v_current_status, v_scheduled_at
    FROM messaging.message_campaigns
    WHERE id = p_campaign_id AND is_deleted = FALSE;

    IF v_current_status IS NULL THEN
        RAISE EXCEPTION 'error.messaging.campaign-not-found';
    END IF;

    IF v_current_status NOT IN ('draft', 'scheduled') THEN
        RAISE EXCEPTION 'error.messaging.campaign-not-publishable';
    END IF;

    -- Zamanlanmış mı yoksa hemen mi gönderilecek?
    IF v_scheduled_at IS NOT NULL AND v_scheduled_at > now() THEN
        v_new_status := 'scheduled';
    ELSE
        v_new_status := 'processing';
    END IF;

    -- Durumu güncelle
    UPDATE messaging.message_campaigns SET
        status       = v_new_status,
        published_at = now(),
        updated_at   = now(),
        updated_by   = p_published_by
    WHERE id = p_campaign_id;

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION messaging.admin_campaign_publish(INTEGER, INTEGER) IS 'Publish a draft campaign - sets to scheduled if future date, processing if immediate. Backend pushes to RabbitMQ after this call.';
