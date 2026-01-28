
-- ================================================================
-- COMPANY_DELETE: Şirketi sil (soft delete)
-- Yönetim paneli için şirket kaydını siler (soft delete)
-- Soft deletes a company record for management UI
-- ================================================================

DROP FUNCTION IF EXISTS core.company_delete(BIGINT);

CREATE OR REPLACE FUNCTION core.company_delete(
    p_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Şirket varlık ve aktiflik kontrolü
    IF NOT EXISTS (SELECT 1 FROM core.companies WHERE id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.company.not-found';
    END IF;
    IF EXISTS (SELECT 1 FROM core.companies WHERE id = p_id AND status = 0) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.company.delete.already-deleted';
    END IF;

    UPDATE core.companies
    SET status = 0, updated_at = now()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION core.company_delete(BIGINT) IS 'Soft deletes a company record for management UI.';
