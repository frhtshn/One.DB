-- =============================================
-- Bonus Schema Foreign Key Constraints
-- =============================================

-- bonus_types.tenant_id -> tenants (opsiyonel - NULL = platform seviyesi)
-- Not: Cross-database FK desteklenmez, uygulama seviyesinde kontrol edilmeli

-- bonus_rules.bonus_type_id -> bonus_types
ALTER TABLE bonus.bonus_rules
    ADD CONSTRAINT fk_bonus_rules_bonus_type
    FOREIGN KEY (bonus_type_id) REFERENCES bonus.bonus_types(id);

-- bonus_triggers.bonus_rule_id -> bonus_rules
ALTER TABLE bonus.bonus_triggers
    ADD CONSTRAINT fk_bonus_triggers_bonus_rule
    FOREIGN KEY (bonus_rule_id) REFERENCES bonus.bonus_rules(id);


-- =============================================
-- Promotion Schema Foreign Key Constraints
-- =============================================

-- promo_codes.bonus_rule_id -> bonus_rules
ALTER TABLE promotion.promo_codes
    ADD CONSTRAINT fk_promo_codes_bonus_rule
    FOREIGN KEY (bonus_rule_id) REFERENCES bonus.bonus_rules(id);


-- =============================================
-- Campaign Schema Foreign Key Constraints
-- =============================================

-- campaigns: bonus_rule_ids JSONB array olduğu için FK uygulanamaz
-- Uygulama seviyesinde kontrol edilmeli
