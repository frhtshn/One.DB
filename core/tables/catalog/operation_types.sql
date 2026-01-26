-- =============================================
-- Tablo: catalog.operation_types
-- Açıklama: Cüzdan operasyon tip kataloğu
-- Cüzdan bakiyesini etkileyen tüm operasyon türleri
-- DEBIT: Bakiyeden düşme, CREDIT: Bakiyeye ekleme
-- HOLD: Kilitli bakiyeye aktarım, RELEASE: Kilitli bakiyeden çıkarım
-- =============================================

DROP TABLE IF EXISTS catalog.operation_types CASCADE;

CREATE TABLE catalog.operation_types (
    code              varchar(30) PRIMARY KEY,            -- Operasyon kodu: DEBIT, CREDIT, HOLD, RELEASE
    wallet_effect     smallint NOT NULL,                   -- Cüzdan etkisi: -1 (düş), +1 (artır), 0 (etkisiz)
    affects_balance   boolean NOT NULL,                    -- Ana bakiyeyi etkiler mi?
    affects_locked    boolean NOT NULL,                    -- Kilitli bakiyeyi etkiler mi?
    description       text,                                -- Operasyon açıklaması
    is_active         boolean NOT NULL DEFAULT true        -- Aktif/pasif durumu
);

COMMENT ON TABLE catalog.operation_types IS 'Wallet operation type catalog defining DEBIT, CREDIT, HOLD, RELEASE operations and their effect on wallet balances';

