-- =============================================
-- Tablo: catalog.data_retention_policies
-- Açıklama: Jurisdiction bazlı veri saklama süreleri
-- Partition silme ve GDPR uyumu için kullanılır
-- Backend bu tabloyu okuyarak tenant başına
-- doğru retention süresi ile maintenance çağırır
-- =============================================

DROP TABLE IF EXISTS catalog.data_retention_policies CASCADE;

CREATE TABLE catalog.data_retention_policies (
    id serial PRIMARY KEY,

    jurisdiction_id int NOT NULL,                    -- Hangi otorite için
    data_category varchar(50) NOT NULL,              -- Veri kategorisi
    -- kyc_data: KYC belge ve doğrulama verileri
    -- transaction_logs: Finansal işlem logları
    -- player_data: Oyuncu kişisel verileri
    -- affiliate_logs: Affiliate işlem logları
    -- game_logs: Oyun tur logları
    -- audit_logs: Audit kayıtları

    retention_days int NOT NULL,                     -- Saklama süresi (gün)
    legal_reference varchar(100),                    -- Yasal dayanak (GDPR Art.17, GwG §8 vb.)
    description varchar(255),                        -- Açıklama

    is_active boolean NOT NULL DEFAULT true,         -- Aktif kural mı

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE catalog.data_retention_policies IS 'Jurisdiction-specific data retention periods for partition management and GDPR compliance';
