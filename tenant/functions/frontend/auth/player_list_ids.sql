-- ================================================================
-- PLAYER_LIST_IDS: Tum oyuncu ID'lerini doner
-- ================================================================
-- Re-encryption batch job icin hafif fonksiyon.
-- JOIN yok, filtre yok — sadece ID listesi.
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_list_ids();

CREATE OR REPLACE FUNCTION auth.player_list_ids()
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(p.id ORDER BY p.id), '[]'::jsonb)
    INTO v_result
    FROM auth.players p;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION auth.player_list_ids IS 'Returns all player IDs as JSONB array for re-encryption batch processing. Lightweight — no JOINs or filters.';
