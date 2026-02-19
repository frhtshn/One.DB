-- ================================================================
-- WELCOME_CALL_TASK_RESCHEDULE: Hoşgeldin araması yeniden planla
-- ================================================================
-- Ulaşılamayan oyuncu için aramayı yeniden planlar.
-- call_result: no_answer, busy, voicemail.
-- Max deneme aşılırsa otomatik failed olur.
-- Rescheduled durumunda assigned_to_id NULL olur (kuyruğa geri düşer).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.welcome_call_task_reschedule(BIGINT, BIGINT, VARCHAR, TEXT, INT);

CREATE OR REPLACE FUNCTION support.welcome_call_task_reschedule(
    p_task_id           BIGINT,
    p_performed_by_id   BIGINT,
    p_call_result       VARCHAR(20),
    p_call_notes        TEXT DEFAULT NULL,
    p_reschedule_minutes INT DEFAULT 60
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_task          RECORD;
    v_new_count     SMALLINT;
BEGIN
    -- Görev mevcut mu kontrol
    SELECT id, status, attempt_count, max_attempts INTO v_task
    FROM support.welcome_call_tasks
    WHERE id = p_task_id;

    IF v_task.id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.welcome-task-not-found';
    END IF;

    -- Status kontrolü: assigned veya in_progress olmalı
    IF v_task.status NOT IN ('assigned', 'in_progress') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.welcome-task-not-in-progress';
    END IF;

    -- call_result validasyonu
    IF p_call_result IS NULL OR p_call_result NOT IN ('no_answer', 'busy', 'voicemail') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.invalid-reschedule-result';
    END IF;

    -- Deneme sayısını artır
    v_new_count := v_task.attempt_count + 1;

    -- Max deneme kontrolü
    IF v_new_count >= v_task.max_attempts THEN
        -- Failed — max deneme aşıldı
        UPDATE support.welcome_call_tasks
        SET status         = 'failed',
            call_result    = p_call_result,
            call_notes     = p_call_notes,
            attempt_count  = v_new_count,
            updated_at     = NOW()
        WHERE id = p_task_id;
    ELSE
        -- Rescheduled — kuyruğa geri düşür
        UPDATE support.welcome_call_tasks
        SET status          = 'rescheduled',
            call_result     = p_call_result,
            call_notes      = p_call_notes,
            attempt_count   = v_new_count,
            next_attempt_at = NOW() + (p_reschedule_minutes || ' minutes')::INTERVAL,
            assigned_to_id  = NULL,
            assigned_at     = NULL,
            updated_at      = NOW()
        WHERE id = p_task_id;
    END IF;
END;
$$;

COMMENT ON FUNCTION support.welcome_call_task_reschedule IS 'Reschedules a welcome call task when player is unreachable. If max attempts exceeded, task transitions to failed.';
