-- =============================================
-- Transaction Workflows (İşlem İş Akışları)
-- Onay gerektiren işlemlerin durumu
-- Para çekme, yüksek tutarlı işlemler için
-- =============================================

DROP TABLE IF EXISTS transaction.transaction_workflows CASCADE;

CREATE TABLE transaction.transaction_workflows (
    id bigserial PRIMARY KEY,
    transaction_id bigint NOT NULL UNIQUE,        -- Bağlı işlem ID
    workflow_type varchar(30) NOT NULL,           -- Akış tipi: WITHDRAWAL, HIGH_VALUE, SUSPICIOUS
    status varchar(30) NOT NULL,                  -- Durum: PENDING, APPROVED, REJECTED, CANCELLED
    reason varchar(255),                          -- Durum açıklaması
    created_by_id bigint,                         -- Akışı başlatan (BO User veya System)
    assigned_to_id bigint,                        -- Atanan onaylayan (opsiyonel)
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

