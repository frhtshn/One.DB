DROP TABLE IF EXISTS execution.bonus_awards CASCADE;

CREATE TABLE execution.bonus_awards (
    id bigserial PRIMARY KEY,

    -- Denormalize edilmiş bilgiler
    tenant_id bigint NOT NULL,
    tenant_code varchar(50) NOT NULL,
    player_id bigint NOT NULL,
    player_username varchar(150),

    -- Bonus bilgileri
    bonus_rule_id bigint NOT NULL,
    bonus_type_code varchar(50) NOT NULL,
    trigger_id bigint,
    promo_code_id bigint,
    campaign_id bigint,

    -- Değerler
    bonus_amount decimal(18,2) NOT NULL,
    currency char(3) NOT NULL,

    -- Çevrim takibi
    wagering_requirement decimal(5,2),
    wagering_progress decimal(18,2) DEFAULT 0,
    wagering_completed boolean DEFAULT false,

    -- Geçerlilik
    expires_at timestamp without time zone,

    -- Durum
    status varchar(20) NOT NULL DEFAULT 'pending',  -- pending, active, completed, expired, cancelled

    -- Tenant'a gönderilen transaction referansı
    tenant_transaction_id bigint,

    awarded_at timestamp without time zone NOT NULL DEFAULT now(),
    completed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
