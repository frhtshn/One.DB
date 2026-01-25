DROP TABLE IF EXISTS bonus.bonus_rules CASCADE;

CREATE TABLE bonus.bonus_rules (
    id bigserial PRIMARY KEY,
    tenant_id bigint,  -- NULL = platform seviyesi, değer = tenant'a ait
    rule_code varchar(100) NOT NULL,
    rule_name varchar(255) NOT NULL,
    bonus_type_id bigint NOT NULL,

    -- Değer
    bonus_value decimal(18,2) NOT NULL,
    max_bonus_amount decimal(18,2),

    -- Minimum gereksinimler
    min_deposit decimal(18,2),
    min_bet decimal(18,2),

    -- Çevrim şartları
    wagering_requirement decimal(5,2),  -- örn: 30x
    wagering_game_types jsonb,          -- hangi oyun tiplerinde geçerli

    -- Geçerlilik
    valid_from timestamp without time zone,
    valid_until timestamp without time zone,
    expires_in_days int,                -- Bonus alındıktan sonra kaç gün geçerli

    -- Kısıtlamalar
    max_uses_total int,
    max_uses_per_player int DEFAULT 1,
    eligible_countries jsonb,
    eligible_currencies jsonb,

    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
