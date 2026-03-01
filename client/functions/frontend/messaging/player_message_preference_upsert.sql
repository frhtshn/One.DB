-- ================================================================
-- PLAYER_MESSAGE_PREFERENCE_UPSERT: Oyuncu mesaj tercihi güncelle
-- Kanal bazlı opt-in/opt-out ayarı yapar
-- INSERT ON CONFLICT ile upsert semantiği
-- ================================================================

DROP FUNCTION IF EXISTS messaging.player_message_preference_upsert(BIGINT, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION messaging.player_message_preference_upsert(
    p_player_id         BIGINT,             -- Oyuncu ID
    p_channel_type      VARCHAR(10),        -- Kanal tipi: email, sms, local
    p_is_opted_in       BOOLEAN             -- Kabul/Ret
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Parametre doğrulama
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.player-id-required';
    END IF;

    IF p_channel_type IS NULL OR p_channel_type NOT IN ('email', 'sms', 'local') THEN
        RAISE EXCEPTION 'error.messaging.preference.invalid-channel-type';
    END IF;

    IF p_is_opted_in IS NULL THEN
        RAISE EXCEPTION 'error.messaging.preference.opted-in-required';
    END IF;

    -- Upsert: varsa güncelle, yoksa ekle
    INSERT INTO messaging.player_message_preferences (player_id, channel_type, is_opted_in, updated_at)
    VALUES (p_player_id, p_channel_type, p_is_opted_in, now())
    ON CONFLICT (player_id, channel_type)
    DO UPDATE SET
        is_opted_in = EXCLUDED.is_opted_in,
        updated_at  = now();
END;
$$;

COMMENT ON FUNCTION messaging.player_message_preference_upsert(BIGINT, VARCHAR, BOOLEAN) IS 'Upsert player messaging channel preference. Creates or updates opt-in/out setting for a specific channel.';
