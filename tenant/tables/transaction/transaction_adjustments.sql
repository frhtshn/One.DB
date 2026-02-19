-- =============================================
-- Tablo: transaction.transaction_adjustments
-- Açıklama: BO hesap düzeltme detayları
-- Workflow zorunlu — onay sonrası wallet'a uygulanır
-- GGR etkili düzeltmeler provider_id + game_id ile
-- =============================================

DROP TABLE IF EXISTS transaction.transaction_adjustments CASCADE;

CREATE TABLE transaction.transaction_adjustments (
    id                  BIGSERIAL       PRIMARY KEY,
    transaction_id      BIGINT,                          -- NULL → apply sonrası dolar
    player_id           BIGINT          NOT NULL,
    wallet_type         VARCHAR(10)     NOT NULL,        -- REAL, BONUS
    direction           VARCHAR(10)     NOT NULL,        -- CREDIT, DEBIT
    amount              NUMERIC(18,8)   NOT NULL,
    currency_code       VARCHAR(20)     NOT NULL,
    adjustment_type     VARCHAR(30)     NOT NULL,        -- GAME_CORRECTION, BONUS_CORRECTION, FRAUD, MANUAL
    status              VARCHAR(20)     NOT NULL DEFAULT 'PENDING',  -- PENDING, APPLIED, CANCELLED
    provider_id         BIGINT,                          -- GGR için (GAME_CORRECTION'da zorunlu)
    game_id             BIGINT,                          -- GGR için
    external_ref        VARCHAR(100),                    -- Provider referansı
    reason              VARCHAR(500)    NOT NULL,
    created_by_id       BIGINT          NOT NULL,        -- BO user ID (Core DB)
    approved_by_id      BIGINT,                          -- Onaylayan BO user ID
    workflow_id         BIGINT,                          -- Bağlı workflow
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    applied_at          TIMESTAMPTZ
);

COMMENT ON TABLE transaction.transaction_adjustments IS 'Account adjustment details with mandatory workflow approval. Supports GAME_CORRECTION (GGR-affecting with provider/game refs), BONUS_CORRECTION, FRAUD, and MANUAL types.';
