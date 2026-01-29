-- =============================================
-- Tablo: catalog.transaction_types
-- Açıklama: İşlem türü kataloğu
-- Tüm finansal işlem türlerinin tanımlandığı referans tablosu
-- Örnek: BET, WIN, DEPOSIT, WITHDRAWAL, BONUS_CREDIT
-- =============================================

DROP TABLE IF EXISTS catalog.transaction_types CASCADE;

CREATE TABLE catalog.transaction_types (
    code            varchar(50) PRIMARY KEY,              -- İşlem kodu (değişmez): BET, WIN, DEPOSIT
    category        varchar(30) NOT NULL,                  -- Kategori: BET, WIN, BONUS, PAYMENT, ADJUSTMENT
    product         varchar(30),                           -- Ürün: SPORTS, CASINO, POKER, PAYMENT
    is_bonus        boolean NOT NULL DEFAULT false,        -- Bonus işlemi mi?
    is_free         boolean NOT NULL DEFAULT false,        -- Bedava (free spin/bet) işlemi mi?
    is_rollback     boolean NOT NULL DEFAULT false,        -- Geri alma (iptal) işlemi mi?
    is_winning      boolean NOT NULL DEFAULT false,        -- Kazanç işlemi mi?
    is_reportable   boolean NOT NULL DEFAULT true,         -- Raporlarda gösterilecek mi?
    description     text,                                  -- İşlem türü açıklaması
    is_active       boolean NOT NULL DEFAULT true,         -- Aktif/pasif durumu
    created_at      timestamptz NOT NULL DEFAULT now()     -- Kayıt oluşturma zamanı
);

COMMENT ON TABLE catalog.transaction_types IS 'Transaction type reference catalog for all financial transaction types such as BET, WIN, DEPOSIT, WITHDRAWAL, BONUS';
