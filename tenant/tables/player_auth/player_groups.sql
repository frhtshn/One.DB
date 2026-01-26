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
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
