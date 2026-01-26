-- =============================================
-- Operation Types (Operasyon Tipleri)
-- Cüzdan üzerindeki işlem yönü tanımları
-- Credit (+), Debit (-), Lock, Unlock vb.
-- =============================================

DROP TABLE IF EXISTS finance.operation_types CASCADE;

CREATE TABLE finance.operation_types (
    id                smallserial PRIMARY KEY,
    code              varchar(30) NOT NULL UNIQUE,  -- Operasyon kodu: CREDIT, DEBIT, LOCK
    wallet_effect     smallint NOT NULL,            -- Cüzdan etkisi: +1=Artır, -1=Azalt, 0=Etkisiz
    affects_balance   boolean NOT NULL,             -- Bakiyeyi etkiler mi?
    affects_locked    boolean NOT NULL              -- Kilitli bakiyeyi etkiler mi?
);
