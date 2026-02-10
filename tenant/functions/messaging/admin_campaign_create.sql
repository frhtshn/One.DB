-- ================================================================
-- CAMPAIGN_CREATE: Yeni mesaj kampanyası oluşturma
-- Kampanya detayları, çeviri ve segment bilgilerini tek işlemde yazar
-- Varsayılan durum: draft
-- ================================================================

DROP FUNCTION IF EXISTS messaging.campaign_create(VARCHAR, VARCHAR, INTEGER, TIMESTAMP, JSONB, JSONB, INTEGER);

CREATE OR REPLACE FUNCTION messaging.campaign_create(
    p_name              VARCHAR(200),       -- Kampanya adı
    p_channel_type      VARCHAR(10),        -- Kanal tipi: email, sms, local
    p_template_id       INTEGER DEFAULT NULL, -- Şablon ID (opsiyonel)
    p_scheduled_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL, -- Zamanlama (NULL = hemen)
    p_translations      JSONB DEFAULT NULL, -- Çeviri dizisi: [{"language_code":"en","subject":"...","body":"...","preview_text":"..."}]
    p_segments          JSONB DEFAULT NULL, -- Segment dizisi: [{"segment_type":"country","segment_value":"TR","is_include":true}]
    p_created_by        INTEGER DEFAULT NULL -- Oluşturan kullanıcı
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_campaign_id INTEGER;
BEGIN
    -- Parametre doğrulama
    IF p_name IS NULL OR p_name = '' THEN
        RAISE EXCEPTION 'error.messaging.campaign-name-required';
    END IF;

    IF p_channel_type IS NULL OR p_channel_type NOT IN ('email', 'sms', 'local') THEN
        RAISE EXCEPTION 'error.messaging.invalid-channel-type';
    END IF;

    -- Şablon varsa varlığını kontrol et
    IF p_template_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM messaging.message_templates WHERE id = p_template_id AND is_deleted = FALSE) THEN
            RAISE EXCEPTION 'error.messaging.template-not-found';
        END IF;
    END IF;

    -- Kampanya oluştur
    INSERT INTO messaging.message_campaigns (
        name, channel_type, template_id, scheduled_at, created_by
    ) VALUES (
        p_name, p_channel_type, p_template_id, p_scheduled_at, p_created_by
    )
    RETURNING id INTO v_campaign_id;

    -- Çevirileri ekle
    IF p_translations IS NOT NULL AND jsonb_array_length(p_translations) > 0 THEN
        INSERT INTO messaging.message_campaign_translations (
            campaign_id, language_code, subject, body, preview_text, created_by
        )
        SELECT
            v_campaign_id,
            (t->>'language_code')::CHAR(2),
            t->>'subject',
            t->>'body',
            t->>'preview_text',
            p_created_by
        FROM jsonb_array_elements(p_translations) AS t;
    END IF;

    -- Segmentleri ekle
    IF p_segments IS NOT NULL AND jsonb_array_length(p_segments) > 0 THEN
        INSERT INTO messaging.message_campaign_segments (
            campaign_id, segment_type, segment_value, is_include, created_by
        )
        SELECT
            v_campaign_id,
            s->>'segment_type',
            s->>'segment_value',
            COALESCE((s->>'is_include')::BOOLEAN, TRUE),
            p_created_by
        FROM jsonb_array_elements(p_segments) AS s;
    END IF;

    RETURN v_campaign_id;
END;
$$;

COMMENT ON FUNCTION messaging.campaign_create(VARCHAR, VARCHAR, INTEGER, TIMESTAMP, JSONB, JSONB, INTEGER) IS 'Create a new message campaign with translations and targeting segments in a single transaction';
