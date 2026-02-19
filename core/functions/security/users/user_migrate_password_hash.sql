-- ================================================================
-- USER_MIGRATE_PASSWORD_HASH: Sifre hash algoritmasi sizsiz gunceller
-- ================================================================
-- NOT: Bu fonksiyon SADECE algorithm migration icin kullanilir.
-- History kaydetmez, session'lari etkilemez, audit yazmaz.
-- Grain'de basarili verify sonrasi, eski format hash'leri PHC formatina yukseltmek icin cagrilir.
-- ================================================================

DROP FUNCTION IF EXISTS security.user_migrate_password_hash(BIGINT, TEXT);

CREATE OR REPLACE FUNCTION security.user_migrate_password_hash(
    p_user_id BIGINT,
    p_new_password_hash TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = security, pg_temp
AS $$
BEGIN
    UPDATE security.users
    SET password   = p_new_password_hash,
        updated_at = NOW()
    WHERE id = p_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION security.user_migrate_password_hash(BIGINT, TEXT) IS
'Silently updates password hash for algorithm migration (PHC format upgrade).
Does NOT log to password history. Does NOT revoke sessions.
Called automatically on successful login when hash format is outdated.';
