-- ================================================================
-- WELCOME_CALL_TASK_COMPLETE: Hoşgeldin araması tamamla
-- ================================================================
-- Arama başarılı sonuçlandığında görevi tamamlar.
-- call_result: answered veya declined → completed.
-- call_result: wrong_number → failed (tekrar arama anlamsız).
-- Temsilci atama bu fonksiyonda YAPILMAZ — backend ayrıca
-- player_representative_assign() çağırır.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.welcome_call_task_complete(BIGINT, BIGINT, VARCHAR, TEXT, INT);

CREATE OR REPLACE FUNCTION support.welcome_call_task_complete(
    p_task_id               BIGINT,
    p_performed_by_id       BIGINT,
    p_call_result           VARCHAR(20),
    p_call_notes            TEXT DEFAULT NULL,
    p_call_duration_seconds INT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_task      RECORD;
    v_new_status VARCHAR(20);
BEGIN
    -- Görev mevcut mu kontrol
    SELECT id, status, attempt_count INTO v_task
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
    IF p_call_result IS NULL OR p_call_result NOT IN ('answered', 'declined', 'wrong_number') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.invalid-call-result';
    END IF;

    -- Hedef durumu belirle
    IF p_call_result = 'wrong_number' THEN
        v_new_status := 'failed';
    ELSE
        v_new_status := 'completed';
    END IF;

    -- Güncelle
    UPDATE support.welcome_call_tasks
    SET status                = v_new_status,
        call_result           = p_call_result,
        call_notes            = p_call_notes,
        call_duration_seconds = p_call_duration_seconds,
        attempt_count         = v_task.attempt_count + 1,
        completed_at          = CASE WHEN v_new_status = 'completed' THEN NOW() ELSE NULL END,
        updated_at            = NOW()
    WHERE id = p_task_id;
END;
$$;

COMMENT ON FUNCTION support.welcome_call_task_complete IS 'Completes a welcome call task. answered/declined → completed, wrong_number → failed. Representative assignment is handled separately by backend.';
