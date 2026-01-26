-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

DROP FUNCTION IF EXISTS catalog.localization_domain_list();

-- localization_domain_list: Aktif domain'ler
CREATE OR REPLACE FUNCTION catalog.localization_domain_list()
RETURNS TABLE(domain VARCHAR, count BIGINT)
LANGUAGE sql STABLE
AS $$
    SELECT k.domain, COUNT(*) as count
    FROM catalog.localization_keys k
    GROUP BY k.domain
    ORDER BY k.domain;
$$;

COMMENT ON FUNCTION catalog.localization_domain_list() IS 'Lists distinct localization domains.';
