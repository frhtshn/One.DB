-- ================================================================
-- AGENT_SETTING_GET: Agent ayarını getir
-- ================================================================
-- Belirli bir user_id için aktif agent ayarını döner.
-- Kayıt yoksa NULL döner (hata fırlatmaz — henüz ayar yok).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.agent_setting_get(BIGINT);

CREATE OR REPLACE FUNCTION support.agent_setting_get(
    p_user_id   BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result    JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', a.id,
        'userId', a.user_id,
        'displayName', a.display_name,
        'isAvailable', a.is_available,
        'maxConcurrentTickets', a.max_concurrent_tickets,
        'skills', a.skills,
        'createdAt', a.created_at,
        'updatedAt', a.updated_at
    ) INTO v_result
    FROM support.agent_settings a
    WHERE a.user_id = p_user_id
      AND a.is_active = true;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION support.agent_setting_get IS 'Returns agent settings for a specific user. Returns NULL if no settings exist yet.';
