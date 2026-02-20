-- =============================================
-- Compliance Seed Data
-- 15 iGaming jurisdiction için referans veriler
-- =============================================
-- Kaynak: Canlı DB (1-12) + Eski seed (13-15)
-- TRUNCATE + INSERT pattern (idempotent re-seed)
-- =============================================
-- Jurisdiction sırası:
--  1 MGA (MT)    2 UKGC (GB)   3 GGL (DE)    4 SGA (SE)
--  5 DGA (DK)    6 AGCO (CA)   7 CUR (CW)    8 GIB (GI)
--  9 IOM (IM)   10 ONJN (RO)  11 ADM (IT)   12 DGOJ (ES)
-- 13 ANJ (FR)   14 KSA (NL)   15 TR (dev/test)
-- =============================================

-- ============================================================
-- 1. JURISDICTIONS (Lisans Otoriteleri) — 15 kayıt
-- ============================================================

INSERT INTO catalog.jurisdictions (id, code, name, country_code, region, authority_type, website_url, license_prefix, is_active)
VALUES
    (1,  'MGA',  'Malta Gaming Authority',                      'MT', NULL,      'national',  'https://www.mga.org.mt',                    'MGA/B2C/', true),
    (2,  'UKGC', 'UK Gambling Commission',                      'GB', NULL,      'national',  'https://www.gamblingcommission.gov.uk',      'GC-',      true),
    (3,  'GGL',  'Gemeinsame Glücksspielbehörde der Länder',     'DE', NULL,      'national',  'https://www.ggl-behoerde.de',               'GGL-',     true),
    (4,  'SGA',  'Swedish Gambling Authority',                   'SE', NULL,      'national',  'https://www.spelinspektionen.se',            'SGA-',     true),
    (5,  'DGA',  'Danish Gambling Authority',                    'DK', NULL,      'national',  'https://www.spillemyndigheden.dk',           'DGA-',     true),
    (6,  'AGCO', 'Alcohol and Gaming Commission of Ontario',     'CA', 'Ontario', 'regional',  'https://www.agco.ca',                       'iGO-',     true),
    (7,  'CUR',  'Curacao eGaming',                              'CW', NULL,      'offshore',  'https://www.curacao-egaming.com',            'CEG/',     true),
    (8,  'GIB',  'Gibraltar Gambling Commissioner',              'GI', NULL,      'offshore',  'https://www.gibraltar.gov.gi/gambling',      'RGL/',     true),
    (9,  'IOM',  'Isle of Man Gambling Supervision Commission',  'IM', NULL,      'offshore',  'https://www.gov.im/gambling',                'GSC/',     true),
    (10, 'ONJN', 'Romanian National Gambling Office',            'RO', NULL,      'national',  'https://www.onjn.gov.ro',                   'ONJN-',    true),
    (11, 'ADM',  'Agenzia delle Dogane e dei Monopoli',          'IT', NULL,      'national',  'https://www.adm.gov.it',                    'ADM/',     true),
    (12, 'DGOJ', 'Dirección General de Ordenación del Juego',    'ES', NULL,      'national',  'https://www.ordenacionjuego.es',            'DGOJ-',    true),
    (13, 'ANJ',  'Autorité Nationale des Jeux',                  'FR', NULL,      'national',  'https://www.anj.fr',                        'ANJ-',     true),
    (14, 'KSA',  'Kansspelautoriteit',                           'NL', NULL,      'national',  'https://www.kansspelautoriteit.nl',          'KSA-',     true),
    (15, 'TR',   'Türkiye (Gevşek KYC — Geliştirme)',            'TR', NULL,      'offshore',  NULL,                                        'TR-',      true);

SELECT setval('catalog.jurisdictions_id_seq', 15);

-- ============================================================
-- 2. KYC POLICIES (KYC Politikaları) — 15 kayıt
-- ============================================================
-- verification_timing:
--   before_registration: Kayıt öncesi tam doğrulama (DE, SE, NL, IT)
--   before_deposit:      İlk para yatırma öncesi (UK, CA, FR, ES, RO)
--   after_registration:  Kayıttan sonra (MGA 72s, DK 30gün, GIB, IOM)
--   before_withdrawal:   İlk çekim öncesi (CUR, TR)
-- ============================================================

INSERT INTO catalog.kyc_policies (id, jurisdiction_id, verification_timing,
    verification_deadline_hours, grace_period_hours,
    edd_deposit_threshold, edd_withdrawal_threshold, edd_cumulative_threshold, edd_threshold_currency,
    min_age, age_verification_required, address_verification_required, address_document_max_age_days,
    sof_threshold, sof_required_above_threshold,
    pep_screening_required, sanctions_screening_required, is_active)
