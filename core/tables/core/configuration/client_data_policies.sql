-- =============================================
-- Client Data Retention Policies (Veri Saklama Politikaları)
-- KYC, Lisans ve Log stratejilerine göre verinin ömrünü belirler.
-- Partition Manager Job'ları bu tabloyu referans alır.
-- =============================================

DROP TABLE IF EXISTS core.client_data_policies CASCADE;

CREATE TABLE core.client_data_policies (
    id bigserial PRIMARY KEY,
    client_id bigint NOT NULL,

    -- Veri Kategorisi
    data_category varchar(50) NOT NULL,
    -- Örnekler:
    -- 'SYSTEM_LOGS' (Hata/Debug logları)
    -- 'AUDIT_LOGS' (Güvenlik/Admin logları)
    -- 'PLAYER_TRANSACTIONS' (Finansal hareketler)
    -- 'KYC_DOCUMENTS' (Oyuncu belgeleri/verileri)
    -- 'GAME_HISTORY' (Oyun geçmişi)

    -- Saklama Süresi (Gün cinsinden)
    retention_days int NOT NULL,            -- Örn: 30, 90, 365, 1825 (5 yıl)

    -- Süre Dolunca Yapılacak İşlem
    action_type varchar(20) NOT NULL DEFAULT 'drop_partition',
    -- Seçenekler:
    -- 'DROP_PARTITION' : Veriyi kalıcı olarak sil (Partition drop)
    -- 'DELETE_ROWS'    : Satır bazlı silme (Partition yoksa)
    -- 'ARCHIVE_COLD'   : S3/Blob storage'a taşı ve DB'den sil
    -- 'ANONYMIZE'      : Kişisel verileri maskele (GDPR/Right to be forgotten)

    is_active boolean DEFAULT true,
    description text,                       -- Örn: "MGA lisansı gereği 5 yıl saklanmalı"

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE core.client_data_policies IS 'Defines data retention and cleanup rules per client and data type (KYC, Logs, Audit)';
