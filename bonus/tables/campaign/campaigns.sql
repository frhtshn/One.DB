DROP TABLE IF EXISTS campaign.campaigns CASCADE;

CREATE TABLE campaign.campaigns (
    id bigserial PRIMARY KEY,
    tenant_id bigint,  -- NULL = platform seviyesi, değer = tenant'a ait
    campaign_code varchar(100) NOT NULL,
    campaign_name varchar(255) NOT NULL,
    description text,

    -- Kampanya tipi
    campaign_type varchar(50) NOT NULL,  -- welcome, deposit_bonus, tournament, seasonal

    -- İlişkili bonus kuralları
    bonus_rule_ids jsonb,                -- Birden fazla bonus kuralı olabilir

    -- Süre
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,

    -- Bütçe (opsiyonel)
    total_budget decimal(18,2),
    spent_budget decimal(18,2) DEFAULT 0,

    -- Hedef kitle
    target_segments jsonb,               -- ["new_players", "vip", "dormant"]

    -- Durum
    status varchar(20) NOT NULL DEFAULT 'draft',  -- draft, active, paused, ended

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);

COMMENT ON TABLE campaign.campaigns IS 'Marketing campaigns management including welcome, deposit bonus, tournament, and seasonal promotions with budget tracking and audience segmentation';