VALUES
    -- MGA: Kayıttan sonra, 72 saat veya 2.000 EUR
    (1, 1, 'after_registration',
     72, 72,
     2000.00, 2000.00, 2000.00, 'EUR',
     18, true, true, 90,
     10000.00, true,
     true, true, true),

    -- UKGC: Doğrulama para yatırma öncesi, EDD 25.000 GBP/12 ay
    (2, 2, 'before_deposit',
     NULL, 0,
     5000.00, 5000.00, 25000.00, 'GBP',
     18, true, true, 90,
     25000.00, true,
     true, true, true),

    -- GGL: Kayıt öncesi tam doğrulama
    (3, 3, 'before_registration',
     NULL, 0,
     10000.00, 10000.00, 10000.00, 'EUR',
     18, true, true, 90,
     10000.00, true,
     true, true, true),

    -- SGA (SE): Kayıt öncesi BankID
    (4, 4, 'before_registration',
     NULL, 0,
     5000.00, 5000.00, 10000.00, 'SEK',
     18, true, true, 90,
     10000.00, true,
     true, true, true),

    -- DGA (DK): Kayıtta MitID, geçici hesap 30 gün DKK 10.000
    (5, 5, 'after_registration',
     720, 720,
     10000.00, 10000.00, 10000.00, 'DKK',
     18, true, true, 90,
     10000.00, true,
     true, true, true),

    -- AGCO (Ontario): Kayıt öncesi doğrulama, PCMLTFA uyumlu
    (6, 6, 'before_deposit',
     NULL, 0,
     10000.00, 10000.00, 10000.00, 'CAD',
     19, true, true, 90,
     10000.00, true,
     true, true, true),

    -- CUR: Risk bazlı, çekim öncesi zorunlu
    (7, 7, 'before_withdrawal',
     NULL, 0,
     5000.00, 5000.00, 10000.00, 'EUR',
     18, true, true, 90,
     10000.00, true,
     true, true, true),

    -- GIB: Kayıttan sonra 72 saat, UK benzeri rejim
    (8, 8, 'after_registration',
     72, 72,
     2000.00, 2000.00, 15000.00, 'GBP',
     18, true, true, 90,
     15000.00, true,
     true, true, true),

    -- IOM: Kayıttan sonra 72 saat, UK benzeri rejim
    (9, 9, 'after_registration',
     72, 72,
     2000.00, 2000.00, 15000.00, 'GBP',
     18, true, true, 90,
     15000.00, true,
     true, true, true),

    -- ONJN: Hesap aktivasyonu öncesi tam doğrulama
    (10, 10, 'before_deposit',
     NULL, 0,
     5000.00, 5000.00, 15000.00, 'EUR',
     18, true, true, 90,
     15000.00, true,
     true, true, true),

    -- ADM: Kayıt öncesi tam doğrulama (SPID/CIE zorunlu)
    (11, 11, 'before_registration',
     NULL, 0,
     10000.00, 10000.00, 15000.00, 'EUR',
     18, true, true, 90,
     15000.00, true,
     true, true, true),

    -- DGOJ: İlk para yatırma öncesi, RGIAJ kontrolü
    (12, 12, 'before_deposit',
     NULL, 0,
     3000.00, 3000.00, 10000.00, 'EUR',
     18, true, true, 90,
     10000.00, true,
     true, true, true),

    -- ANJ: İlk bahis/yatırma öncesi tam doğrulama
    (13, 13, 'before_deposit',
     NULL, 0,
     5000.00, 5000.00, 15000.00, 'EUR',
     18, true, true, 90,
     10000.00, true,
     true, true, true),

    -- KSA: Kayıt öncesi (iDIN + kimlik)
    (14, 14, 'before_registration',
     NULL, 0,
     700.00, 700.00, 5000.00, 'EUR',
     18, true, true, 90,
     5000.00, true,
     true, true, true),

    -- TR: Gevşek — kayıt sonrası, çekimde zorunlu, yüksek eşikler
    (15, 15, 'after_registration',
     NULL, 0,
     50000.00, 25000.00, 100000.00, 'TRY',
     18, true, false, NULL,
     100000.00, false,
     false, false, true);

SELECT setval('catalog.kyc_policies_id_seq', 15);

-- ============================================================
-- 3. KYC LEVEL REQUIREMENTS (KYC Seviye Gereksinimleri) — 45 kayıt
-- ============================================================
-- Her jurisdiction için 3 seviye: basic (0), standard (1), enhanced (2)
-- ============================================================

INSERT INTO catalog.kyc_level_requirements (id, jurisdiction_id, kyc_level, level_order,
    trigger_cumulative_deposit, trigger_cumulative_withdrawal, trigger_single_deposit, trigger_single_withdrawal,
    trigger_balance_threshold, trigger_threshold_currency, trigger_days_since_registration, trigger_on_first_withdrawal,
    max_single_deposit, max_single_withdrawal, max_daily_deposit, max_daily_withdrawal,
    max_monthly_deposit, max_monthly_withdrawal, limit_currency,
    required_documents, required_verifications,
    verification_deadline_hours, grace_period_hours, on_deadline_action, is_active)
