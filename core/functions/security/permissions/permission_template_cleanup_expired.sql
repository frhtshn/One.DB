-- ================================================================
-- PERMISSION_TEMPLATE_CLEANUP_EXPIRED: Expired assignment + override temizligi
-- ================================================================
-- Akis:
--   1. Expired assignment'lari bul (expires_at < NOW(), removed_at IS NULL)
--   2. Her biri icin: override'lari SIL, assignment soft-delete
--   3. Etkilenen user_id'leri don (cache invalidation icin)
-- Returns: JSONB - temizlenen kayit sayisi + etkilenen user_id'ler
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_template_cleanup_expired();

CREATE OR REPLACE FUNCTION security.permission_template_cleanup_expired()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_assignment RECORD;
    v_cleaned_count INT := 0;
    v_total_overrides INT := 0;
    v_override_count INT;
    v_affected_user_ids BIGINT[] := '{}';
BEGIN
    -- Expired assignment'lari bul
    FOR v_assignment IN
        SELECT id, user_id
        FROM security.permission_template_assignments
        WHERE expires_at IS NOT NULL
          AND expires_at < NOW()
          AND removed_at IS NULL
    LOOP
        -- Override'lari sil
        DELETE FROM security.user_permission_overrides
        WHERE template_assignment_id = v_assignment.id;

        GET DIAGNOSTICS v_override_count = ROW_COUNT;
        v_total_overrides := v_total_overrides + v_override_count;

        -- Assignment soft-delete
        UPDATE security.permission_template_assignments
        SET
            removed_at = NOW(),
            removed_by = 0, -- System caller
            removal_reason = 'Automatic: assignment expired'
        WHERE id = v_assignment.id;

        v_cleaned_count := v_cleaned_count + 1;

        -- Etkilenen user_id'yi ekle (duplicate yoksa)
        IF NOT v_assignment.user_id = ANY(v_affected_user_ids) THEN
            v_affected_user_ids := v_affected_user_ids || v_assignment.user_id;
        END IF;
    END LOOP;

    RETURN jsonb_build_object(
        'cleanedAssignments', v_cleaned_count,
        'deletedOverrides', v_total_overrides,
        'affectedUserIds', to_jsonb(v_affected_user_ids)
    );
END;
$$;

COMMENT ON FUNCTION security.permission_template_cleanup_expired IS
'Cleans up expired template assignments and their associated overrides.
Returns affected user IDs for cache invalidation.';
