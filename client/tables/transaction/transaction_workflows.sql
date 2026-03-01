-- =============================================
-- Transaction Workflows (İşlem İş Akışları)
-- Onay gerektiren işlemlerin durumu
-- Para çekme, yüksek tutarlı işlemler için
-- =============================================

DROP TABLE IF EXISTS transaction.transaction_workflows CASCADE;

CREATE TABLE transaction.transaction_workflows (
    id bigserial PRIMARY KEY,
    transaction_id bigint,                          -- Bağlı işlem ID (ADJUSTMENT workflow'larında NULL — tx apply sonrası oluşur)
    workflow_type varchar(30) NOT NULL,           -- Akış tipi: WITHDRAWAL, HIGH_VALUE, SUSPICIOUS, ADJUSTMENT, KYC_REQUIRED
    status varchar(30) NOT NULL,                  -- Durum: PENDING, IN_REVIEW, APPROVED, REJECTED, CANCELLED
    reason varchar(255),                          -- Durum açıklaması
    created_by_id bigint,                         -- Akışı başlatan (BO User veya System)
    assigned_to_id bigint,                        -- Atanan onaylayan (opsiyonel)
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE transaction.transaction_workflows IS 'Transaction approval workflows for withdrawals, high-value transactions, and suspicious activity. Detailed history is tracked in transaction_workflow_actions.';

