-- =============================================
-- Tablo: presentation.tabs
-- Açıklama: Sayfa içi sekme tanımları
-- Bir sayfadaki tab panelleri buradan yönetilir
-- Örnek: Player Detail > Profile, Wallet, Transactions, Documents
-- =============================================

DROP TABLE IF EXISTS presentation.tabs CASCADE;

CREATE TABLE presentation.tabs (
    id BIGSERIAL PRIMARY KEY,                              -- Benzersiz sekme kimliği
    page_id BIGINT NOT NULL,                               -- Sayfa ID (FK: presentation.pages)
    code VARCHAR(50) NOT NULL,                             -- Sekme kodu: WALLET, PROFILE, TRANSACTIONS
    title_localization_key VARCHAR(150) NOT NULL,          -- Çeviri anahtarı: bo.tab.wallet
    order_index INT NOT NULL,                              -- Sıralama indeksi
    required_permission VARCHAR(100) NOT NULL,             -- Gerekli yetki kodu
    is_active BOOLEAN NOT NULL DEFAULT true,               -- Aktif/pasif durumu
    UNIQUE (page_id, code)                                 -- Sayfa başına benzersiz sekme kodu
);
