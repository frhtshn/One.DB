DROP TABLE IF EXISTS affiliate.network_commission_rules CASCADE;

-- Network komisyon kuralları (Parent gelirleri)
-- Alt affiliate'lerden üst affiliate'lere aktarılacak komisyon oranları
CREATE TABLE affiliate.network_commission_rules (
    id bigserial PRIMARY KEY,
    parent_level smallint NOT NULL,         -- Seviye (1 = doğrudan üst)
    rate numeric(5,2) NOT NULL,             -- Yüzde oranı
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
