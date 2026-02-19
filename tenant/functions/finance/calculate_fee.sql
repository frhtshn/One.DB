-- ================================================================
-- CALCULATE_FEE: Ödeme yöntemi komisyon hesaplama
-- ================================================================
-- Belirtilen ödeme yöntemi, para birimi ve yön için komisyon
-- hesaplar. Formül: raw = amount × percent + fixed,
-- fee = MAX(min, MIN(max, raw)). NULL min/max = sınırsız.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS finance.calculate_fee(BIGINT, VARCHAR, VARCHAR, DECIMAL);

CREATE OR REPLACE FUNCTION finance.calculate_fee(
    p_payment_method_id     BIGINT,
    p_currency_code         VARCHAR(20),
    p_direction             VARCHAR(20),
    p_amount                DECIMAL(18,8)
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_limits        RECORD;
    v_fee_percent   DECIMAL(5,4);
    v_fee_fixed     DECIMAL(18,8);
    v_fee_min       DECIMAL(18,8);
    v_fee_max       DECIMAL(18,8);
    v_raw_fee       DECIMAL(18,8);
    v_fee_amount    DECIMAL(18,8);
    v_net_amount    DECIMAL(18,8);
BEGIN
    -- Direction kontrolü
    IF p_direction IS NULL OR p_direction NOT IN ('DEPOSIT', 'WITHDRAWAL') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.calculate-fee.invalid-direction';
    END IF;

    -- Limit ve fee bilgilerini al
    SELECT *
    INTO v_limits
    FROM finance.payment_method_limits
    WHERE payment_method_id = p_payment_method_id
      AND currency_code = p_currency_code
      AND is_active = true;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.calculate-fee.method-not-found';
    END IF;

    -- Yöne göre fee parametrelerini seç
    IF p_direction = 'DEPOSIT' THEN
        v_fee_percent := COALESCE(v_limits.deposit_fee_percent, 0);
        v_fee_fixed   := COALESCE(v_limits.deposit_fee_fixed, 0);
        v_fee_min     := v_limits.deposit_fee_min;
        v_fee_max     := v_limits.deposit_fee_max;
    ELSE
        v_fee_percent := COALESCE(v_limits.withdrawal_fee_percent, 0);
        v_fee_fixed   := COALESCE(v_limits.withdrawal_fee_fixed, 0);
        v_fee_min     := v_limits.withdrawal_fee_min;
        v_fee_max     := v_limits.withdrawal_fee_max;
    END IF;

    -- Ham fee hesapla: amount × percent + fixed
    v_raw_fee := p_amount * v_fee_percent + v_fee_fixed;

    -- Min/max cap uygula: MAX(min, MIN(max, raw))
    v_fee_amount := v_raw_fee;

    IF v_fee_max IS NOT NULL AND v_fee_amount > v_fee_max THEN
        v_fee_amount := v_fee_max;
    END IF;

    IF v_fee_min IS NOT NULL AND v_fee_amount < v_fee_min THEN
        v_fee_amount := v_fee_min;
    END IF;

    -- Negatif fee olamaz
    IF v_fee_amount < 0 THEN
        v_fee_amount := 0;
    END IF;

    -- Net tutar hesapla
    IF p_direction = 'DEPOSIT' THEN
        v_net_amount := p_amount - v_fee_amount;  -- Deposit: oyuncu fee'den sonra az alır
    ELSE
        v_net_amount := p_amount + v_fee_amount;  -- Withdrawal: toplam kesinti = amount + fee
    END IF;

    RETURN jsonb_build_object(
        'feeAmount', v_fee_amount,
        'feePercent', v_fee_percent,
        'feeFixed', v_fee_fixed,
        'feeMin', v_fee_min,
        'feeMax', v_fee_max,
        'netAmount', v_net_amount,
        'direction', p_direction
    );
END;
$$;

COMMENT ON FUNCTION finance.calculate_fee IS 'Calculates payment method fee for deposit or withdrawal. Formula: MAX(min, MIN(max, amount * percent + fixed)). Returns fee breakdown and net amount.';
