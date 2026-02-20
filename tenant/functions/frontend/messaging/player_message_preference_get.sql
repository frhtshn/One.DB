-- ================================================================
-- PLAYER_MESSAGE_PREFERENCE_GET: Oyuncu mesaj tercihleri getir
-- Oyuncunun kanal bazlı opt-in/out tercihlerini döner
-- Kayıt yoksa default değerler (tümü opt-in) döner
-- ================================================================

DROP FUNCTION IF EXISTS messaging.player_message_preference_get(BIGINT);

CREATE OR REPLACE FUNCTION messaging.player_message_preference_get(
    p_player_id         BIGINT              -- Oyuncu ID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_items JSONB;
BEGIN
    -- Parametre doğrulama
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.player-id-required';
    END IF;

    -- Kanal tercihleri (mevcut kayıtlar + default'lar)
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'channelType', ch.channel_type,
        'isOptedIn', COALESCE(p.is_opted_in, TRUE),
        'updatedAt', p.updated_at
    ) ORDER BY ch.channel_type), '[]'::JSONB)
    INTO v_items
    FROM (VALUES ('email'), ('local'), ('sms')) AS ch(channel_type)
    LEFT JOIN messaging.player_message_preferences p
        ON p.player_id = p_player_id AND p.channel_type = ch.channel_type;

    RETURN v_items;
END;
$$;

COMMENT ON FUNCTION messaging.player_message_preference_get(BIGINT) IS 'Get player messaging channel preferences. Returns defaults (all opted-in) for channels without explicit preference.';
