-- ================================================================
-- LIMIT_ACTIVATE_PENDING: Bekleyen limitleri aktifleştir
-- ================================================================
-- Bekleme süresi dolmuş limitleri aktifleştirir.
-- Scheduler tarafından çağrılır (parametresiz).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.limit_activate_pending();

CREATE OR REPLACE FUNCTION kyc.limit_activate_pending()
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT := 0;
    v_rec   RECORD;
BEGIN
    FOR v_rec IN
        SELECT id, player_id, limit_type, limit_value, pending_value
        FROM kyc.player_limits
        WHERE pending_value IS NOT NULL
          AND pending_activation_at IS NOT NULL
          AND pending_activation_at <= NOW()
          AND status = 'active'
    LOOP
        -- Limiti güncelle
        UPDATE kyc.player_limits
        SET limit_value = v_rec.pending_value,
            pending_value = NULL,
            pending_activation_at = NULL,
            updated_at = NOW()
        WHERE id = v_rec.id;

        -- Geçmiş kaydı
        INSERT INTO kyc.player_limit_history (
            player_id, action_type, entity_type, entity_id,
            old_value, new_value, performed_by
        ) VALUES (
            v_rec.player_id, 'ACTIVATE_PENDING', 'limit', v_rec.id,
            jsonb_build_object('limitValue', v_rec.limit_value),
            jsonb_build_object('limitValue', v_rec.pending_value),
            'system'
        );

        v_count := v_count + 1;
    END LOOP;

    RETURN v_count;
END;
$$;

COMMENT ON FUNCTION kyc.limit_activate_pending IS 'Activates pending limit increases after cooling period. Called by scheduler. Returns count of activated limits.';
