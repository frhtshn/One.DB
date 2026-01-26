-- =============================================
-- Tablo: presentation.tabs
-- Açıklama: Sayfa İçi Sekmeler
-- Sayfalarda kullanılan sekmeler (Overview, Wallet, KYC vb.)
-- =============================================

DROP TABLE IF EXISTS presentation.tabs CASCADE;

CREATE TABLE presentation.tabs (
    id BIGSERIAL PRIMARY KEY,                              -- Benzersiz sekme kimliği
    page_id BIGINT NOT NULL,                               -- Sayfa ID
    code VARCHAR(50) NOT NULL,                             -- Sekme kodu
    title_localization_key VARCHAR(150) NOT NULL,          -- Çeviri anahtarı
    order_index INT NOT NULL,                              -- Sıralama indeksi
    required_permission VARCHAR(100) NOT NULL,             -- Gerekli yetki kodu
    is_active BOOLEAN NOT NULL DEFAULT true,               -- Aktif/pasif durumu
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Oluşturulma zamanı
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Güncellenme zamanı

    CONSTRAINT uq_tabs_page_code UNIQUE (page_id, code)
);

COMMENT ON TABLE presentation.tabs IS 'In-page tabs (Overview, Wallet, KYC...)';
