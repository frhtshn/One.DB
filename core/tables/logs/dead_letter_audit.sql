-- =============================================
-- Tablo: logs.dead_letter_audit
-- Açıklama: Dead letter admin işlemleri audit log
-- No FK - DL silindikten sonra da kayıt kalır
-- =============================================

DROP TABLE IF EXISTS logs.dead_letter_audit CASCADE;

CREATE TABLE IF NOT EXISTS logs.dead_letter_audit (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dead_letter_id UUID NOT NULL,
    event_type VARCHAR(255),
    event_id VARCHAR(255),
    action VARCHAR(50) NOT NULL,
    performed_by VARCHAR(255) NOT NULL,
    performed_at TIMESTAMPTZ DEFAULT NOW(),
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    notes TEXT
);

-- Audit action constraint
DO $$ BEGIN
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_dead_letter_audit_action') THEN
        ALTER TABLE logs.dead_letter_audit DROP CONSTRAINT chk_dead_letter_audit_action;
    END IF;
END $$;

ALTER TABLE logs.dead_letter_audit ADD CONSTRAINT chk_dead_letter_audit_action
    CHECK (action IN (
        'retry', 'resolve', 'ignore', 'archive',
        'bulk_retry', 'bulk_resolve', 'bulk_ignore',
        'auto_retry', 'schedule_retry'
    ));

COMMENT ON TABLE logs.dead_letter_audit IS 'Audit log for dead letter admin operations. No FK - survives DL deletion.';
