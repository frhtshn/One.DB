-- ================================================================
-- TICKET_DASHBOARD_STATS: Dashboard istatistikleri
-- ================================================================
-- Support dashboard için özet istatistikler.
-- Status, öncelik, kanal bazlı dağılım + hoşgeldin araması özeti.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_dashboard_stats();

CREATE OR REPLACE FUNCTION support.ticket_dashboard_stats()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_by_status         JSONB;
    v_by_priority       JSONB;
    v_by_channel        JSONB;
    v_welcome_calls     JSONB;
    v_unassigned        BIGINT;
    v_avg_resolution    NUMERIC;
BEGIN
    -- Status bazlı dağılım
    SELECT COALESCE(jsonb_object_agg(t.status, t.cnt), '{}'::JSONB)
    INTO v_by_status
    FROM (
        SELECT status, COUNT(*) AS cnt
        FROM support.tickets
        GROUP BY status
    ) t;

    -- Öncelik bazlı dağılım (sadece açık ticketlar: closed/cancelled hariç)
    SELECT jsonb_build_object(
        'low', COALESCE(SUM(CASE WHEN priority = 0 THEN 1 ELSE 0 END), 0),
        'normal', COALESCE(SUM(CASE WHEN priority = 1 THEN 1 ELSE 0 END), 0),
        'high', COALESCE(SUM(CASE WHEN priority = 2 THEN 1 ELSE 0 END), 0),
        'urgent', COALESCE(SUM(CASE WHEN priority = 3 THEN 1 ELSE 0 END), 0)
    )
    INTO v_by_priority
    FROM support.tickets
    WHERE status NOT IN ('closed', 'cancelled');

    -- Kanal bazlı dağılım (sadece açık ticketlar)
    SELECT COALESCE(jsonb_object_agg(t.channel, t.cnt), '{}'::JSONB)
    INTO v_by_channel
    FROM (
        SELECT channel, COUNT(*) AS cnt
        FROM support.tickets
        WHERE status NOT IN ('closed', 'cancelled')
        GROUP BY channel
    ) t;

    -- Hoşgeldin araması özeti
    SELECT jsonb_build_object(
        'pending', COALESCE(SUM(CASE WHEN wct.status IN ('pending', 'rescheduled') THEN 1 ELSE 0 END), 0),
        'assigned', COALESCE(SUM(CASE WHEN wct.status IN ('assigned', 'in_progress') THEN 1 ELSE 0 END), 0),
        'completedToday', COALESCE(SUM(CASE WHEN wct.status = 'completed' AND wct.completed_at >= CURRENT_DATE THEN 1 ELSE 0 END), 0),
        'failedToday', COALESCE(SUM(CASE WHEN wct.status = 'failed' AND wct.updated_at >= CURRENT_DATE THEN 1 ELSE 0 END), 0)
    )
    INTO v_welcome_calls
    FROM support.welcome_call_tasks wct;

    -- Atanmamış ticket sayısı
    SELECT COUNT(*) INTO v_unassigned
    FROM support.tickets
    WHERE status IN ('open', 'reopened');

    -- Bugünkü ortalama çözüm süresi (dakika)
    SELECT COALESCE(
        ROUND(AVG(EXTRACT(EPOCH FROM (resolved_at - created_at)) / 60)),
        0
    )
    INTO v_avg_resolution
    FROM support.tickets
    WHERE resolved_at IS NOT NULL
      AND resolved_at >= CURRENT_DATE;

    RETURN jsonb_build_object(
        'byStatus', v_by_status,
        'byPriority', v_by_priority,
        'byChannel', v_by_channel,
        'welcomeCalls', v_welcome_calls,
        'unassignedCount', v_unassigned,
        'averageResolutionMinutesToday', v_avg_resolution
    );
END;
$$;

COMMENT ON FUNCTION support.ticket_dashboard_stats IS 'Returns support dashboard statistics including ticket distribution by status/priority/channel, welcome call summary, and average resolution time.';
