-- ================================================================
-- ADMIN_CAMPAIGN_UPDATE: Kampanya bilgilerini güncelleme
-- Sadece draft durumundaki kampanyalar güncellenebilir
-- Çeviri ve segmentler sıfırlanıp yeniden yazılır
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_campaign_update(INTEGER, VARCHAR, VARCHAR, INTEGER, TIMESTAMP, JSONB, JSONB, INTEGER);

CREATE OR REPLACE FUNCTION messaging.admin_campaign_update(
    p_campaign_id       INTEGER,            -- Kampanya ID
    p_name              VARCHAR(200) DEFAULT NULL, -- Kampanya adı
    p_channel_type      VARCHAR(10) DEFAULT NULL,  -- Kanal tipi
    p_template_id       INTEGER DEFAULT NULL,      -- Şablon ID
    p_scheduled_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL, -- Zamanlama
    p_translations      JSONB DEFAULT NULL, -- Çeviri dizisi (NULL = güncelleme)
    p_segments          JSONB DEFAULT NULL, -- Segment dizisi (NULL = güncelleme)
    p_updated_by        INTEGER DEFAULT NULL -- Güncelleyen kullanıcı
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
        RAISE EXCEPTION 'error.messaging.campaign-not-editable';
    END IF;

    -- Kampanya ana bilgilerini güncelle
    UPDATE messaging.message_campaigns SET
        name           = COALESCE(p_name, name),
        channel_type   = COALESCE(p_channel_type, channel_type),
        template_id    = COALESCE(p_template_id, template_id),
        scheduled_at   = COALESCE(p_scheduled_at, scheduled_at),
        updated_at     = now(),
        updated_by     = p_updated_by
    WHERE id = p_campaign_id;

    -- Çevirileri güncelle (sil + yeniden yaz)
    IF p_translations IS NOT NULL THEN
        DELETE FROM messaging.message_campaign_translations WHERE campaign_id = p_campaign_id;

        IF jsonb_array_length(p_translations) > 0 THEN
            INSERT INTO messaging.message_campaign_translations (
                campaign_id, language_code, subject, body, preview_text, created_by
            )
            SELECT
                p_campaign_id,
                (t->>'language_code')::CHAR(2),
                t->>'subject',
                t->>'body',
                t->>'preview_text',
                p_updated_by
            FROM jsonb_array_elements(p_translations) AS t;
        END IF;
    END IF;

    -- Segmentleri güncelle (sil + yeniden yaz)
    IF p_segments IS NOT NULL THEN
        DELETE FROM messaging.message_campaign_segments WHERE campaign_id = p_campaign_id;

        IF jsonb_array_length(p_segments) > 0 THEN
            INSERT INTO messaging.message_campaign_segments (
                campaign_id, segment_type, segment_value, is_include, created_by
            )
            SELECT
                p_campaign_id,
                s->>'segment_type',
                s->>'segment_value',
                COALESCE((s->>'is_include')::BOOLEAN, TRUE),
                p_updated_by
            FROM jsonb_array_elements(p_segments) AS s;
        END IF;
    END IF;

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION messaging.admin_campaign_update(INTEGER, VARCHAR, VARCHAR, INTEGER, TIMESTAMP, JSONB, JSONB, INTEGER) IS 'Update a draft/scheduled campaign with new details, translations, and segments';
