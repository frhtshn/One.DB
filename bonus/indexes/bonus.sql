-- =============================================
-- Bonus Schema Indexes
-- =============================================

-- bonus_types
CREATE INDEX IF NOT EXISTS idx_bonus_types_tenant ON bonus.bonus_types USING btree(tenant_id);
CREATE INDEX IF NOT EXISTS idx_bonus_types_category ON bonus.bonus_types USING btree(category);
CREATE INDEX IF NOT EXISTS idx_bonus_types_active ON bonus.bonus_types USING btree(is_active) WHERE is_active = true;
CREATE UNIQUE INDEX IF NOT EXISTS idx_bonus_types_code ON bonus.bonus_types USING btree(tenant_id, type_code);

-- bonus_rules
CREATE INDEX IF NOT EXISTS idx_bonus_rules_tenant ON bonus.bonus_rules USING btree(tenant_id);
CREATE INDEX IF NOT EXISTS idx_bonus_rules_bonus_type ON bonus.bonus_rules USING btree(bonus_type_id);
CREATE INDEX IF NOT EXISTS idx_bonus_rules_active ON bonus.bonus_rules USING btree(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_bonus_rules_validity ON bonus.bonus_rules USING btree(valid_from, valid_until);
CREATE UNIQUE INDEX IF NOT EXISTS idx_bonus_rules_code ON bonus.bonus_rules USING btree(tenant_id, rule_code);
-- JSONB indexes for bonus rules
CREATE INDEX IF NOT EXISTS idx_bonus_rules_wagering_games ON bonus.bonus_rules USING gin(wagering_game_types);
CREATE INDEX IF NOT EXISTS idx_bonus_rules_countries ON bonus.bonus_rules USING gin(eligible_countries);
CREATE INDEX IF NOT EXISTS idx_bonus_rules_currencies ON bonus.bonus_rules USING gin(eligible_currencies);

-- bonus_triggers
CREATE INDEX IF NOT EXISTS idx_bonus_triggers_tenant ON bonus.bonus_triggers USING btree(tenant_id);
CREATE INDEX IF NOT EXISTS idx_bonus_triggers_bonus_rule ON bonus.bonus_triggers USING btree(bonus_rule_id);
CREATE INDEX IF NOT EXISTS idx_bonus_triggers_type ON bonus.bonus_triggers USING btree(trigger_type);
CREATE INDEX IF NOT EXISTS idx_bonus_triggers_active ON bonus.bonus_triggers USING btree(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_bonus_triggers_priority ON bonus.bonus_triggers USING btree(priority DESC) WHERE is_active = true;
CREATE UNIQUE INDEX IF NOT EXISTS idx_bonus_triggers_code ON bonus.bonus_triggers USING btree(tenant_id, trigger_code);
-- JSONB index for trigger conditions
CREATE INDEX IF NOT EXISTS idx_bonus_triggers_conditions ON bonus.bonus_triggers USING gin(trigger_conditions);


-- =============================================
-- Promotion Schema Indexes
-- =============================================

-- promo_codes
CREATE INDEX IF NOT EXISTS idx_promo_codes_tenant ON promotion.promo_codes USING btree(tenant_id);
CREATE INDEX IF NOT EXISTS idx_promo_codes_bonus_rule ON promotion.promo_codes USING btree(bonus_rule_id);
CREATE INDEX IF NOT EXISTS idx_promo_codes_active ON promotion.promo_codes USING btree(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_promo_codes_validity ON promotion.promo_codes USING btree(valid_from, valid_until);
CREATE UNIQUE INDEX IF NOT EXISTS idx_promo_codes_code ON promotion.promo_codes USING btree(tenant_id, code);
-- Promo code lookup (case-insensitive)
CREATE INDEX IF NOT EXISTS idx_promo_codes_lookup ON promotion.promo_codes USING btree(tenant_id, upper(code)) WHERE is_active = true;


-- =============================================
-- Campaign Schema Indexes
-- =============================================

-- campaigns
CREATE INDEX IF NOT EXISTS idx_campaigns_tenant ON campaign.campaigns USING btree(tenant_id);
CREATE INDEX IF NOT EXISTS idx_campaigns_type ON campaign.campaigns USING btree(campaign_type);
CREATE INDEX IF NOT EXISTS idx_campaigns_status ON campaign.campaigns USING btree(status);
CREATE INDEX IF NOT EXISTS idx_campaigns_dates ON campaign.campaigns USING btree(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_campaigns_active ON campaign.campaigns USING btree(status, start_date, end_date) WHERE status = 'active';
CREATE UNIQUE INDEX IF NOT EXISTS idx_campaigns_code ON campaign.campaigns USING btree(tenant_id, campaign_code);
-- JSONB index for bonus_rule_ids array search
CREATE INDEX IF NOT EXISTS idx_campaigns_bonus_rules ON campaign.campaigns USING gin(bonus_rule_ids);
-- JSONB index for target_segments array search
CREATE INDEX IF NOT EXISTS idx_campaigns_segments ON campaign.campaigns USING gin(target_segments);

