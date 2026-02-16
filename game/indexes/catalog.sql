-- Catalog Schema Indexes (Game DB)
-- Core DB'den taşınan game indexleri + yeni tablo indexleri

-- =============================================
-- game_providers indexes
-- =============================================

-- provider_code unique lookup (game_provider_sync)
CREATE UNIQUE INDEX IF NOT EXISTS idx_game_providers_code ON catalog.game_providers USING btree(provider_code);

-- is_active filtresi (aktif provider listesi)
CREATE INDEX IF NOT EXISTS idx_game_providers_active ON catalog.game_providers USING btree(is_active) WHERE is_active = true;

-- =============================================
-- games indexes (Core'dan taşındı + ek)
-- =============================================

-- provider_id FK index (JOIN performance)
CREATE INDEX IF NOT EXISTS idx_games_provider_id ON catalog.games USING btree(provider_id);

-- game_type filtresi (lobi sorguları)
CREATE INDEX IF NOT EXISTS idx_games_game_type ON catalog.games USING btree(game_type);

-- is_active filtresi (aktif oyun listesi)
CREATE INDEX IF NOT EXISTS idx_games_is_active ON catalog.games USING btree(is_active);

-- categories GIN (array @> operatörü ile filtreleme)
CREATE INDEX IF NOT EXISTS idx_games_categories ON catalog.games USING GIN(categories);

-- tags GIN (array @> operatörü ile filtreleme)
CREATE INDEX IF NOT EXISTS idx_games_tags ON catalog.games USING GIN(tags);

-- features GIN (array @> operatörü ile filtreleme)
CREATE INDEX IF NOT EXISTS idx_games_features ON catalog.games USING GIN(features);

-- popülerlik sıralaması (lobi varsayılan sıralama)
CREATE INDEX IF NOT EXISTS idx_games_popularity ON catalog.games USING btree(popularity_score DESC) WHERE is_active = true;

-- yayın tarihi (yeni oyunlar filtresi)
CREATE INDEX IF NOT EXISTS idx_games_release_date ON catalog.games USING btree(release_date DESC);

-- RTP filtresi (oyun mekanik filtreleme)
CREATE INDEX IF NOT EXISTS idx_games_rtp ON catalog.games USING btree(rtp) WHERE rtp IS NOT NULL;

-- jackpot oyunları (has_jackpot partial)
CREATE INDEX IF NOT EXISTS idx_games_has_jackpot ON catalog.games USING btree(has_jackpot) WHERE has_jackpot = true;

-- =============================================
-- game_currency_limits indexes
-- =============================================

-- game_id FK index (JOIN performance)
CREATE INDEX IF NOT EXISTS idx_game_currency_limits_game ON catalog.game_currency_limits USING btree(game_id);

-- currency_type filtresi (fiat vs crypto ayırma)
CREATE INDEX IF NOT EXISTS idx_game_currency_limits_currency_type ON catalog.game_currency_limits USING btree(currency_type);

-- aktif limitler (soft delete filtresi)
CREATE INDEX IF NOT EXISTS idx_game_currency_limits_active ON catalog.game_currency_limits USING btree(is_active) WHERE is_active = true;
