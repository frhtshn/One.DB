-- ================================================================
-- KYC_CASE_CREATE: Yeni KYC doğrulama süreci başlat
-- ================================================================
-- Oyuncu için yeni bir KYC case oluşturur.
-- İlk workflow kaydını da ekler.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.kyc_case_create(BIGINT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION kyc.kyc_case_create(
    p_player_id      BIGINT,
    p_initial_status VARCHAR(30) DEFAULT 'not_started',
    p_kyc_level      VARCHAR(20) DEFAULT 'basic'
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_case_id BIGINT;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-case.player-required';
    END IF;

    -- Oyuncu kontrolü
    IF NOT EXISTS (SELECT 1 FROM auth.players WHERE id = p_player_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-case.player-not-found';
    END IF;

    -- KYC case oluştur
    INSERT INTO kyc.player_kyc_cases (
        player_id, current_status, kyc_level
    ) VALUES (
        p_player_id, p_initial_status, p_kyc_level
    )
    RETURNING id INTO v_case_id;

    -- İlk workflow kaydı
    INSERT INTO kyc.player_kyc_workflows (
        kyc_case_id, current_status, action
    ) VALUES (
        v_case_id, p_initial_status, 'CREATE'
    );

    RETURN v_case_id;
END;
$$;

COMMENT ON FUNCTION kyc.kyc_case_create IS 'Creates a new KYC verification case for a player with initial workflow entry.';
