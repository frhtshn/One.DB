-- ================================================================
-- UPDATE_UPDATED_AT_COLUMN
-- Generic trigger function to update 'updated_at' column to NOW()
-- ================================================================

CREATE OR REPLACE FUNCTION core.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION core.update_updated_at_column() IS 'Generic trigger function to auto-update updated_at timestamp.';
