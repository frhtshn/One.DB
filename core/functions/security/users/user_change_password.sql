-- ================================================================
-- USER_CHANGE_PASSWORD: Kullanıcı kendi şifresini değiştirir
-- ================================================================
-- Güvenlik Kuralları:
--   - Kullanıcı aktif ve kilitli değil olmalı
--   - Mevcut şifre hash'i doğrulanmalı
--   - Yeni şifre son N şifre ile aynı olmamalı (password_policy.history_count)
-- İşlem:
--   - Eski şifre -> user_password_history'ye kaydedilir
--   - password_changed_at güncellenir
--   - require_password_change = FALSE yapılır
--   - Fazla history kayıtları temizlenir
-- ================================================================

DROP FUNCTION IF EXISTS security.user_change_password(BIGINT, BIGINT, TEXT, TEXT);
DROP FUNCTION IF EXISTS security.user_change_password(BIGINT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION security.user_change_password(
    p_user_id BIGINT,
    p_current_password_hash TEXT,    -- Application'dan gelen mevcut şifre hash'i (doğrulama için)
    p_new_password_hash TEXT         -- Application'dan gelen yeni şifre hash'i
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = security, pg_temp
AS $$
DECLARE
    v_user RECORD;
    v_history_count INT := 3;
    v_history_match_count INT := 0;
BEGIN
    -- ========================================
    -- 1. KULLANICI BİLGİLERİNİ AL VE DOĞRULA
    -- ========================================
    SELECT id, password, status, is_locked, locked_until
    INTO v_user
    FROM security.users
    WHERE id = p_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- Hesap aktif mi?
    IF v_user.status != 1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.user.account-inactive';
    END IF;

    -- Hesap kilitli mi?
    IF v_user.is_locked AND (v_user.locked_until IS NULL OR v_user.locked_until > NOW()) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0423', MESSAGE = 'error.user.account-locked';
    END IF;

    -- ========================================
    -- 2. MEVCUT ŞİFRE DOĞRULAMA
    -- ========================================
    IF v_user.password != p_current_password_hash THEN
        RAISE EXCEPTION USING ERRCODE = 'P0401', MESSAGE = 'error.user.change-password.current-password-invalid';
    END IF;

    -- ========================================
    -- 3. PASSWORD POLICY'DEN HISTORY COUNT AL
    -- ========================================
    SELECT COALESCE(pp.history_count, 3)
    INTO v_history_count
    FROM security.password_policy pp
    WHERE pp.id = 1;

    -- ========================================
    -- 4. YENİ ŞİFRE MEVCUT ŞİFRE İLE AYNI MI?
    -- ========================================
    IF v_user.password = p_new_password_hash THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.user.change-password.same-as-current';
    END IF;

    -- ========================================
    -- 5. YENİ ŞİFRE GEÇMİŞ ŞİFRELER İLE AYNI MI?
    -- ========================================
    IF v_history_count > 0 THEN
        SELECT COUNT(*)
        INTO v_history_match_count
        FROM (
            SELECT password_hash
            FROM security.user_password_history
            WHERE user_id = p_user_id
            ORDER BY changed_at DESC
            LIMIT v_history_count
        ) recent_passwords
        WHERE password_hash = p_new_password_hash;

        IF v_history_match_count > 0 THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.user.change-password.recently-used';
        END IF;
    END IF;

    -- ========================================
    -- 6. ESKİ ŞİFREYİ HISTORY'YE KAYDET
    -- ========================================
    INSERT INTO security.user_password_history (user_id, password_hash, changed_at)
    VALUES (p_user_id, v_user.password, NOW());

    -- ========================================
    -- 7. ŞİFREYİ GÜNCELLE
    -- ========================================
    UPDATE security.users
    SET password = p_new_password_hash,
        password_changed_at = NOW(),
        require_password_change = FALSE,
        updated_at = NOW(),
        updated_by = p_user_id
    WHERE id = p_user_id;

    -- ========================================
    -- 8. FAZLA HISTORY KAYITLARINI TEMİZLE
    -- ========================================
    IF v_history_count > 0 THEN
        DELETE FROM security.user_password_history
        WHERE user_id = p_user_id
          AND id NOT IN (
              SELECT id
              FROM security.user_password_history
              WHERE user_id = p_user_id
              ORDER BY changed_at DESC
              LIMIT v_history_count
          );
    END IF;
END;
$$;

COMMENT ON FUNCTION security.user_change_password(BIGINT, TEXT, TEXT) IS
'User changes their own password.
- Current password hash must match
- New password cannot match current or recent N passwords (from password_policy)
- Old password saved to history, excess history records cleaned up
- Sets password_changed_at = NOW(), require_password_change = FALSE';