VALUES
    -- ===================== MGA (MT) — jur 1 =====================
    (1, 1, 'basic', 0,
     NULL, NULL, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'EUR',
     '[]'::jsonb,
     '["EMAIL"]'::jsonb,
     72, 72, 'block_withdrawals', true),

    (2, 1, 'standard', 1,
     2000.00, NULL, NULL, NULL, NULL, 'EUR', NULL, true,
     NULL, NULL, NULL, NULL, NULL, NULL, 'EUR',
     '["identity", "proof_of_address"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_withdrawals', true),

    (3, 1, 'enhanced', 2,
     10000.00, 5000.00, 5000.00, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'EUR',
     '["identity", "proof_of_address", "source_of_funds"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_all', true),

    -- ===================== UKGC (GB) — jur 2 =====================
    (4, 2, 'basic', 0,
     NULL, NULL, NULL, NULL, NULL, 'GBP', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'GBP',
     '[]'::jsonb,
     '["EMAIL"]'::jsonb,
     NULL, 0, 'block_deposits', true),

    (5, 2, 'standard', 1,
     150.00, NULL, NULL, NULL, NULL, 'GBP', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'GBP',
     '["identity", "proof_of_address"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_deposits', true),

    (6, 2, 'enhanced', 2,
     25000.00, NULL, NULL, NULL, NULL, 'GBP', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'GBP',
     '["identity", "proof_of_address", "source_of_funds"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_all', true),

    -- ===================== GGL (DE) — jur 3 =====================
    (7, 3, 'basic', 0,
     NULL, NULL, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, 1000.00, NULL, 1000.00, NULL, 'EUR',
     '["identity"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_deposits', true),

    (8, 3, 'standard', 1,
     1000.00, NULL, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, 10000.00, NULL, 10000.00, NULL, 'EUR',
     '["identity", "proof_of_address"]'::jsonb,
     '["EMAIL", "PHONE", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_deposits', true),

    (9, 3, 'enhanced', 2,
     10000.00, NULL, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, 30000.00, NULL, 30000.00, NULL, 'EUR',
     '["identity", "proof_of_address", "source_of_funds"]'::jsonb,
     '["EMAIL", "PHONE", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_all', true),

    -- ===================== SGA / SE — jur 4 =====================
    (10, 4, 'basic', 0,
     NULL, NULL, NULL, NULL, NULL, 'SEK', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'SEK',
     '[]'::jsonb,
     '["EMAIL"]'::jsonb,
     NULL, 0, 'block_deposits', true),

    (11, 4, 'standard', 1,
     50000.00, NULL, NULL, NULL, NULL, 'SEK', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'SEK',
     '["identity", "proof_of_address"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_deposits', true),

    (12, 4, 'enhanced', 2,
     100000.00, 50000.00, NULL, NULL, NULL, 'SEK', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'SEK',
     '["identity", "proof_of_address", "source_of_funds"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_all', true),

    -- ===================== DGA / DK — jur 5 =====================
    (13, 5, 'basic', 0,
     NULL, NULL, NULL, NULL, NULL, 'DKK', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'DKK',
     '[]'::jsonb,
     '["EMAIL"]'::jsonb,
     720, 720, 'block_withdrawals', true),

    (14, 5, 'standard', 1,
     10000.00, NULL, NULL, NULL, NULL, 'DKK', NULL, true,
     NULL, NULL, NULL, NULL, NULL, NULL, 'DKK',
     '["identity", "proof_of_address"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_withdrawals', true),

    (15, 5, 'enhanced', 2,
     50000.00, 25000.00, NULL, NULL, NULL, 'DKK', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'DKK',
     '["identity", "proof_of_address", "source_of_funds"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_all', true),

    -- ===================== AGCO / CA Ontario — jur 6 =====================
    (16, 6, 'basic', 0,
     NULL, NULL, NULL, NULL, NULL, 'CAD', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'CAD',
     '[]'::jsonb,
     '["EMAIL"]'::jsonb,
     NULL, 0, 'block_deposits', true),

    (17, 6, 'standard', 1,
     3000.00, NULL, NULL, NULL, NULL, 'CAD', NULL, true,
     NULL, NULL, NULL, NULL, NULL, NULL, 'CAD',
     '["identity", "proof_of_address"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_deposits', true),

    (18, 6, 'enhanced', 2,
     10000.00, 10000.00, NULL, NULL, NULL, 'CAD', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'CAD',
     '["identity", "proof_of_address", "source_of_funds"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_all', true),

    -- ===================== CUR / CW — jur 7 =====================
    (19, 7, 'basic', 0,
     NULL, NULL, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'EUR',
     '[]'::jsonb,
     '["EMAIL"]'::jsonb,
     NULL, 0, 'block_withdrawals', true),

    (20, 7, 'standard', 1,
     2000.00, NULL, NULL, NULL, NULL, 'EUR', NULL, true,
     NULL, NULL, NULL, NULL, NULL, NULL, 'EUR',
     '["identity", "proof_of_address"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_withdrawals', true),

    (21, 7, 'enhanced', 2,
     10000.00, 5000.00, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'EUR',
     '["identity", "proof_of_address", "source_of_funds"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_all', true),

    -- ===================== GIB / GI — jur 8 =====================
    (22, 8, 'basic', 0,
     NULL, NULL, NULL, NULL, NULL, 'GBP', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'GBP',
     '[]'::jsonb,
     '["EMAIL"]'::jsonb,
     72, 72, 'block_withdrawals', true),

    (23, 8, 'standard', 1,
     2000.00, NULL, NULL, NULL, NULL, 'GBP', NULL, true,
     NULL, NULL, NULL, NULL, NULL, NULL, 'GBP',
     '["identity", "proof_of_address"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_withdrawals', true),

    (24, 8, 'enhanced', 2,
     15000.00, 5000.00, NULL, NULL, NULL, 'GBP', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'GBP',
     '["identity", "proof_of_address", "source_of_funds"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_all', true),

    -- ===================== IOM / IM — jur 9 =====================
    (25, 9, 'basic', 0,
     NULL, NULL, NULL, NULL, NULL, 'GBP', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'GBP',
     '[]'::jsonb,
     '["EMAIL"]'::jsonb,
     72, 72, 'block_withdrawals', true),

    (26, 9, 'standard', 1,
     2000.00, NULL, NULL, NULL, NULL, 'GBP', NULL, true,
     NULL, NULL, NULL, NULL, NULL, NULL, 'GBP',
     '["identity", "proof_of_address"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_withdrawals', true),

    (27, 9, 'enhanced', 2,
     15000.00, 5000.00, NULL, NULL, NULL, 'GBP', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'GBP',
     '["identity", "proof_of_address", "source_of_funds"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_all', true),

    -- ===================== ONJN / RO — jur 10 =====================
    (28, 10, 'basic', 0,
     NULL, NULL, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'EUR',
     '["identity"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_deposits', true),

    (29, 10, 'standard', 1,
     5000.00, NULL, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'EUR',
     '["identity", "proof_of_address"]'::jsonb,
     '["EMAIL", "PHONE", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_deposits', true),

    (30, 10, 'enhanced', 2,
     15000.00, 10000.00, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'EUR',
     '["identity", "proof_of_address", "source_of_funds"]'::jsonb,
     '["EMAIL", "PHONE", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_all', true),

    -- ===================== ADM / IT — jur 11 =====================
    (31, 11, 'basic', 0,
     NULL, NULL, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'EUR',
     '["identity"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_deposits', true),

    (32, 11, 'standard', 1,
     5000.00, NULL, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'EUR',
     '["identity", "proof_of_address"]'::jsonb,
     '["EMAIL", "PHONE", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_deposits', true),

    (33, 11, 'enhanced', 2,
     15000.00, 10000.00, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'EUR',
     '["identity", "proof_of_address", "source_of_funds"]'::jsonb,
     '["EMAIL", "PHONE", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_all', true),

    -- ===================== DGOJ / ES — jur 12 =====================
    (34, 12, 'basic', 0,
     NULL, NULL, NULL, NULL, NULL, 'EUR', NULL, false,
     600.00, NULL, 600.00, NULL, 3000.00, NULL, 'EUR',
     '["identity"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_deposits', true),

    (35, 12, 'standard', 1,
     3000.00, NULL, NULL, NULL, NULL, 'EUR', NULL, false,
     600.00, NULL, 600.00, NULL, 3000.00, NULL, 'EUR',
     '["identity", "proof_of_address"]'::jsonb,
     '["EMAIL", "PHONE", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_deposits', true),

    (36, 12, 'enhanced', 2,
     10000.00, 5000.00, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'EUR',
     '["identity", "proof_of_address", "source_of_funds"]'::jsonb,
     '["EMAIL", "PHONE", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_all', true),

    -- ===================== ANJ / FR — jur 13 =====================
    (37, 13, 'basic', 0,
     NULL, NULL, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'EUR',
     '["identity"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_deposits', true),

    (38, 13, 'standard', 1,
     5000.00, NULL, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'EUR',
     '["identity", "proof_of_address"]'::jsonb,
     '["EMAIL", "PHONE", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_deposits', true),

    (39, 13, 'enhanced', 2,
     15000.00, 10000.00, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'EUR',
     '["identity", "proof_of_address", "source_of_funds"]'::jsonb,
     '["EMAIL", "PHONE", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_all', true),

    -- ===================== KSA / NL — jur 14 =====================
    (40, 14, 'basic', 0,
     NULL, NULL, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, 700.00, NULL, 700.00, NULL, 'EUR',
     '["identity"]'::jsonb,
     '["EMAIL", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_deposits', true),

    (41, 14, 'standard', 1,
     700.00, NULL, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'EUR',
     '["identity", "proof_of_address"]'::jsonb,
     '["EMAIL", "PHONE", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_deposits', true),

    (42, 14, 'enhanced', 2,
     5000.00, 5000.00, NULL, NULL, NULL, 'EUR', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'EUR',
     '["identity", "proof_of_address", "source_of_funds"]'::jsonb,
     '["EMAIL", "PHONE", "PEP_CHECK", "SANCTIONS_CHECK"]'::jsonb,
     NULL, 0, 'block_all', true),

    -- ===================== TR (Gevşek) — jur 15 =====================
    -- Basic: Sadece email, hiçbir belge gerekmez, limit yok
    (43, 15, 'basic', 0,
     NULL, NULL, NULL, NULL, NULL, 'TRY', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'TRY',
     '[]'::jsonb,
     '["EMAIL"]'::jsonb,
     NULL, 0, 'block_withdrawals', true),

    -- Standard: İlk çekimde veya 50.000 TRY'de tetiklenir
    (44, 15, 'standard', 1,
     50000.00, NULL, NULL, NULL, NULL, 'TRY', NULL, true,
     NULL, NULL, NULL, NULL, NULL, NULL, 'TRY',
     '["identity"]'::jsonb,
     '["EMAIL", "PHONE"]'::jsonb,
     NULL, 0, 'block_withdrawals', true),

    -- Enhanced: 100.000 TRY kümülatif
    (45, 15, 'enhanced', 2,
     100000.00, 50000.00, NULL, NULL, NULL, 'TRY', NULL, false,
     NULL, NULL, NULL, NULL, NULL, NULL, 'TRY',
     '["identity", "proof_of_address"]'::jsonb,
     '["EMAIL", "PHONE"]'::jsonb,
     NULL, 0, 'block_withdrawals', true);

