-- ================================================================
-- USER_CONTEXT_OVERRIDES_LOAD - Context-Scoped Override Yükleme
-- ================================================================
-- Kullanım: ProtectedFieldReadFilter tarafından kullanıcının
-- context-scoped override'larını yüklemek için. IDOR kontrolü YOK.
-- Bu fonksiyon sadece internal servisler tarafından çağrılmalı.
--
-- Tüm context override'ları tek seferde yükler.
-- C# tarafında Dictionary<string contextCode, List<(permission, isGranted)>>
-- oluşturularak per-field resolve yapılır.
-- ================================================================

DROP FUNCTION IF EXISTS security.user_context_overrides_load(BIGINT);

CREATE OR REPLACE FUNCTION security.user_context_overrides_load(
    p_user_id BIGINT
)
RETURNS TABLE (
    context_code VARCHAR(100),
    permission_code VARCHAR(100),
    is_granted BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- User var mı kontrolü
    IF NOT EXISTS (SELECT 1 FROM security.users WHERE id = p_user_id AND status = 1) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    RETURN QUERY
    SELECT
        ctx.code AS context_code,
        perm.code AS permission_code,
        upo.is_granted
    FROM security.user_permission_overrides upo
    JOIN security.permissions perm ON upo.permission_id = perm.id AND perm.status = 1
    JOIN presentation.contexts ctx ON upo.context_id = ctx.id AND ctx.is_active = TRUE
    WHERE upo.user_id = p_user_id
      AND upo.context_id IS NOT NULL
      AND (upo.expires_at IS NULL OR upo.expires_at > NOW())
      -- Global deny + context grant = DENY kuralı:
      -- Context GRANT olan kayıtları, aynı permission için global DENY varsa hariç tut
      AND NOT (
          upo.is_granted = TRUE
          AND EXISTS (
              SELECT 1 FROM security.user_permission_overrides gd
              WHERE gd.user_id = upo.user_id
                AND gd.permission_id = upo.permission_id
                AND gd.context_id IS NULL
                AND gd.is_granted = FALSE
                AND (gd.expires_at IS NULL OR gd.expires_at > NOW())
          )
      )
    ORDER BY ctx.code, perm.code;
END;
$$;

COMMENT ON FUNCTION security.user_context_overrides_load IS
'Internal function for ProtectedFieldReadFilter. Loads all context-scoped overrides for a user.
Returns context_code (from presentation.contexts), permission_code, and is_granted.
Enforces "global deny > context grant" rule: context grants are excluded if a global deny exists for the same permission.
WARNING: Do not expose this to user-facing APIs.';
