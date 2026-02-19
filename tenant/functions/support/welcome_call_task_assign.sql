-- ================================================================
-- WELCOME_CALL_TASK_ASSIGN: Hoşgeldin araması görevi al
-- ================================================================
-- Call center personeli kuyruktaki görevi alır.
-- Sadece pending veya rescheduled durumundaki görevler atanabilir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.welcome_call_task_assign(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION support.welcome_call_task_assign(
    p_task_id           BIGINT,
    p_assigned_to_id    BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_task  RECORD;
BEGIN
    -- Görev mevcut mu kontrol
    SELECT id, status INTO v_task
    FROM support.welcome_call_tasks
    WHERE id = p_task_id;

    IF v_task.id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.welcome-task-not-found';
    END IF;

    -- Status kontrolü: sadece pending veya rescheduled atanabilir
    IF v_task.status NOT IN ('pending', 'rescheduled') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.welcome-task-not-assignable';
    END IF;

    IF p_assigned_to_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.assigned-to-required';
    END IF;

    -- Atama yap
    UPDATE support.welcome_call_tasks
    SET status         = 'assigned',
        assigned_to_id = p_assigned_to_id,
        assigned_at    = NOW(),
        updated_at     = NOW()
    WHERE id = p_task_id;
END;
$$;

COMMENT ON FUNCTION support.welcome_call_task_assign IS 'Assigns a pending or rescheduled welcome call task to a call center agent.';
