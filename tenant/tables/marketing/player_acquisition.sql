DROP TABLE IF EXISTS marketing.player_acquisition CASCADE;

-- Oyuncu kazanım kaynağı
-- Oyuncunun sisteme ilk nasıl geldiğini kaydeder
CREATE TABLE marketing.player_acquisition (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,              -- Oyuncu referansı
    tenant_id bigint NOT NULL,              -- Tenant referansı

    acquisition_type varchar(30) NOT NULL,  -- Kazanım tipi
        -- AFFILIATE / ORGANIC / PAID / ADMIN

    affiliate_id bigint,                    -- Affiliate referansı (varsa)
    campaign_id bigint,                     -- Kampanya referansı (varsa)
    tracking_code varchar(100),             -- Takip kodu
    click_id uuid,                          -- Tıklama ID'si (tracking için)

    acquired_at timestamp without time zone NOT NULL DEFAULT now(),  -- Kazanım zamanı

    created_by varchar(30) NOT NULL DEFAULT 'SYSTEM',  -- Kaydı oluşturan

    UNIQUE (player_id, tenant_id)
);
