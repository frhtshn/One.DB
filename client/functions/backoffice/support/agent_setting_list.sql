-- ================================================================
-- AGENT_SETTING_LIST: Agent listesi
-- ================================================================
-- Tüm aktif agent ayarlarını listeler.
-- Her agent'ın mevcut açık ticket sayısı (workload) dahil.
-- Opsiyonel is_available filtresi.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.agent_setting_list(BOOLEAN);

CREATE OR REPLACE FUNCTION support.agent_setting_list(
    p_is_available  BOOLEAN DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_items JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(sub.item ORDER BY sub.display_name_sort), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', a.id,
            'userId', a.user_id,
            'displayName', a.display_name,
            'isAvailable', a.is_available,
            'maxConcurrentTickets', a.max_concurrent_tickets,
            'currentTicketCount', (
                SELECT COUNT(*)
                FROM support.tickets t
                WHERE t.assigned_to_id = a.user_id
                  AND t.status IN ('assigned', 'in_progress', 'pending_player')
            ),
            'skills', a.skills,
            'createdAt', a.created_at,
            'updatedAt', a.updated_at
        ) AS item,
        COALESCE(a.display_name, '') AS display_name_sort
        FROM support.agent_settings a
        WHERE a.is_active = true
          AND (p_is_available IS NULL OR a.is_available = p_is_available)
    ) sub;

    RETURN jsonb_build_object('items', v_items);
END;
$$;

COMMENT ON FUNCTION support.agent_setting_list IS 'Lists all active agent settings with current ticket workload count. Optional availability filter.';
