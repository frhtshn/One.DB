-- ================================================================
-- ANNOUNCEMENT_BAR_LIST: Duyuru çubuklarını listele (BO paneli)
-- Çevirilerle birlikte döner
-- ================================================================

DROP FUNCTION IF EXISTS presentation.list_announcement_bars(BOOLEAN);

CREATE OR REPLACE FUNCTION presentation.list_announcement_bars(
    p_include_inactive BOOLEAN DEFAULT FALSE
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT COALESCE(jsonb_agg(jsonb_build_object(
            'id',               b.id,
            'code',             b.code,
            'startsAt',         b.starts_at,
            'endsAt',           b.ends_at,
            'targetAudience',   b.target_audience,
            'countryCodes',     b.country_codes,
            'priority',         b.priority,
            'bgColor',          b.bg_color,
            'textColor',        b.text_color,
            'isDismissible',    b.is_dismissible,
            'isActive',         b.is_active,
            'createdAt',        b.created_at,
            'updatedAt',        b.updated_at,
            'translations',     COALESCE((
                SELECT jsonb_agg(jsonb_build_object(
                    'languageCode', t.language_code,
                    'text',         t.text,
                    'linkUrl',      t.link_url,
                    'linkLabel',    t.link_label
                ))
                FROM presentation.announcement_bar_translations t
                WHERE t.announcement_bar_id = b.id
            ), '[]'::JSONB)
        ) ORDER BY b.priority DESC, b.id), '[]'::JSONB)
        FROM presentation.announcement_bars b
        WHERE (p_include_inactive OR b.is_active = TRUE)
    );
END;
$$;

COMMENT ON FUNCTION presentation.list_announcement_bars(BOOLEAN) IS 'List announcement bars with translations for backoffice. Returns JSONB array ordered by priority desc.';
