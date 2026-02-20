-- ================================================================
-- PLAYER_CHANGE_PASSWORD: Oyuncu şifre değiştirme
-- ================================================================
-- Eski şifreyi geçmişe kaydeder, yeni şifreyi set eder.
-- require_password_change = FALSE yapar.
-- Geçmiş temizliği yapar (son N şifre saklanır).
-- Pattern: core.user_change_password referans.
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_change_password(BIGINT, VARCHAR, INT);

CREATE OR REPLACE FUNCTION auth.player_change_password(
    p_player_id        BIGINT,
    p_new_password_hash VARCHAR(255),
    p_history_count    INT DEFAULT 3
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_hash VARCHAR(255);
    v_status   SMALLINT;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-password.player-required';
    END IF;

    IF p_new_password_hash IS NULL OR TRIM(p_new_password_hash) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-password.password-required';
    END IF;

    -- Oyuncu kontrolü
    SELECT password, status INTO v_old_hash, v_status
    FROM auth.players
    WHERE id = p_player_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-password.player-not-found';
    END IF;

    -- Hesap aktif veya beklemede olmalı
    IF v_status NOT IN (0, 1) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.player-password.account-inactive';
    END IF;

    -- Eski şifreyi geçmişe kaydet
    INSERT INTO auth.player_password_history (player_id, password_hash)
    VALUES (p_player_id, v_old_hash);

    -- Yeni şifreyi set et
    UPDATE auth.players
    SET password = p_new_password_hash,
        last_password_change_at = NOW(),
        require_password_change = FALSE,
        updated_at = NOW()
    WHERE id = p_player_id;

    -- Eski geçmiş temizliği (son N kaydı sakla)
    DELETE FROM auth.player_password_history
    WHERE player_id = p_player_id
      AND id NOT IN (
          SELECT id FROM auth.player_password_history
          WHERE player_id = p_player_id
          ORDER BY changed_at DESC
          LIMIT p_history_count
      );
END;
$$;

COMMENT ON FUNCTION auth.player_change_password IS 'Changes player password. Saves old password to history, sets new hash, clears require_password_change flag. Trims history to last N entries.';