SELECT setval('catalog.kyc_level_requirements_id_seq', 45);

-- ============================================================
-- 4. KYC DOCUMENT REQUIREMENTS (KYC Belge Gereksinimleri) — 49 kayıt
-- ============================================================

INSERT INTO catalog.kyc_document_requirements (id, jurisdiction_id, document_type, accepted_subtypes,
    is_required, required_for, max_document_age_days, expires_after_days,
    verification_method, display_order, is_active)
VALUES
    -- ===================== MGA (MT) — jur 1 =====================
    (1,  1, 'identity',          '["passport", "driving_license", "national_id"]'::jsonb,
     true, 'all', NULL, 365, 'hybrid', 1, true),
    (2,  1, 'proof_of_address',  '["utility_bill", "bank_statement"]'::jsonb,
     true, 'all', 90, 365, 'manual', 2, true),
    (3,  1, 'selfie',            '["selfie_with_id"]'::jsonb,
     false, 'all', NULL, 365, 'automated', 3, true),
    (4,  1, 'source_of_funds',   '["payslip", "bank_statement", "tax_return"]'::jsonb,
     true, 'edd', NULL, 180, 'manual', 4, true),

    -- ===================== UKGC (GB) — jur 2 =====================
    (5,  2, 'identity',          '["passport", "driving_license", "national_id"]'::jsonb,
     true, 'all', NULL, 365, 'hybrid', 1, true),
    (6,  2, 'proof_of_address',  '["utility_bill", "bank_statement", "council_tax"]'::jsonb,
     true, 'all', 90, 365, 'manual', 2, true),
    (7,  2, 'selfie',            '["selfie_with_id"]'::jsonb,
     false, 'all', NULL, 365, 'automated', 3, true),
    (8,  2, 'source_of_funds',   '["payslip", "bank_statement", "tax_return", "employer_letter"]'::jsonb,
     true, 'edd', NULL, 180, 'manual', 4, true),

    -- ===================== GGL (DE) — jur 3 =====================
    (9,  3, 'identity',          '["personalausweis", "reisepass", "video_ident", "eID"]'::jsonb,
     true, 'all', NULL, 365, 'automated', 1, true),
    (10, 3, 'proof_of_address',  '["meldebestätigung", "utility_bill", "bank_statement"]'::jsonb,
     true, 'all', 90, 365, 'manual', 2, true),
    (11, 3, 'source_of_funds',   '["payslip", "bank_statement", "tax_return"]'::jsonb,
     true, 'edd', NULL, 180, 'manual', 3, true),

    -- ===================== SGA / SE — jur 4 =====================
    (12, 4, 'identity',          '["BankID"]'::jsonb,
     true, 'all', NULL, NULL, 'automated', 1, true),
    (13, 4, 'source_of_funds',   '["payslip", "bank_statement", "tax_return"]'::jsonb,
     true, 'edd', NULL, 180, 'manual', 2, true),

    -- ===================== DGA / DK — jur 5 =====================
    (14, 5, 'identity',          '["passport", "driving_license", "health_card", "MitID"]'::jsonb,
     true, 'all', NULL, 365, 'automated', 1, true),
    (15, 5, 'proof_of_address',  '["utility_bill", "bank_statement"]'::jsonb,
     true, 'withdrawal', 90, 365, 'manual', 2, true),
    (16, 5, 'source_of_funds',   '["payslip", "bank_statement"]'::jsonb,
     true, 'edd', NULL, 180, 'manual', 3, true),

    -- ===================== AGCO / CA Ontario — jur 6 =====================
    (17, 6, 'identity',          '["passport", "driving_license", "provincial_id", "citizenship_card"]'::jsonb,
     true, 'all', NULL, 365, 'hybrid', 1, true),
    (18, 6, 'proof_of_address',  '["utility_bill", "bank_statement", "government_letter"]'::jsonb,
     true, 'all', 90, 365, 'manual', 2, true),
    (19, 6, 'selfie',            '["selfie_with_id"]'::jsonb,
     false, 'all', NULL, 365, 'automated', 3, true),
    (20, 6, 'source_of_funds',   '["payslip", "bank_statement", "tax_return", "CRA_notice"]'::jsonb,
     true, 'edd', NULL, 180, 'manual', 4, true),

    -- ===================== CUR / CW — jur 7 =====================
    (21, 7, 'identity',          '["passport", "driving_license", "national_id"]'::jsonb,
     true, 'withdrawal', NULL, 365, 'manual', 1, true),
    (22, 7, 'proof_of_address',  '["utility_bill", "bank_statement"]'::jsonb,
     true, 'withdrawal', 90, 365, 'manual', 2, true),
    (23, 7, 'selfie',            '["selfie_with_id"]'::jsonb,
     false, 'withdrawal', NULL, 365, 'manual', 3, true),
    (24, 7, 'source_of_funds',   '["bank_statement", "crypto_wallet_proof"]'::jsonb,
     true, 'edd', NULL, 180, 'manual', 4, true),

    -- ===================== GIB / GI — jur 8 =====================
    (25, 8, 'identity',          '["passport", "driving_license", "national_id"]'::jsonb,
     true, 'all', NULL, 365, 'hybrid', 1, true),
    (26, 8, 'proof_of_address',  '["utility_bill", "bank_statement"]'::jsonb,
     true, 'all', 90, 365, 'manual', 2, true),
    (27, 8, 'selfie',            '["selfie_with_id"]'::jsonb,
     false, 'all', NULL, 365, 'automated', 3, true),
    (28, 8, 'source_of_funds',   '["payslip", "bank_statement", "tax_return"]'::jsonb,
     true, 'edd', NULL, 180, 'manual', 4, true),

    -- ===================== IOM / IM — jur 9 =====================
    (29, 9, 'identity',          '["passport", "driving_license", "national_id"]'::jsonb,
     true, 'all', NULL, 365, 'hybrid', 1, true),
    (30, 9, 'proof_of_address',  '["utility_bill", "bank_statement"]'::jsonb,
     true, 'all', 90, 365, 'manual', 2, true),
    (31, 9, 'selfie',            '["selfie_with_id"]'::jsonb,
     false, 'all', NULL, 365, 'automated', 3, true),
    (32, 9, 'source_of_funds',   '["payslip", "bank_statement", "tax_return"]'::jsonb,
     true, 'edd', NULL, 180, 'manual', 4, true),

    -- ===================== ONJN / RO — jur 10 =====================
    (33, 10, 'identity',         '["carte_identitate", "passport"]'::jsonb,
     true, 'all', NULL, 365, 'hybrid', 1, true),
    (34, 10, 'proof_of_address', '["utility_bill", "bank_statement"]'::jsonb,
     true, 'all', 90, 365, 'manual', 2, true),
    (35, 10, 'source_of_funds',  '["payslip", "bank_statement"]'::jsonb,
     true, 'edd', NULL, 180, 'manual', 3, true),

    -- ===================== ADM / IT — jur 11 =====================
    (36, 11, 'identity',         '["carta_identita", "passport", "patente", "SPID", "CIE"]'::jsonb,
     true, 'all', NULL, 365, 'automated', 1, true),
    (37, 11, 'proof_of_address', '["utility_bill", "bank_statement"]'::jsonb,
     true, 'all', 90, 365, 'manual', 2, true),
    (38, 11, 'source_of_funds',  '["payslip", "bank_statement", "tax_return"]'::jsonb,
     true, 'edd', NULL, 180, 'manual', 3, true),

    -- ===================== DGOJ / ES — jur 12 =====================
    (39, 12, 'identity',         '["dni", "passport", "residence_permit"]'::jsonb,
     true, 'all', NULL, 365, 'automated', 1, true),
    (40, 12, 'proof_of_address', '["utility_bill", "bank_statement", "empadronamiento"]'::jsonb,
     true, 'all', 90, 365, 'manual', 2, true),
    (41, 12, 'source_of_funds',  '["payslip", "bank_statement", "irpf"]'::jsonb,
     true, 'edd', NULL, 180, 'manual', 3, true),

    -- ===================== ANJ / FR — jur 13 =====================
    (42, 13, 'identity',         '["carte_identite", "passport", "titre_sejour"]'::jsonb,
     true, 'all', NULL, 365, 'hybrid', 1, true),
    (43, 13, 'proof_of_address', '["utility_bill", "bank_statement", "tax_notice"]'::jsonb,
     true, 'all', 90, 365, 'manual', 2, true),
    (44, 13, 'source_of_funds',  '["payslip", "bank_statement", "avis_imposition"]'::jsonb,
     true, 'edd', NULL, 180, 'manual', 3, true),

    -- ===================== KSA / NL — jur 14 =====================
    (45, 14, 'identity',         '["passport", "id_card", "driving_license", "iDIN"]'::jsonb,
     true, 'all', NULL, 365, 'automated', 1, true),
    (46, 14, 'proof_of_address', '["utility_bill", "bank_statement"]'::jsonb,
     true, 'all', 90, 365, 'manual', 2, true),
    (47, 14, 'source_of_funds',  '["payslip", "bank_statement", "tax_return"]'::jsonb,
     true, 'edd', NULL, 180, 'manual', 3, true),

    -- ===================== TR (Gevşek) — jur 15 =====================
    -- Kimlik: Sadece çekimde zorunlu, otomatik doğrulama yok
    (48, 15, 'identity',         '["tc_kimlik", "passport", "ehliyet"]'::jsonb,
     true, 'withdrawal', NULL, NULL, 'manual', 1, true),
    -- Adres: Sadece enhanced seviyede
    (49, 15, 'proof_of_address', '["utility_bill", "bank_statement", "ikametgah"]'::jsonb,
     false, 'edd', 90, 365, 'manual', 2, true);

