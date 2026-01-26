-- =============================================
-- Tablo: affiliate.network_commission_rules
-- Açıklama: Network komisyon kuralları
-- Alt affiliate'lerden üst affiliate'lere aktarılacak oranlar
-- MLM/Sub-affiliate yapısı için kullanılır
-- =============================================

DROP TABLE IF EXISTS affiliate.network_commission_rules CASCADE;

CREATE TABLE affiliate.network_commission_rules (
    id bigserial PRIMARY KEY,                              -- Benzersiz kural kimliği
    parent_level smallint NOT NULL,                        -- Seviye (1 = doğrudan üst, 2 = iki kademe üst)
    rate numeric(5,2) NOT NULL,                            -- Komisyon oranı (yüzde)
    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);
