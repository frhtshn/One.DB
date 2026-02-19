-- =============================================
-- Player Groups (Oyuncu Grupları)
-- Manuel veya otomatik oluşturulan oyuncu grupları
-- Promosyon ve kampanya hedeflemesi için kullanılır
-- =============================================

DROP TABLE IF EXISTS auth.player_groups CASCADE;

CREATE TABLE auth.player_groups (
    id bigserial PRIMARY KEY,
    group_code varchar(50) NOT NULL,              -- Grup kodu: high_rollers, new_members
    group_name varchar(100) NOT NULL,             -- Grup adı: "Yüksek Bahisçiler"
    description varchar(255),                     -- Açıklama
    level int NOT NULL DEFAULT 0,                 -- Hiyerarşi seviyesi (yüksek = daha iyi)
    is_active boolean NOT NULL DEFAULT true,      -- Soft delete desteği
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE auth.player_groups IS 'Player groups for promotional targeting such as high rollers, new members, dormant players';