SELECT setval('catalog.kyc_document_requirements_id_seq', 49);

-- ============================================================
-- 5. RESPONSIBLE GAMING POLICIES (Sorumlu Oyun Politikaları) — 15 kayıt
-- ============================================================

INSERT INTO catalog.responsible_gaming_policies (id, jurisdiction_id,
    deposit_limit_required, deposit_limit_options, deposit_limit_max_increase_wait_hours,
    loss_limit_required, loss_limit_options,
    session_limit_required, session_limit_max_hours, session_break_required, session_break_after_hours, session_break_duration_minutes,
    reality_check_required, reality_check_interval_minutes,
    cooling_off_available, cooling_off_min_days, cooling_off_max_days, cooling_off_revocable,
    self_exclusion_available, self_exclusion_min_months, self_exclusion_permanent_option, self_exclusion_revocable,
    central_exclusion_system, central_exclusion_integration_required, central_exclusion_api_endpoint,
    anonymous_payments_allowed, crypto_payments_allowed, credit_card_gambling_allowed,
    payment_method_ownership_verification, is_active)
VALUES
    -- MGA (MT): Gevşek, operatör seviyesinde dışlama
    (1, 1,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb, 24,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb,
     true, NULL, false, NULL, NULL,
     true, 60,
     true, 1, 42, false,
     true, 6, true, false,
     NULL, false, NULL,
     true, true, true,
     false, true),

    -- UKGC (GB): Kredi kartı yasak, GAMSTOP zorunlu
    (2, 2,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb, 24,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb,
     true, NULL, false, NULL, NULL,
     true, 60,
     true, 1, 42, false,
     true, 6, true, false,
     'GAMSTOP', true, NULL,
     false, true, false,
     false, true),

    -- GGL (DE): En sıkı — 1.000 EUR/ay cross-operator limit, OASIS, paralel oyun yasak
    (3, 3,
     true, '["MONTHLY"]'::jsonb, 0,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb,
     true, NULL, true, 1, 5,
     true, 60,
     true, 1, 42, false,
     true, 3, true, false,
     'OASIS', true, NULL,
     false, false, false,
     true, true),

    -- SGA / SE: BankID zorunlu, Spelpaus
    (4, 4,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb, 72,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb,
     true, NULL, false, NULL, NULL,
     true, 60,
     true, 1, 42, false,
     true, 1, true, false,
     'SPELPAUS', true, 'https://www.spelpaus.se',
     false, true, false,
     false, true),

    -- DGA / DK: ROFUS, MitID
    (5, 5,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb, 24,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb,
     true, NULL, false, NULL, NULL,
     true, 60,
     true, 1, 42, true,
     true, 1, true, false,
     'ROFUS', true, NULL,
     false, true, true,
     false, true),

    -- AGCO / CA Ontario: PlaySmart, CONNEX self-exclusion
    (6, 6,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb, 24,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb,
     true, NULL, false, NULL, NULL,
     true, 60,
     true, 1, 42, false,
     true, 6, true, false,
     'CONNEX', true, NULL,
     false, false, true,
     true, true),

    -- CUR / CW: LOK çerçevesi ile güncellenen kurallar
    (7, 7,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb, 72,
     false, NULL,
     false, NULL, false, NULL, NULL,
     true, 60,
     true, 7, 180, true,
     true, 12, true, false,
     NULL, false, NULL,
     true, true, true,
     false, true),

    -- GIB / GI: UK benzeri rejim, operatör seviyesinde dışlama
    (8, 8,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb, 24,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb,
     true, NULL, false, NULL, NULL,
     true, 60,
     true, 1, 42, false,
     true, 6, true, false,
     NULL, false, NULL,
     false, true, true,
     false, true),

    -- IOM / IM: UK benzeri rejim, GamCare
    (9, 9,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb, 24,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb,
     true, NULL, false, NULL, NULL,
     true, 60,
     true, 1, 42, false,
     true, 6, true, false,
     NULL, false, NULL,
     false, true, true,
     false, true),

    -- ONJN / RO: Yeni merkezi dışlama sistemi (2025)
    (10, 10,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb, 48,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb,
     true, NULL, false, NULL, NULL,
     true, 60,
     true, 1, 42, false,
     true, 6, true, false,
     'ONJN_REGISTRY', true, NULL,
     false, true, true,
     false, true),

    -- ADM / IT: Autoesclusione, sıkı reklam kuralları, 7 gün artış bekleme
    (11, 11,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb, 168,
     true, '["WEEKLY","MONTHLY"]'::jsonb,
     true, NULL, false, NULL, NULL,
     true, 60,
     true, 1, 42, false,
     true, 3, true, false,
     'AUTOESCLUSIONE', true, NULL,
     false, false, true,
     true, true),

    -- DGOJ / ES: Varsayılan limitler zorunlu, RGIAJ merkezi dışlama
    (12, 12,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb, 48,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb,
     true, NULL, false, NULL, NULL,
     true, 60,
     true, 1, 42, false,
     true, 1, true, false,
     'RGIAJ', true, NULL,
     false, true, true,
     false, true),

    -- ANJ / FR: 48 saat artış bekleme, 3 yıl min dışlama
    (13, 13,
     true, '["WEEKLY"]'::jsonb, 48,
     true, '["WEEKLY"]'::jsonb,
     true, NULL, false, NULL, NULL,
     true, 60,
     true, 1, 42, false,
     true, 36, true, false,
     'INTERDICTION_VOLONTAIRE', true, 'https://interdictiondejeux.anj.fr',
     false, false, true,
     false, true),

    -- KSA / NL: iDIN doğrulama, CRUKS, 700 EUR/ay eşik
    (14, 14,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb, 72,
     true, '["DAILY","WEEKLY","MONTHLY"]'::jsonb,
     true, NULL, false, NULL, NULL,
     true, 60,
     true, 1, 42, false,
     true, 6, true, false,
     'CRUKS', true, NULL,
     false, true, false,
     true, true),

    -- TR: Minimum kural — limitler opsiyonel, merkezi sistem yok, tüm ödeme yöntemleri açık
    (15, 15,
     false, '["DAILY","WEEKLY","MONTHLY"]'::jsonb, 24,
     false, NULL,
     false, NULL, false, NULL, NULL,
     false, NULL,
     true, 1, 180, true,
     true, 6, true, true,
     NULL, false, NULL,
     true, true, true,
     false, true);

