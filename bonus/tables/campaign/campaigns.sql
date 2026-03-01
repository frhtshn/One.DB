DROP TABLE IF EXISTS campaign.campaigns CASCADE;

CREATE TABLE campaign.campaigns (
    id bigserial PRIMARY KEY,
    client_id bigint,  -- NULL = platform seviyesi, değer = client'a ait
    campaign_code varchar(100) NOT NULL,
    campaign_name varchar(255) NOT NULL,
    description text,

    -- Kampanya tipi
    campaign_type varchar(50) NOT NULL,  -- welcome, deposit_bonus, tournament, seasonal

    -- İlişkili bonus kuralları
    bonus_rule_ids jsonb,                -- Birden fazla bonus kuralı olabilir

    -- Süre
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,

    -- Bütçe (opsiyonel)
    budget_currency CHAR(3),                   -- Bütçe para birimi (multi-currency desteği)
    total_budget DECIMAL(18,2),
    spent_budget DECIMAL(18,2) DEFAULT 0,

    -- Ödül stratejisi
    award_strategy VARCHAR(30) DEFAULT 'automatic',  -- automatic, claim, manual

    -- Hedef kitle
    target_segments jsonb,               -- ["new_players", "vip", "dormant"]

    -- Durum
    status varchar(20) NOT NULL DEFAULT 'draft',  -- draft, active, paused, ended

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE campaign.campaigns IS 'Marketing campaigns management including welcome, deposit bonus, tournament, and seasonal promotions with budget tracking and audience segmentation';
