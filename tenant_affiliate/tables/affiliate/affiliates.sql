DROP TABLE IF EXISTS affiliate.affiliates CASCADE;

-- Affiliate tanımları (Ticari Varlık)
-- Sistemdeki tüm affiliate hesaplarını tutar
CREATE TABLE affiliate.affiliates (
    id bigserial PRIMARY KEY,
    code varchar(50) UNIQUE NOT NULL,       -- Benzersiz affiliate kodu
    name varchar(150) NOT NULL,             -- Affiliate adı
    status smallint NOT NULL,               -- ACTIVE / SUSPENDED / CLOSED
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