SELECT setval('catalog.responsible_gaming_policies_id_seq', 15);

-- ============================================================
-- 6. DATA RETENTION POLICIES (Veri Saklama Süreleri) — 75 kayıt
-- ============================================================
-- Kategoriler: kyc_data, transaction_logs, player_data,
--              game_logs, audit_logs
-- ============================================================

INSERT INTO catalog.data_retention_policies (id, jurisdiction_id, data_category, retention_days, legal_reference, description, is_active)
VALUES
    -- ===================== MGA (MT) — 5 yıl =====================
    (1,  1, 'kyc_data',         1825, 'SL 583.12 (Malta Gaming Act)',  'KYC documents and verification records', true),
    (2,  1, 'transaction_logs', 1825, 'SL 583.12',                     'Financial transaction records', true),
    (3,  1, 'player_data',      1825, 'EU GDPR + SL 583.12',          'Player personal data', true),
    (4,  1, 'game_logs',         365, 'MGA Directive 2018',            'Game round and bet records', true),
    (5,  1, 'audit_logs',       1825, 'SL 583.12',                     'System audit trail', true),

    -- ===================== UKGC (GB) — 5 yıl =====================
    (6,  2, 'kyc_data',         1825, 'UK MLR 2017 Reg 40',           'KYC documents and verification records', true),
    (7,  2, 'transaction_logs', 1825, 'UK MLR 2017 Reg 40',           'Financial transaction records', true),
    (8,  2, 'player_data',      1825, 'UK MLR 2017 + UK GDPR',        'Player personal data', true),
    (9,  2, 'game_logs',         365, 'UKGC LCCP 15.2.1',             'Game round and bet records', true),
    (10, 2, 'audit_logs',       1825, 'UK MLR 2017 Reg 40',           'System audit trail', true),

    -- ===================== GGL (DE) — 5 yıl =====================
    (11, 3, 'kyc_data',         1825, 'GwG §8 (Geldwäschegesetz)',     'KYC documents and verification records', true),
    (12, 3, 'transaction_logs', 1825, 'GwG §8',                        'Financial transaction records', true),
    (13, 3, 'player_data',      1825, 'GwG + BDSG',                    'Player personal data', true),
    (14, 3, 'game_logs',         365, 'GlüStV 2021 §6a',              'Game round and bet records', true),
    (15, 3, 'audit_logs',       1825, 'GwG §8',                        'System audit trail', true),

    -- ===================== SGA / SE — 5 yıl =====================
    (16, 4, 'kyc_data',         1825, 'Lag 2017:630 §3.17',            'KYC documents and verification records', true),
    (17, 4, 'transaction_logs', 1825, 'Lag 2017:630 §3.17',            'Financial transaction records', true),
    (18, 4, 'player_data',      1825, 'GDPR + Lag 2017:630',           'Player personal data', true),
    (19, 4, 'game_logs',         365, 'Spelinspektionen Licence',       'Game round and bet records', true),
    (20, 4, 'audit_logs',       1825, 'Lag 2017:630 §3.17',            'System audit trail', true),

    -- ===================== DGA / DK — 5 yıl =====================
    (21, 5, 'kyc_data',         1825, 'Hvidvaskloven §30',             'KYC documents and verification records', true),
    (22, 5, 'transaction_logs', 1825, 'Hvidvaskloven §30',             'Financial transaction records', true),
    (23, 5, 'player_data',      2007, 'ROFUS: 5 yıl + current year',  'Player personal data', true),
    (24, 5, 'game_logs',         365, 'DGA Licence Conditions',        'Game round and bet records', true),
    (25, 5, 'audit_logs',       1825, 'Hvidvaskloven §30',             'System audit trail', true),

    -- ===================== AGCO / CA Ontario — 5 yıl =====================
    (26, 6, 'kyc_data',         1825, 'PCMLTFA Reg 71',               'KYC documents and verification records', true),
    (27, 6, 'transaction_logs', 1825, 'PCMLTFA Reg 71',               'Financial transaction records', true),
    (28, 6, 'player_data',      1825, 'PIPEDA + AGCO iGaming Standards', 'Player personal data', true),
    (29, 6, 'game_logs',         365, 'AGCO iGaming Standards',        'Game round and bet records', true),
    (30, 6, 'audit_logs',       1825, 'PCMLTFA Reg 71',               'System audit trail', true),

    -- ===================== CUR / CW — 5 yıl =====================
    (31, 7, 'kyc_data',         1825, 'LOK AML/CFT Framework',         'KYC documents and verification records', true),
    (32, 7, 'transaction_logs', 1825, 'LOK AML/CFT Framework',         'Financial transaction records', true),
    (33, 7, 'player_data',      1825, 'LOK AML/CFT Framework',         'Player personal data', true),
    (34, 7, 'game_logs',         180, 'CGA Licence Conditions',        'Game round and bet records', true),
    (35, 7, 'audit_logs',       1825, 'LOK AML/CFT Framework',         'System audit trail', true),

    -- ===================== GIB / GI — 5 yıl =====================
    (36, 8, 'kyc_data',         1825, 'Gibraltar POCA 2015',           'KYC documents and verification records', true),
    (37, 8, 'transaction_logs', 1825, 'Gibraltar POCA 2015',           'Financial transaction records', true),
    (38, 8, 'player_data',      1825, 'Gibraltar DPA + GDPR',          'Player personal data', true),
    (39, 8, 'game_logs',         365, 'Gibraltar Gambling Act 2005',   'Game round and bet records', true),
    (40, 8, 'audit_logs',       1825, 'Gibraltar POCA 2015',           'System audit trail', true),

    -- ===================== IOM / IM — 5 yıl =====================
    (41, 9, 'kyc_data',         1825, 'IOM POCA 2008',                 'KYC documents and verification records', true),
    (42, 9, 'transaction_logs', 1825, 'IOM POCA 2008',                 'Financial transaction records', true),
    (43, 9, 'player_data',      1825, 'IOM GDPR + GSC Requirements',   'Player personal data', true),
    (44, 9, 'game_logs',         365, 'GSC Licence Conditions',        'Game round and bet records', true),
    (45, 9, 'audit_logs',       1825, 'IOM POCA 2008',                 'System audit trail', true),

    -- ===================== ONJN / RO — 5-10 yıl =====================
    (46, 10, 'kyc_data',        1825, 'Legea 129/2019 Art 21',         'KYC documents and verification records', true),
    (47, 10, 'transaction_logs', 3650, 'Legea 129/2019 Art 21',        'Financial transaction records (10 years)', true),
    (48, 10, 'player_data',     1825, 'GDPR + Legea 129/2019',         'Player personal data', true),
    (49, 10, 'game_logs',        365, 'ONJN Licence Conditions',       'Game round and bet records', true),
    (50, 10, 'audit_logs',      3650, 'Legea 129/2019 Art 21',         'System audit trail (10 years)', true),

    -- ===================== ADM / IT — 10 yıl =====================
    (51, 11, 'kyc_data',        3650, 'D.Lgs. 231/2007 Art 31',        'KYC documents and verification records (10 years)', true),
    (52, 11, 'transaction_logs', 3650, 'D.Lgs. 231/2007 Art 31',       'Financial transaction records (10 years)', true),
    (53, 11, 'player_data',     3650, 'D.Lgs. 231/2007 + GDPR',        'Player personal data (10 years)', true),
    (54, 11, 'game_logs',        365, 'ADM Regulatory Framework',       'Game round and bet records', true),
    (55, 11, 'audit_logs',      3650, 'D.Lgs. 231/2007 Art 31',        'System audit trail (10 years)', true),

    -- ===================== DGOJ / ES — 10 yıl =====================
    (56, 12, 'kyc_data',        3650, 'Ley 10/2010 Art 25',            'KYC documents and verification records', true),
    (57, 12, 'transaction_logs', 3650, 'Ley 10/2010 Art 25',           'Financial transaction records', true),
    (58, 12, 'player_data',     3650, 'Ley 10/2010 + LOPDGDD',         'Player personal data', true),
    (59, 12, 'game_logs',        365, 'DGOJ Regulatory Framework',     'Game round and bet records', true),
    (60, 12, 'audit_logs',      3650, 'Ley 10/2010 Art 25',            'System audit trail', true),

    -- ===================== ANJ / FR — 5 yıl =====================
    (61, 13, 'kyc_data',        1825, 'Code monétaire L561-12',        'KYC documents and verification records', true),
    (62, 13, 'transaction_logs', 1825, 'Code monétaire L561-12',       'Financial transaction records', true),
    (63, 13, 'player_data',     1825, 'RGPD + Code monétaire',         'Player personal data', true),
    (64, 13, 'game_logs',        365, 'ANJ Cahier des charges',        'Game round and bet records', true),
    (65, 13, 'audit_logs',      1825, 'Code monétaire L561-12',        'System audit trail', true),

    -- ===================== KSA / NL — 5 yıl =====================
    (66, 14, 'kyc_data',        1825, 'Wwft Art 33',                   'KYC documents and verification records', true),
    (67, 14, 'transaction_logs', 1825, 'Wwft Art 33',                  'Financial transaction records', true),
    (68, 14, 'player_data',     1825, 'AVG (GDPR) + Wwft',            'Player personal data', true),
    (69, 14, 'game_logs',        365, 'KSA Regulatory Framework',      'Game round and bet records', true),
    (70, 14, 'audit_logs',      1825, 'Wwft Art 33',                   'System audit trail', true),

    -- ===================== TR — 5 yıl (MASAK) =====================
    (71, 15, 'kyc_data',        1825, 'MASAK Yönetmeliği',             'KYC documents and verification records', true),
    (72, 15, 'transaction_logs', 1825, 'MASAK Yönetmeliği',            'Financial transaction records', true),
    (73, 15, 'player_data',     1825, 'KVKK Madde 7',                 'Player personal data', true),
    (74, 15, 'game_logs',        365, 'Operatör politikası',           'Game round and bet records', true),
    (75, 15, 'audit_logs',      1825, 'MASAK Yönetmeliği',            'System audit trail', true);

SELECT setval('catalog.data_retention_policies_id_seq', 75);
