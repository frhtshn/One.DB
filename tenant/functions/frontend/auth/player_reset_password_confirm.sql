-- ================================================================
-- PLAYER_RESET_PASSWORD_CONFIRM: Şifre sıfırlama onayı
-- ================================================================
-- Token doğrulayarak yeni şifreyi set eder.
-- Eski şifreyi geçmişe kaydeder.
-- Token'ı kullanıldı olarak işaretler.
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_reset_password_confirm(UUID, VARCHAR, INT);

CREATE OR REPLACE FUNCTION auth.player_reset_password_confirm(
    p_token             UUID,
    p_new_password_hash VARCHAR(255),
    p_history_count     INT DEFAULT 3
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_token_record RECORD;
    v_old_hash     VARCHAR(255);
BEGIN
    IF p_token IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-password.token-required';
    END IF;

    IF p_new_password_hash IS NULL OR TRIM(p_new_password_hash) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-password.password-required';
    END IF;

    -- Token bul (kullanılmamış)
    SELECT t.id, t.player_id, t.expires_at
    INTO v_token_record
    FROM auth.password_reset_tokens t
    WHERE t.token = p_token
      AND t.used_at IS NULL;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-password.token-not-found';
    END IF;

    -- Süre kontrolü
    IF v_token_record.expires_at < NOW() THEN
        RAISE EXCEPTION USING ERRCODE = 'P0410', MESSAGE = 'error.player-password.token-expired';
    END IF;

    -- Token'ı kullanıldı olarak işaretle
    UPDATE auth.password_reset_tokens
    SET used_at = NOW()
    WHERE id = v_token_record.id;

    -- Eski şifreyi geçmişe kaydet
    SELECT password INTO v_old_hash
    FROM auth.players
    WHERE id = v_token_record.player_id;

    INSERT INTO auth.player_password_history (player_id, password_hash)
    VALUES (v_token_record.player_id, v_old_hash);

    -- Yeni şifreyi set et
    UPDATE auth.players
    SET password = p_new_password_hash,
        last_password_change_at = NOW(),
        require_password_change = FALSE,
        updated_at = NOW()
    WHERE id = v_token_record.player_id;

    -- Eski geçmiş temizliği
    DELETE FROM auth.player_password_history
    WHERE player_id = v_token_record.player_id
      AND id NOT IN (
          SELECT id FROM auth.player_password_history
          WHERE player_id = v_token_record.player_id
          ORDER BY changed_at DESC
          LIMIT p_history_count
      );

    RETURN jsonb_build_object(
        'playerId', v_token_record.player_id,
        'passwordChanged', TRUE
    );
END;
$$;

COMMENT ON FUNCTION auth.player_reset_password_confirm IS 'Confirms password reset using token. Validates token, saves old password to history, sets new password hash.';
