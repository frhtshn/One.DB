-- ================================================================
-- GET_ACTIVE_ANNOUNCEMENT_BARS: Aktif duyuru çubuklarını getir (frontend)
-- Zaman, hedef kitle ve ülke filtreleri uygulanır
-- Auth gerektirmez — public endpoint
-- ================================================================

DROP FUNCTION IF EXISTS presentation.get_active_announcement_bars(VARCHAR, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION presentation.get_active_announcement_bars(
    p_player_country    VARCHAR(2)  DEFAULT NULL,   -- GeoIP ülke kodu; NULL = filtre yok
    p_language_code     VARCHAR(5)  DEFAULT 'en',   -- Tercih edilen dil
    p_target_audience   VARCHAR(20) DEFAULT 'all'   -- 'all', 'guest', 'logged_in'
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_now TIMESTAMPTZ := NOW();
BEGIN
    RETURN (
        SELECT COALESCE(jsonb_agg(jsonb_build_object(
            'id',               b.id,
            'code',             b.code,
            'targetAudience',   b.target_audience,
            'priority',         b.priority,
            'bgColor',          b.bg_color,
            'textColor',        b.text_color,
            'isDismissible',    b.is_dismissible,
            'text',             COALESCE(
                                    (SELECT t.text FROM presentation.announcement_bar_translations t
                                     WHERE t.announcement_bar_id = b.id AND t.language_code = p_language_code),
                                    (SELECT t.text FROM presentation.announcement_bar_translations t
                                     WHERE t.announcement_bar_id = b.id AND t.language_code = 'en'
                                     LIMIT 1)
                                ),
            'linkUrl',          COALESCE(
                                    (SELECT t.link_url FROM presentation.announcement_bar_translations t
                                     WHERE t.announcement_bar_id = b.id AND t.language_code = p_language_code),
                                    (SELECT t.link_url FROM presentation.announcement_bar_translations t
                                     WHERE t.announcement_bar_id = b.id AND t.language_code = 'en'
                                     LIMIT 1)
                                ),
            'linkLabel',        COALESCE(
                                    (SELECT t.link_label FROM presentation.announcement_bar_translations t
                                     WHERE t.announcement_bar_id = b.id AND t.language_code = p_language_code),
                                    (SELECT t.link_label FROM presentation.announcement_bar_translations t
                                     WHERE t.announcement_bar_id = b.id AND t.language_code = 'en'
                                     LIMIT 1)
                                )
        ) ORDER BY b.priority DESC, b.id), '[]'::JSONB)
        FROM presentation.announcement_bars b
        WHERE b.is_active = TRUE
          AND (b.starts_at IS NULL OR b.starts_at <= v_now)
          AND (b.ends_at IS NULL OR b.ends_at > v_now)
          AND (b.target_audience = 'all' OR b.target_audience = p_target_audience)
          AND (
              b.country_codes = '{}'
              OR p_player_country IS NULL
              OR p_player_country = ANY(b.country_codes)
          )
    );
END;
$$;

COMMENT ON FUNCTION presentation.get_active_announcement_bars(VARCHAR, VARCHAR, VARCHAR) IS 'Public frontend endpoint: returns currently active announcement bars filtered by time window, target audience, and player country. Falls back to English translation if preferred language not found.';
