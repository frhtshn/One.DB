-- =============================================
-- Promotion Games (Promosyon Oyun Filtreleri)
-- Promosyonun hangi oyunlarda geçerli olduğu
-- Oyun, provider, kategori veya tag bazlı filtreleme
-- =============================================

DROP TABLE IF EXISTS content.promotion_games CASCADE;

CREATE TABLE content.promotion_games (
    id SERIAL PRIMARY KEY,
    promotion_id INTEGER NOT NULL,                -- Bağlı promosyon
    filter_type VARCHAR(20) NOT NULL,             -- Filtre tipi: game, provider, category, tag
    filter_value VARCHAR(100) NOT NULL,           -- Filtre değeri (game_id, provider_code, category_code, tag)
    is_include BOOLEAN NOT NULL DEFAULT TRUE,     -- TRUE: sadece bunlarda geçerli, FALSE: bunlar hariç
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER
);

COMMENT ON TABLE content.promotion_games IS 'Promotion game filters defining eligible games by provider, category, or specific game IDs';

-- Örnek kullanımlar:
-- filter_type='provider', filter_value='pragmatic', is_include=TRUE  → Sadece Pragmatic oyunlarında geçerli
-- filter_type='category', filter_value='slots', is_include=TRUE      → Sadece slot oyunlarında geçerli
-- filter_type='game', filter_value='123', is_include=FALSE           → Bu oyun hariç tümünde geçerli
-- filter_type='tag', filter_value='new', is_include=TRUE             → Sadece 'new' etiketli oyunlarda geçerli
