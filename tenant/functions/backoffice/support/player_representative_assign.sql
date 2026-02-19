-- ================================================================
-- PLAYER_REPRESENTATIVE_ASSIGN: Temsilci ata/değiştir
-- ================================================================
-- Oyuncuya müşteri temsilcisi atar veya mevcut temsilciyi değiştirir.
-- Her değişiklik player_representative_history'ye kaydedilir.
-- change_reason zorunludur (prim hakediş raporları için).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.player_representative_assign(BIGINT, BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION support.player_representative_assign(
    p_player_id             BIGINT,
    p_representative_id     BIGINT,
    p_assigned_by           BIGINT,
    p_reason                VARCHAR(500)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_rep   BIGINT;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.player-required';
    END IF;

    IF p_representative_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.representative-required';
    END IF;

    IF p_assigned_by IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.assigned-by-required';
    END IF;

    IF p_reason IS NULL OR TRIM(p_reason) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.representative-reason-required';
    END IF;

    -- Mevcut atama var mı kontrol
    SELECT representative_id INTO v_old_rep
    FROM support.player_representatives
    WHERE player_id = p_player_id;

    IF v_old_rep IS NULL THEN
        -- İlk atama
        INSERT INTO support.player_representatives (
            player_id, representative_id, assigned_by, note, assigned_at
        ) VALUES (
            p_player_id, p_representative_id, p_assigned_by, p_reason, NOW()
        );

        -- Tarihçeye kaydet
        INSERT INTO support.player_representative_history (
            player_id, old_representative_id, new_representative_id,
            changed_by, change_reason, changed_at
        ) VALUES (
            p_player_id, NULL, p_representative_id,
            p_assigned_by, p_reason, NOW()
        );

    ELSIF v_old_rep = p_representative_id THEN
        -- Aynı temsilci zaten atanmış
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.representative-already-assigned';

    ELSE
        -- Temsilci değişikliği
        UPDATE support.player_representatives
        SET representative_id = p_representative_id,
            assigned_by       = p_assigned_by,
            note              = p_reason,
            assigned_at       = NOW()
        WHERE player_id = p_player_id;

        -- Tarihçeye kaydet
        INSERT INTO support.player_representative_history (
            player_id, old_representative_id, new_representative_id,
            changed_by, change_reason, changed_at
        ) VALUES (
            p_player_id, v_old_rep, p_representative_id,
            p_assigned_by, p_reason, NOW()
        );
    END IF;
END;
$$;

COMMENT ON FUNCTION support.player_representative_assign IS 'Assigns or changes a player representative. Every change is recorded in history with mandatory reason.';
