-- ================================================================
-- BONUS_RULE_DELETE: Bonus kuralı pasifleştir (soft delete)
-- ================================================================
-- is_active = false yapar. Mevcut award'lar etkilenmez.
-- Worker bu kuralı artık değerlendirmez.
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_rule_delete(BIGINT);

CREATE OR REPLACE FUNCTION bonus.bonus_rule_delete(
    p_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-rule.id-required';
    END IF;

    UPDATE bonus.bonus_rules SET
        is_active = false,
        updated_at = NOW()
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-rule.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_rule_delete(BIGINT) IS 'Soft-deletes a bonus rule (is_active=false). Worker will no longer evaluate this rule. Existing awards are not affected.';
