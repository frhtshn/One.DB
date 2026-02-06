-- ================================================================
-- USER_CHANGE_PASSWORD: Kullanıcı kendi şifresini değiştirir
-- ================================================================
-- NOT: Mevcut şifre ve history doğrulaması Grain'de yapılır (Argon2id Verify)
-- DB sadece: user kontrolü, update, history kaydet, temizlik
-- ================================================================

DROP FUNCTION IF EXISTS security.user_change_password(BIGINT, TEXT);

CREATE OR REPLACE FUNCTION security.user_change_password(
    p_user_id BIGINT,
    p_new_password_hash TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = security, pg_temp
AS $$
DECLARE
    v_user RECORD;
    v_history_count INT := 3;
BEGIN
    -- ========================================
    -- 1. KULLANICI BİLGİLERİNİ AL VE DOĞRULA
    -- ========================================
    SELECT id, company_id, password, status, is_locked, locked_until
    INTO v_user
    FROM security.users
    WHERE id = p_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    IF v_user.status != 1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.user.account-inactive';
    END IF;

    IF v_user.is_locked AND (v_user.locked_until IS NULL OR v_user.locked_until > NOW()) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0423', MESSAGE = 'error.user.account-locked';
    END IF;

    -- ========================================
    -- 2. COMPANY PASSWORD POLICY'DEN HISTORY COUNT AL
    -- ========================================
    SELECT COALESCE(
        (SELECT cpp.history_count FROM security.company_password_policy cpp
         WHERE cpp.company_id = v_user.company_id),
        3
    ) INTO v_history_count;

    -- ========================================
    -- 3. ESKİ ŞİFREYİ HISTORY'YE KAYDET
    -- ========================================
    INSERT INTO security.user_password_history (user_id, password_hash, changed_at)
    VALUES (p_user_id, v_user.password, NOW());

    -- ========================================
    -- 4. ŞİFREYİ GÜNCELLE
    -- ========================================
    UPDATE security.users
    SET password = p_new_password_hash,
        password_changed_at = NOW(),
        require_password_change = FALSE,
        updated_at = NOW(),
        updated_by = p_user_id
    WHERE id = p_user_id;

    -- ========================================
    -- 5. FAZLA HISTORY KAYITLARINI TEMİZLE
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

COMMENT ON FUNCTION security.user_change_password(BIGINT, TEXT) IS
'Updates user password. Current password and history validation done in Grain (Argon2id Verify).
DB only: user validation, update password, save to history, cleanup old history.';
