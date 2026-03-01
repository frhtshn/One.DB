-- ================================================================
-- GET_PUBLIC_TRUST_ELEMENTS: Public footer güven elemanlarını getir
-- GeoIP country filtresi uygulanır
-- Backend cross-DB lookup ile jurisdiction adı/kodu zenginleştirilir
-- ================================================================

DROP FUNCTION IF EXISTS content.get_public_trust_elements(VARCHAR);

CREATE OR REPLACE FUNCTION content.get_public_trust_elements(
    p_player_country VARCHAR(2) DEFAULT NULL   -- NULL = ülke filtresi uygulanmaz
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_licenses  JSONB;
    v_rg_orgs   JSONB;
    v_payments  JSONB;
    v_certs     JSONB;
    v_awards    JSONB;
    v_partners  JSONB;
BEGIN
    -- Aktif lisanslar (süresi dolmamış + ülke filtreli)
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id',               id,
        'jurisdictionId',   jurisdiction_id,
        'licenseNumber',    license_number,
        'logoUrl',          logo_url,
        'verificationUrl',  verification_url,
        'countryCodes',     country_codes
    ) ORDER BY display_order, id), '[]'::JSONB)
    INTO v_licenses
    FROM content.operator_licenses
    WHERE is_active = TRUE
      AND (expiry_date IS NULL OR expiry_date > CURRENT_DATE)
      AND (
          country_codes = '{}'
          OR p_player_country IS NULL
          OR p_player_country = ANY(country_codes)
      );

    -- Sorumlu oyun logoları
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'code',     code,
        'name',     name,
        'logoUrl',  logo_url,
        'linkUrl',  link_url
    ) ORDER BY display_order, id), '[]'::JSONB)
    INTO v_rg_orgs
    FROM content.trust_logos
    WHERE is_active = TRUE
      AND logo_type = 'rg_org'
      AND (
          country_codes = '{}'
          OR p_player_country IS NULL
          OR p_player_country = ANY(country_codes)
      );

    -- Ödeme logoları
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'code',     code,
        'name',     name,
        'logoUrl',  logo_url,
        'linkUrl',  link_url
    ) ORDER BY display_order, id), '[]'::JSONB)
    INTO v_payments
    FROM content.trust_logos
    WHERE is_active = TRUE
      AND logo_type = 'payment'
      AND (
          country_codes = '{}'
          OR p_player_country IS NULL
          OR p_player_country = ANY(country_codes)
      );

    -- Test/sertifikasyon logoları (testing_cert + ssl_badge)
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'code',     code,
        'name',     name,
        'logoUrl',  logo_url,
        'linkUrl',  link_url,
        'logoType', logo_type
    ) ORDER BY display_order, id), '[]'::JSONB)
    INTO v_certs
    FROM content.trust_logos
    WHERE is_active = TRUE
      AND logo_type IN ('testing_cert', 'ssl_badge')
      AND (
          country_codes = '{}'
          OR p_player_country IS NULL
          OR p_player_country = ANY(country_codes)
      );

    -- Ödüller
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'code',     code,
        'name',     name,
        'logoUrl',  logo_url,
        'linkUrl',  link_url
    ) ORDER BY display_order, id), '[]'::JSONB)
    INTO v_awards
    FROM content.trust_logos
    WHERE is_active = TRUE
      AND logo_type = 'award'
      AND (
          country_codes = '{}'
          OR p_player_country IS NULL
          OR p_player_country = ANY(country_codes)
      );

    -- Partner logoları
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'code',     code,
        'name',     name,
        'logoUrl',  logo_url,
        'linkUrl',  link_url
    ) ORDER BY display_order, id), '[]'::JSONB)
    INTO v_partners
    FROM content.trust_logos
    WHERE is_active = TRUE
      AND logo_type = 'partner_logo'
      AND (
          country_codes = '{}'
          OR p_player_country IS NULL
          OR p_player_country = ANY(country_codes)
      );

    RETURN jsonb_build_object(
        'licenses', v_licenses,
        'rgOrgs',   v_rg_orgs,
        'payments', v_payments,
        'certs',    v_certs,
        'awards',   v_awards,
        'partners', v_partners
    );
END;
$$;

COMMENT ON FUNCTION content.get_public_trust_elements(VARCHAR) IS 'Public endpoint: returns active licenses and trust logos grouped by type, filtered by player country. Backend must enrich license records with jurisdiction name/code/website from core.catalog.jurisdictions.';
