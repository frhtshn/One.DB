-- =============================================
-- Tablo: bonus.bonus_rules
-- Açıklama: JSON-driven bonus kural motoru
--           6 JSONB bileşen ile her bonus tipini
--           tek genel yapıda tanımlar
-- =============================================

DROP TABLE IF EXISTS bonus.bonus_rules CASCADE;

CREATE TABLE bonus.bonus_rules (
    id BIGSERIAL PRIMARY KEY,
    tenant_id BIGINT,                              -- NULL = platform seviyesi, değer = tenant'a ait
    rule_code VARCHAR(100) NOT NULL,
    rule_name VARCHAR(255) NOT NULL,
    bonus_type_id BIGINT NOT NULL,                 -- FK → bonus_types

    -- ═══ JSON Rule Engine Bileşenleri ═══

    -- 1. TRIGGER: Ne zaman tetiklenir?
    -- {"event":"first_deposit","conditions":{"min_amount":100}}
    -- {"event":"period_end","schedule":"0 0 * * 2"}
    -- {"event":"bet_settled","conditions":{"bet_type":"accumulator","min_selections":3}}
    trigger_config JSONB NOT NULL,

    -- 2. DATA: Hangi veri gerekli?
    -- {"source":"deposit_event","fields":["amount","currency","payment_method"]}
    -- {"source":"player_period_stats","period":"weekly","metrics":["net_loss","total_wagered"]}
    data_config JSONB,

    -- 3. ELIGIBILITY: Kim hak eder?
    -- {"conditions":[
    --   {"field":"player.country","op":"in","value":["TR","DE"]},
    --   {"field":"player.account_age_days","op":"lte","value":7},
    --   {"field":"player.kyc_status","op":"eq","value":"approved"}
    -- ]}
    eligibility_criteria JSONB,

    -- 4. REWARD: Ne kadar, nasıl hesaplanır?
    -- {"type":"percentage","source_field":"event.amount","value":100,"max_amount":1000}
    -- {"type":"tiered","source_field":"stats.net_loss","tiers":[...]}
    -- {"type":"scaled","source_field":"event.selection_count","scale":[...]}
    reward_config JSONB NOT NULL,

    -- 5. USAGE: Nasıl kullanılmalı?
    -- {"wagering_multiplier":30,"min_combined_count":5,"min_selection_odds":1.65,
    --  "min_total_odds":13.0,"excluded_bet_types":["virtual","live"],
    --  "max_withdrawal_factor":25,"expires_in_days":30,
    --  "turnover_applies_to":"bonus","game_contributions":{"SLOT":100,"LIVE":10},
    --  "withdrawal_policy":"transfer_earned"}
    usage_criteria JSONB,

    -- 6. TARGET: Bonus alt tipi ve tamamlanma politikası
    -- {"bonus_subtype":"freebet","completion_target":"real"}
    -- bonus_subtype: monetary, freebet, freespin, cashback
    -- completion_target: Hak ediş sonrası transfer hedefi (her zaman "real")
    target_config JSONB,

    -- ═══ Değerlendirme Ayarları ═══
    evaluation_type VARCHAR(20) NOT NULL DEFAULT 'immediate',
    -- immediate: event-driven (deposit gelince hemen)
    -- periodic:  cron ile (haftalık cashback)
    -- manual:    admin tetikler
    -- claim:     oyuncu talep eder (ClaimBonus)

    -- ═══ Atomik Sayaçlar ═══
    max_uses_total INT,                            -- NULL = sınırsız
    max_uses_per_player INT DEFAULT 1,
    current_uses_total INT DEFAULT 0,              -- Atomik kullanım sayacı

    -- ═══ Geçerlilik ═══
    valid_from TIMESTAMPTZ,
    valid_until TIMESTAMPTZ,

    -- ═══ Stacking Kontrolü ═══
    disables_other_bonuses BOOLEAN DEFAULT false,  -- Bu bonus aktifken başka bonus alınamaz
    stacking_group VARCHAR(50),                    -- Aynı grupta max 1 aktif bonus

    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE bonus.bonus_rules IS 'JSON-driven bonus rule engine with 6 JSONB components for trigger, data, eligibility, reward, usage, and target configuration';
