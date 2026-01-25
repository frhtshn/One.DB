DROP TABLE IF EXISTS bonus.bonus_triggers CASCADE;

CREATE TABLE bonus.bonus_triggers (
    id bigserial PRIMARY KEY,
    tenant_id bigint,  -- NULL = platform seviyesi, değer = tenant'a ait
    trigger_code varchar(100) NOT NULL,
    trigger_name varchar(255) NOT NULL,
    bonus_rule_id bigint NOT NULL,

    -- Tetikleyici tipi
    trigger_type varchar(50) NOT NULL,  -- registration, first_deposit, deposit, bet, loss, birthday, vip_level_up

    -- Koşullar
    trigger_conditions jsonb,           -- {"min_amount": 100, "payment_method": "paypal"}

    -- Zamanlama
    schedule_type varchar(30),          -- immediate, scheduled, cron
    schedule_cron varchar(100),         -- "0 0 * * *" (günlük)

    priority int DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
