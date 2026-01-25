DROP TABLE IF EXISTS transaction.transaction_workflows CASCADE;

CREATE TABLE transaction.transaction_workflows (
    id bigserial PRIMARY KEY,
    transaction_id bigint NOT NULL UNIQUE,
    workflow_type varchar(30) NOT NULL,
    status varchar(30) NOT NULL,
    reason varchar(255),
    created_by_id bigint,                   -- Workflow'u başlatan kullanıcı (BO User or System)
    assigned_to_id bigint,                  -- Atanan kullanıcı (Opsiyonel)
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

